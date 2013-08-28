//
//  VideoEditorController.m
//  dialogueEditor
//
//  Created by yiplee on 13-8-19.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import "VideoEditorController.h"
#import "dialog.h"

@interface VideoEditorController ()

@end

@implementation VideoEditorController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self)
    {
        dialogueName    = nil;
        saveURL         = nil;
        videoURL        = nil;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.window.title = @"Video";

    [self.loadVideoButton setEnabled:YES];
    [self.publishButton setEnabled:NO];
    
    [self.progressBar setDoubleValue:100];
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setCanCreateDirectories:YES];
    savePanel.title = @"Video";
    
    [savePanel setMessage:@"输入对话名称"];

    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL *url = savePanel.URL;
            dialogueName = [savePanel.nameFieldStringValue copy];
            NSDictionary *attri;
            attri = @{@"directoryName": dialogueName};
            [[NSFileManager defaultManager] createDirectoryAtURL:url
                                     withIntermediateDirectories:YES
                                                      attributes:attri
                                                           error:nil];
            saveURL = [NSURL URLWithString:dialogueName relativeToURL:url];
            self.window.title = dialogueName;
        }
        else if (result == NSFileHandlingPanelCancelButton)
        {
            [self close];
        }
    }];
}

- (IBAction)publish:(NSToolbarItem *)sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:videoURL.path isDirectory:NO])
    {
        // show progress
        [self.progressBar startAnimation:self];
        [self.progressBar setHidden:NO];
        
        NSString *name = [NSString stringWithFormat:@"%s.%@",videoFilePrefix,[videoURL pathExtension]];
        NSString *dstPath = [[saveURL path] stringByAppendingPathComponent:name];
        [fileManager copyItemAtPath:[videoURL path] toPath:dstPath error:nil];
        
        NSMutableDictionary *root = [NSMutableDictionary dictionary];
        [root setValue:dialogueName forKey:@"title"];
        [root setValue:[NSNumber numberWithInt:DIALOG_TYPE_VIDEO] forKey:@"type"];
        [root setValue:name forKey:@"video"];
        
        NSString *infoPath;
        infoPath = [[saveURL path] stringByAppendingPathComponent:[NSString stringWithCString:dialogInfoFile encoding:NSUTF8StringEncoding]];
        [root writeToFile:infoPath atomically:YES];
        
        [self performSelector:@selector(stopProgress) withObject:nil afterDelay:1];
    }
    else
    {
        NSAlert *alart;
        alart = [NSAlert alertWithMessageText:@"Error : file not found" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"请重新导入视频"];
        [alart runModal];
    }
}

- (IBAction)loadVideo:(NSToolbarItem *)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanSelectHiddenExtension:NO];
    [openPanel setAllowsMultipleSelection:NO];
    
    [openPanel setAllowedFileTypes:@[@"mp4",@"m4v"]];
//    [openPanel setDirectoryURL:saveURL];
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton)
        {
            videoURL = [[openPanel URLs] objectAtIndex:0];
            self.videoName.title = [[[videoURL pathComponents] lastObject] copy];
            self.videoName.textColor = [NSColor blackColor];
            self.window.title = [dialogueName stringByAppendingPathComponent:self.videoName.title];
            [self.publishButton setEnabled:YES];
        }
    }];
}

- (void) stopProgress
{
    [self.progressBar stopAnimation:nil];
    [self.progressBar setHidden:YES];
}

@end
