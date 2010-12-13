//
//  CCCJinxAppLoadLogicTest.m
//  Jinx
//
//  Created by Clifton Craig on 12/11/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import "CCCJinxAppLoadLogic.h"

@interface CCCJinxAppLoadLogicTest : SenTestCase
{
	CCCJinxAppLoadLogic *appLoadLogic;
}

@end

@implementation CCCJinxAppLoadLogicTest

-(void) setUp
{
	appLoadLogic = [[CCCJinxAppLoadLogic alloc] init];
}

-(void) testLoadListForFirstScreen
{
	NSArray *expectedBuddies = [NSArray arrayWithObjects:@"Clint", @"Leeza", @"Stuart", nil];
	STAssertEqualObjects(appLoadLogic.buddyList, expectedBuddies, @"Should begin with expected buddies.");
}

-(void) testMemoryMgmt
{
	NSArray *expectedBuddies = [[NSArray alloc] initWithObjects:@"Clint", @"Leeza", @"Stuart", nil];
	STAssertEquals([expectedBuddies retainCount], (NSUInteger)1, @"Should have a single retain.");
	appLoadLogic.buddyList = expectedBuddies;
	STAssertEquals([expectedBuddies retainCount], (NSUInteger)2, @"Should have a single retain.");
	[appLoadLogic release];
	STAssertEquals([expectedBuddies retainCount], (NSUInteger)1, @"Should have a single retain.");
}

@end
