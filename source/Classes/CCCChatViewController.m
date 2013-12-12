//
//  CCCChatViewController.m
//  Jinx
//
//  Created by Clifton Craig on 12/12/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//
#import "JinxApplicationGlobal.h"
#import "CCCChatViewController.h"
#import "CCCChatBuddy.h"
#import "CCCBasicChatRepository.h"
#import "CCCCallScreen.h"
#import "CCCSoundServices.h"

#define YOU @"You"
#define kCCCBallonViewTag 1
#define kCCCLabelTag 2
#define kCCCMessageTag 0
static NSString *CellIdentifier = @"Cell";

@interface CCCChatViewController (PrivateMethods)

-(UIView*) createMessageView:(CGRect)cellFrame;
-(UITableViewCell*) createReusableTableCellForChatMessageView:(UIView*) chatMessageView;
-(void) addRawMessage:(NSString*)raw toMessageView:(UIView*)messageView;
-(void) removeLastMessageFromSpeaker: (NSString*)speaker;
-(void) onMessageAdded;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
-(void) saveConversation;
-(void) loadConversationForBuddy:(NSString*)aChatBuddy;

@end

@implementation CCCChatViewController
@synthesize tableView, messageToSend, toolbar, chatBuddy = _chatBuddy, keyboardFrameRect;

#pragma mark -
#pragma mark Public API

+ (CCCChatViewController*) chatViewForBuddy:(NSString*)aChatBuddy andConversation:(NSArray*)existingMessages
{
	return [[[CCCChatViewController alloc] initWithBuddy:aChatBuddy andMessages:existingMessages] autorelease];
}

- (void)prepare
{
    messages = [[NSMutableArray  alloc] init];
    [CCCSoundServices loadClipFromFile:[[NSBundle mainBundle] pathForResource:@"outgoing-blip" ofType:@"aiff"] asSoundId: &outgoingMessageClip];
    [CCCSoundServices loadClipFromFile:[[NSBundle mainBundle] pathForResource:@"incoming-blip" ofType:@"aiff"] asSoundId: &incomingMessageClip];
    [CCCSoundServices loadClipFromFile:[[NSBundle mainBundle] pathForResource:@"clear-screen" ofType:@"aiff"] asSoundId: &clearScreenClip];
    // This could be in an init method.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keypadWillToggle:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keypadWillToggle:) name:UIKeyboardWillHideNotification object:nil];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self prepare];
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nil];
	if (self != nil) {
        [self prepare];
	}
	return self;
}

- (void)keypadWillToggle:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* beginKeyboardValue = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    NSValue* endKeyboardValue = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [endKeyboardValue CGRectValue];
    self.keyboardFrameRect = keyboardRect;
    int adjust = beginKeyboardValue.CGRectValue.origin.y < endKeyboardValue.CGRectValue.origin.y ? 1 : -1;
    adjust = keyboardFrameRect.size.height*adjust;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.toolbar.frame = CGRectOffset(self.toolbar.frame, 0, adjust);
    CGRect frame = self.tableView.frame;
    self.tableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + adjust);
    [UIView commitAnimations];
}

-(void)setChatBuddy:(CCCChatBuddy *)chatBuddy
{
    [_chatBuddy release];
    _chatBuddy = [chatBuddy retain];
    self.navigationItem.title = [NSString stringWithFormat:@"Chat with %@...", self.chatBuddy.buddyName];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJinxNotificationCoversationStarted object:self userInfo:
     [NSDictionary dictionaryWithObjectsAndKeys:
      self.chatBuddy, kJinxNotificationKeyChatBuddy, self.chatBuddy.buddyName, kJinxNotificationKeyChatBuddyName, messages, kJinxNotificationKeyMessages,
      nil]];
    [self loadConversationForBuddy:self.chatBuddy.buddyName];
}

- (id)initWithBuddy:(NSString *)aChatBuddy
{
	return [self initWithBuddy:aChatBuddy andMessages:[NSArray array]];
}

- (id)initWithBuddy:(NSString *)aChatBuddy andMessages:(NSArray*)existingMessages
{
	self = [self initWithBuddy:aChatBuddy andNibName:@"CCCChatViewController" bundle:nil];
	if (self != nil) {
		[messages addObjectsFromArray:existingMessages];
	}
	return self;
}


- (id)initWithBuddy:(NSString *)aChatBuddy andNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	self = [self initWithNibName:nibName bundle:nibBundle];
	if (self != nil) {
		self.chatBuddy = [[CCCChatBuddy alloc] initWithBuddy:aChatBuddy loadedFromRepository: [[[CCCBasicChatRepository alloc] init] autorelease] ];
	}
	return self;
}

- (void)addMessage:(NSString*) aNewMessage
{
	NSString *youInitialMessage = [YOU stringByAppendingString:@": ..."];
	NSString *buddyInitialMessage = [self.chatBuddy.buddyName stringByAppendingString:@": ..."];
	if (! [aNewMessage isEqualToString:youInitialMessage] && ! [aNewMessage isEqualToString:buddyInitialMessage])
	{
		DLog(@"Do chime...");
		if ([aNewMessage hasPrefix:YOU]) {
			[CCCSoundServices playClip:outgoingMessageClip];
		}else {
			[CCCSoundServices playClip:incomingMessageClip];
		}
	}
	[messages addObject:aNewMessage];
	//Need to ensure screen update is done on the Main Thread
	[self performSelectorOnMainThread:@selector(onMessagesUpdated) withObject:nil waitUntilDone:NO];
}

-(void) completeTheBuddyReply:(NSString*)aMessageToBuddy
{
	NSString *reply = [self.chatBuddy tellBuddy:aMessageToBuddy];
	[self removeLastMessageFromSpeaker:self.chatBuddy.buddyName];
	[self addMessage:[NSString stringWithFormat:@"%@: %@", self.chatBuddy.buddyName, reply]];
}

-(void) buddyReplyForMessage:(NSString*) aMessageToBuddy
{
	[self addMessage:[NSString stringWithFormat:@"%@: ...", self.chatBuddy.buddyName]];
	[self performSelector:@selector(completeTheBuddyReply:) withObject:aMessageToBuddy afterDelay:1];
}

-(void) sendMessageToBuddy:(NSString*) aMessageToBuddy
{
	if(youWereTypingSomething) {
		youWereTypingSomething = NO;
		[self removeLastMessageFromSpeaker:YOU];
	}
	[self addMessage:[NSString stringWithFormat:@"%@: %@", YOU, aMessageToBuddy]];
	[self performSelector:@selector(buddyReplyForMessage:) withObject:aMessageToBuddy afterDelay:1];
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

- (IBAction)onSendButton:(id)sender
{
	[self textFieldShouldReturn:messageToSend];
}

- (IBAction)onClearButton:(id)sender
{
	[messages removeAllObjects];
	[tableView reloadData];
	[CCCSoundServices playClip:clearScreenClip];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification object:nil];
    UIImageView *customImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phoneicon.png"]] autorelease];
	UIBarButtonItem *callButton = [[[UIBarButtonItem alloc] initWithCustomView:customImageView] autorelease];
    
	callButton.width = 28;
	callButton.action = @selector(onCallButton:);
	self.navigationItem.rightBarButtonItem = callButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification object:self.view.window]; 
    self.tableView.transform = CGAffineTransformMakeRotation(M_PI);
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	[self saveConversation];
	[[NSNotificationCenter defaultCenter] postNotificationName:kJinxNotificationCoversationEnded object:self userInfo:
	 [NSDictionary dictionaryWithObjectsAndKeys:
	  self.chatBuddy, kJinxNotificationKeyChatBuddy, self.chatBuddy.buddyName, kJinxNotificationKeyChatBuddyName, messages, kJinxNotificationKeyMessages,
	  nil]];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return YES;
}

#pragma mark -
#pragma mark Orientation methods

-(void) updateView
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscape)
	{
		isShowingLandscape = YES;
	} else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscape) {
		isShowingLandscape = NO;
	}
}

- (void)orientationChanged:(NSNotification *)notification
{
    // We must add a delay here, otherwise we'll swap in the new view
	// too quickly and we'll get an animation glitch
    [self performSelector:@selector(updateView) withObject:nil afterDelay:0];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	isInEditMode = NO;
	[messageToSend resignFirstResponder];
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
    int messageIndex = messages.count - indexPath.row - 1;
	[self addRawMessage:[messages objectAtIndex:messageIndex] toMessageView:[cell.contentView viewWithTag:kCCCMessageTag]];
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.transform =     self.tableView.transform = CGAffineTransformMakeRotation(M_PI);

    return cell;
}

- (CGRect)chatBubbleSize:(NSString *)body {
    CGRect rect = [body boundingRectWithSize:CGSizeMake(240.0, 480.0) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes: [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:15] forKey: NSFontAttributeName] context:nil];
    return rect;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *body = [messages objectAtIndex:indexPath.row];
    CGRect rect;
    rect = [self chatBubbleSize:body];
	return rect.size.height + 40;
}

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
	label.lineBreakMode = NSLineBreakByWordWrapping;
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
	CGSize size = [self chatBubbleSize:text].size;
	
	UIImage *balloon;
	
	if([[speaker lowercaseString] isEqualToString:@"you"])
	{
		CGFloat widthAdj = isShowingLandscape ? 480.0f - 320.0f : 0;
		balloonView.frame = CGRectMake((320.0f + widthAdj) - (size.width + 28.0f), 2.0f, size.width + 28.0f, size.height + 15.0f);
		balloon = [[UIImage imageNamed:@"green.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
		label.frame = CGRectMake((307.0f + widthAdj) - (size.width + 5.0f), 8.0f, size.width + 5.0f, size.height);
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
	[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void) saveConversation
{
	@try { ensureDirectoryExistsAtPath(JinxArchivePath); }
	@catch (NSException * e) { return; } //Errors are propgated to NSNotificationCenter for application-wide handling, it's safe to return here...
	[NSKeyedArchiver archiveRootObject:messages toFile:JinxArchiveFileForBuddy(self.chatBuddy.buddyName)];
}

-(void) loadConversationForBuddy:(NSString*)aChatBuddy
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:JinxArchiveFileForBuddy(self.chatBuddy.buddyName)]) {
		[messages addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithFile:JinxArchiveFileForBuddy(self.chatBuddy.buddyName)]];
	}
}
-(void)onCallButton:(id)sender
{
	[self.navigationController pushViewController: [[CCCCallScreen alloc] initWithBuddy:self.chatBuddy.buddyName] animated:YES];
	if (isShowingLandscape && [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
		self.navigationController.visibleViewController.view.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
	} else if(isShowingLandscape && [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
		self.navigationController.visibleViewController.view.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
	}
}

#pragma mark -
#pragma mark UITextField delegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	
	if (! youWereTypingSomething && [textField.text isEqualToString:@""]) {
		[self addMessage:[NSString stringWithFormat:@"%@: ...", YOU]];
		youWereTypingSomething = YES;
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	[self sendMessageToBuddy:textField.text];
	textField.text = @"";
	return YES;
}

- (void)keyboardWillShow:(NSNotification *)notif {
	isInEditMode = YES;
	
	if([messages count] > 0)
	{
		[self performSelectorOnMainThread:@selector(onMessagesUpdated) withObject:nil waitUntilDone:NO];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[self saveConversation];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[tableView release];
	[messageToSend release];
	[messages release];
	[toolbar release];
	[_chatBuddy release];
    [super dealloc];
}


@end

