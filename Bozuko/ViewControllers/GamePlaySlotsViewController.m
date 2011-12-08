//
//  GamePlayViewController.m
//  Bozuko
//
//  Created by Tom Corwine on 5/5/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import "GamePlaySlotsViewController.h"
#import "BozukoGame.h"
#import "BozukoPage.h"
#import "BozukoGameState.h"
#import "BozukoHandler.h"
#import "BozukoGameResult.h"
#import "LoadingView.h"
#import "GameTermsViewController.h"
#import "PrizeWrapperViewController.h"
#import "SlotMachineWheel.h"
#import "ImageHandler.h"
#import "GamePrizesView.h"
#import "GameTermsAndConditionsView.h"

#define kSlotMachine_CardAnimationDuration		4.0

#define kAlertView_GameOverTag					234
#define kAlertView_ConsolationPrizeTag			236

@implementation GamePlaySlotsViewController

@synthesize bozukoPage = _bozukoPage;
@synthesize bozukoGame = _bozukoGame;
@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    
	if (self)
	{
		[_animationTimer invalidate];
		_animationTimer = nil;
		
		_closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closeView)];
		_backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonWasPressed)];
    }
    
	return self;
}

- (void)dealloc
{
	[_goodLuckSequence release];
	[_youWonSequence release];
	[_youLoseSequence release];
	[_freeSpinSequence release];
	[_playAgainSequence release];
	
	[_slotItemsArray release];
	[_backButton release];
	[_closeButton release];
	
	[_bozukoGameResult release];
	
	self.delegate = nil;

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
	[_goodLuckSequence release];
	_goodLuckSequence = nil;
	
	[_youWonSequence release];
	_youWonSequence = nil;
	
	[_youLoseSequence release];
	_youLoseSequence = nil;
	
	[_freeSpinSequence release];
	_freeSpinSequence = nil;
	
	[_playAgainSequence release];
	_playAgainSequence = nil;
	 
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSArray *)goodLuckSequence
{
	if (_goodLuckSequence == nil)
	{
		NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
		
		for (int i = 0; i < 60; i++)
		{
			[tmpArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"images/slot/goodLuck/goodLuck_%05d", i]]];
		}
		
		_goodLuckSequence = [[NSArray alloc] initWithArray:tmpArray];
		[tmpArray release];
	}
	
	return _goodLuckSequence;
}

- (NSArray *)youWonSequence
{
	if (_youWonSequence == nil)
	{
		NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
		
		for (int i = 0; i < 53; i++)
		{
			[tmpArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"images/slot/youWin/youWin_%05d", i]]];
		}
		
		_youWonSequence = [[NSArray alloc] initWithArray:tmpArray];
		[tmpArray release];
	}
	
	return _youWonSequence;
}

- (NSArray *)youLoseSequence
{
	if (_youLoseSequence == nil)
	{
		NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
		
		for (int i = 0; i < 58; i++)
		{
			[tmpArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"images/slot/youLose/youLose_%05d", i]]];
		}
		
		_youLoseSequence = [[NSArray alloc] initWithArray:tmpArray];
		[tmpArray release];
	}
	
	return _youLoseSequence;
}

- (NSArray *)playAgainSequence
{
	if (_playAgainSequence == nil)
	{
		NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
		
		for (int i = 0; i < 56; i++)
		{
			[tmpArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"images/slot/playAgain/playAgain_%05d", i]]];
		}
		
		_playAgainSequence = [[NSArray alloc] initWithArray:tmpArray];
		[tmpArray release];
	}
	
	return _playAgainSequence;
}

- (NSArray *)freeSpinSequence
{
	if (_freeSpinSequence == nil)
	{
		NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
		
		for (int i = 0; i < 55; i++)
		{
			[tmpArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"images/slot/freeSpin/freeSpin_%05d", i]]];
		}
		
		_freeSpinSequence = [[NSArray alloc] initWithArray:tmpArray];
		[tmpArray release];
	}
	
	return _freeSpinSequence;
}

#pragma mark Button Actions

- (void)spinWheels
{
	[_animationTimer invalidate];
	_animationTimer = nil;
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	[_wheel1 spin];
	[_wheel2 spin];
	[_wheel3 spin];
	
	_creditsLabel.text = [NSString stringWithFormat:@"%d", [_creditsLabel.text intValue] - 1];
	
	[[BozukoHandler sharedInstance] bozukoGameResultsForGame:_bozukoGame];
	
	_spinButton.enabled = NO;
	_areGameResultsIn = NO;
	
	_bannerImageView.animationImages = [self goodLuckSequence];
	_bannerImageView.animationDuration = 4;
	[_bannerImageView startAnimating];
	
	[self performSelector:@selector(stopWheels) withObject:nil afterDelay:5.0];
	
	_spinTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(closeView) userInfo:nil repeats:NO];
}

- (void)prizesButtonWasPressed
{
	[self.navigationItem performSelector:@selector(setLeftBarButtonItem:) withObject:_backButton afterDelay:1.0];
	
	_detailsView = [[GamePrizesView alloc] initWithGame:_bozukoGame];
	[UIView transitionFromView:self.view toView:_detailsView duration:1.0 options:UIViewAnimationOptionTransitionCurlUp completion:^(BOOL done){}];
	[_detailsView release];
}

- (void)rulesButtonWasPressed
{
	[self.navigationItem performSelector:@selector(setLeftBarButtonItem:) withObject:_backButton afterDelay:1.0];
	
	_detailsView = [[GameTermsAndConditionsView alloc] initWithGame:_bozukoGame];
	[UIView transitionFromView:self.view toView:_detailsView duration:1.0 options:UIViewAnimationOptionTransitionCurlUp completion:^(BOOL done){}];
	[_detailsView release];
}

- (void)backButtonWasPressed
{
	[self.navigationItem performSelector:@selector(setLeftBarButtonItem:) withObject:_closeButton afterDelay:1.0];
	//[self.navigationItem performSelector:@selector(setLeftBarButtonItem:) withObject:nil afterDelay:1.0];
	
	[UIView transitionFromView:_detailsView toView:self.view duration:1.0 options:UIViewAnimationOptionTransitionCurlDown completion:^(BOOL done){}];
}

#pragma mark Helper Methods

- (void)stopWheels
{	
	if (_areGameResultsIn == NO)
	{
		[self performSelector:@selector(stopWheels) withObject:nil afterDelay:1.0];
		
		return;
	}
	
	NSArray *tmpArray = [_bozukoGameResult result];
	
	if ([tmpArray isKindOfClass:[NSArray class]] == YES)
	{
		NSInteger i = 0;
		for (NSDictionary *tmpDictionary in _slotItemsArray)
		{
			NSString *tmpItemName = [tmpDictionary objectForKey:@"name"];
				
			if ([tmpItemName isEqualToString:[tmpArray objectAtIndex:0]] == YES)
				[_wheel1 setStopIndex:i];
			
			if ([tmpItemName isEqualToString:[tmpArray objectAtIndex:1]] == YES)
				[_wheel2 setStopIndex:i];
			
			if ([tmpItemName isEqualToString:[tmpArray objectAtIndex:2]] == YES)
				[_wheel3 setStopIndex:i];
			
			i++;
		}
	}
	
	[_wheel1 stop];
	[self stopWheel2];
	[self stopWheel3];

	[self displayResults];
}

- (void)stopWheel2
{
	if (_wheel1.isSpinning == NO)
		[_wheel2 performSelector:@selector(stop) withObject:nil afterDelay:1.0];
	else
		[self performSelector:@selector(stopWheel2) withObject:nil afterDelay:0.2];
}

- (void)stopWheel3
{
	if (_wheel2.isSpinning == NO)
		[_wheel3 performSelector:@selector(stop) withObject:nil afterDelay:1.0];
	else
		[self performSelector:@selector(stopWheel3) withObject:nil afterDelay:0.2];
}

- (void)displayResults
{
	// Wait until all wheels are done spinning before displaying results
	if (_wheel1.isSpinning == YES || _wheel2.isSpinning == YES || _wheel3.isSpinning == YES)
	{
		[self performSelector:@selector(displayResults) withObject:nil afterDelay:0.2];
		
		return;
	}
	
	[_spinTimeoutTimer invalidate];
	_spinTimeoutTimer = nil;

	[_bannerImageView stopAnimating];
	
	_creditsLabel.text = [NSString stringWithFormat:@"%d", [[_bozukoGame gameState] userTokens]];
	
	if ([_bozukoGameResult freePlay] == YES)
		[self freePlay];
	else if ([_bozukoGameResult win] == YES)
		[self youWin];
	else
		[self youLose];
	
	//if (_viewIsVisible == YES)
	_animationTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(playDoneMessage) userInfo:nil repeats:NO];
	
	// Enable spin button unless this is a winner. Free plays have the win boolean set to true, but those aren't winners.
	if ([[_bozukoGame gameState] buttonEnabled] == YES && [[_bozukoGame gameState] userTokens] > 0 &&
		([_bozukoGameResult win] == NO || ([_bozukoGameResult win] == YES && [_bozukoGameResult freePlay] == YES)))
		_spinButton.enabled = YES;
}

- (void)youWin
{
	_bannerImageView.animationImages = [self youWonSequence];
	_bannerImageView.animationDuration = kSlotMachine_CardAnimationDuration;
	[_bannerImageView startAnimating];
}

- (void)youLose
{
	_bannerImageView.animationImages = [self youLoseSequence];
	_bannerImageView.animationDuration = kSlotMachine_CardAnimationDuration;
	[_bannerImageView startAnimating];
}

- (void)freePlay
{
	_bannerImageView.animationImages = [self freeSpinSequence];
	_bannerImageView.animationDuration = kSlotMachine_CardAnimationDuration;
	[_bannerImageView startAnimating];
	
	[self blinkCreditsLabel];
}

- (void)blinkCreditsLabel
{
	dispatch_queue_t tmpBlinkQueue = dispatch_queue_create("tmpBlinkQueue", NULL);
	
	dispatch_async(tmpBlinkQueue, ^{
		for (int i = 0; i < 10; i++)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				_creditsLabel.hidden = YES;
			});
			
			[NSThread sleepForTimeInterval:0.1];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				_creditsLabel.hidden = NO;
			});
			
			[NSThread sleepForTimeInterval:0.1];
		}
	});
	
	dispatch_release(tmpBlinkQueue);
}

- (void)playDoneMessage
{
	_animationTimer = nil;
	
	if ([_bozukoGameResult freePlay] == NO && [_bozukoGameResult win] == YES)
	{
		PrizeWrapperViewController *tmpViewController = [[PrizeWrapperViewController alloc] initWithBozukoPrize:[_bozukoGameResult prize]];
		tmpViewController.delegate = self;
		self.navigationItem.hidesBackButton = YES;
		[self.navigationController pushViewController:tmpViewController animated:YES];
		DLog(@"Push");
		[tmpViewController release];
		
		[_bannerImageView stopAnimating];
		_bannerImageView.animationImages = nil;
	}
	else if ([_bozukoGameResult freePlay] == NO && [_bozukoGameResult consolation] == YES)
	{
		UIAlertView *tmpAlertView = [[UIAlertView alloc] initWithTitle:@"No More Plays"
															   message:[_bozukoGameResult message]
															  delegate:self
													 cancelButtonTitle:@"OK"
													 otherButtonTitles:nil];
		
		tmpAlertView.tag = kAlertView_ConsolationPrizeTag;
		[tmpAlertView show];
		[tmpAlertView release];
		
		[_bannerImageView stopAnimating];
		_bannerImageView.animationImages = nil;
	}
	else if ([[_bozukoGame gameState] buttonEnabled] == YES && [[_bozukoGame gameState] userTokens] > 0)
	{
		_spinButton.enabled = YES;
		
		_bannerImageView.animationImages = [self playAgainSequence];
		_bannerImageView.animationDuration = kSlotMachine_CardAnimationDuration;
		[_bannerImageView startAnimating];
	}
	else
	{
		_spinButton.enabled = NO;
		
		[_bannerImageView stopAnimating];
		_bannerImageView.animationImages = nil;
		
		UIAlertView *tmpAlertView = [[UIAlertView alloc] initWithTitle:@"No More Plays"
															   message:@"Please come back later."
															  delegate:self
													 cancelButtonTitle:@"OK"
													 otherButtonTitles:nil];
		
		tmpAlertView.tag = kAlertView_GameOverTag;
		[tmpAlertView show];
		[tmpAlertView release];
	}
	
	self.navigationItem.leftBarButtonItem.enabled = YES;
}

#pragma mark UIAlertView Delegates

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == kAlertView_GameOverTag)
	{
		if ([_delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] == YES)
			[_delegate dismissModalViewControllerAnimated:YES];
		
		_delegate = nil;
	}
	else if (alertView.tag == kAlertView_ConsolationPrizeTag)
	{
		PrizeWrapperViewController *tmpViewController = [[PrizeWrapperViewController alloc] initWithBozukoPrize:[_bozukoGameResult prize]];
		tmpViewController.delegate = self;
		self.navigationItem.hidesBackButton = YES;
		[self.navigationController pushViewController:tmpViewController animated:YES];
		DLog(@"Push");
		[tmpViewController release];
	}
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
	self.navigationItem.title = [_bozukoGame name];
	
	_wheel1 = [[SlotMachineWheel alloc] initWithOrigin:CGPointMake(17.0, 54.0)];
	_wheel2 = [[SlotMachineWheel alloc] initWithOrigin:CGPointMake(115.0, 54.0)];
	_wheel3 = [[SlotMachineWheel alloc] initWithOrigin:CGPointMake(213.0, 54.0)];
	
	[self.view addSubview:_wheel1];
	[self.view addSubview:_wheel2];
	[self.view addSubview:_wheel3];
	
	[_wheel1 release];
	[_wheel2 release];
	[_wheel3 release];
	
	UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 415.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/slotFrame"];
	[self.view addSubview:tmpImageView];
	[tmpImageView release];
	
	_creditsLabel = [[UILabel alloc] initWithFrame:CGRectMake(252.0, 230.0, 60.0, 60.0)];
	_creditsLabel.backgroundColor = [UIColor clearColor];
	_creditsLabel.textColor = [UIColor redColor];
	_creditsLabel.font = [UIFont boldSystemFontOfSize:40.0];
	_creditsLabel.minimumFontSize = 20.0;
	_creditsLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:_creditsLabel];
	[_creditsLabel release];
	
	tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 233.0,144.0, 144.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/photoDefaultLarge"];
	[self.view addSubview:tmpImageView];
	[tmpImageView release];
	
	_pageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 235.0, 140.0, 140.0)];
	[self.view addSubview:_pageIcon];
	[_pageIcon release];
	_pageIcon.image = [[ImageHandler sharedInstance] imageForBusiness:_bozukoPage];
	
	_bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 42.0)];
	[self.view addSubview:_bannerImageView];
	[_bannerImageView release];
	
	_spinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_spinButton.frame = CGRectMake(170.0, 300.0, 137.0, 90.0);
	_spinButton.enabled = NO;
	[_spinButton setImage:[UIImage imageNamed:@"images/slotSpinBtn"] forState:UIControlStateNormal];
	[_spinButton setImage:[UIImage imageNamed:@"images/slotSpinBtnPress"] forState:UIControlStateHighlighted];
	[_spinButton addTarget:self action:@selector(spinWheels) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_spinButton];
	
	// Prizes link
	UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 390.0, 35.0, 20.0)];
	tmpLabel.backgroundColor = [UIColor clearColor];
	tmpLabel.textColor = [UIColor whiteColor];
	tmpLabel.font = [UIFont systemFontOfSize:12.0];
	tmpLabel.text = @"Prizes";
	[self.view addSubview:tmpLabel];
	[tmpLabel release];
	
	// Underline
	UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 407.0, 33.0, 1.0)];
	tmpView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:tmpView];
	[tmpView release];
	
	UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
	tmpButton.frame = CGRectMake(10.0, 390.0, 50.0, 20.0);
	[tmpButton addTarget:self action:@selector(prizesButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:tmpButton];
	
	// Rules link
	tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(240.0, 390.0, 75.0, 20.0)];
	tmpLabel.backgroundColor = [UIColor clearColor];
	tmpLabel.textColor = [UIColor whiteColor];
	tmpLabel.font = [UIFont systemFontOfSize:12.0];
	tmpLabel.text = @"Official Rules";
	[self.view addSubview:tmpLabel];
	[tmpLabel release];
	
	// Underline
	tmpView = [[UIView alloc] initWithFrame:CGRectMake(240.0, 407.0, 73.0, 1.0)];
	tmpView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:tmpView];
	[tmpView release];
	
	tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
	tmpButton.frame = CGRectMake(240.0, 390.0, 100.0, 20.0);
	[tmpButton addTarget:self action:@selector(rulesButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:tmpButton];
	
	_loadingOverlay = [[LoadingView alloc] init];
	[self.view addSubview:_loadingOverlay];
	[_loadingOverlay release];
	
	// Load game config
	NSDictionary *tmpDictionary = [[_bozukoGame config] objectForKey:@"theme"];
	
	NSDictionary *tmpIconDictionary = nil;
	NSString *tmpURLBase = nil;
	if ([tmpDictionary isKindOfClass:[NSDictionary class]] == YES)
	{
		tmpURLBase = [[[_bozukoGame config] objectForKey:@"theme"] objectForKey:@"base"];
		tmpIconDictionary = [[[_bozukoGame config] objectForKey:@"theme"] objectForKey:@"icons"];
	}

	if ([tmpIconDictionary isKindOfClass:[NSDictionary class]] == YES)
	{
		NSMutableArray *tmpMutableArray = [[NSMutableArray alloc] init];
		
		for (NSString *tmpIconName in [tmpIconDictionary allKeys])
		{
			NSMutableDictionary *tmpMutableDictionary = [[NSMutableDictionary alloc] init];
			[tmpMutableDictionary setObject:tmpIconName forKey:@"name"];
			
			// Store image URL
			if ([tmpIconDictionary objectForKey:tmpIconName] != nil)
			{
				NSString *tmpIconURL = nil;
				NSString *tmpIconPath = [tmpIconDictionary objectForKey:tmpIconName];
				
				if ([tmpIconPath hasPrefix:@"https://"] == YES || [tmpIconPath hasPrefix:@"http://"] == YES) // If this is an absolute URL, don't append "base" to the beginning.
					tmpIconURL = tmpIconPath;
				else if ([tmpURLBase isKindOfClass:[NSString class]] == YES)
					tmpIconURL = [NSString stringWithFormat:@"%@/%@", tmpURLBase, tmpIconPath];

				[tmpMutableDictionary setObject:tmpIconURL forKey:@"url"];

				// Set image if it's in cache
				UIImage *tmpImage = [[ImageHandler sharedInstance] permanentCachedImageForURL:tmpIconURL];
				if (tmpImage != nil)
					[tmpMutableDictionary setObject:tmpImage forKey:@"image"];
			}
			
			[tmpMutableArray addObject:tmpMutableDictionary];
			[tmpMutableDictionary release];
		}
		
		[_slotItemsArray release];
		_slotItemsArray = [[NSArray alloc] initWithArray:tmpMutableArray];
		[tmpMutableArray release];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameEntryDidFinish:) name:kBozukoHandler_GameEntryDidFinish object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameEntryDidFail:) name:kBozukoHandler_GameEntryDidFail object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResultsDidFinish:) name:kBozukoHandler_GameResultsDidFinish object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResultsDidFail:) name:kBozukoHandler_GameResultsDidFail object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBusinessIcon:) name:kBozukoHandler_PageImageWasUpdated object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iconImageWasUpdated:) name:kImageHandler_ImageWasUpdatedNotification object:nil];
	
	if ([[[_bozukoGame gameState] buttonAction] isEqualToString:@"enter"] == YES)
		[[BozukoHandler sharedInstance] bozukoEnterGame:_bozukoGame];
	else
		[self startGame];
	
	_viewIsVisible = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationItem.leftBarButtonItem = _closeButton;
	//self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_goodLuckSequence release];
	[_youWonSequence release];
	[_youLoseSequence release];
	[_freeSpinSequence release];
	[_playAgainSequence release];
	
	self.delegate = nil;
	
	[super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)areAllIconsLoaded
{
	for (NSDictionary *tmpDictionary in _slotItemsArray)
	{
		NSArray *tmpArray = [tmpDictionary allKeys];
		BOOL tmpBool = NO;
		
		for (NSString *tmpString in tmpArray)
			if ([tmpString isEqualToString:@"image"] == YES)
				tmpBool = YES;
		
		if (tmpBool == NO)
			return NO;
	}
	
	return YES;
}

- (void)startGame
{
	static NSInteger tmpCount = 0;
	
	if ([self areAllIconsLoaded] == YES)
	{
		//DLog(@"All Icons Loaded");
		NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
		
		for (NSDictionary *tmpDictionary in _slotItemsArray)
			[tmpArray addObject:[tmpDictionary objectForKey:@"image"]];
		
		[_wheel1 setImages:tmpArray];
		[_wheel2 setImages:tmpArray];
		[_wheel3 setImages:tmpArray];
		
		[tmpArray release];
		
		_loadingOverlay.hidden = YES;
		_spinButton.enabled = YES;
		_creditsLabel.text = [NSString stringWithFormat:@"%d", [[_bozukoGame gameState] userTokens]];
	}
	else
	{
		tmpCount++;
		
		if (tmpCount == 60) // If it takes more than 30 seconds for icons to load, abort.
		{
			DLog(@"Icon loading timeout");
			if ([_delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] == YES)
				[_delegate dismissModalViewControllerAnimated:YES];
			
			_delegate = nil;
		}
		else
			[self performSelector:@selector(startGame) withObject:nil afterDelay:0.5];
	}
}

#pragma mark - BozukoHandler Notification Methods

- (void)gameEntryDidFinish:(NSNotification *)inNotification
{
	//DLog(@"%@", _bozukoGame);
	//DLog(@"%@", [inNotification description]);
	
	if ([[inNotification object] isKindOfClass:[BozukoGameState class]] == YES)
	{
		if ([_bozukoGame.gameID isEqualToString:[[inNotification object] gameID]] == NO)
			return;
		
		[_bozukoGame setGameState:[inNotification object]];
		
		[self startGame];
	}
	else
	{
		DLog(@"This is NOT a valid entry");
		if ([_delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] == YES)
			[_delegate dismissModalViewControllerAnimated:YES];
		
		_delegate = nil;
	}
}

- (void)gameEntryDidFail:(NSNotification *)inNotification
{
	DLog(@"Game entry fail");
	_loadingOverlay.hidden = YES;
	
	if ([_delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] == YES)
		[_delegate dismissModalViewControllerAnimated:YES];
	
	_delegate = nil;
}

- (void)gameResultsDidFinish:(NSNotification *)inNotification
{
	//DLog(@"%@", _bozukoGame);
	//DLog(@"%@", [inNotification description]);
	
	if ([[inNotification object] isKindOfClass:[BozukoGameResult class]] == YES)
	{
		//DLog(@"%@", _bozukoGame.gameID);
		//DLog(@"%@", [[inNotification object] gameID]);
		if ([_bozukoGame.gameID isEqualToString:[[inNotification object] gameID]] == NO)
			return;
		
		//DLog(@"This is a valid result");
		[_bozukoGameResult release];
		_bozukoGameResult = [[inNotification object] retain];
		
		//DLog(@"%@", [_bozukoGameResult description]);
		
		[_bozukoGame setGameState:[_bozukoGameResult gameState]];
		
		//_creditsLabel.text = [NSString stringWithFormat:@"%d", [[_bozukoGame gameState] userTokens]];

		_areGameResultsIn = YES;
		
		if ([_delegate respondsToSelector:@selector(updateView)] == YES)
			[_delegate updateView];
	}
	else
	{
		//DLog(@"This is NOT a valid result");
		if ([_delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] == YES)
			[_delegate dismissModalViewControllerAnimated:YES];
		
		_delegate = nil;
	}
}

- (void)gameResultsDidFail:(NSNotification *)inNotification
{
	DLog(@"Game results fail");
	if ([_delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] == YES)
		[_delegate dismissModalViewControllerAnimated:YES];
	
	_delegate = nil;
}

- (void)updateBusinessIcon:(NSNotification *)inNotification
{
	if ([inNotification object] == _bozukoPage)
	{
		_pageIcon.image = [[ImageHandler sharedInstance] imageForBusiness:_bozukoPage];
	}
}

#pragma mark PrizeView Delegate

- (void)closeView
{
	//DLog(@"%@", [_bozukoGame gameState]);
	[_animationTimer invalidate];
	_animationTimer = nil;
	_spinTimeoutTimer = nil;
	_viewIsVisible = NO;
	
	if ([[_bozukoGame gameState] userTokens] > 0 && self.navigationController.topViewController != self)
	{
		[self.navigationController popToRootViewControllerAnimated:YES];
		
		if ([[_bozukoGame gameState] buttonEnabled] == YES)
		{
			_spinButton.enabled = YES;
			
			_bannerImageView.animationImages = [self playAgainSequence];
			_bannerImageView.animationDuration = kSlotMachine_CardAnimationDuration;
			[_bannerImageView startAnimating];
		}
		else
		{
			_spinButton.enabled = NO;
			
			[_bannerImageView stopAnimating];
			_bannerImageView.animationImages = nil;
		}
	}
	else
	{
		if ([_delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] == YES)
			[_delegate dismissModalViewControllerAnimated:YES];
		else
			[self dismissModalViewControllerAnimated:YES];
	
		_delegate = nil;
	}
}

#pragma mark - ImageHandler Notification Methods

- (void)iconImageWasUpdated:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[NSString class]] == NO)
		return;
	
	for (NSMutableDictionary *tmpDictionary in _slotItemsArray)
	{
		if ([[inNotification object] isEqualToString:[tmpDictionary objectForKey:@"url"]] == YES)
		{
			UIImage *tmpImage = [[ImageHandler sharedInstance] permanentCachedImageForURL:[inNotification object]];
			
			if (tmpImage != nil)
				[tmpDictionary setObject:tmpImage forKey:@"image"];
			
			break;
		}
	}
}

@end
