//
//  BackgroundRotation.m
//  Jinx
//
//  Created by Clifton Craig on 12/18/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//
#import "JinxMath.h"
#import "BackgroundRotation.h"


@implementation BackgroundRotation

- (id) initWithBackgroundsForPortrait:(UIImageView*)aBackgroundImage andLandscape:(UIImageView*)aBackgroundImageLandscape
{
	self = [super init];
	if (self != nil) {
		backgroundImage = [aBackgroundImage retain];
		backgroundImageLandscape = [aBackgroundImageLandscape retain];
	}
	return self;
}

- (void) dealloc
{
	[backgroundImage release];
	[backgroundImageLandscape release];
	[super dealloc];
}

-(void) updateViews
{
	[self updateViewsWithPortraitAnimations:nil andLandscapeAnimations:nil];
}

-(void) updateViewsWithPortraitAnimations:(void(^)(void))portraitAnimations andLandscapeAnimations: (void(^)(void))landscapeAnimations
{
	CGFloat rotation = 0.0f;
	BOOL isLandscape = NO;
	switch ([UIDevice currentDevice].orientation) {
		case UIDeviceOrientationLandscapeLeft:
			rotation = 0.0;
			isLandscape = YES;
			break;
		case UIDeviceOrientationLandscapeRight:
			rotation = 180.0f;
			isLandscape = YES;
			break;
		default:
			break;
	}
	if (isLandscape) {
		[UIView beginAnimations:@"switch-background" context:nil];
		backgroundImage.alpha = 0.0f;
		backgroundImageLandscape.alpha = 1.0f;
		backgroundImageLandscape.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(rotation));
		if (landscapeAnimations) {
			landscapeAnimations();
		}
		[UIView commitAnimations];
	} else {
		[UIView beginAnimations:@"switch-background" context:nil];
		if (portraitAnimations) {
			portraitAnimations();
		}
		backgroundImage.alpha = 1.0f;
		backgroundImageLandscape.alpha = 0.0f;
		if( [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown ) {
			backgroundImage.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-180.0f));
			backgroundImage.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
		} else {
			backgroundImage.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0.0f));
			backgroundImage.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
		}
		
		[UIView commitAnimations];
	}
}

@end
