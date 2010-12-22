/*
 *  CCCAudioSupport.h
 *  SpeexCodec
 *
 *  Created by cliftoncraig07 on 2/14/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>

#pragma mark Supplementary C functions
#define OSStatusCall(expr) {NSAutoreleasePool *osStatusCheckPool = [[NSAutoreleasePool alloc] init];\
checkOSStatusCall((expr), ([NSString stringWithFormat:@"[%@ %s]", [[self class] description], _cmd]));\
[osStatusCheckPool release];}
#define OSStatusCallMessage(message, expr) checkOSStatusCall((expr), (message));
void checkOSStatusCall(OSStatus aStatus, NSString *message);
