//
//  BozukoHomeViewController.m
//  Bozuko
//
//  Created by Tom Corwine on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameTermsViewController.h"
#import "BozukoPage.h"
#import "BozukoGame.h"
#import "BozukoGamePrize.h"
#import "BozukoGameState.h"
#import "GameTermsHeaderTableCell.h"
#import "DetailTableCell.h"
#import "GamePlaySlotsViewController.h"
#import "GamePlayScratchViewController.h"
#import "GamePrizeDetailsViewController.h"
#import "GamePrizeCell.h"
#import "UserHandler.h"
#import "BozukoHandler.h"
#import "NSDate+Formatter.h"

#define kGameTermsHeaderSection		0
#define kGameTermsPrizesSection		1
#define kGameTermsTACSection		2

#define kGameTermsDefaultRefreshGameStateSeconds	30

@implementation GameTermsViewController

@synthesize bozukoPage = _bozukoPage;
@synthesize bozukoGame = _bozukoGame;
@synthesize bozukoGameIndex = _bozukoGameIndex;

- (id)init
{
    self = [super init];
    
	if (self)
	{
		UIBarButtonItem *tmpItem = [[UIBarButtonItem alloc] init];
		tmpItem.title = @"Back";
        self.navigationItem.backBarButtonItem = tmpItem;
		[tmpItem release];
    }
    
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_refreshTimer invalidate];
	_tableView.delegate = nil;
	_tableView.dataSource = nil;
	self.bozukoGame = nil;
	self.bozukoPage = nil;
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - TableView Delegate and Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == kGameTermsPrizesSection)
		return [[_bozukoGame prizes] count] + [[_bozukoGame consolationPrizes] count];

	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kGameTermsHeaderSection)
	{
		CGSize tmpNameSize = [[_bozukoGame name] sizeWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToSize:CGSizeMake(230.0, 300.0)];
		CGSize tmpDescriptionSize = [[_bozukoGame entryMethodDescription] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(245.0, 300.0)];
		return tmpNameSize.height + tmpDescriptionSize.height + 20.0; // +20.0 for padding
	}
	else if (indexPath.section == kGameTermsPrizesSection)
	{
		return 55.0;
	}
	else if (indexPath.section == kGameTermsTACSection)
	{
		CGSize tmpSize = [[_bozukoGame rules] sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(280.0, 30000.0)];
		return tmpSize.height + 45.0; // +45.0 for the "Official Rules" header.
	}
	else
		return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == kGameTermsPrizesSection)
		return 25.0;
	
	return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == kGameTermsPrizesSection)
	{
		UIView *tmpView = [[UIView alloc] init];
		UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, 150.0, 25.0)];
		tmpLabel.font = [UIFont boldSystemFontOfSize:16.0];
		tmpLabel.backgroundColor = [UIColor clearColor];
		tmpLabel.text = @"Available Prizes";
		[tmpView addSubview:tmpLabel];
		[tmpLabel release];
		
		return [tmpView autorelease];
	}
	
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{	
	return [[[UIView alloc] init] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if (section == kGameTermsTACSection)
		return 90.0;
	
	return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kGameTermsHeaderSection)
	{
		GameTermsHeaderTableCell *tmpCell = (GameTermsHeaderTableCell *)[_tableView dequeueReusableCellWithIdentifier:@"GameTermsHeader"];
		
		if (tmpCell == nil)
			tmpCell = [[[GameTermsHeaderTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GameTermsHeader"] autorelease];
		
		tmpCell.controller = self;
		[tmpCell setGame:_bozukoGame];
		
		tmpCell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return tmpCell;
	}
	
	if (indexPath.section == kGameTermsPrizesSection)
	{
		GamePrizeCell *tmpCell = (GamePrizeCell *)[_tableView dequeueReusableCellWithIdentifier:@"GamePrizeCell"];
		
		if (tmpCell == nil)
			tmpCell = [[[GamePrizeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GamePrizeCell"] autorelease];
		
		BozukoGamePrize *tmpBozukoGamePrize = nil;
		
		NSInteger tmpRow = indexPath.row;
		if (tmpRow < [[_bozukoGame prizes] count])
		{
			// Regular prize
			tmpBozukoGamePrize = [BozukoGamePrize objectWithProperties:[[_bozukoGame prizes] objectAtIndex:tmpRow]];
		}
		else
		{
			// Consolation prize
			tmpRow = tmpRow - [[_bozukoGame prizes] count];
			tmpBozukoGamePrize = [BozukoGamePrize objectWithProperties:[[_bozukoGame consolationPrizes] objectAtIndex:tmpRow]];
		}
		
		[tmpCell populateContentForGamePrize:tmpBozukoGamePrize];
		
		return tmpCell;
	}
	
	DetailTableCell *tmpCell = (DetailTableCell *)[_tableView dequeueReusableCellWithIdentifier:@"DetailTableCell"];
	
	if (tmpCell == nil)
		tmpCell = [[[DetailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailTableCell"] autorelease];
	
	[tmpCell setMainLabelText:@"Official Rules"];
	[tmpCell setDetailLabelText:[_bozukoGame rules]];
	
	tmpCell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return tmpCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == kGameTermsPrizesSection)
	{
		GamePrizeDetailsViewController *tmpViewController = [[GamePrizeDetailsViewController alloc] init];
		
		NSInteger tmpRow = indexPath.row;
		if (tmpRow < [[_bozukoGame prizes] count])
		{
			// Regular prize
			tmpViewController.bozukoGamePrize = [BozukoGamePrize objectWithProperties:[[_bozukoGame prizes] objectAtIndex:tmpRow]];
		}
		else
		{
			// Consolation prize
			tmpRow = tmpRow - [[_bozukoGame prizes] count];
			tmpViewController.bozukoGamePrize = [BozukoGamePrize objectWithProperties:[[_bozukoGame consolationPrizes] objectAtIndex:tmpRow]];
		}
		
		[self.navigationController pushViewController:tmpViewController animated:YES];
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
	_refreshTimer = nil;
	
	self.bozukoGame = [[self.bozukoPage games] objectAtIndex:self.bozukoGameIndex];
	
	//DLog(@"First: %@", self.bozukoGame);
	//DLog(@"First: %@", self.bozukoGame.gameId);
	//DLog(@"First: %@", self.bozukoGame.gameState);
	//DLog(@"Did Load: %@", [self.bozukoGame gameId]);
	
	self.navigationItem.title = [_bozukoPage pageName];
	
	UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 83.0, 30.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/bozukoLogo"];
	UIBarButtonItem *tmpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tmpImageView];
	[tmpImageView release];
	self.navigationItem.rightBarButtonItem = tmpBarButtonItem;
	[tmpBarButtonItem release];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 370.0) style:UITableViewStyleGrouped];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	[_tableView release];
	
	_bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 370.0, 320.0, 80.0)];
	_bottomBarView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_bottomBarView];
	[_bottomBarView release];
	
	[self updateView];
	
	[[BozukoHandler sharedInstance] bozukoRefreshGameStateForGame:_bozukoGame];
	//DLog(@"First Refresh: %@", [_bozukoGame gameId]);
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bozukoGameResultsInProgress:) name:kBozukoHandler_GameResultsRequestInProgress object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bozukoGameResultsDidFinish:) name:kBozukoHandler_GameResultsDidFinish object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bozukoGameResultsDidFail:) name:kBozukoHandler_GameResultsDidFail object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bozukoGameStateDidFinish:) name:kBozukoHandler_GameStateDidFinish object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bozukoGameStateDidFail:) name:kBozukoHandler_GameStateDidFail object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:kBozukoHandler_PageDidFinish object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageUpdateDidFinish:) name:kBozukoHandler_PageDidFinish object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageUpdateDidFail:) name:kBozukoHandler_PageDidFail object:nil];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_refreshTimer invalidate];
	_refreshTimer = nil;
	
	self.bozukoGame = nil;
	self.bozukoPage = nil;
	
	[super viewDidUnload];
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//	[_refreshTimer invalidate];
//	_refreshTimer = nil;
//}

- (void)updateView
{
	//DLog(@"Update: %@", self.bozukoGame.gameState);
	
	[_tableView reloadData];
	
	for (UIView *tmpView in [_bottomBarView subviews])
		[tmpView removeFromSuperview];
	
	_gameEntryButton = nil;
	
	UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 80.0)];
	tmpView.backgroundColor = [UIColor blackColor];
	tmpView.alpha = 0.7;
	[_bottomBarView addSubview:tmpView];
	[tmpView release];
	
	//DLog(@"Game: %@", [_bozukoGame description]);
	//DLog(@"GameState: %@", [[_bozukoGame gameState] description]);
	
	if ([BozukoGameResult loadObjectFromDiskForPageID:[_bozukoGame gameID]])
	{
		UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 55.0, 320.0, 20.0)];
		tmpLabel.backgroundColor = [UIColor clearColor];
		tmpLabel.textColor = [UIColor whiteColor];
		tmpLabel.textAlignment = UITextAlignmentCenter;
		tmpLabel.font = [UIFont systemFontOfSize:12.0];
		tmpLabel.text = @"I agree to the official rules above.";
		[_bottomBarView addSubview:tmpLabel];
		[tmpLabel release];
		
		_gameEntryButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_gameEntryButton.frame = CGRectMake(20.0, 5.0, 278.0, 45.0);
		[_gameEntryButton setBackgroundImage:[UIImage imageNamed:@"images/greenBtn"] forState:UIControlStateNormal];
		[_gameEntryButton setBackgroundImage:[UIImage imageNamed:@"images/greenBtnPress"] forState:UIControlStateHighlighted];
		_gameEntryButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
		_gameEntryButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		[_gameEntryButton setTitle:@"Play" forState:UIControlStateNormal];
		[_gameEntryButton addTarget:self action:@selector(playButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		[_bottomBarView addSubview:_gameEntryButton];
	}
	else if ([[_bozukoGame gameState] buttonEnabled] == YES)
	{
		UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 55.0, 320.0, 20.0)];
		tmpLabel.backgroundColor = [UIColor clearColor];
		tmpLabel.textColor = [UIColor whiteColor];
		tmpLabel.textAlignment = UITextAlignmentCenter;
		tmpLabel.font = [UIFont systemFontOfSize:12.0];
		tmpLabel.text = @"I agree to the official rules above.";
		[_bottomBarView addSubview:tmpLabel];
		[tmpLabel release];
		
		_gameEntryButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_gameEntryButton.frame = CGRectMake(20.0, 5.0, 278.0, 45.0);
		[_gameEntryButton setBackgroundImage:[UIImage imageNamed:@"images/greenBtn"] forState:UIControlStateNormal];
		[_gameEntryButton setBackgroundImage:[UIImage imageNamed:@"images/greenBtnPress"] forState:UIControlStateHighlighted];
		_gameEntryButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
		_gameEntryButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		[_gameEntryButton setTitle:[[_bozukoGame gameState] buttonText] forState:UIControlStateNormal];
		[_gameEntryButton addTarget:self action:@selector(playButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		[_bottomBarView addSubview:_gameEntryButton];
	}
	else
	{
		UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 25.0, 300.0, 30.0)];
		tmpLabel.backgroundColor = [UIColor clearColor];
		tmpLabel.textColor = [UIColor whiteColor];
		tmpLabel.textAlignment = UITextAlignmentCenter;
		tmpLabel.font = [UIFont systemFontOfSize:25.0];
		tmpLabel.minimumFontSize = 16.0;
		tmpLabel.adjustsFontSizeToFitWidth = YES;
		tmpLabel.text = [[_bozukoGame gameState] buttonText];
		[_bottomBarView addSubview:tmpLabel];
		[tmpLabel release];
		
		//DLog(@"Enter Interval: %d", [_bozukoGame gameState].nextEnterInterval);
		//DLog(@"%@", [_bozukoGame gameState]);
		
		if ([_bozukoGame gameState].nextEnterInterval > 0)
			_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:[_bozukoGame gameState].nextEnterInterval + 1 target:self selector:@selector(updateGameState) userInfo:nil repeats:NO];
		else
			_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kGameTermsDefaultRefreshGameStateSeconds target:self selector:@selector(updateGameState) userInfo:nil repeats:NO];
	}
}

- (void)updateGameState
{
	_refreshTimer = nil;
	[[BozukoHandler sharedInstance] bozukoRefreshGameStateForGame:_bozukoGame];
	//DLog(@"Timer Refresh: %@", [_bozukoGame gameId]);
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[UIView animateWithDuration:0.75 animations:^{
		_bottomBarView.frame = CGRectMake(0.0, 290.0, 320.0, 80.0);
	}];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
	[self updateView];
	[super dismissModalViewControllerAnimated:animated];
}

#pragma mark Button Actions

- (void)playButtonWasPressed
{
	if ([[_bozukoGame gameType] isEqualToString:@"slots"] == YES)
	{
		GamePlaySlotsViewController *tmpViewController = [[GamePlaySlotsViewController alloc] init];
		tmpViewController.bozukoGame = _bozukoGame;
		tmpViewController.bozukoPage = _bozukoPage;
		tmpViewController.delegate = self;
		
		UINavigationController *tmpNavigationController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
		tmpNavigationController.navigationBar.tintColor = [UIColor blackColor];
		[tmpViewController release];
		
		[self.navigationController presentModalViewController:tmpNavigationController animated:YES];
		[tmpNavigationController release];
	}
	else if ([[_bozukoGame gameType] isEqualToString:@"scratch"] == YES)
	{
		GamePlayScratchViewController *tmpViewController = [[GamePlayScratchViewController alloc] init];
		tmpViewController.bozukoGame = _bozukoGame;
		tmpViewController.bozukoPage = _bozukoPage;
		tmpViewController.delegate = self;
		
		UINavigationController *tmpNavigationController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
		tmpNavigationController.navigationBar.tintColor = [UIColor blackColor];
		[tmpViewController release];
		
		[self.navigationController presentModalViewController:tmpNavigationController animated:YES];
		[tmpNavigationController release];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark BozukoHandler Notification Methods

- (void)bozukoGameResultsInProgress:(NSNotification *)inNotification
{
	for (UIView *tmpView in [_bottomBarView subviews])
		[tmpView removeFromSuperview];
	
	_gameEntryButton = nil;
	
	UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 80.0)];
	tmpView.backgroundColor = [UIColor blackColor];
	tmpView.alpha = 0.7;
	[_bottomBarView addSubview:tmpView];
	[tmpView release];
	
	//DLog(@"Game: %@", [_bozukoGame description]);
	//DLog(@"GameState: %@", [[_bozukoGame gameState] description]);

	UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 25.0, 320.0, 30.0)];
	tmpLabel.backgroundColor = [UIColor clearColor];
	tmpLabel.textColor = [UIColor whiteColor];
	tmpLabel.textAlignment = UITextAlignmentCenter;
	tmpLabel.font = [UIFont systemFontOfSize:25.0];
	tmpLabel.text = @"Loading...";
	[_bottomBarView addSubview:tmpLabel];
	[tmpLabel release];
	
	UIActivityIndicatorView *tmpActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	tmpActivityIndicator.frame = CGRectMake(40.0, 25.0, 37.0, 37.0);
	tmpActivityIndicator.hidesWhenStopped = YES;
	[tmpActivityIndicator startAnimating];
	[_bottomBarView addSubview:tmpActivityIndicator];
	[tmpActivityIndicator release];
}

- (void)bozukoGameResultsDidFinish:(NSNotification *)inNotification
{
	[self updateView];
}

- (void)bozukoGameResultsDidFail:(NSNotification *)inNotification
{
}

- (void)bozukoGameStateDidFinish:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[BozukoGameState class]] == NO)
		return;
	
	//DLog(@"\n%@\n%@", _bozukoGame.gameID, [[inNotification object] gameID]);
	//DLog(@"%@", [inNotification object]);
	
	if ([_bozukoGame.gameID isEqualToString:[[inNotification object] gameID]] == NO)
		return;
	
	[_bozukoGame setGameState:[inNotification object]];
	
	[self updateView];
}

- (void)bozukoGameStateDidFail:(NSNotification *)inNotification
{
}

#pragma mark BozukoHandler Notification Methods

- (void)pageUpdateDidFinish:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[BozukoPage class]] == NO)
		return;
	
	if ([[[inNotification object] pageID] isEqualToString:[_bozukoPage pageID]] == NO)
		return;
	
	self.bozukoPage = [inNotification object];
	self.bozukoGame = [[self.bozukoPage games] objectAtIndex:self.bozukoGameIndex];
	
	//DLog(@"Page Refresh: %@", self.bozukoPage);
	
	[self updateView];
}

- (void)pageUpdateDidFail:(NSNotification *)inNotification
{
}

@end
