//
//  RootViewController.h
//  Jinx
//
//  Created by Clifton Craig on 12/11/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController <UITableViewDelegate, UIScrollViewDelegate> {
	NSArray *buddyList;
	UIImageView *backgroundImage;
	UIImageView *backgroundImageLandscape;
}

@property (nonatomic, retain) NSArray *buddyList;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageLandscape;

@end
