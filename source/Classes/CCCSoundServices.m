//
//  CCCSoundServices.m
//  Jinx
//
//  Created by Clifton Craig on 12/19/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import "CCCSoundServices.h"


@implementation CCCSoundServices

+ (void) loadClipFromFile:(NSString*)path asSoundId:(SystemSoundID*)systemSoundId
{
	AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], systemSoundId);
}

+ (void) playClip:(SystemSoundID)systemSoundIdClip
{
	AudioServicesPlaySystemSound(systemSoundIdClip);
}

@end
