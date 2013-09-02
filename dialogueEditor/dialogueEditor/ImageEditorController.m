//
//  ImageEditorController.m
//  dialogueEditor
//
//  Created by yiplee on 13-8-23.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import "ImageEditorController.h"
#import "dialog.h"

#import "NSImage+PixelSize.h"

typedef enum {
	RGBA8888 = 0,
    RGBA4444 = 1,
    RGB565   = 2,
}Texture2DPixelFormat;

static NSImage *ATThumbnailImageFromImage(NSImage *image,NSSize size)
{
    NSSize imageSize = [image size];
    CGFloat imageAspectRatio = imageSize.width / imageSize.height;
    // Create a thumbnail image from this image (this part of the slow operation)
    NSSize thumbnailSize = NSMakeSize(size.height * imageAspectRatio, size.height);
    NSImage *thumbnailImage = [[NSImage alloc] initWithSize:thumbnailSize];
    [thumbnailImage lockFocus];
    [image drawInRect:NSMakeRect(0, 0, thumbnailSize.width, thumbnailSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    [thumbnailImage unlockFocus];
    
    return thumbnailImage;
}

static NSImage *imageWithNewSize(NSImage *image,NSSize size)
{
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImage* targetImage = nil;
    NSImageRep *sourceImageRep =
    [image bestRepresentationForRect:targetFrame
                                   context:nil
                                     hints:nil];
    
    targetImage = [[NSImage alloc] initWithSize:size];
    
    [targetImage lockFocus];
    [sourceImageRep drawInRect: targetFrame];
    [targetImage unlockFocus];
    
    return targetImage;
}

static void saveNSImageAsPNGToPath(NSImage *image,NSString *path)
{
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
    [imageData writeToFile:path atomically:NO];
}

@implementation ImageScene

- (id) init
{
    if (self = [super init])
    {
        _startTime = 0;
        _endTime = 0;
    }
    return self;
}

- (BOOL) isValid
{
    return (_endTime >= _startTime) && _imagePath ;//&& _content ;
}

- (NSString *) imageName
{
    if (_imagePath)
        return [_imagePath lastPathComponent];
    else return @"NULL";
}

- (NSDictionary *) sceneInfo
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info addEntriesFromDictionary:@{@"image": [self imageName],
                                     @"time":NSStringFromPoint((CGPoint){_startTime,_endTime}),}];
    if (self.content)
    {
        [info setValue:self.content forKey:@"content"];
    }
    
    if (self.timeLine.length > 0)
    {
        [info setValue:[NSNumber numberWithBool:YES] forKey:@"synchronize"];
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" ,-{}<>|/"];
        NSArray *times = [self.timeLine componentsSeparatedByCharactersInSet:set];
        NSUInteger count = [times count] / 2;
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        for (int i=0;i < count;i++)
        {
            NSString *start = [times objectAtIndex:2*i];
            NSString *end   = [times objectAtIndex:2*i+1];
            NSString *period = [NSString stringWithFormat:@"{%@,%@}",start,end];
            [array addObject:period];
        }
        [info setValue:array forKey:@"wordPeriods"];
    }
    
    return info;
}

- (NSString *) description
{
    return [[self sceneInfo] description];
}

@end

@interface ImageEditorController ()

@end

@implementation ImageEditorController

@synthesize _allow_fit_screen = _allow_fit_screen;
@synthesize _allow_pvr_ccz = _allow_pvr_ccz;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        _selectedIndexOfScene = -1;
        
        _thumbnailImageCache = [[NSMutableDictionary alloc] init];
        
        NSString *publicThumbnailPath = [[NSBundle mainBundle] pathForResource:@"Sprite" ofType:@"icns"];
        _publicThumbnail = [[NSImage alloc] initWithContentsOfFile:publicThumbnailPath];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
//    [self.loadAudioButton setEnabled:YES];
//    [self.pickTimeButton setEnabled:YES];
//    [self.publishSettingButton setEnabled:YES];
//    [self.publishButton setEnabled:YES];
    self.window.title = @"image";
    [self.indicator setDoubleValue:100];
    
    _allow_pvr_ccz.state = NSOnState;
    _allow_fit_screen.state = NSOnState;
    
    [self.pixelFormat selectItemAtIndex:RGB565];

    self.sceneTable.delegate = self;
    self.sceneTable.dataSource = self;
    [self.sceneTable setAllowsMultipleSelection:NO];
    
    self.scenes = [[NSMutableArray alloc] init];
    ImageScene *firstScene = [[ImageScene alloc] init];
    [self.scenes addObject:firstScene];
    [self.sceneTable reloadData];
    
    NSIndexSet *index = [NSIndexSet indexSetWithIndex:0];
    [self.sceneTable selectRowIndexes:index byExtendingSelection:YES];
    
    self.startTimeLabel.delegate = self;
    self.endTimeLabel.delegate = self;
    self.dialogContent.delegate = self;
    self.timeLineLabel.delegate = self;

    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setCanCreateDirectories:YES];
    savePanel.title = @"image";
    
    [savePanel setMessage:@"输入对话名称"];
    [savePanel setNameFieldStringValue:@"dialoge_name"];
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL *url = savePanel.URL;
            _dialogTitle = [savePanel.nameFieldStringValue copy];
            _workPath = [url path];
            self.window.title = _dialogTitle;
        }
        else if (result == NSFileHandlingPanelCancelButton)
        {
            [self close];
        }
    }];

}

- (IBAction)loadAudio:(id)sender {
    NSArray *fileTypes = [NSArray arrayWithObjects: @"AIFF", @"aif", @"aiff", @"aifc", @"wav", @"WAV",@"mp3", nil];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	if (_audioFilePath)
    {
        NSURL *_url = [NSURL fileURLWithPath:_audioFilePath isDirectory:YES];
        [oPanel setDirectoryURL:_url];
    }
    
    [oPanel setAllowsMultipleSelection:NO];
	[oPanel setAllowedFileTypes:fileTypes];
    [oPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if(result == NSFileHandlingPanelOKButton) {
			if(oPanel.URLs.count == 1) {
				NSURL *url = nil;
				url = [oPanel.URLs objectAtIndex:0];
				[self.wfx openAudioURL:url];
                _audioFilePath = [url path];
			}
		};
	}];
}

- (IBAction)pickStartTime:(NSToolbarItem *)sender {
    NSString *time = [NSString stringWithFormat:@"%.2f",CMTimeGetSeconds(self.wfx.player.currentTime)];
    
    [_startTimeLabel setStringValue:time];
    
    if (_selectedIndexOfScene < 0 || _selectedIndexOfScene >= [self.scenes count])
        return;
    
    ImageScene *scene = [self.scenes objectAtIndex:_selectedIndexOfScene];
    scene.startTime = [_startTimeLabel floatValue];
}

- (IBAction)pickEndTime:(NSToolbarItem *)sender {
    NSString *time = [NSString stringWithFormat:@"%.2f",CMTimeGetSeconds(self.wfx.player.currentTime)];
    
    [_endTimeLabel setStringValue:time];
    
    if (_selectedIndexOfScene < 0 || _selectedIndexOfScene >= [self.scenes count])
        return;
    
    ImageScene *scene = [self.scenes objectAtIndex:_selectedIndexOfScene];
    scene.endTime = [_endTimeLabel floatValue];
}

- (IBAction)pickTimeLine:(NSToolbarItem *)sender {
    NSString *time = [NSString stringWithFormat:@"%.2f",CMTimeGetSeconds(self.wfx.player.currentTime)];
    
    NSString *timeLine = [_timeLineLabel stringValue];
    [_timeLineLabel setStringValue:[timeLine stringByAppendingPathComponent:time]];
    
    if (_selectedIndexOfScene < 0 || _selectedIndexOfScene >= [self.scenes count])
        return;
    
    ImageScene *scene = [self.scenes objectAtIndex:_selectedIndexOfScene];
    scene.timeLine = [_timeLineLabel stringValue];
}

- (IBAction)publishSetting:(id)sender {
    [NSApp beginSheet:self.optionPanel
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

- (IBAction)publish:(id)sender {
    
    for (ImageScene *scene in self.scenes)
    {
        if (![scene isValid])
        {
            NSAlert *alart;
            alart = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"存在无效的 scene"];
            [alart runModal];
            return;
        }
    }
    
    if (!_audioFilePath)
    {
        NSAlert *alart;
        alart = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"找不到音频文件"];
        [alart runModal];
        return;
    }
    
    // indicator
    [self.indicator startAnimation:self];
    [self.indicator setHidden:NO];
    NSLog(@"work path:%@",_workPath);
    
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_workPath isDirectory:&isDir] && isDir)
    {
        [[NSFileManager defaultManager] removeItemAtPath:_workPath error:nil];
    }
    
    NSDictionary *attri;
    attri = @{@"directoryName": _dialogTitle};
    NSURL *url = [NSURL fileURLWithPath:_workPath isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:url
                                     withIntermediateDirectories:YES
                                                      attributes:attri
                                                           error:nil];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setValue:[NSNumber numberWithInt:DIALOG_TYPE_IMAGE] forKey:@"type"];
    [info setValue:_dialogTitle forKey:@"title"];
    [info setValue:[_audioFilePath lastPathComponent] forKey:@"audioFile"];
    NSLog(@"copy %@ to %@",_audioFilePath,_workPath);
    NSString *audioCopyPath = [_workPath stringByAppendingPathComponent:[_audioFilePath lastPathComponent]];
    [[NSFileManager defaultManager] copyItemAtPath:_audioFilePath toPath:audioCopyPath error:nil];
    NSString *imagePixelFormat = nil;
    NSInteger formatIndex = self.pixelFormat.selectedTag;
    imagePixelFormat =  formatIndex == RGBA8888 ? @"RGBA8888":
                        formatIndex == RGBA4444 ? @"RGBA4444" : @"RGB565";
    [info setValue:imagePixelFormat forKey:@"pixelFormat"];
    BOOL fitScreen = _allow_fit_screen.state == NSOnState?YES:NO;
    [info setValue:[NSNumber numberWithBool:fitScreen] forKey:@"fitScreen"];
    
    NSTask *task = [[NSTask alloc] init];
    
    NSString *TPPath;
    TPPath = @"/Applications/TexturePacker.app/Contents/MacOS/TexturePacker";
    [task setLaunchPath:@"/bin/ls"];
    [task setArguments:@[TPPath]];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardInput:[NSPipe pipe]];
    [task launch];
    [task waitUntilExit];
    
    NSLog(@"exit status:%d",task.terminationStatus);
    BOOL isTPExit = task.terminationStatus == 0;
    [task terminate];
    if (_allow_pvr_ccz.state == NSOnState && !isTPExit)
    {
        NSAlert *alart;
        alart = [NSAlert alertWithMessageText:@"Warning"
                                defaultButton:@"OK"
                              alternateButton:nil
                                  otherButton:nil
                    informativeTextWithFormat:@"TexturePacker not found,将不转换图片格式"];
        [alart runModal];
    }

    NSMutableArray *sceneInfo = [NSMutableArray array];
    NSString *_temp= nil;
    
    NSMutableSet *_processedImages = [NSMutableSet set];
    for (ImageScene *scene in self.scenes)
    {
        _temp = scene.imagePath; // for backup
        
        if ([_processedImages containsObject:scene.imagePath])
        {
            continue;
        }
        else [_processedImages addObject:scene.imagePath];
        
        NSLog(@"image count:%ld",(unsigned long)[_processedImages count]);
        if (_allow_pvr_ccz.state == NSOnState && isTPExit)
        {
            NSString *_newImageName;
            _newImageName = [[scene.imageName stringByDeletingPathExtension] stringByAppendingPathExtension:@"pvr.ccz"];
            NSString *_tempName;
            _tempName = [[[scene.imageName stringByDeletingPathExtension] stringByAppendingString:@"-ipadhd"] stringByAppendingPathExtension:@"pvr.ccz"];
            
            NSString *_newImagePath;
            _newImagePath = [_workPath stringByAppendingPathComponent:_newImageName];
            NSString *_tempPath;
            _tempPath = [_workPath stringByAppendingPathComponent:_tempName];
            
//            [task setLaunchPath:TPPath];
            NSArray *arg = @[scene.imagePath,
                             @"--sheet",_tempPath,
                             @"--data",@"tempFile-ipadhd.plist",
                             @"--format",@"cocos2d",
                             @"--opt",imagePixelFormat,
                             @"--border-padding",@"0",
                             @"--auto-sd",
                             @"--premultiply-alpha",
                             @"--no-trim",
                             @"--allow-free-size",
                             @"--dither-fs-alpha",
                             @"--algorithm",@"MaxRects",
                             @"--disable-rotation"];
//            [task setArguments:arg];
//            [task launch];
//            [task waitUntilExit];
//            NSLog(@"%@",[arg description]);
//            [NSTask launchedTaskWithLaunchPath:TPPath arguments:arg];
            NSTask *_task= [[NSTask alloc] init];
            [_task setLaunchPath:TPPath];
            [_task setArguments:arg];
            [_task setStandardInput:[NSPipe pipe]];
            [_task launch];
            [_task waitUntilExit];
            scene.imagePath = _newImagePath;
            
//            [task terminate];
        }
        else
        {
            NSImage *_originImage;
            _originImage = [[NSImage alloc] initWithContentsOfFile:scene.imagePath];
      
            NSString *imageName = [scene.imageName stringByDeletingPathExtension];
            NSString *_newiPadHDImageName,*_newiPadImageName;
            _newiPadHDImageName = [imageName stringByAppendingString:@"-ipadhd.png"];
            _newiPadImageName = [imageName stringByAppendingString:@"-ipad.png"];
            
            saveNSImageAsPNGToPath(_originImage, [_workPath stringByAppendingPathComponent:_newiPadHDImageName]);
            
            NSImage *_newIpadImage;
            
            NSSize _newSize;
            _newSize.width = _originImage.pixelsWide * 0.5;
            _newSize.height = _originImage.pixelsHigh * 0.5;
            NSLog(@"new size:%@",NSStringFromSize(_newSize));
            _newIpadImage = imageWithNewSize(_originImage, _newSize);
            NSLog(@"new image size:%@",NSStringFromSize(_newIpadImage.size));
            NSLog(@"new image pixel size:%@",NSStringFromSize(_newIpadImage.pixelSize));
            
            if (CGSizeEqualToSize(_newIpadImage.pixelSize,_originImage.pixelSize))
            {
                _newSize.width /= 2;
                _newSize.height /= 2;
                _newIpadImage = imageWithNewSize(_originImage, _newSize);
            }
            
            saveNSImageAsPNGToPath(_newIpadImage, [_workPath stringByAppendingPathComponent:_newiPadImageName]);
            
            if (![scene.imageName hasSuffix:@".png"])
            {
                scene.imagePath = [[scene.imagePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
            }
        }
        [sceneInfo addObject:scene.sceneInfo];
        scene.imagePath = _temp;
    }
    [info setValue:sceneInfo forKey:@"scenes"];
    NSString *infoPath;
    infoPath = [_workPath stringByAppendingPathComponent:[NSString stringWithCString:dialogInfoFile encoding:NSUTF8StringEncoding]];
    [info writeToFile:infoPath atomically:YES];
    // stop indicator
    [self.indicator stopAnimation:self];
    [self.indicator setHidden:YES];
}

- (IBAction)loadImage:(id)sender {
    ImageScene *scene = [self.scenes objectAtIndex:_selectedIndexOfScene];
    
    NSArray *fileTypes = [NSImage imageFileTypes];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    
    if (scene.imagePath)
    {
        NSURL *_url = [NSURL fileURLWithPath:[scene.imagePath stringByDeletingLastPathComponent] isDirectory:YES];
        [oPanel setDirectoryURL:_url];
    }
    
    [oPanel setAllowsMultipleSelection:NO];
	[oPanel setAllowedFileTypes:fileTypes];
    [oPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if(result == NSFileHandlingPanelOKButton) {
			if(oPanel.URLs.count == 1) {
				NSURL *url = nil;
				url = [oPanel.URLs objectAtIndex:0];
				NSString *imagePath = [url path];
                if (![imagePath isEqualToString:scene.imagePath])
                {
                    scene.imagePath = imagePath;
                    NSImage *thumbnail = [_thumbnailImageCache objectForKey:scene.imagePath];
                    if (!thumbnail)
                    {
                        NSImage *image = [[NSImage alloc] initWithContentsOfFile:scene.imagePath];
                        thumbnail = ATThumbnailImageFromImage(image, self.thumbImage.frame.size);
                        [_thumbnailImageCache setValue:thumbnail forKey:scene.imagePath];
                    }
                    [self.thumbImage setImage:thumbnail];
                }
			}
		};
	}];
    NSIndexSet *index = [NSIndexSet indexSetWithIndex:_selectedIndexOfScene];
    [self.sceneTable reloadDataForRowIndexes:index columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (IBAction)playAudio:(id)sender {
    NSString *errorInfo = nil;
    ImageScene *scene = [self.scenes objectAtIndex:_selectedIndexOfScene];
    do {
        if (!_audioFilePath)
        {
            errorInfo = @"请先载入音频";
            break;
        }
        if (scene.endTime <= scene.startTime)
        {
            errorInfo = @"结束时间得比开始时间大";
            break;
        }
        if (scene.startTime < 0 || scene.endTime > self.wfx.wsp.duration)
        {
            errorInfo = @"请检查开始和结束时间";
        }
    } while (0);
    
    if (errorInfo)
    {
        NSAlert *alart;
        alart = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",errorInfo];
        [alart runModal];
    }
    else
    {
        [self.wfx.player pause];
        CMTime tm = CMTimeMakeWithSeconds(scene.startTime, NSEC_PER_SEC);
        [self.wfx.player seekToTime:tm];
        [self.wfx.player play];
    }
}
- (IBAction)addScene:(id)sender {
    ImageScene *newScene;
    newScene = [[ImageScene alloc] init];
    [self.scenes insertObject:newScene atIndex:_selectedIndexOfScene+1];
    [self.sceneTable reloadData];
}

- (IBAction)removeScene:(id)sender {
    if ([self.sceneTable numberOfRows] <= 1)
        return;
    
    NSIndexSet *index = [NSIndexSet indexSetWithIndex:_selectedIndexOfScene];
    [self.sceneTable beginUpdates];
    [self.sceneTable removeRowsAtIndexes:index withAnimation:NSTableViewAnimationSlideLeft];
    [self.scenes removeObjectAtIndex:_selectedIndexOfScene];
    [self.sceneTable endUpdates];
    
    if (_selectedIndexOfScene == [self.sceneTable numberOfRows])
    {
        NSIndexSet *index = [NSIndexSet indexSetWithIndex:_selectedIndexOfScene-1];
        [self.sceneTable selectRowIndexes:index byExtendingSelection:YES];
    }
}

#pragma mark --NSTableViewDelegate

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if (self.sceneTable.selectedRow < 0)
    {
        NSIndexSet *index = [NSIndexSet indexSetWithIndex:_selectedIndexOfScene];
        [self.sceneTable selectRowIndexes:index byExtendingSelection:YES];
        
        return;
    }
    _selectedIndexOfScene = self.sceneTable.selectedRow;
    NSLog(@"select %ld",(long)_selectedIndexOfScene);
    
    ImageScene *scene = [self.scenes objectAtIndex:_selectedIndexOfScene];
    
    [self.startTimeLabel setStringValue:[NSString stringWithFormat:@"%f",scene.startTime]];
    [self.endTimeLabel setStringValue:[NSString stringWithFormat:@"%f",scene.endTime]];
    
    [self.dialogContent setStringValue:scene.content?scene.content:@""];
    
    [self.timeLineLabel setStringValue:scene.timeLine?scene.timeLine:@""];
    // thumbnail image
    if (scene.imagePath)
    {
        NSImage *thumbnail = [_thumbnailImageCache objectForKey:scene.imagePath];
        if (!thumbnail)
        {
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:scene.imagePath];
            thumbnail = ATThumbnailImageFromImage(image, self.thumbImage.frame.size);
            [_thumbnailImageCache setValue:thumbnail forKey:scene.imagePath];
        }
        [self.thumbImage setImage:thumbnail];
    }
    else
    {
        [self.thumbImage setImage:_publicThumbnail];
    }
}

#pragma mark --NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.scenes count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    ImageScene *scene = [self.scenes objectAtIndex:row];
    return [NSString stringWithFormat:@"%li %@",row+1,[scene imageName]];
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    ImageScene *scene = [self.scenes objectAtIndex:row];
    
    NSTextFieldCell *_cell = (NSTextFieldCell*)cell;
    _cell.textColor = [scene isValid] ? [NSColor blackColor] : [NSColor redColor];
}

#pragma mark --NSTextFieldDelegate

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    if (_selectedIndexOfScene < 0 || _selectedIndexOfScene >= [self.scenes count])
        return;
    
    ImageScene *scene = [self.scenes objectAtIndex:_selectedIndexOfScene];
    NSTextField *textField = [obj object];
    
    if (textField == self.startTimeLabel)
    {
        scene.startTime = [textField floatValue];
    }
    else if (textField == self.endTimeLabel)
    {
        scene.endTime = [textField floatValue];
    }
    else if (textField == self.dialogContent)
    {
        scene.content = [textField stringValue];
    }
    else if (textField == self.timeLineLabel)
    {
        scene.timeLine = [textField stringValue];
    }
    
    NSIndexSet *index = [NSIndexSet indexSetWithIndex:_selectedIndexOfScene];
    [self.sceneTable reloadDataForRowIndexes:index columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (IBAction)applyPublishSetting:(id)sender {
    [NSApp endSheet:self.optionPanel];
    [self.optionPanel orderOut:sender];
}
@end
