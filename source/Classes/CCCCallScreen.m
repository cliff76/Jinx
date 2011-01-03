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
#import "BackgroundRotation.h"
#import "JinxMath.h"

@interface CCCCallScreen (PrivateMethods)

-(void) stopPhoneCall;
-(AVCaptureDevice*) backFacingCamera;
-(AVCaptureDevice*) frontFacingCamera;
-(AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position;
-(void) startVideoCapture:(UIView*)theVideoPreview;
-(void) stopVideoCapture;

@end

@implementation CCCCallScreen
@synthesize backgroundImage, backgroundImageLandscape, youAvatar, youLabel, buddyAvatar, buddyLabel;

static int lastReply = 0;
- (id) initWithBuddy:(NSString*)aChatBuddy
{
	self = [super init];
	if (self != nil) {
		chatBuddy = [aChatBuddy retain];
#if TARGET_IPHONE_SIMULATOR
		int nextReply = (++lastReply < 7) ? lastReply : 0;
#else
		int nextReply = (arc4random() % 7);
		while (nextReply == lastReply) {
			nextReply = (arc4random() % 7);
		}
#endif
		lastReply = nextReply;
		audioPlayList = [[NSMutableArray alloc] initWithObjects:
						 @"ringout", @"wav",
						 @"ringout", @"wav",
						 @"ringout", @"wav",
						 [NSString stringWithFormat:@"%@Call%i", chatBuddy,nextReply], @"aiff",
						 nil];
	}
	return self;
}

#pragma mark -
#pragma mark Orientation Methods
-(void) layoutViewComponentsPortrait
{
	CGFloat angle = ([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) ? 180.0f : 0;
	if (([UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown)) {
		youAvatar.frame = CGRectMake(144, 95, 125, 125);
//		youAvatar.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		youLabel.frame = CGRectMake(24, 170, 76, 37);
		youLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		buddyAvatar.frame = CGRectMake(52, 242, 100, 100);
		buddyAvatar.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		buddyLabel.frame = CGRectMake(200, 300, 76, 47);
		buddyLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
	} else {
		youAvatar.frame = CGRectMake(169, 139, 100, 100);
//		youAvatar.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		youLabel.frame = CGRectMake(40, 139, 76, 37);
		youLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		buddyAvatar.frame = CGRectMake(50, 264, 125, 125);
		buddyAvatar.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		buddyLabel.frame = CGRectMake(219, 264, 76, 47);
		buddyLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
	}
}

-(void) layoutViewComponentsLandscape
{
	CGFloat angle = ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) ? 90.0f : -90.0f;
	if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
		youAvatar.frame = CGRectMake(147, 108, 90, 90);
//		youAvatar.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		youLabel.frame = CGRectMake(54, 108, 76, 37);
		youLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		buddyAvatar.frame = CGRectMake(25, 254, 100, 100);
		buddyAvatar.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		buddyLabel.frame = CGRectMake(175, 300, 76, 37);
		buddyLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
	}else {
		youAvatar.frame = CGRectMake(200, 108, 90, 90);
//		youAvatar.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		youLabel.frame = CGRectMake(72, 125, 76, 37);
		youLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		buddyAvatar.frame = CGRectMake(80, 264, 95, 95);
		buddyAvatar.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		buddyLabel.frame = CGRectMake(195, 320, 76, 37);
		buddyLabel.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
		
	}
}

-(void) updateView
{
	self.view.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
	self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	if (([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) || ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)) {
		youLabel.text = chatBuddy;
		buddyLabel.text = @"You";
	}
	else {
		youLabel.text = @"You";
		buddyLabel.text = chatBuddy;
	}
	
	[[[[BackgroundRotation alloc] initWithBackgroundsForPortrait:backgroundImage andLandscape:backgroundImageLandscape] autorelease] 
	 updateViewsWithPortraitAnimations:^(void){
		 [self layoutViewComponentsPortrait];
	 } 
	 andLandscapeAnimations:^(void){
		 [self layoutViewComponentsLandscape];
	 } ];
}

- (void)orientationChanged:(NSNotification *)notification
{
    // We must add a delay here, otherwise we'll swap in the new view
	// too quickly and we'll get an animation glitch
    [self performSelector:@selector(updateView) withObject:nil afterDelay:0];
}

#pragma mark -
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
#define ImageAvatarNameForBuddy(buddyName) ([NSString stringWithFormat:@"%@Avatar.png", buddyName])

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.buddyLabel.text = chatBuddy;
	buddyAvatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ImageAvatarNameForBuddy(chatBuddy)]];
	[self layoutViewComponentsPortrait];
	[self.view addSubview:buddyAvatar];
	[buddyAvatar release];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification object:nil];
	[self startVideoCapture:youAvatar];
	[self playNextFromPlaylist];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self stopPhoneCall];
}

- (void)viewDidDisappear:(BOOL)animated {
	[self stopVideoCapture];
 [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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
{
}

-(void) playbackIsStoppingForPlayer:(CCCAudioPlayer*)audioPlayer
{
}

-(void) playbackIsStartingForPlayer:(CCCAudioPlayer*)audioPlayer
{
}

-(void) playbackDidStopForPlayer:(CCCAudioPlayer*)audioPlayer;
{
	self.navigationController.navigationItem.leftBarButtonItem.enabled = NO;
	if ([audioPlayList count] > 0) {
		[self performSelector:@selector(playNextFromPlaylist) withObject:nil afterDelay:1.5];
	} else if(self.navigationController.visibleViewController == self) {
		[self.navigationController popViewControllerAnimated:YES];
	}

}

#pragma mark -
#pragma mark Video management logic
-(void) startVideoCapture:(UIView*)theVideoPreview
{
	NSLog(@"Go Video!");
	CALayer *previewLayer = theVideoPreview.layer;
	NSLog(@"Preview on view layer %@", previewLayer);
	captureSession = [[AVCaptureSession alloc] init];
	videoCaptureDevice = [self frontFacingCamera];
	error = nil;
	videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
	
	[captureSession beginConfiguration];
	[captureSession removeInput:videoInput];
	if (videoInput && [captureSession canAddInput:videoInput]) {
		NSLog(@"Adding video input to session.");
		[captureSession addInput:videoInput];
	}
	else {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Video Error" message:@"Could not start video session." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
	[captureSession commitConfiguration];
	
	AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	[captureSession addOutput:videoOutput];
	[videoOutput release];
	NSLog(@"Recording started.");
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
	captureVideoPreviewLayer.frame = [previewLayer bounds];
	[captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	NSLog(@"Preview on adding layer %@", captureVideoPreviewLayer);
	[previewLayer addSublayer:captureVideoPreviewLayer];
	[captureSession startRunning];
}

-(void) stopVideoCapture
{
	[captureSession stopRunning];
	[captureSession release];
	captureSession = nil;
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

-(AVCaptureDevice*) backFacingCamera
{
	return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

-(AVCaptureDevice*) frontFacingCamera
{
	return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

@end
