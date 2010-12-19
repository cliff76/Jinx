/*
 *  JinxApplicationGlobal.h
 *  Jinx
 *
 *  Created by Clifton Craig on 12/17/10.
 *  Copyright 2010 Craig Corp. All rights reserved.
 *
 */
#import "JinxNotifications.h"
#import "SharedFunctions.h"

#define M_PI   3.14159265358979323846264338327950288   /* pi */
// Our conversion definition
#define DEGREES_TO_RADIANS(angle) ((angle / 180.0) * M_PI)
#define JinxArchivePath ([NSString stringWithFormat:@"%@/%@",\
[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],\
@"conversations"\
])
#define JinxArchiveFileForBuddy(buddyName) ( [NSString stringWithFormat:@"%@/%@.chat", JinxArchivePath, buddyName] )
#define JinxArchiveFileForLastChat ( [NSString stringWithFormat:@"%@/LastChat.txt", JinxArchivePath] )
