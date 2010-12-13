//
//  CCCChatViewController.h
//  Jinx
//
//  Created by Clifton Craig on 12/12/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CCCChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
	UITableView *tableView;
	UITextField *messageToSend;
	NSArray *messages;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITextField *messageToSend;

@end
