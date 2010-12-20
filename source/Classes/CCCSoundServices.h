//
//  CCCSoundServices.h
//  Jinx
//
//  Created by Clifton Craig on 12/19/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface CCCSoundServices : NSObject {

}
+ (void) loadClipFromFile:(NSString*)path asSoundId:(SystemSoundID*)systemSoundId;
+ (void) playClip:(SystemSoundID)systemSoundIdClip;
@end
