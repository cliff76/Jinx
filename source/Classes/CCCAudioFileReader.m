//
//  CCCAudioFileReader.m
//  SpeexCodec
//
//  Created by cliftoncraig07 on 2/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CCCAudioFileReader.h"

@interface CCCAudioFileReader (Private)

-(OSStatus) readFromPosition:(SInt64)position numberOfBytes:(UInt32)requestedBytesToRead intoBuffer:(void*)buffer returningActualCount:(UInt32*)actualCount;
-(SInt64) readFileSize;
-(SInt64) fileSize;

@end

OSStatus MQAudioFile_ReadProc (
                               void     *inClientData,
                               SInt64   inPosition,
                               UInt32   requestCount,
                               void     *buffer,
                               UInt32   *actualCount)
{
  CCCAudioFileReader* reader = (CCCAudioFileReader*) inClientData;
  return [reader readFromPosition:inPosition numberOfBytes:requestCount intoBuffer:buffer returningActualCount:actualCount];
}

SInt64 MQAudioFile_GetSizeProc (void  *inClientData)
{
  CCCAudioFileReader* reader = (CCCAudioFileReader*) inClientData;
  return [reader fileSize];
}

@implementation CCCAudioFileReader

#pragma mark lifecycle methods
- (id) initWithFile:(NSString*) aFilePath
{
  self = [super init];
  if (self != nil) {
    filePath = [aFilePath retain];
		[self openFileWithFileTypeHint:0];
  }
  return self;
}

- (void) dealloc
{
  [filePath release];
  OSStatusCall( AudioFileClose(fileHandle) );
  [audioFile closeFile];
  [audioFile release];
  [super dealloc];
}

#pragma mark -
#pragma mark MQAudioSource callbacks
-(void) audioFormat:(AudioStreamBasicDescription*)fileFormatOutput
{
  UInt32 fileFormatOutputSize = sizeof(*fileFormatOutput); AudioFilePropertyID fileProperty = kAudioFilePropertyDataFormat;
  OSStatusCall( AudioFileGetProperty(fileHandle, fileProperty, &fileFormatOutputSize, fileFormatOutput) );
}

-(void) read:(UInt32*) packetsToRead packetsOfAudioDataInBuffer: (void*) outputBuffer returningBytesRead:(UInt32*)bytesRead
{
//	DLog(@"Reading %i packet(s) from audio file @ current packet %i", *packetsToRead, currentPacket);
  OSStatusCall( AudioFileReadPackets(fileHandle, false, bytesRead, packetDescriptors, currentPacket, packetsToRead, outputBuffer) );
	currentPacket += *packetsToRead;
//	DLog(@"Read %i bytes from audio file at currentPacket %i", *bytesRead, currentPacket);
}

-(void) describePackets:(AudioStreamPacketDescription *)somePacketDescriptors
{
	somePacketDescriptors = packetDescriptors;
}

-(UInt32) maxPacketSize
{
  UInt32 maxPacketSize; UInt32 propertySize = sizeof(maxPacketSize);
  AudioFileGetProperty(fileHandle, kAudioFilePropertyPacketSizeUpperBound, &propertySize, &maxPacketSize);
	return maxPacketSize;
}

#pragma mark -
-(void) openFileWithFileTypeHint: (AudioFileTypeID) hint
{
  theFileSize = [self readFileSize];
  audioFile = [[NSFileHandle fileHandleForReadingAtPath:filePath] retain];
	NSAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath], @"Should always have a file for playback!");
  //DLog(@"opening file %@", filePath);
  OSStatusCall( AudioFileOpenWithCallbacks(self, MQAudioFile_ReadProc, NULL, MQAudioFile_GetSizeProc, NULL, hint, &fileHandle) );
  //DLog(@"File %@ is open", filePath);
}

-(BOOL) isAnError:(NSError*)error
{
  return 0!=[error code];
}

-(OSStatus) readFromPosition:(SInt64)position numberOfBytes:(UInt32)requestedBytesToRead intoBuffer:(void*)buffer returningActualCount:(UInt32*)actualCount
{
//	DLog(@"Reading audio file...");
//  DLog(@"Audio file position %qi", [audioFile offsetInFile]);
  [audioFile seekToFileOffset:position];
  @try
  {
    NSData *theData = [audioFile readDataOfLength:requestedBytesToRead];
    *actualCount = [theData length];
    memcpy(buffer, [theData bytes], *actualCount);
    NSAssert(*actualCount >=0, @"Negative read count!");
    //DLog(@"Read %i", *actualCount);
    //DLog(@"Requested %i bytes. Read %i bytes for CoreAudio", requestedBytesToRead, *actualCount);
  }
  @catch (NSException *ex)
  {
    NSString *description = [NSString stringWithFormat:@"%@ %@ Requested %i bytes read from pos. %i", [ex name], [ex reason], requestedBytesToRead, position];
    [NSException raise:@"MQReadStreamError" format:description, nil];
  }
  return kAudioServicesNoError;
}

-(SInt64) fileSize
{
  //DLog(@"Returning file size to CoreAudio %i", theFileSize);
  return theFileSize;
}

-(SInt64) readFileSize
{
  NSError *error = nil;
  NSDictionary *attributes = (NSDictionary*)[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
  NSNumber *theSize = [attributes objectForKey:NSFileSize];
  if(error && [self isAnError:error]) {
    DLog(@"Error caught determining the size of file %@ in %s Error: %@", filePath, _cmd, error);
    [NSException raise:@"MQFileSizeReadException" format:[error description], nil];
  }
  return [theSize integerValue];
}

@end
