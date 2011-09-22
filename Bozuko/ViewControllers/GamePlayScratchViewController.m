    //
//  GamePlayScratchViewController.m
//  Bozuko
//
//  Created by Joseph Hankin on 5/10/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import "GamePlayScratchViewController.h"
#import "BozukoGame.h"
#import "BozukoPage.h"
#import "BozukoHandler.h"
#import "UserHandler.h"
#import "BozukoGameState.h"
#import "LoadingView.h"
#import "BozukoGameResult.h"
#import "GameScratchButton.h"
#import "ImageHandler.h"
#import "PrizeWrapperViewController.h"
#import "GamePrizesView.h"
#import "GameTermsAndConditionsView.h"

#define kScratchButton_DoesNotCount			0
#define kScratchButton_Counts				1
#define kScratchButton_Scratched			2

#define kAlertView_GameOverTag					434
#define kAlertView_ConsolationPrizeTag			436

#define kScratchTicketCard_AnimationDuration	3.0

#define degreesToRadian(x) (M_PI * (x) / 180.0)

@implementation GamePlayScratchViewController

@synthesize bozukoPage = _bozukoPage;
@synthesize bozukoGame = _bozukoGame;
@synthesize delegate = _delegate;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[_backgroundImageURL release];
	[_closeButton release];
	[_backButton release];
	[_tapRecognizer release];
	
	[_bozukoGameResult release];
	
	self.delegate = nil;
	
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
	if (self)
	{
		_closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissModalViewControllerAnimated:)];
		_backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonWasPressed)];
    }
    
	return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (UIImage *)scratchBackgroundImage
{
	if (_backgroundImageURL == nil)
	{
		id tmpConfigObject = [_bozukoGame config];
		if ([tmpConfigObject isKindOfClass:[NSDictionary class]] == NO)
			return nil;
		
		id tmpThemeObject = [tmpConfigObject objectForKey:@"theme"];
		if ([tmpThemeObject isKindOfClass:[NSDictionary class]] == NO)
			return nil;
		
		id tmpImagesObject = [tmpThemeObject objectForKey:@"images"];
		if ([tmpImagesObject isKindOfClass:[NSDictionary class]] == NO)
			return nil;
		
		NSString *tmpBackgroundString = [tmpImagesObject objectForKey:@"background"];
		
		if ([UIScreen mainScreen].scale == 2.0)
			_backgroundImageURL = [[NSString stringWithFormat:@"%@2x/%@", [tmpThemeObject objectForKey:@"base"], tmpBackgroundString] retain];
		else
			_backgroundImageURL = [[NSString stringWithFormat:@"%@/%@", [tmpThemeObject objectForKey:@"base"], tmpBackgroundString] retain];
	}
	
	//DLog(@"Background URL: %@", _backgroundImageURL);
	
	return [[ImageHandler sharedInstance] permanentCachedImageForURL:_backgroundImageURL];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = [_bozukoGame name];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	_scratchTicketPositions = 0;
	
	_tapRecognizer = [[UITapGestureRecognizer alloc] init];
	[_tapRecognizer addTarget:self action:@selector(userDidTapScreen)];
	
	UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, 6.0, 81.0, 81.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/photoDefaultLarge"];
	tmpImageView.transform = CGAffineTransformMakeRotation(degreesToRadian(-15.0));
	[self.view addSubview:tmpImageView];
	[tmpImageView release];
	
	_pageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 8.0, 77.0, 77.0)];
	_pageIcon.transform = CGAffineTransformMakeRotation(degreesToRadian(-15.0));
	[self.view addSubview:_pageIcon];
	[_pageIcon release];
	_pageIcon.image = [[ImageHandler sharedInstance] imageForBusiness:_bozukoPage];
	
	_backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 415.0)];
	[self.view addSubview:_backgroundView];
	[_backgroundView release];
	
	UIImage *tmpImage = [self scratchBackgroundImage];
	if (tmpImage == nil)
		_isBackgroundLoaded = NO;
	else
	{
		_backgroundView.image = tmpImage;
		_isBackgroundLoaded = YES;
	}
	
	_scratchableView = [[UIView alloc] initWithFrame:CGRectMake(25, 125, 275, 230)];
	_scratchableView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_scratchableView];
	[_scratchableView release];
	
	NSMutableSet *tmpButtonSet = [[NSMutableSet alloc] init];
	
	for (int i = 0; i < NUMBER_OF_SCRATCH_AREAS; i++)
	{
		int tmpRow = (int)(i / (NUMBER_OF_SCRATCH_AREAS / 2));
		
		GameScratchButton *tmpButton = [[GameScratchButton alloc] initWithOrigin:CGPointMake((i % (NUMBER_OF_SCRATCH_AREAS / 2)) * (275 / 3 + 1), tmpRow * (230 / 2))];
		//[tmpButton setTag:TAG_OFFSET + i];
		tmpButton.scratchTicketPosition = (int)pow(2, i + 1); // Set bitmask for button position
		[tmpButton addTarget:self action:@selector(scratchButtonPress:) forControlEvents:UIControlEventTouchUpInside];
		[tmpButtonSet addObject:tmpButton];
		
		// Set each button's number and subtitle here (or any time hereafter, using the _button array).
		//[tmpButton setNumber:[NSString stringWithFormat:@"%d", i]];
		//[tmpButton setLabelText:@"Appetizer"];
		
		[_scratchableView addSubview:tmpButton];
		_button[i] = tmpButton;
		[tmpButton release];
	}
	
	_creditsLabel = [[UILabel alloc] initWithFrame:CGRectMake(102.0, 4.0, 40.0, 40.0)];
	_creditsLabel.backgroundColor = [UIColor clearColor];
	_creditsLabel.textColor = [UIColor whiteColor];
	_creditsLabel.font = [UIFont boldSystemFontOfSize:20.0];
	_creditsLabel.minimumFontSize = 10.0;
	_creditsLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:_creditsLabel];
	[_creditsLabel release]; 
	
	_cardBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 40.0, 320.0, 320.0)];
	[self.view addSubview:_cardBackgroundImageView];
	_cardBackgroundImageView.hidden = YES;
	[_cardBackgroundImageView release];
	
	_cardStarsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 40.0, 320.0, 320.0)];
	[self.view addSubview:_cardStarsImageView];
	_cardStarsImageView.hidden = YES;
	[_cardStarsImageView release];
	
	_cardTextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 40.0, 320.0, 320.0)];
	[self.view addSubview:_cardTextImageView];
	_cardTextImageView.hidden = YES;
	_cardTextImageView.userInteractionEnabled = YES;
	[_cardTextImageView release];
	
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundImageWasUpdated:) name:kImageHandler_ImageWasUpdatedNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameEntryDidFinish:) name:kBozukoHandler_GameEntryDidFinish object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameEntryDidFail:) name:kBozukoHandler_GameEntryDidFail object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResultsDidFinish:) name:kBozukoHandler_GameResultsDidFinish object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResultsDidFail:) name:kBozukoHandler_GameResultsDidFail object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBusinessIcon:) name:kBozukoHandler_PageImageWasUpdated object:nil];
	
	_areGameResultsIn = NO;
	
	BozukoGameResult *tmpBozukoGameResult = [BozukoGameResult loadObjectFromDiskForPageID:[_bozukoGame gameID]];
	
	if (tmpBozukoGameResult != nil) // See if there is a game saved to disk from a previous play
	{
		//DLog(@"Restored");
		
		if ([[tmpBozukoGameResult prize] isKindOfClass:[BozukoPrize class]] == YES &&
			[[UserHandler sharedInstance] doesPrizeExistForPrizeID:[[tmpBozukoGameResult prize] prizeID]] == YES)
		{
			//DLog(@"Prize exists - Skipping");
			[tmpBozukoGameResult deleteObjectFromDisk];
			[self enterGame];
		}
		else
		{
			[self setGameResult:tmpBozukoGameResult];
			_creditsLabel.text = [NSString stringWithFormat:@"%d", [[_bozukoGame gameState] userTokens] + 1]; // Add an extra token because we have a game saved
		
			_scratchTicketPositions = [_bozukoGameResult scratchedAreas];
		
			for (GameScratchButton *tmpButton in tmpButtonSet)
			{
				// Restore button to scratched state if it was previsouly scratched
				if (_scratchTicketPositions & tmpButton.scratchTicketPosition)
				{
					if (tmpButton.tag == kScratchButton_Counts)
						_scratchTotal--;
				
					tmpButton.tag = kScratchButton_Scratched;
					[tmpButton setScratched];
				}
			}
		}
	}
	else
		[self enterGame];
	
	[tmpButtonSet release];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.delegate = nil;
}

- (void)enterGame
{
	if ([[[_bozukoGame gameState] buttonAction] isEqualToString:@"enter"] == YES)
	{
		//DLog(@"Enter");
		[[BozukoHandler sharedInstance] bozukoEnterGame:_bozukoGame];
	}
	else
	{
		//DLog(@"Play");
		_creditsLabel.text = [NSString stringWithFormat:@"%d", [[_bozukoGame gameState] userTokens]];
		[[BozukoHandler sharedInstance] bozukoGameResultsForGame:_bozukoGame];
	}
}

- (void)scratchButtonPress:(GameScratchButton *)sender
{
	if (_scratchTotal == kScratchButton_DoesNotCount || sender.tag == kScratchButton_Scratched)
		return; // Prevent further buttons from being scratched off when ticket wins, or when there are no more plays.
	
	_scratchTicketPositions = (_scratchTicketPositions ^ sender.scratchTicketPosition); // Add ticket position to mask
	
	//DLog(@"%d", _scratchTicketPositions);
	
	if (sender.tag == kScratchButton_Counts)
		_scratchTotal--;
	
	sender.tag = kScratchButton_Scratched;
	
	if (_scratchTotal == 0)
	{
		//DLog(@"Deleted");
		self.navigationItem.leftBarButtonItem.enabled = NO;
		[_bozukoGameResult deleteObjectFromDisk];
		[self performSelector:@selector(allButtonsHaveBeenScratched) withObject:nil afterDelay:1.0];
	}
	else
	{
		//DLog(@"Saved");
		[_bozukoGameResult setScratchedAreas:_scratchTicketPositions];
		[_bozukoGameResult setGameID:[_bozukoGame gameID]];
		[_bozukoGameResult saveObjectToDisk]; // Persist to disk in case user leaves game during play
		//DLog(@"%@", [_bozukoGame gameId]);
	}
	
	[sender animate];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationItem.leftBarButtonItem = _closeButton;
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)allButtonsHaveBeenScratched
{
	_shouldAnimationStop = NO;
	[self playEndingSequence];
	_cardBackgroundImageView.hidden = NO;
	_cardStarsImageView.hidden = NO;
	_cardTextImageView.hidden = NO;
	
	_creditsLabel.text = [NSString stringWithFormat:@"%d", [[_bozukoGame gameState] userTokens]];
	
	//[self performSelector:@selector(resetGame) withObject:nil afterDelay:5.0];
	_animationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(resetGame) userInfo:nil repeats:NO];
}

- (void)playEndingSequence
{	
	[self.view addGestureRecognizer:_tapRecognizer];
	
	if (_cardBackgroundImageView.bounds.size.width == 320.0)
	{
		[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction animations:^{
			_cardBackgroundImageView.frame = CGRectMake(-10.0, 30.0, 340.0, 340.0);
			_cardStarsImageView.frame = CGRectMake(-10.0, 30.0, 340.0, 340.0);
			_cardTextImageView.frame = CGRectMake(0.0, 40.0, 320.0, 320.0);
			
			_cardStarsImageView.transform = CGAffineTransformMakeRotation(degreesToRadian(90.0));
		}
		completion:^(BOOL done){
			if (_shouldAnimationStop == NO)
				[self playEndingSequence];
		}];
	}
	else if (_cardBackgroundImageView.bounds.size.width == 340.0)
	{
		[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction animations:^{
			_cardBackgroundImageView.frame = CGRectMake(0.0, 40.0, 320.0, 320.0);
			_cardStarsImageView.frame = CGRectMake(0.0, 40.0, 320.0, 320.0);
			_cardTextImageView.frame = CGRectMake(-10.0, 30.0, 340.0, 340.0);
			
			_cardStarsImageView.transform = CGAffineTransformMakeRotation(degreesToRadian(180.0));
		}
		completion:^(BOOL done){
			_cardStarsImageView.transform = CGAffineTransformMakeRotation(degreesToRadian(0.0));
			
			if (_shouldAnimationStop == NO)
				[self playEndingSequence];
		}];
	}
}

- (void)stopEndingSequence
{
	_shouldAnimationStop = YES;
}

- (void)userDidTapScreen
{
	[_animationTimer invalidate];
	_animationTimer = nil;
	
	[self resetGame];
}

- (void)resetGame
{
	[self.view removeGestureRecognizer:_tapRecognizer];
	
	self.navigationItem.leftBarButtonItem.enabled = YES;
	
	for (int i = 0; i < NUMBER_OF_SCRATCH_AREAS; i++)
		[_button[i] reset];
	
	[self stopEndingSequence];
	
	_cardBackgroundImageView.hidden = YES;
	_cardStarsImageView.hidden = YES;
	_cardTextImageView.hidden = YES;
	_cardBackgroundImageView.frame = CGRectMake(0.0, 40.0, 320.0, 320.0);
	_cardTextImageView.frame = CGRectMake(0.0, 40.0, 320.0, 320.0);
	
	_areGameResultsIn = NO;
	
	_scratchTicketPositions = 0;
	
	if ([_bozukoGameResult freePlay] == NO && [_bozukoGameResult win] == YES)
	{
		PrizeWrapperViewController *tmpViewController = [[PrizeWrapperViewController alloc] initWithBozukoPrize:[_bozukoGameResult prize]];
		tmpViewController.delegate = self;
		self.navigationItem.hidesBackButton = YES;
		[self.navigationController pushViewController:tmpViewController animated:YES];
		[tmpViewController release];
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
	}
	else if ([[_bozukoGame gameState] userTokens] > 0)
	{
		_loadingOverlay.hidden = NO;
		[[BozukoHandler sharedInstance] bozukoGameResultsForGame:_bozukoGame];
	}
	else
	{
		UIAlertView *tmpAlertView = [[UIAlertView alloc] initWithTitle:@"No More Plays"
															   message:@"Please come back later."
															  delegate:self
													 cancelButtonTitle:@"OK"
													 otherButtonTitles:nil];
		
		tmpAlertView.tag = kAlertView_GameOverTag;
		[tmpAlertView show];
		[tmpAlertView release];
		
//		if ([_delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] == YES)
//			[_delegate dismissModalViewControllerAnimated:YES];
	}
}

#pragma mark Button Actions

- (void)prizesButtonWasPressed
{
	//[self.navigationItem performSelector:@selector(setRightBarButtonItem:) withObject:nil afterDelay:1.0];
	[self.navigationItem performSelector:@selector(setLeftBarButtonItem:) withObject:_backButton afterDelay:1.0];
	
	_detailsView = [[GamePrizesView alloc] initWithGame:_bozukoGame];
	[UIView transitionFromView:self.view toView:_detailsView duration:1.0 options:UIViewAnimationOptionTransitionCurlUp completion:^(BOOL done){}];
	[_detailsView release];
}

- (void)rulesButtonWasPressed
{
	//[self.navigationItem performSelector:@selector(setRightBarButtonItem:) withObject:nil afterDelay:1.0];
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
		[tmpViewController release];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)startGame
{
	static NSInteger tmpCount = 0;
	
	if (_isBackgroundLoaded == YES)
	{
		//DLog(@"Background Loaded");
		_loadingOverlay.hidden = YES;
	}
	else
	{
		tmpCount++;
		
		if (tmpCount == 60) // If it takes more than 30 seconds for background to load, abort.
		{
			DLog(@"Background loading timeout");
			if ([_delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] == YES)
				[_delegate dismissModalViewControllerAnimated:YES];
			
			_delegate = nil;
		}
		else
			[self performSelector:@selector(startGame) withObject:nil afterDelay:0.5];
	}
}

#pragma mark PrizeView Delegate

- (void)closeView
{
	//DLog(@"%@", [_bozukoGame gameState]);
	
	if ([[_bozukoGame gameState] userTokens] > 0)
	{
		[self.navigationController popToRootViewControllerAnimated:YES];
		
		_loadingOverlay.hidden = NO;
		[[BozukoHandler sharedInstance] bozukoGameResultsForGame:_bozukoGame];
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

- (void)backgroundImageWasUpdated:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[NSString class]] == NO)
		return;
	
	if ([[inNotification object] isEqualToString:_backgroundImageURL] == YES)
	{
		UIImage *tmpImage = [self scratchBackgroundImage];
		
		if (tmpImage != nil)
		{
			_backgroundView.image = tmpImage;
			_isBackgroundLoaded = YES;
		}
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
		_creditsLabel.text = [NSString stringWithFormat:@"%d", [[_bozukoGame gameState] userTokens]];
		
		[[BozukoHandler sharedInstance] bozukoGameResultsForGame:_bozukoGame];
	}
	else
	{
		if ([_delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] == YES)
			[_delegate dismissModalViewControllerAnimated:YES];
		
		_delegate = nil;
	}
}

- (void)gameEntryDidFail:(NSNotification *)inNotification
{
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
		
		if ([[inNotification object] code] == 0) // Make sure there's no error message before saving to disk
		{
			//[_bozukoGameResult setGameID:[_bozukoGame gameId]];
			//[_bozukoGameResult saveObjectToDisk]; // Persist to disk in case user leaves game during play
			[self setGameResult:[inNotification object]];
			//DLog(@"%@", [_bozukoGame gameId]);
		}
		else
		{
			if ([_delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] == YES)
				[_delegate dismissModalViewControllerAnimated:YES];
			
			_delegate = nil;
		}
	}
	else
	{
		if ([_delegate respondsToSelector:@selector(dismissModalViewControllerAnimated:)] == YES)
			[_delegate dismissModalViewControllerAnimated:YES];
		
		_delegate = nil;
	}
}

- (void)gameResultsDidFail:(NSNotification *)inNotification
{
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

- (void)setGameResult:(BozukoGameResult *)inBozukoGameResult
{
	[_bozukoGameResult release];
	_bozukoGameResult = [inBozukoGameResult retain];
	
	//DLog(@"GameResult: %@", [_bozukoGameResult description]);
	
	[_bozukoGame setGameState:[_bozukoGameResult gameState]];
	
	if ([[_bozukoGameResult result] isKindOfClass:[NSDictionary class]] == NO)
		return;
	
	NSArray *tmpNumbersArray = [[_bozukoGameResult result] objectForKey:@"numbers"];
	if ([tmpNumbersArray isKindOfClass:[NSArray class]] == NO)
		return;
	
	NSInteger tmpWinningNumber = [[[_bozukoGameResult result] objectForKey:@"winning_number"] intValue];
	
	for (int i = 0; i < NUMBER_OF_SCRATCH_AREAS; i++)
	{
		[_button[i] setNumber:[NSString stringWithFormat:@"%@", [[tmpNumbersArray objectAtIndex:i] objectForKey:@"number"]]];
		[_button[i] setLabelText:[[tmpNumbersArray objectAtIndex:i] objectForKey:@"text"]];
		
		// Button tag is used to determin when to end game - when all 1's are scratched off, game is done.
		if ([_bozukoGameResult win] == YES || [_bozukoGameResult freePlay] == YES)
		{
			_scratchTotal = 3; // There's 3 winning scratch areas
			
			if ([[[tmpNumbersArray objectAtIndex:i] objectForKey:@"number"] intValue] == tmpWinningNumber)
				[_button[i] setTag:kScratchButton_Counts];
			else
				[_button[i] setTag:kScratchButton_DoesNotCount];
		}
		else
		{
			_scratchTotal = NUMBER_OF_SCRATCH_AREAS; // This is a losing ticket, wait until all areas are scratched off.
			[_button[i] setTag:kScratchButton_Counts];
		}
		
		if ([_bozukoGameResult freePlay] == YES)
		{
			_cardBackgroundImageView.image = [UIImage imageNamed:@"images/scratch/scratchYouWinBg"];
			_cardStarsImageView.image = [UIImage imageNamed:@"images/scratch/scratchStarsBg"];
			_cardTextImageView.image = [UIImage imageNamed:@"images/scratch/scratchBonusTixTxt"];
		}
		else if ([_bozukoGameResult win] == YES)
		{
			_cardBackgroundImageView.image = [UIImage imageNamed:@"images/scratch/scratchYouWinBg"];
			_cardStarsImageView.image = [UIImage imageNamed:@"images/scratch/scratchStarsBg"];
			_cardTextImageView.image = [UIImage imageNamed:@"images/scratch/scratchYouWinTxt"];
		}
		else if ([[_bozukoGame gameState] userTokens] > 0)
		{
			_cardBackgroundImageView.image = [UIImage imageNamed:@"images/scratch/scratchYouLosePlayAgainBg"];
			_cardStarsImageView.image = nil;
			_cardTextImageView.image = [UIImage imageNamed:@"images/scratch/scratchYouLosePlayAgainTxt"];
		}
		else
		{
			_cardBackgroundImageView.image = [UIImage imageNamed:@"images/scratch/scratchYouLoseBg"];
			_cardStarsImageView.image = nil;
			_cardTextImageView.image = [UIImage imageNamed:@"images/scratch/scratchYouLoseTxt"];
		}
		
		_areGameResultsIn = YES;
		[self startGame];
	}
}

@end
