//
//  CCCCallScreen.m
//  Jinx
//
//  Created by Clifton Craig on 12/17/10.
//  Copyright 2010 Craig Corp. All rights reserved.
//

#import "CCCCallScreen.h"
#import "CCCAudioPlayer.h"
#import "CCCAudioFileReader.h"

@implementation CCCCallScreen

- (id) initWithBuddy:(NSString*)aChatBuddy
{
	self = [super init];
	if (self != nil) {
		chatBuddy = [aChatBuddy retain];
	}
	return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSString *ring = [[NSBundle bundleForClass:[CCCCallScreen class]] pathForResource:@"ringout" ofType:@"wav"];
	player = [[CCCAudioPlayer alloc] initWithSource:
			  [[[CCCAudioFileReader alloc] initWithFile:ring] autorelease]
			  ];
	[player startPlayback];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[chatBuddy release];
    [super dealloc];
}


@end
