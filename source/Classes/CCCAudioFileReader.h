//
//  CCCAudioFileReader.h
//  SpeexCodec
//
//  Created by cliftoncraig07 on 2/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCCAudioSupport.h"
#import "CCCAudioSource.h"

@interface CCCAudioFileReader : NSObject <CCCAudioSource>{
  NSString *filePath;
  SInt64 theFileSize;
  NSFileHandle *audioFile;
  SInt64 currPosition;
	AudioFileID fileHandle;
	AudioStreamPacketDescription *packetDescriptors;
	SInt64 currentPacket;
}
- (id) initWithFile:(NSString*) aFilePath;
-(void) openFileWithFileTypeHint: (AudioFileTypeID) hint;
@end
