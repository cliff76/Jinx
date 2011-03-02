//
//  JinxAppDelegate.m
//  Jinx
//
//  Created by Clifton Craig on 12/11/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import "JinxApplicationGlobal.h"
#import "JinxAppDelegate.h"
#import "CCCChatViewController.h"
#import "TVOutManager.h"

@interface JinxAppDelegate (PrivateMethods)

-(void) loadConversations;
-(void) saveCurrentConversation:(NSString*)aChatBuddy;
-(void) aConversationEnded:(NSNotification*)notification;
-(void) newConversationStarted:(NSNotification*)notification;

@end

@implementation JinxAppDelegate

@synthesize window;
@synthesize navigationController;

-(void) doSplash
{
	UIImageView *loadScreen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
	loadScreen.frame = CGRectMake(0.0f, 0.0f, 320, 480);
	[window addSubview: loadScreen];
    [window makeKeyAndVisible];

	[UIView animateWithDuration:1.0 delay:2.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		loadScreen.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-180));
		loadScreen.frame = CGRectMake(0.0f, 0.0f, loadScreen.frame.size.width * 2, loadScreen.frame.size.height * 2);
		loadScreen.alpha = 0.0f;
	} 
					 completion:^(BOOL finished){
						 [loadScreen removeFromSuperview];
						 [loadScreen release];
					 }];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newConversationStarted:) name:kJinxNotificationCoversationStarted object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aConversationEnded:) name:kJinxNotificationCoversationEnded object:nil];
    // Add the navigation controller's view to the window and display.
    [window addSubview:navigationController.view];
	[self loadConversations];
	[self doSplash];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	[[TVOutManager sharedInstance] stopTVOut];
	[self saveCurrentConversation:currentConversation];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	[self doSplash];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	[[TVOutManager sharedInstance] startTVOut];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

#pragma mark -
#pragma mark PrivateMethods
-(void) loadConversations
{
	NSString *lastConversation = readStringFromFile(JinxArchiveFileForLastChat);
	DLog(@"Last conversation was %@", lastConversation);
	if ([lastConversation isEqualToString:@""]) {
		return;
	} else {
		[navigationController pushViewController:[[[CCCChatViewController alloc] initWithBuddy:lastConversation] autorelease] animated:YES];
	}
}

-(void) saveCurrentConversation:(NSString*)aChatBuddy
{
	NSString *conversation = aChatBuddy ? aChatBuddy : @"";
	ensureDirectoryExistsAtPath(JinxArchivePath);
	[[NSFileManager defaultManager] createFileAtPath:JinxArchiveFileForLastChat contents:[NSData data] attributes:nil];
	writeStringToFile(conversation, JinxArchiveFileForLastChat);
}

-(void) aConversationEnded:(NSNotification*)notification
{
	DLog(@"A conversation ended.");
	currentConversation = @"";
	[self saveCurrentConversation:currentConversation];
}

-(void) newConversationStarted:(NSNotification*)notification
{
	currentConversation = [(NSDictionary*)[notification userInfo] objectForKey:kJinxNotificationKeyChatBuddyName];
	[self saveCurrentConversation:currentConversation];
}

@end

