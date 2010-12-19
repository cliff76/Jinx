//
//  RootViewController.m
//  Jinx
//
//  Created by Clifton Craig on 12/11/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import "RootViewController.h"
#import "CCCJinxAppLoadLogic.h"
#import "CCCChatViewController.h"
#import "CCCBuddySelectorCell.h"
#import "JinxApplicationGlobal.h"

@implementation RootViewController
@synthesize buddyList, backgroundImage, backgroundImageLandscape;

#pragma mark -
#pragma mark Orientation Methods

-(void) updateView
{
	CGFloat rotation = 0.0f;
	BOOL isLandscape = NO;
	switch ([UIDevice currentDevice].orientation) {
		case UIDeviceOrientationLandscapeLeft:
			rotation = 0.0;
			isLandscape = YES;
			break;
		case UIDeviceOrientationLandscapeRight:
			rotation = 180.0f;
			isLandscape = YES;
			break;
		default:
			break;
	}
	if (isLandscape) {
		[UIView beginAnimations:@"switch-background" context:nil];
		backgroundImage.alpha = 0.0f;
		backgroundImageLandscape.alpha = 1.0f;
		backgroundImageLandscape.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(rotation));
		[UIView commitAnimations];
	} else {
		[UIView beginAnimations:@"switch-background" context:nil];
		backgroundImage.alpha = 1.0f;
		backgroundImageLandscape.alpha = 0.0f;
		if( [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown ) {
			backgroundImage.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-180.0f));
			backgroundImage.frame = CGRectMake(0.0f, 0.0f, 320.0f, 460.0f);
		} else {
			backgroundImage.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0.0f));
			backgroundImage.frame = CGRectMake(0.0f, 20.0f, 320.0f, 460.0f);
		}

		[UIView commitAnimations];
	}
}

- (void)orientationChanged:(NSNotification *)notification
{
    // We must add a delay here, otherwise we'll swap in the new view
	// too quickly and we'll get an animation glitch
    [self performSelector:@selector(updateView) withObject:nil afterDelay:0];
}

#pragma mark -
#pragma mark View lifecycle

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self != nil) {
		CCCJinxAppLoadLogic *appLoadLogic = [[CCCJinxAppLoadLogic alloc] init];
		self.buddyList = appLoadLogic.buddyList;
		self.tableView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90.0f));
		[appLoadLogic release];
	}
	return self;
}

-(void) scrollTo:(NSNumber*)row
{
	[self.tableView reloadData];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[row intValue] inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
//	self.tableView.delegate = nil;
//	[self performSelector:@selector(scrollTo:) withObject:[NSNumber numberWithInt:1] afterDelay:1.0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification object:nil];
	self.tableView.delegate = self;
	[self performSelector:@selector(scrollTo:) withObject:[NSNumber numberWithInt:2] afterDelay:0.0];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return YES;
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.buddyList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSString *buddyName = [self.buddyList objectAtIndex:indexPath.row];
		cell = [[[CCCBuddySelectorCell alloc] initWithIndex:indexPath.row forBuddy:buddyName andStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

    }
    
	// Configure the cell.

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 150.0f;
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
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	CCCChatViewController *detailViewController = [[CCCChatViewController alloc] initWithBuddy:[buddyList objectAtIndex:indexPath.row] 
																					andNibName:@"CCCChatViewController" bundle:nil];
	
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
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
}


- (void)dealloc {
	self.buddyList = nil;
    [super dealloc];
}

@end

