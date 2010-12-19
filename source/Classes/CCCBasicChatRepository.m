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
			[NSArray arrayWithObjects:@"Are you asking me a question?",@"If a parsley farmer is sued do they garnish his wages?",
			 @"What would happen if the traffic light switched from red to purple?", @"Isn't it scary that doctors call what they do \"practice\"? ",
			 @"Do ten millipedes equal one centipede?", @"That's for me to know and for you to worry about!", @"I'll let you know when the time is right.", nil],
			@"interrogative message",
			[NSArray arrayWithObjects:@"That sounds cool.", @"Tell me about it.", @"I know, that's what I was thinking.", 
			 @"There's a fine line between looking tan and looking like you rolled in Doritos.",
			 @"\"The best thing about the internet is that you can quote something and totally make up the source.\" - Benjamin Franklin",
			 @"Gargling is a good way to see if your throat leaks.",
			 @"If at first you don't succeed, you'll get a lot of free advice from folks who didn't succeed either.",
			 @"Bare feet magnetize sharp metal objects so they always point upward from the floor.",
			 @"I use big words to sound smart... I mean I utilize gargantuan idioms to fabricate the semblance of substantial intelligence.",
			 @"Newton's 120th law: any argument carried far enough will end up in semantics.",
			 @"The best developers say, \"one ounce of application is worth a ton of abstraction!\"",
			 @"Shot my first turkey the other day. Scared the hell outta everyone in the frozen food section. I guess they must be environmentalists or something.",
			 @"If you say the word \"gullible\" real slow it sounds like \"ice cream\". Some folks get it...",
			 @"I think I could be a Jedi but so far I can only get \"The Force\" to work on grocery store doors and hand towel dispensers.",
			 @"Two wrongs don't make a right but three rights eventually make a left.",
			 @"Do not follow, for I may not lead. Do not lead, for I may not follow. Just go over there somewhere, please?",
			 @"if the world doesn't end on 12/21/2012 then it will definitely be over populated with newborn babies on 9/20/2013.",
			 nil],
			@"arbitrary message",
			nil];
}

@end
