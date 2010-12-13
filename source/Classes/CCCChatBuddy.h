//
//  CCCChatBuddy.h
//  Jinx
//
//  Created by Clifton Craig on 12/12/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CCCBuddyRepository <NSObject>
-(NSDictionary*) loadRepliesForBuddy:(NSString*)buddy;
@end

@interface CCCChatBuddy : NSObject {
	NSString *buddy;
	id<CCCBuddyRepository> buddyRepository;
	NSDictionary *replies;
	int lastReply;
}

- (id) initWithBuddy:(NSString*)aBuddy loadedFromRepository:(id<CCCBuddyRepository>)aRepository;
-(NSString*) tellBuddy:(NSString*)message;

@end
