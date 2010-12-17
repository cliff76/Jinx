//
//  CCCAudioSource.h
//  SpeexCodec
//
//  Created by cliftoncraig07 on 7/1/10.
//  Copyright 2010 MapQuest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCAudioSupport.h"

@protocol CCCAudioSource <NSObject>

-(void) audioFormat:(AudioStreamBasicDescription*)fileFormatOutput;
-(void) read:(UInt32*) packetsToRead packetsOfAudioDataInBuffer: (void*) outputBuffer returningBytesRead:(UInt32*)bytesRead;
-(void) describePackets:(AudioStreamPacketDescription *)somePacketDescriptors;
-(UInt32) maxPacketSize;

@end
