//
//  CCCChatViewController.m
//  Jinx
//
//  Created by Clifton Craig on 12/12/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import "CCCChatViewController.h"
#import "CCCChatBuddy.h"
#import "CCCBasicChatRepository.h"

#define kCCCBallonViewTag 1
#define kCCCLabelTag 2
#define kCCCMessageTag 0
static NSString *CellIdentifier = @"Cell";

@interface CCCChatViewController (PrivateMethods)

-(UIView*) createMessageView:(CGRect)cellFrame;
-(UITableViewCell*) createReusableTableCellForChatMessageView:(UIView*) chatMessageView;
-(void) addRawMessage:(NSString*)raw toMessageView:(UIView*)messageView;
-(void) onMessageAdded;

@end

@implementation CCCChatViewController
@synthesize tableView, messageToSend, toolbar, chatBuddy;

#pragma mark -
#pragma mark Public API
- (id)initWithBuddy:(NSString *)aChatBuddy andNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (self != nil) {
		self.chatBuddy = [[CCCChatBuddy alloc] initWithBuddy:aChatBuddy loadedFromRepository: [[[CCCBasicChatRepository alloc] init] autorelease] ];
		self.navigationItem.title = [NSString stringWithFormat:@"Chat with %@...", self.chatBuddy.buddyName];
	}
	return self;
}

- (void)addMessage:(NSString*) aNewMessage
{
	[messages addObject:aNewMessage];
	//Need to ensure screen update is done on the Main Thread
	[self performSelectorOnMainThread:@selector(onMessagesUpdated) withObject:nil waitUntilDone:NO];
}

-(void) sendMessageToBuddy:(NSString*) aMessageToBuddy
{
	[self addMessage:[NSString stringWithFormat:@"You: %@", aMessageToBuddy]];
	NSString *reply = [self.chatBuddy tellBuddy:aMessageToBuddy];
	[self addMessage:[NSString stringWithFormat:@"%@: %@", chatBuddy.buddyName, reply]];
}

-(void) removeLastMessageFromSpeaker: (NSString*)speaker
{
	for (int i = [messages count] - 1; i>=0; i--) {
		if ([(NSString*)[messages objectAtIndex:i] hasPrefix:speaker]) {
			[messages removeObjectAtIndex:i];
			[self performSelectorOnMainThread:@selector(onMessagesUpdated) withObject:nil waitUntilDone:NO];
			return;
		}
	}
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	messages = [[NSMutableArray  alloc] init];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification object:self.view.window]; 
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil]; 
}/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [messages count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) { cell = [self createReusableTableCellForChatMessageView:[self createMessageView:cell.frame]]; }
	[self addRawMessage:[messages objectAtIndex:indexPath.row] toMessageView:[cell.contentView viewWithTag:kCCCMessageTag]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *body = [messages objectAtIndex:indexPath.row];
	CGSize size = [body sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0, 480.0) lineBreakMode:UILineBreakModeWordWrap];
	return size.height + 20;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark -
#pragma mark PrivateMethods
-(UIView*) createMessageView:(CGRect)cellFrame
{
	UIImageView *balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
	balloonView.tag = kCCCBallonViewTag;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.tag = kCCCLabelTag;
	label.numberOfLines = 0;
	label.lineBreakMode = UILineBreakModeWordWrap;
	label.font = [UIFont systemFontOfSize:14.0];
	
	UIView *message = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cellFrame.size.width, cellFrame.size.height)];
	message.tag = kCCCMessageTag;
	[message addSubview:balloonView];
	[message addSubview:label];
	
	[balloonView release];
	[label release];
	return [message autorelease];
}

-(UITableViewCell*) createReusableTableCellForChatMessageView:(UIView*) chatMessageView
{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	[cell.contentView addSubview:chatMessageView];
	return [cell autorelease];
}

-(void) addRawMessage:(NSString*)raw toMessageView:(UIView*)messageView
{
	UIImageView *balloonView = (UIImageView *)[messageView viewWithTag:kCCCBallonViewTag];
	UILabel *label = (UILabel *)[messageView viewWithTag:kCCCLabelTag];
	
	NSString *text = [raw substringFromIndex:[raw rangeOfString:@":"].location + 2];
	NSString *speaker = [raw substringToIndex:[raw rangeOfString:@":"].location];
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
	
	UIImage *balloon;
	
	if([[speaker lowercaseString] isEqualToString:@"you"])
	{
		balloonView.frame = CGRectMake(320.0f - (size.width + 28.0f), 2.0f, size.width + 28.0f, size.height + 15.0f);
		balloon = [[UIImage imageNamed:@"green.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
		label.frame = CGRectMake(307.0f - (size.width + 5.0f), 8.0f, size.width + 5.0f, size.height);
	}
	else
	{
		balloonView.frame = CGRectMake(0.0, 2.0, size.width + 28, size.height + 15);
		balloon = [[UIImage imageNamed:@"grey.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
		label.frame = CGRectMake(16, 8, size.width + 5, size.height);
	}
	
	balloonView.image = balloon;
	label.text = text;
}

-(void) onMessagesUpdated
{
	[tableView reloadData];
	NSUInteger index = [messages count] - 1;
	[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

#pragma mark -
#pragma mark UITextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//	[self addMessage:[NSString stringWithFormat:@"You: %@", textField.text]];
	[self sendMessageToBuddy:textField.text];
	textField.text = @"";
	//	[textField resignFirstResponder];
	//	[UIView beginAnimations:nil context:NULL];
	//    [UIView setAnimationDuration:0.3];	
	//	toolbar.frame = CGRectMake(0, 372, 320, 44);
	//	tbl.frame = CGRectMake(0, 0, 320, 372);	
	//	[UIView commitAnimations];
	return YES;
}

- (void)keyboardWillShow:(NSNotification *)notif {
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];	
	toolbar.frame = CGRectMake(0, 156, 320, 44);
	tableView.frame = CGRectMake(0, 0, 320, 156);	
	[UIView commitAnimations];
	
	if([messages count] > 0)
	{
		NSUInteger index = [messages count] - 1;
		[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[tableView release];
	[messageToSend release];
	[messages release];
	[toolbar release];
	[chatBuddy release];
    [super dealloc];
}


@end

