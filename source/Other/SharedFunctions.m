//
//  SharedFunctions.m
//  Jinx
//
//  Created by Clifton Craig on 12/17/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import "JinxApplicationGlobal.h"

void raiseApplicationExceptionIfError(NSError *error, NSString* errorName, NSString *aDescription)
{
	if (error) {
		NSLog(@"Error: %@", error);
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  aDescription, kJinxNotificationApplicationErrorKeyFriendlyMessage,
								  error, kJinxNotificationApplicationErrorKeyActualMessage,
								  nil];
		[notificationCenter postNotificationName:kJinxNotificationApplicationError object:error userInfo: userInfo];
		@throw [NSException exceptionWithName:errorName reason:[error description] userInfo:
				[NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil]
				];
	}
}

void ensureDirectoryExistsAtPath(NSString* aPath) //Throws NSException
{
	if (! [[NSFileManager defaultManager] fileExistsAtPath:aPath]) {
		NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:aPath withIntermediateDirectories:YES attributes:nil error:&error];
		raiseApplicationExceptionIfError(error, @"ConversationSaveException", @"Jinx could not save your conversation.");
	}
}

void writeStringToFile(NSString *aString, NSString *aPath)
{
	NSError *error = nil;
	[aString writeToFile:aPath atomically:NO encoding:NSUTF8StringEncoding error:&error];
	raiseApplicationExceptionIfError(error, @"ConversationSaveException", @"Jinx could not save record of who your conversation was with.");
}

NSString* readStringFromFile(NSString *aFilePath)
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:aFilePath]) {
		return @"";
	} else {
		NSError *error = nil;
		NSString *aString = [NSString stringWithContentsOfFile:aFilePath encoding:NSUTF8StringEncoding error:&error];
		raiseApplicationExceptionIfError(error, @"ConversationReadException", @"Jinx could not restore your prior conversation.");
		return aString;
	}
}