//
//  CCCBuddyRepository.h
//  Jinx
//
//  Created by Clifton Craig on 12/13/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCCBuddyRepository <NSObject>
-(NSDictionary*) loadRepliesForBuddy:(NSString*)buddy;
@end
