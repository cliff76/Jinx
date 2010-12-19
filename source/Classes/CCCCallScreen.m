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

@interface CCCCallScreen (PrivateMethods)

-(void) stopPhoneCall;

@end

@implementation CCCCallScreen

- (id) initWithBuddy:(NSString*)aChatBuddy
{
	self = [super init];
	if (self != nil) {
		chatBuddy = [aChatBuddy retain];
		audioPlayList = [[NSMutableArray alloc] initWithObjects:
						 @"ringout", @"wav",
						 @"ringout", @"wav",
						 @"ringout", @"wav",
						 [NSString stringWithFormat:@"%@Call", chatBuddy], @"aiff",
						 nil];
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

-(void) playNextFromPlaylist
{
	if (cancel) {
		return;
	}
	NSString *nextAudio = [audioPlayList objectAtIndex:0];
	NSString *nextAudioType = [audioPlayList objectAtIndex:1];
	NSString *nextAudioFile = [[NSBundle bundleForClass:[CCCCallScreen class]] pathForResource:nextAudio ofType:nextAudioType];
	[audioPlayList removeObjectAtIndex:0];
	[audioPlayList removeObjectAtIndex:0];
	DLog(@"Playing file %@...", nextAudioFile);
	[player release];
	player = [[CCCAudioPlayer alloc] initWithSource:
			  [[[CCCAudioFileReader alloc] initWithFile:nextAudioFile] autorelease]
			  ];
	player.delegate = self;
	[player startPlayback];
}

-(void) stopPhoneCall
{
	cancel = YES;
	[player stopPlaybackImmediately];
	[player release];
	player = nil;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [super viewDidLoad];
	[self playNextFromPlaylist];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self stopPhoneCall];
}

- (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
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
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[chatBuddy release];
	[audioPlayList release];
	[player release];
    [super dealloc];
}

#pragma mark -
#pragma mark CCCAudioPlaybackDelegate methods
-(void) playbackStateDidChangeForPlayer:(CCCAudioPlayer*)audioPlayer
{}

-(void) playbackIsStoppingForPlayer:(CCCAudioPlayer*)audioPlayer
{
}

-(void) playbackIsStartingForPlayer:(CCCAudioPlayer*)audioPlayer
{
}

-(void) playbackDidStopForPlayer:(CCCAudioPlayer*)audioPlayer;
{
	if ([audioPlayList count] > 0) {
		[self performSelector:@selector(playNextFromPlaylist) withObject:nil afterDelay:1.5];
	}
}

@end
