//
//  CCCBuddySelectorCell.m
//  Jinx
//
//  Created by Clifton Craig on 12/18/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import "CCCBuddySelectorCell.h"
#import "JinxMath.h"

#define ImageIconNameForBuddy(buddyName) ([NSString stringWithFormat:@"%@.png", buddyName])
#define NameLabelImageNameForBuddy(buddyName) ([NSString stringWithFormat:@"%@Label.png", buddyName])
@implementation CCCBuddySelectorCell

- (id)initWithIndex:(int)buddyIndex forBuddy:(NSString*)buddyName andStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		buddyImage = [UIImage imageNamed:ImageIconNameForBuddy(buddyName)];
		UIImageView *buddyView = [[UIImageView alloc] initWithImage:buddyImage];
		buddyView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90.0f));
		buddyView.frame = CGRectMake(20.0f, (150.0f - buddyImage.size.width)/2, buddyImage.size.height, buddyImage.size.width);
		
		UIImage *nameLabel = [UIImage imageNamed:NameLabelImageNameForBuddy(buddyName)];
		UIImageView *nameView = [[UIImageView alloc] initWithImage:nameLabel];
		nameView.center = CGPointMake(60.0f, buddyView.center.y);
		nameView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90.0f));
		[self.contentView addSubview:buddyView];
		[self.contentView addSubview:nameView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
