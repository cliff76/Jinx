//
//  BackgroundRotation.h
//  Jinx
//
//  Created by Clifton Craig on 12/18/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BackgroundRotation : NSObject {
	UIImageView *backgroundImage;
	UIImageView *backgroundImageLandscape;
}

- (id) initWithBackgroundsForPortrait:(UIImageView*)backgroundImage andLandscape:(UIImageView*)backgroundImageLandscape;
-(void) updateViews;
-(void) updateViewsWithPortraitAnimations:(void(^)(void))portraitAnimations andLandscapeAnimations: (void(^)(void))landscapeAnimations;

@end
