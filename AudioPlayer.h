//
//  AudioPlayer.h
//  ap
//
//  Created by yuta on 11/06/29.
//  Copyright 2011 carocara. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AVFoundation/AVFoundation.h>

@protocol AudioPlayerDelegate
-(void) audioSequence:(double)currentTime;
-(void) audioFadein:(double)volume;
-(void) audioFadeout:(double)volume;
@optional
@end
@interface AudioPlayer : NSObject 
<AVAudioPlayerDelegate>
{
    NSTimer * timer;
    NSTimer * timerFade;
    AVAudioPlayer * audio;
    float power, currentVolume;
    double duration;
    BOOL fading, pausing;
    id<AudioPlayerDelegate> delegate;
}

@property (nonatomic, assign) id<AudioPlayerDelegate> delegate;
@property (nonatomic, retain) AVAudioPlayer * audio;
@property double duration;
@property float power;
@property float currentVolume;

-(id) initWithFilename:(NSString *)filename ofType:(NSString *)ofType delegate:(id)targetDelegate;
-(void)audioStart:(BOOL)fade currentTime:(double)currentTime volume:(float)volume;
-(void)audioStop:(BOOL)fade;
-(void)audioPause;
-(void)audioPlayThreaded:(id)threadAudio;
-(void)setVolume:(double)volume;
@end
