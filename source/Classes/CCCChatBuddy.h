//
//  CCCChatBuddy.h
//  Jinx
//
//  Created by Clifton Craig on 12/12/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCCBuddyRepository.h"

@interface CCCChatBuddy : NSObject {
	NSString *buddyName;
	id<CCCBuddyRepository> buddyRepository;
	NSDictionary *replies;
	int lastReply;
}

- (id) initWithBuddy:(NSString*)aBuddy loadedFromRepository:(id<CCCBuddyRepository>)aRepository;
-(NSString*) tellBuddy:(NSString*)message;
@property (nonatomic, retain) NSString *buddyName;
@end
