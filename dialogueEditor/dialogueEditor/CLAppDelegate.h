//
//  CLAppDelegate.h
//  dialogueEditor
//
//  Created by yiplee on 13-8-19.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VideoEditorController,ImageEditorController;

@interface CLAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic,strong) VideoEditorController *videoEditorWindow;
@property (nonatomic,strong) ImageEditorController *imageEditorWindow;

- (IBAction)closeApp:(NSButton *)sender;

- (IBAction)newImageDialog:(NSButton *)sender;

- (IBAction)newVideoDialog:(NSButton *)sender;
- (IBAction)newFile:(id)sender;
@end
