//
//  CCCCallScreen.h
//  Jinx
//
//  Created by Clifton Craig on 12/17/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface CCCCallScreen : UIViewController <CCCAudioPlaybackDelegate>{
	NSString *chatBuddy;
	NSMutableArray *audioPlayList;
	CCCAudioPlayer *player;
	BOOL cancel;
	UIImageView *backgroundImage;
	UIImageView *backgroundImageLandscape;
	UIImageView *youAvatar;
	UILabel *youLabel;
	UIImageView *buddyAvatar;
	UILabel *buddyLabel;

#pragma mark Video management vars
#if ! TARGET_IPHONE_SIMULATOR
	AVCaptureSession *captureSession;
	AVCaptureDevice *videoCaptureDevice;
	NSError *error;	
	AVCaptureDeviceInput *videoInput;
	UIView *videoPreview;
#endif	
}

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageLandscape;
@property (nonatomic, retain) IBOutlet UIImageView *youAvatar;
@property (nonatomic, retain) IBOutlet UILabel *youLabel;
@property (nonatomic, retain) UIImageView *buddyAvatar;
@property (nonatomic, retain) IBOutlet UILabel *buddyLabel;

@end
