/*
 *  CCCAudioSupport.cpp
 *  SpeexCodec
 *
 *  Created by cliftoncraig07 on 2/14/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#import "CCCAudioSupport.h"
void checkOSStatusCall(OSStatus aStatus, NSString *message)
{
  if(kAudioServicesNoError == aStatus) {return;}
  
  CFErrorRef error = CFErrorCreate(NULL, kCFErrorDomainOSStatus, aStatus, NULL);
  NSString *errorDescription = (NSString*) CFErrorCopyDescription(error);
  NSString *errorReason = (NSString*) CFErrorCopyFailureReason(error); errorReason = errorReason ? errorReason : @" ";
  NSString *errorRecovery = (NSString*)CFErrorCopyRecoverySuggestion(error); errorRecovery = errorRecovery ? errorRecovery : @" ";

  if(kAudioFileInvalidFileError==[(NSError*)error code]) {
    errorReason = @"Audio data is invalid/malformed: (Did you forget to decode the audio before passing it directly to a core audio function?)";
    errorRecovery = @"Decode the audio before passing it directly to a core audio function.";
  }
  [NSException raise:@"SystemError" format:
        [NSString stringWithFormat:@"%@ Description: %@ Reason: %@ Recovery: %@", message, errorDescription, errorReason, errorRecovery], nil];
  [errorReason release];
  [errorRecovery release];
  [errorDescription release];
  CFRelease(error);
}
