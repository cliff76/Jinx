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
	UIImageView *backgroundImage;
	UIImageView *backgroundImageLandscape;
	UILabel *buddyLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageLandscape;
@property (nonatomic, retain) IBOutlet UILabel *buddyLabel;

@end
