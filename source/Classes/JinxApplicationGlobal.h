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
#import "JinxMath.h"

#define JinxArchivePath ([NSString stringWithFormat:@"%@/%@",\
[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],\
@"conversations"\
])
#define JinxArchiveFileForBuddy(buddyName) ( [NSString stringWithFormat:@"%@/%@.chat", JinxArchivePath, buddyName] )
#define JinxArchiveFileForLastChat ( [NSString stringWithFormat:@"%@/LastChat.txt", JinxArchivePath] )
