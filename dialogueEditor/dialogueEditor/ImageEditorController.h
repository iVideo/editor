//
//  ImageEditorController.h
//  dialogueEditor
//
//  Created by yiplee on 13-8-23.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WaveFormClasses/WaveFormViewOSX.h"
#import "LBProgressBar.h"

@interface ImageScene : NSObject

@property (nonatomic,copy) NSString *imagePath;
@property (nonatomic,copy) NSString *content;

@property (nonatomic,assign) CGFloat startTime;
@property (nonatomic,assign) CGFloat endTime;

- (BOOL) isValid;

- (NSString *) imageName;

- (NSDictionary *) sceneInfo;

@end

@interface ImageEditorController : NSWindowController <NSTableViewDelegate,NSTableViewDataSource,NSTextFieldDelegate>
{
    NSString *_dialogTitle;
    
    NSString *_audioFilePath;
    NSString *_workPath;
    
    NSInteger _selectedIndexOfScene;
    
    __strong NSMutableDictionary *_thumbnailImageCache;
    __strong NSImage             *_publicThumbnail;
    
    __weak NSButton *_allow_pvr_ccz;
    
    __weak NSButton *_allow_fit_screen;
}

@property (atomic,retain) NSMutableArray *scenes;
@property (weak) IBOutlet NSToolbarItem *loadAudioButton;
@property (weak) IBOutlet NSToolbarItem *pickTimeButton;
@property (weak) IBOutlet NSToolbarItem *publishSettingButton;
@property (weak) IBOutlet NSToolbarItem *publishButton;

@property (weak) IBOutlet WaveFormViewOSX *wfx;

- (IBAction)loadAudio:(id)sender;

- (IBAction)pickTime:(id)sender;

- (IBAction)publishSetting:(id)sender;

- (IBAction)publish:(id)sender;

@property (weak) IBOutlet NSImageView *thumbImage;

@property (weak) IBOutlet NSTextField *dialogContent;

- (IBAction)loadImage:(id)sender;
- (IBAction)playAudio:(id)sender;

@property (weak) IBOutlet NSTextField *startTimeLabel;

@property (weak) IBOutlet NSTextField *endTimeLabel;

@property (weak) IBOutlet NSTableView *sceneTable;

- (IBAction)addScene:(id)sender;

- (IBAction)removeScene:(id)sender;

@property (weak) IBOutlet LBProgressBar *indicator;

@property (strong) IBOutlet NSPanel *optionPanel;

- (IBAction)applyPublishSetting:(id)sender;

@property (weak) IBOutlet NSButton *_allow_pvr_ccz;
@property (weak) IBOutlet NSButton *_allow_fit_screen;
@property (weak) IBOutlet NSPopUpButton *pixelFormat;
@end
