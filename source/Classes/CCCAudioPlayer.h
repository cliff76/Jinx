//
//  CCCAudioPlayer.h
//  SpeexCodec
//
//  Created by cliftoncraig07 on 2/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCCAudioSource.h"

#define NUM_BUFFERS 3

typedef struct
  {
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef  queue;
    AudioQueueBufferRef buffers[NUM_BUFFERS];
    UInt32 bufferSize;
    UInt32 numberOfPacketsToRead;
    //Array of individual descriptors for each packet w/ VBR audio
    AudioStreamPacketDescription *packetDescriptors;
    SInt64 currentPacket;
    bool  isPlaying;
    bool isInitialized;
  } PlaybackState;

@protocol CCCAudioOutputProvider <NSObject>

-(void) whenAudioQueueIsDepleted:(AudioQueueRef) outAQ forBuffer:(AudioQueueBufferRef) inBuffer;

@end

@protocol CCCAudioStartStopDelegate <NSObject>

-(void) playbackStateDidChange;

@end

@class CCCAudioPlayer;
@protocol CCCAudioPlaybackDelegate <NSObject>

-(void) playbackStateDidChangeForPlayer:(CCCAudioPlayer*)audioPlayer;
-(void) playbackIsStoppingForPlayer:(CCCAudioPlayer*)audioPlayer;
-(void) playbackIsStartingForPlayer:(CCCAudioPlayer*)audioPlayer;
-(void) playbackDidStopForPlayer:(CCCAudioPlayer*)audioPlayer;

@end

@class CCCAudioFileReader;
@interface CCCAudioPlayer : NSObject <CCCAudioOutputProvider, CCCAudioStartStopDelegate>{
  NSString* filePath;
  BOOL isAudioFileOpen;
  PlaybackState playbackState;
  id<CCCAudioSource> audioSource;
  id<CCCAudioPlaybackDelegate> delegate;
}

- (id) initWithSource:(id<CCCAudioSource>) source;
- (void) play;
- (void)startPlayback;
- (void)stopPlayback;
- (void)stopPlaybackImmediately;
- (BOOL)isPlaying;

@property (nonatomic, retain) id<CCCAudioPlaybackDelegate> delegate;

@end