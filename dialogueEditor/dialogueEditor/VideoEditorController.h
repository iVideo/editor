//
//  VideoEditorController.h
//  dialogueEditor
//
//  Created by yiplee on 13-8-19.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LBProgressBar.h"

@interface VideoEditorController : NSWindowController <NSOpenSavePanelDelegate>
{
    NSString    *dialogueName;
    NSURL       *saveURL;
    NSURL       *videoURL;
}

@property (weak) IBOutlet NSToolbarItem *loadVideoButton;

- (IBAction)loadVideo:(NSToolbarItem *)sender;

@property (weak) IBOutlet NSToolbarItem *publishButton;
- (IBAction)publish:(NSToolbarItem *)sender;

@property (weak) IBOutlet NSTextFieldCell *videoName;
@property (weak) IBOutlet LBProgressBar *progressBar;

@end
