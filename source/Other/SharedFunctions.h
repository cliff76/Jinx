/*
 *  SharedFunctions.h
 *  Jinx
 *
 *  Created by Clifton Craig on 12/17/10.
 *  Copyright 2010 Craig Corp. All rights reserved.
 *
 */

void raiseApplicationExceptionIfError(NSError *error, NSString* errorName, NSString *aDescription); //Throws NSException
void ensureDirectoryExistsAtPath(NSString* aPath); //Throws NSException
void writeStringToFile(NSString *aString, NSString *aPath); //Throws NSException
NSString* readStringFromFile(NSString *aFilePath); //Throws NSException
