//
//  main.m
//  Jinx
//
//  Created by Clifton Craig on 12/11/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JinxAppDelegate.h"
int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    id aClass = [JinxAppDelegate class];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass(aClass));
    [pool release];
    return retVal;
}
