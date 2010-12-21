//
//  CCCChatViewController.h
//  Jinx
//
//  Created by Clifton Craig on 12/12/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@class CCCChatBuddy;
@interface CCCChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
	UITableView *tableView;
	UITextField *messageToSend;
	NSMutableArray *messages;
	UIToolbar *toolbar;
	CCCChatBuddy *chatBuddy;
	BOOL isShowingLandscape;
	BOOL isInEditMode;
	BOOL youWereTypingSomething;
	SystemSoundID outgoingMessageClip;
	SystemSoundID incomingMessageClip;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITextField *messageToSend;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) CCCChatBuddy *chatBuddy;

+ (CCCChatViewController*) chatViewForBuddy:(NSString*)aChatBuddy andConversation:(NSArray*)existingMessages;
- (id)initWithBuddy:(NSString *)aChatBuddy;
- (id)initWithBuddy:(NSString *)aChatBuddy andMessages:(NSArray*)existingMessages;
- (id)initWithBuddy:(NSString *)aChatBuddy andNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle;
- (void)addMessage:(NSString*) aNewMessage;
- (IBAction)onSendButton:(id)sender;
- (IBAction)onClearButton:(id)sender;

@end
