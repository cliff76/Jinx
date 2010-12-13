//
//  CCCChatBuddy.m
//  Jinx
//
//  Created by Clifton Craig on 12/12/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import "CCCChatBuddy.h"


@implementation CCCChatBuddy

- (id) initWithBuddy:(NSString*)aBuddy loadedFromRepository:(id<CCCBuddyRepository>)aRepository
{
	self = [super init];
	if (self != nil) {
		buddy = [aBuddy retain];
		buddyRepository = [aRepository retain];
		lastReply = -1;
	}
	return self;
}

- (void) dealloc
{
	[buddy release];
	[buddyRepository release];
	[replies release];
	[super dealloc];
}

-(NSString*) tellBuddy:(NSString*)message
{
	if(! replies) replies = [[buddyRepository loadRepliesForBuddy:buddy] retain];
	NSArray *potentialReplies = [replies objectForKey:@"arbitrary message"];
	int nextReply = (++lastReply < [potentialReplies count]) ? lastReply : 0;
	lastReply = nextReply;
	return (potentialReplies && [potentialReplies count] > 0) ? [potentialReplies objectAtIndex:nextReply] : @"I have nothing to say.";
}

@end
