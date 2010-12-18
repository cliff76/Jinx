//
//  CCCAudioPlayer.m
//  SpeexCodec
//
//  Created by cliftoncraig07 on 2/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CCCAudioPlayer.h"
#import "CCCAudioFileReader.h"

void CCCAudioOutputCallback(void* inUserData, AudioQueueRef outAQ, AudioQueueBufferRef outBuffer)
{
  id<CCCAudioOutputProvider> outputProvider = (id<CCCAudioOutputProvider>)inUserData;
  [outputProvider whenAudioQueueIsDepleted:outAQ forBuffer:outBuffer];
}

void CCCAudioQueueIsRunningCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID)
{
  if([(id)inUserData conformsToProtocol:@protocol(CCCAudioStartStopDelegate)]) {
    id<CCCAudioStartStopDelegate>startStopDelegate = (id<CCCAudioStartStopDelegate>)inUserData;
    [startStopDelegate playbackStateDidChange];
  } else {
    return;
  }
}

#pragma mark -

@interface CCCAudioPlayer(Private)
-(void) openTheAudioFile;
-(void) initializeAudioQueue;
-(void) allocatePacketDescriptors;
-(void) primeTheBuffers;
-(void) estimateBufferSize:(UInt32*)outBufferSize andPacketsPerCall:(UInt32*)outNumPacketsToRead forBufferSizedInSeconds:(Float64)seconds;
-(void) cleanUp;
-(void) processRunLoop;
-(BOOL) isQueueRunning;
@end

@implementation CCCAudioPlayer
@synthesize delegate;

#pragma mark Lifecycle methods
- (id) initWithSource:(id<CCCAudioSource>) source;
{
  self = [super init];
  if (self != nil) {
		playbackState.isInitialized = false;
		playbackState.isPlaying = false;
		playbackState.queue = NULL;
		audioSource = [source retain];
  }
  return self;
}

- (void) dealloc
{
  [self cleanUp];
  [audioSource release];
  [delegate release];
  [super dealloc];
}

#pragma mark -
#pragma mark Public API

- (void) play
{
  if(playbackState.isPlaying) [self stopPlayback];
  else [self performSelectorInBackground:@selector(startPlayback) withObject:nil];
}

-(void) setVolume:(Float32) newVolume
{
  AudioQueueSetParameter(playbackState.queue, kAudioQueueParam_Volume, newVolume);
}

- (void)startPlayback
{
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	@try {
		[(id<CCCAudioSource>)audioSource audioFormat:&playbackState.dataFormat];
		[self estimateBufferSize:&playbackState.bufferSize andPacketsPerCall:&playbackState.numberOfPacketsToRead forBufferSizedInSeconds:0.5];
		playbackState.isPlaying = true;
		[self allocatePacketDescriptors];
		[self initializeAudioQueue];
		[delegate playbackIsStartingForPlayer:self];
		[self primeTheBuffers];
		AudioQueueStart(playbackState.queue, NULL);
		if([[NSThread currentThread] isMainThread] == NO)
			[self processRunLoop];
		
	}
	@catch (NSException * e) {
		//DLog(@"**** Exception caught **** %@",e);
	}
	@finally {
		[pool release];
	}
}

-(void) stopAudioQueue:(bool) immediately
{
	//DLog(@"Stopping the queue...");
	if([self isQueueRunning]) {
		@try {
			OSStatusCall( AudioQueueStop(playbackState.queue, immediately) );
		}
		@catch (NSException * e) {
			//DLog(@"**** Exception stopping audio player **** %@", e);
		}
		//DLog(@"Stopped the queue!");
	} else {
		//DLog(@"Queue was not running!");
	}

	playbackState.isPlaying = false;
}

- (void)stopPlayback
{
	[self stopAudioQueue:false];
}

- (void)stopPlaybackImmediately
{
	[self stopAudioQueue:true];
}

- (BOOL)isPlaying
{
  return playbackState.isPlaying;
}

#pragma mark -
#pragma mark Supporting methods
- (BOOL)isQueueRunning
{
	UInt32 propVal = false, propSize = sizeof(propVal);
	
	if(playbackState.queue) {
		OSStatusCall( AudioQueueGetProperty(playbackState.queue, kAudioQueueProperty_IsRunning, &propVal, &propSize) );
	}
  return propVal;
}

-(void) processRunLoop
{
  @try {
    do {
      CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.25, false);
    }while (playbackState.isPlaying);
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, false);    
  }
  @catch (NSException * e) {
    ////DLog(@"Ut-Oh...! Something brokeded!");
  }
}

#pragma mark -
#pragma mark Audio system call methods
-(void) initializeAudioQueue
{
  if(! playbackState.isInitialized) {
    OSStatusCall( AudioQueueNewOutput(&playbackState.dataFormat, CCCAudioOutputCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &playbackState.queue) );
    OSStatusCall( AudioQueueAddPropertyListener(playbackState.queue, kAudioQueueProperty_IsRunning, CCCAudioQueueIsRunningCallback, self) );
    playbackState.isInitialized = true;
  }
}

-(BOOL) isVariableBitRateAudio
{
  return 0 == playbackState.dataFormat.mBytesPerPacket || 0 == playbackState.dataFormat.mFramesPerPacket;
}

-(void) allocatePacketDescriptors
{
  if([self isVariableBitRateAudio])
    playbackState.packetDescriptors = (AudioStreamPacketDescription*) malloc(playbackState.numberOfPacketsToRead * sizeof(AudioStreamPacketDescription));
  else
    playbackState.packetDescriptors = NULL;
}

-(void) estimateBufferSize:(UInt32*)outBufferSize andPacketsPerCall:(UInt32*)outNumPacketsToRead forBufferSizedInSeconds:(Float64)seconds
{
  AudioStreamBasicDescription *format = &playbackState.dataFormat;
  UInt32 maxPacketSize = [audioSource maxPacketSize];
  static const int minBufferSize = 0x4000; static const int maxBufferSize = 0x50000;
  if(0!=format->mFramesPerPacket) {
    Float64 numPacketsForTime = format->mSampleRate / format->mFramesPerPacket * seconds;
    *outBufferSize = numPacketsForTime * maxPacketSize;
  } else {
    *outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
  }
  if(*outBufferSize > maxBufferSize && *outBufferSize > maxPacketSize) *outBufferSize = maxBufferSize;
  else if(*outBufferSize < minBufferSize) *outBufferSize = minBufferSize;
  
  *outNumPacketsToRead = *outBufferSize / maxPacketSize;
}

-(void) primeTheBuffers
{
  for (int i = 0; i < NUM_BUFFERS && playbackState.isPlaying; i++) {
    //Allocate the buffer
    OSStatusCall( AudioQueueAllocateBuffer(playbackState.queue, playbackState.bufferSize, &playbackState.buffers[i]) );
    //And fill it with audio
    [self whenAudioQueueIsDepleted:playbackState.queue forBuffer:playbackState.buffers[i]];
  }
}

-(void) cleanUp
{
  //DLog(@"cleanup of player...");
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  if(playbackState.isInitialized) {
    playbackState.isInitialized = false;
    OSStatusCall( AudioQueueDispose(playbackState.queue, false) );
		playbackState.queue = NULL;
    if(playbackState.packetDescriptors) free(playbackState.packetDescriptors);
  }
  [pool release];
}

-(BOOL) provide:(UInt32) numPacketsToRead AudioOutputUsingQueue:(AudioQueueRef) outAQ forBuffer:(AudioQueueBufferRef) inBuffer
{
  UInt32 bytesRead, numPackets = numPacketsToRead;
	[(id<CCCAudioSource>)audioSource read: &numPackets packetsOfAudioDataInBuffer: inBuffer->mAudioData returningBytesRead:&bytesRead];
	//DLog(@"Read %i packets and %i bytes from audio file at currentPacket %i", numPackets, bytesRead, playbackState.currentPacket);
  if(numPackets) {
	  //DLog(@"Feeding raw data to queue.");
    inBuffer->mAudioDataByteSize = bytesRead;
    playbackState.currentPacket += numPackets;
		AudioStreamPacketDescription *packetDescriptors = NULL;
		if([audioSource respondsToSelector:@selector(describePackets:)]) {
			[audioSource describePackets:packetDescriptors];
		} else {
			packetDescriptors = NULL;
		}
    OSStatusCall( AudioQueueEnqueueBuffer(playbackState.queue, inBuffer, (packetDescriptors ? numPackets : 0), packetDescriptors) );
		return YES;
  } else{
	  //DLog(@"No more data to feed, we should stop the queue.");
		return NO;
  }
}

-(void) whenAudioQueueIsDepleted:(AudioQueueRef) outAQ forBuffer:(AudioQueueBufferRef) inBuffer
{
	@try {
		if(! [self isPlaying]) return; //If we got here and we are not playing then ignore...
		
		//If we cannot provide output for the queue...
		if(NO==[self provide: playbackState.numberOfPacketsToRead AudioOutputUsingQueue:outAQ forBuffer:inBuffer]) {
			//And if we're currently in playback mode...
			if([self isPlaying]) {
//				[self stopPlayback];//we need to stop playback
				@try {
					OSStatusCall( AudioQueueStop(playbackState.queue, false) );
				}
				@catch (NSException * e) {
					//DLog(@"**** Exception stopping audio player **** %@", e);
				}
				//DLog(@"All done playback.");
			}else {
				//DLog(@"we're all out of audio but we haven't stopped the queue. We probably should stop it to generate the final stop message.");
			}

		}
	}
	@catch (NSException * e) {
		//DLog(@"**** Exception caught **** %@", e);
		if([self isPlaying]) [self stopPlayback];//we need to stop playback
	}
}

-(void) playbackStateDidChange
{
  //DLog(@"Notifying delegate that playback state did change.");
  [delegate playbackStateDidChangeForPlayer:self];
  UInt32 propertyValue; UInt32 propertySize = sizeof(propertyValue);
  AudioQueueGetProperty(playbackState.queue, kAudioQueueProperty_IsRunning, &propertyValue, &propertySize);
  if(0==propertyValue) {
    ////DLog(@"Detected playback stopped will cleanup and notify listener.");
    [self performSelector:@selector(cleanUp) withObject:nil];
	  //DLog(@"Queue is NOT running. Playback should be stopped");
	  [delegate playbackDidStopForPlayer:self];
  }else if(![self isPlaying]) {
	  //DLog(@"Queue IS running, but player is not playing. Inconsistancy? Playback should be stopped?");
	  //...
  } else {
    ////DLog(@"Playback start detected.");
  }
}

@end
