//
//  CLAppDelegate.m
//  dialogueEditor
//
//  Created by yiplee on 13-8-19.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import "CLAppDelegate.h"

#import "VideoEditorController.h"
#import "ImageEditorController.h"

@implementation CLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.window.title = @"Welcome";
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (!flag)
    {
        [self.window orderFront:nil];
        [self.window makeKeyWindow];
    }
    return YES;
}

- (IBAction)closeApp:(NSButton *)sender {
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.2];
}

- (IBAction)newImageDialog:(NSButton *)sender {
    self.imageEditorWindow = [[ImageEditorController alloc] initWithWindowNibName:@"ImageEditorController"];
    
    [self.window close];
    [self.imageEditorWindow.window makeKeyAndOrderFront:self];
}

- (IBAction)newVideoDialog:(NSButton *)sender {
    self.videoEditorWindow = [[VideoEditorController alloc] initWithWindowNibName:@"VideoEditorController"];
    
    [self.window close];
//    [self.videoEditorWindow showWindow:self];
    [self.videoEditorWindow.window makeKeyAndOrderFront:self];
    
}

- (IBAction)newFile:(id)sender {
    [self.window orderFront:nil];
    [self.window makeKeyWindow];
}
@end
