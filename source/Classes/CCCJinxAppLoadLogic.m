//
//  CCCJinxAppLoadLogic.m
//  Jinx
//
//  Created by Clifton Craig on 12/11/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import "CCCJinxAppLoadLogic.h"


@implementation CCCJinxAppLoadLogic
@synthesize buddyList;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.buddyList = [NSArray arrayWithObjects:@"Clint", @"Leeza", @"Stuart", nil];
	}
	return self;
}

- (void) dealloc
{
	self.buddyList = nil;
	[super dealloc];
}


@end
