//
//  CCCChatBuddyTest.m
//  Jinx
//
//  Created by Clifton Craig on 12/12/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import "CCCChatBuddy.h"

@interface CCCChatBuddyTest : SenTestCase <CCCBuddyRepository>
{
	CCCChatBuddy *buddy;
	NSString* testBuddyName;
	id<CCCBuddyRepository> repo;
	NSDictionary *buddyRepliesFromRepo;
	BOOL repositoryWasQueried;
	NSString* buddyQueriedInRepository;
}

@end

@implementation CCCChatBuddyTest

-(void) setUp
{
	repo = self;
	testBuddyName = @"Any buddy name (lol! anybody name!)";
	buddy = [[CCCChatBuddy alloc] initWithBuddy:testBuddyName loadedFromRepository:repo];
}

-(void) testchatBuddyDefinesBuddyRepositoryProtocol
{
	id<CCCBuddyRepository> repository = self;
	STAssertTrue([repository conformsToProtocol:@protocol(CCCBuddyRepository)], @"The test self-shunts itself as a buddy repository.");
}

-(void) testRepositoryCanBeAskedForRepliesForBuddyByName
{
	buddyRepliesFromRepo = [[NSDictionary alloc] init];
	STAssertTrue( [[[repo loadRepliesForBuddy:@"Steve"] class] isSubclassOfClass:[NSDictionary class]],
				 @"Should return a collection of buddy replies");
	[buddyRepliesFromRepo release];
}

-(void) testBuddyRespondsToMessage
{
	NSString *response = [buddy tellBuddy: @"Hi There!"];
	STAssertNotNil(response, @"Buddy should respond with something.");
	STAssertTrue([response length] > 0, @"Response should not be an empty string.");
}

-(void) testRepositoryIsQueriedWhenWeTalkToBuddy
{
	STAssertFalse(repositoryWasQueried, @"Repository should not be queried until buddy is messaged.");
	[buddy tellBuddy:@"I have something to say."];
	STAssertTrue(repositoryWasQueried, @"Repository SHOULD be queried when buddy is messaged.");
	STAssertEqualObjects(buddyQueriedInRepository, testBuddyName, @"Should have queried for the test buddy name.");
}

-(void) testRepliesFromRepositoryShouldBeUsedAsTheResponseForArbitraryMessages
{
	NSArray* arbitraryReplies = [NSArray arrayWithObjects:@"That's cool...", @"Really???!!!", @"Tell me more.", nil];
	buddyRepliesFromRepo = [NSDictionary dictionaryWithObjectsAndKeys:arbitraryReplies, @"arbitrary message",nil];
	NSString *reply = [buddy tellBuddy:@"I'm having fun!"];
	STAssertTrue([arbitraryReplies containsObject:reply],@"Reply should be one of the list of arbitrary replies.");
}


-(void) testRepliesUsedFromRepositoryShouldTheSameAsTheLastReply
{
	NSArray* arbitraryReplies = [NSArray arrayWithObjects:@"That's cool...", @"Really???!!!", @"Tell me more.", nil];
	buddyRepliesFromRepo = [NSDictionary dictionaryWithObjectsAndKeys:arbitraryReplies, @"arbitrary message",nil];
	for (int i=0; i < [arbitraryReplies count]*2; i++) {
		NSString *lastReply = [buddy tellBuddy:@"I'm having fun!"];
		STAssertFalse([[buddy tellBuddy:@"Tell me something new."] isEqualToString:lastReply], @"Buddy should respond differently. Last reply was %@", lastReply);
	}
}

#pragma mark -
#pragma mark CCCBuddyRepository methods.
-(NSDictionary*) loadRepliesForBuddy:(NSString*)aBuddy
{
	repositoryWasQueried = YES;
	buddyQueriedInRepository = aBuddy;
	return buddyRepliesFromRepo;
}

@end
