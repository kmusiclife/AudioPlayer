//
//  AudioPlayer.m
//  ap
//
//  Created by yuta on 11/06/29.
//  Copyright 2011 carocara. All rights reserved.
//

#import "AudioPlayer.h"

@implementation AudioPlayer
@synthesize delegate, duration, power, currentVolume, audio;

#define FEDE_SEED 0.01f
#define VOLUME_SEED 0.005f
#define SEQUENCE_INTERVAL 0.5f
#define AVEPW4CH 0

-(id) initWithFilename:(NSString *)filename ofType:(NSString *)ofType delegate:(id)targetDelegate{
    NSString * path = [[NSBundle mainBundle] pathForResource:filename ofType:ofType];
    NSURL * url = [NSURL fileURLWithPath:path];
    audio = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [audio setMeteringEnabled:YES];
    audio.delegate = targetDelegate;
    self.delegate = targetDelegate;
    duration = audio.duration;
    fading = NO;
    currentVolume = 0.5f;
    return self;
}
- (void)audioSequence{
    if(audio == nil) return;
    if(audio.playing){
        [audio updateMeters];
        power = [audio averagePowerForChannel:AVEPW4CH]; // averagePowerForChannel OR peakPowerForChannel
        [self.delegate audioSequence:audio.currentTime];
	}
}
-(void)audioStart:(BOOL)fade currentTime:(double)currentTime volume:(float)volume{
    if(audio.playing) return;
    currentVolume = volume;
    if(fade){
        if(fading == NO){
            [audio setVolume:0.0f];
            timerFade = [NSTimer scheduledTimerWithTimeInterval:FEDE_SEED target:self selector:@selector(audioFadein) userInfo:nil repeats:YES];        
        }
    }
    audio.currentTime = currentTime;
    [NSThread detachNewThreadSelector:@selector(audioPlayThreaded:) toTarget:self withObject:audio];
    timer = [NSTimer scheduledTimerWithTimeInterval:SEQUENCE_INTERVAL target:self selector:@selector(audioSequence) userInfo:nil repeats:YES];
}
-(void)audioStop:(BOOL)fade{
    if(audio == nil) return;
    
    if(fade){
        if(fading == NO) timerFade = [NSTimer scheduledTimerWithTimeInterval:FEDE_SEED target:self selector:@selector(audioFadeout) userInfo:nil repeats:YES];
    } else {
        if(audio.playing){
            [audio prepareToPlay];
            [audio stop];
            [audio setCurrentTime:0.0f];
        }
    }
    
}
-(void)audioPause{
    if(audio == nil) return;
    if(audio.playing){
        [audio pause];
    }    
}
-(void)audioFadein{
    
    if(audio.playing){
        if((audio.volume+VOLUME_SEED) < currentVolume){
            fading = YES;
            [self.delegate audioFadein:audio.volume];
            [audio setVolume:audio.volume+VOLUME_SEED];
        } else {
            fading = NO;
            if([timerFade isValid]) [timerFade invalidate];
        }
    }
    
}
-(void)audioFadeout{
    
    if(audio.volume <= 0.0f){
        fading = NO;
        if([timerFade isValid]) [timerFade invalidate];
        [self audioStop:NO];
    } else {
        fading = YES;
        [self.delegate audioFadeout:audio.volume];
        [audio setVolume:audio.volume-VOLUME_SEED];
    }
    
}
-(void)audioPlayThreaded:(id)threadAudio{
    if(threadAudio == nil) return;
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [(AVAudioPlayer *)threadAudio prepareToPlay];
    [(AVAudioPlayer *)threadAudio play];
    [pool release];
}
-(void)setVolume:(double)volume{
    [audio setVolume:volume];
}
@end
