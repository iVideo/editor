//
//  NSImage+PixelSize.h
//  dialogueEditor
//
//  Created by yiplee on 13-8-26.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (PixelSize)

- (NSInteger) pixelsWide;
- (NSInteger) pixelsHigh;
- (NSSize) pixelSize;

@end
