//
//  PrizesHomeViewController.m
//  Bozuko
//
//  Created by Tom Corwine on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrizesHomeViewController.h"
#import "BozukoHandler.h"
#import "PrizesTableCell.h"
#import "UserHandler.h"
#import "HowToPlayViewController.h"
#import "LoadingView.h"
#import "LoadMoreTableCell.h"
#import "PrizeWrapperViewController.h"

#define kPrizesHomeViewController_ActivePrizesSection	0
#define kPrizesHomeViewController_PastPrizesSection		1
#define kPrizesHomeViewController_LoadMoreSection		2

@implementation PrizesHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
	if (self)
	{
        // Custom initialization
    }
    
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_tableView release];
	[_notLoggedInView release];
	[_noPrizesView release];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
	if (_tableView.hidden == YES)
	{
		[_tableView removeFromSuperview];
		_tableView = nil;
	}
	
	if (_notLoggedInView.hidden == YES)
	{
		[_notLoggedInView removeFromSuperview];
		_notLoggedInView = nil;
	}
	
	if (_noPrizesView.hidden == YES)
	{
		[_noPrizesView removeFromSuperview];
		_noPrizesView = nil;
	}
	
    // Release any cached data, images, etc that aren't in use.
}

- (void)showTableView
{
	_notLoggedInView.hidden = YES;
	_noPrizesView.hidden = YES;
	
	if (_tableView == nil)
	{
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 367.0) style:UITableViewStylePlain];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		//_tableView.rowHeight = 85.0;
		[self.view addSubview:_tableView];
		[_tableView release];
	}
	else
	{
		_tableView.hidden = NO;
	}
}

- (void)showNotLoggedInView
{
	_tableView.hidden = YES;
	_noPrizesView.hidden = YES;
	
	if (_notLoggedInView == nil)
	{
		_notLoggedInView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 367.0)];
		_notLoggedInView.image = [UIImage imageNamed:@"images/noPrizes"];
		_notLoggedInView.userInteractionEnabled = YES;
		
		UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
		tmpButton.frame = CGRectMake(50.0, 330.0, 220.0, 30.0);
		[tmpButton addTarget:self action:@selector(howToButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		[_notLoggedInView addSubview:tmpButton];
		
		[self.view addSubview:_notLoggedInView];
		[_notLoggedInView release];
	}
	else
	{
		_notLoggedInView.hidden = NO;
	}
}

- (void)showNoPrizesView
{
	_tableView.hidden = YES;
	_notLoggedInView.hidden = YES;
	
	if (_noPrizesView == nil)
	{
		_noPrizesView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 367.0)];
		_noPrizesView.image = [UIImage imageNamed:@"images/noPrizes"];
		_noPrizesView.userInteractionEnabled = YES;
		
		UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
		tmpButton.frame = CGRectMake(50.0, 310.0, 220.0, 30.0);
		[tmpButton addTarget:self action:@selector(howToButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		[_noPrizesView addSubview:tmpButton];
		
		[self.view addSubview:_noPrizesView];
		[_noPrizesView release];
	}
	else
	{
		_noPrizesView.hidden = NO;
	}
}

- (void)refreshView
{	
	if ([[UserHandler sharedInstance] loggedIn] == NO)
		[self showNotLoggedInView];
	else if ([[UserHandler sharedInstance] numberOfPastPrizes] == 0 && [[UserHandler sharedInstance] numberOfActivePrizes] == 0)
		[self showNoPrizesView];
	else 
		[self showTableView];
	
	[_tableView reloadData];
	
	[_loadingOverlay removeFromSuperview];
	_loadingOverlay = nil;
}

#pragma mark Button Actions

- (void)howToButtonWasPressed
{
	HowToPlayViewController *tmpViewController = [[HowToPlayViewController alloc] init];
	UINavigationController *tmpNavigationController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
	tmpNavigationController.navigationBar.tintColor = [UIColor blackColor];
	[tmpViewController release];
	
	[self presentModalViewController:tmpNavigationController animated:YES];
	[tmpNavigationController release];
}

#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kPrizesHomeViewController_LoadMoreSection)
		return 65.0;
	
	return 85.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == kPrizesHomeViewController_LoadMoreSection)
	{
		if ([[BozukoHandler sharedInstance] prizesNextURL] == nil ||
			[[UserHandler sharedInstance] numberOfPastPrizes] + [[UserHandler sharedInstance] numberOfActivePrizes] < 25)
			return 0;
		else
			return 1;
	}
	
	if (section == kPrizesHomeViewController_ActivePrizesSection)
		return [[UserHandler sharedInstance] numberOfActivePrizes];
	
	if (section == kPrizesHomeViewController_PastPrizesSection)
		return [[UserHandler sharedInstance] numberOfPastPrizes];

	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == kPrizesHomeViewController_LoadMoreSection)
		return 0;
	if ((section == kPrizesHomeViewController_ActivePrizesSection && [[UserHandler sharedInstance] numberOfActivePrizes] > 0) ||
		(section == kPrizesHomeViewController_PastPrizesSection && [[UserHandler sharedInstance] numberOfPastPrizes] > 0))
		return 23.0;
	else
		return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == kPrizesHomeViewController_LoadMoreSection)
		return nil;
	
	UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 23.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/listHeader"];
	
	UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 320.0, 23.0)];
	tmpLabel.font = [UIFont boldSystemFontOfSize:18];
	tmpLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
	tmpLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
	tmpLabel.textColor = [UIColor whiteColor];
	tmpLabel.backgroundColor = [UIColor clearColor];
	[tmpImageView addSubview:tmpLabel];
	[tmpLabel release];
	
	switch (section)
	{
		case kPrizesHomeViewController_ActivePrizesSection:
			tmpLabel.text = @"Active Prizes";
			break;
			
		case kPrizesHomeViewController_PastPrizesSection:
			tmpLabel.text = @"Past Prizes";
			break;
	}
	
	return [tmpImageView autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kPrizesHomeViewController_LoadMoreSection)
	{
		LoadMoreTableCell *tmpCell = (LoadMoreTableCell *)[tableView dequeueReusableCellWithIdentifier:@"LoadMoreTableCell"];
		
		if (tmpCell == nil)
			tmpCell = [[[LoadMoreTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoadMoreTableCell"] autorelease];
		
		[tmpCell setActive:NO];
		
		return tmpCell;
	}
	
	PrizesTableCell *tmpCell = (PrizesTableCell *)[tableView dequeueReusableCellWithIdentifier:@"PrizesCell"];
	
	if (tmpCell == nil)
		tmpCell = [[[PrizesTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PrizesCell"] autorelease];

	BozukoPrize *tmpPrize = nil;
	if (indexPath.section == kPrizesHomeViewController_ActivePrizesSection)
		tmpPrize = [[UserHandler sharedInstance] activePrizeAtIndex:indexPath.row];
	else
		tmpPrize = [[UserHandler sharedInstance] pastPrizeAtIndex:indexPath.row];

	[tmpCell setContentForPrize:tmpPrize];
	
	return tmpCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == kPrizesHomeViewController_LoadMoreSection)
	{
		[(LoadMoreTableCell *)[tableView cellForRowAtIndexPath:indexPath] setActive:YES];
		[[BozukoHandler sharedInstance] bozukoPrizesNextPage];
		return;
	}

	BozukoPrize *tmpPrize = nil;
	
	if (indexPath.section == kPrizesHomeViewController_ActivePrizesSection)
		tmpPrize = [[UserHandler sharedInstance] activePrizeAtIndex:indexPath.row];
	else
		tmpPrize = [[UserHandler sharedInstance] pastPrizeAtIndex:indexPath.row];

	if ([tmpPrize state] == BozukoPrizeStateActive)
	{
		PrizeWrapperViewController *tmpViewController = [[PrizeWrapperViewController alloc] initWithBozukoPrize:tmpPrize];
		tmpViewController.delegate = self;
		UINavigationController *tmpNavController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
		tmpNavController.navigationItem.hidesBackButton = YES;
		[tmpNavController.navigationBar setBarStyle:UIBarStyleBlack];
		[self presentModalViewController:tmpNavController animated:YES];
		[tmpNavController release];
		[tmpViewController release];
	}
	else
	{
		PrizeDetailsViewController *tmpViewController = [[PrizeDetailsViewController alloc] initWithBozukoPrize:tmpPrize];
		tmpViewController.delegate = self;
		UINavigationController *tmpNavController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
		tmpNavController.navigationItem.hidesBackButton = YES;
		[tmpNavController.navigationBar setBarStyle:UIBarStyleBlack];
		[self presentModalViewController:tmpNavController animated:YES];
		[tmpNavController release];
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
	
	UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 83.0, 30.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/bozukoLogo"];
	UIBarButtonItem *tmpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tmpImageView];
	[tmpImageView release];
	self.navigationItem.rightBarButtonItem = tmpBarButtonItem;
	[tmpBarButtonItem release];
	
	[self refreshView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:kBozukoHandler_UserLoginStatusChanged object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prizesDidFinish) name:kBozukoHandler_PrizesDidFinish object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prizesDidFail) name:kBozukoHandler_PrizesDidFail object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self refreshView];
	
	if ([[UserHandler sharedInstance] loggedIn] == YES)
	{
		[[BozukoHandler sharedInstance] bozukoPrizes];
	
		_loadingOverlay = [[LoadingView alloc] init];
		[self.view addSubview:_loadingOverlay];
		[_loadingOverlay release];
	}
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_tableView release];
	[_notLoggedInView release];
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark PrizeView Delegate

- (void)closeView
{
	[self dismissModalViewControllerAnimated:YES];
}
	 
#pragma BozukoHandler Notification Methods

- (void)prizesDidFinish
{
	[self refreshView];
}

- (void)prizesDidFail
{
}

@end
