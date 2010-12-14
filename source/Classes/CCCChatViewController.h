//
//  CCCChatViewController.h
//  Jinx
//
//  Created by Clifton Craig on 12/12/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCCChatBuddy;
@interface CCCChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
	UITableView *tableView;
	UITextField *messageToSend;
	NSMutableArray *messages;
	UIToolbar *toolbar;
	CCCChatBuddy *chatBuddy;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITextField *messageToSend;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) CCCChatBuddy *chatBuddy;

- (id)initWithBuddy:(NSString *)aChatBuddy andNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle;
- (void)addMessage:(NSString*) aNewMessage;

@end
