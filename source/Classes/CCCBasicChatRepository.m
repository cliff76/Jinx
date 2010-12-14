//
//  CCCBasicChatRepository.m
//  Jinx
//
//  Created by Clifton Craig on 12/13/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import "CCCBasicChatRepository.h"


@implementation CCCBasicChatRepository
-(NSDictionary*) loadRepliesForBuddy:(NSString*)buddy
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSArray arrayWithObjects:@"That sounds way too exciting!", @"Whoa, hold your horses!", @"I'll continue once you calm down!", nil],
			@"exclamatory message",
			[NSArray arrayWithObjects:@"Are you asking me a question?", @"That's for me to know and for you to worry about!", @"I'll let you know when the time is right.", nil],
			@"interrogative message",
			[NSArray arrayWithObjects:@"That sounds cool.", @"Tell me about it.", @"I know, that's what I was thinking.", nil],
			@"arbitrary message",
			nil];
}

@end
