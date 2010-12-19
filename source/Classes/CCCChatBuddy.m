//
//  CCCChatBuddy.m
//  Jinx
//
//  Created by Clifton Craig on 12/12/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import "CCCChatBuddy.h"


@implementation CCCChatBuddy
@synthesize buddyName;

- (id) initWithBuddy:(NSString*)aBuddy loadedFromRepository:(id<CCCBuddyRepository>)aRepository
{
	self = [super init];
	if (self != nil) {
		buddyName = [aBuddy retain];
		buddyRepository = [aRepository retain];
		lastReply = -1;
	}
	return self;
}

- (void) dealloc
{
	[buddyName release];
	[buddyRepository release];
	[replies release];
	[super dealloc];
}

-(NSString*) tellBuddy:(NSString*)message
{
	if(! replies) replies = [[buddyRepository loadRepliesForBuddy:buddyName] retain];
	NSString *replyType;
	if([message hasSuffix:@"?"]) {
		replyType = @"interrogative message";
	} else if([message hasSuffix:@"!"]) {
		replyType = @"exclamatory message";
	} else {
		replyType = @"arbitrary message";		
	}
	NSArray *potentialReplies = [replies objectForKey:replyType];
	//The simulator has an issue with modulo of the count into the random number, only during unit tests.
#if TARGET_IPHONE_SIMULATOR
	int nextReply = (++lastReply < [potentialReplies count]) ? lastReply : 0;
#else
	int nextReply = (arc4random() % [potentialReplies count]);
	while (nextReply == lastReply) {
		nextReply = (arc4random() % [potentialReplies count]);
	}
#endif
	lastReply = nextReply;
	return (potentialReplies && [potentialReplies count] > 0) ? [potentialReplies objectAtIndex:nextReply] : @"I have nothing to say.";
}

@end
