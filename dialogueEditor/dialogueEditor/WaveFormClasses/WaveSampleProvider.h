//
//  WaveSampleProvider.h
//  CoreAudioTest
//
//  Created by Gyetván András on 6/22/12.
// This software is free.
//

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
#import "WaveSampleProviderDelegate.h"

typedef enum {
	LOADING,
	LOADED,
	ERROR
} WaveSampleStatus;

@interface WaveSampleProvider : NSObject 
{
	ExtAudioFileRef extAFRef;
	Float64 extAFRateRatio;
	int extAFNumChannels;
	BOOL extAFReachedEOF;
	NSString *_path;
	WaveSampleStatus status;
	NSString *statusMessage;
	NSMutableArray *sampleData;
	NSMutableArray *normalizedData;
	int binSize;
	int lengthInSec;
	int minute;
	int sec;
    float duration;
	NSURL *audioURL;
	id<WaveSampleProviderDelegate>delegate;
	NSString *title;
}

@property (readonly, nonatomic) WaveSampleStatus status;
@property (readonly, nonatomic) NSString *statusMessage;
@property (readonly, nonatomic) NSURL *audioURL;
@property (assign, nonatomic) int binSize;
@property (assign, nonatomic) int minute;
@property (assign, nonatomic) int sec;
@property (assign,nonatomic) float duration;
@property (retain) id<WaveSampleProviderDelegate>delegate;
@property (readonly) NSString *title;

- (id) initWithURL:(NSURL *)theURL;
//- (id) initWithPath:(NSString *)thePath;
- (void) createSampleData;
- (float *)dataForResolution:(int)pixelWide lenght:(int *)length;
@end
