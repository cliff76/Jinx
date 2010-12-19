//
//  CCCBuddySelectorCell.h
//  Jinx
//
//  Created by Clifton Craig on 12/18/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CCCBuddySelectorCell : UITableViewCell {
	UIImage *buddyImage;
}
- (id)initWithIndex:(int)buddyIndex forBuddy:(NSString*)buddyName andStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
