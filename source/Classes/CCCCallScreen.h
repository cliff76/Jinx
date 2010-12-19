//
//  CCCCallScreen.h
//  Jinx
//
//  Created by Clifton Craig on 12/17/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCAudioPlayer.h"

@interface CCCCallScreen : UIViewController <CCCAudioPlaybackDelegate>{
	NSString *chatBuddy;
	NSMutableArray *audioPlayList;
	CCCAudioPlayer *player;
	BOOL cancel;
}

@end
