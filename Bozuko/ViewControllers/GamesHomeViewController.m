//
//  GameHomeViewController.m
//  Bozuko
//
//  Created by Tom Corwine on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamesHomeViewController.h"
#import "GamesView.h"
#import "MapView.h"
#import "BozukoHandler.h"
#import "HowToPlayViewController.h"
#import "BozukoPage.h"

#define kGamesSegmentedControl_Nearby		0
#define kGamesSegmentedControl_Favorites	1
#define kGamesSegmentedControl_Map			2
					

@implementation GamesHomeViewController

- (void)dealloc
{
	[_gamesView release];
	[_mapView release];
	
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
	if (self)
	{
		//[BozukoHandler sharedInstance]; // Get location services up and running as quickly as possible
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGamesTable:) name:kBozukoHandler_GetPagesForLocationDidFinish object:nil];	
    }
    
	return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Button Actions

- (void)hideAllViews
{
	_gamesView.hidden = YES;
	_mapView.hidden = YES;
}

- (void)segmentedControlWasChanged:(id)sender
{
	switch ([sender selectedSegmentIndex])
	{
		case kGamesSegmentedControl_Nearby:
			[self hideAllViews];
			
			if (_gamesView == nil)
			{
				_gamesView = [[GamesView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 367.0)];
				_gamesView.controller = self.navigationController;
				[self.view addSubview:_gamesView];
			}
			
			[_gamesView setFavorites:NO];
			_gamesView.hidden = NO;
			break;
			
		case kGamesSegmentedControl_Favorites:
			[self hideAllViews];
			
			if (_gamesView == nil)
			{
				_gamesView = [[GamesView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 367.0)];
				_gamesView.controller = self.navigationController;
				[self.view addSubview:_gamesView];
			}
			
			[_gamesView setFavorites:YES];
			_gamesView.hidden = NO;
			break;
			
		case kGamesSegmentedControl_Map:
			[_gamesView viewWillDisappear];
			[self hideAllViews];
			
			if (_mapView == nil)
			{
				_mapView = [[MapView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 400.0)];
				_mapView.controller = self.navigationController;
				[self.view addSubview:_mapView];
			}
			else
				[_mapView viewDidAppear];
			
			_mapView.hidden = NO;
			break;
	}
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated {
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGamesTable:) name:kBozukoHandler_GetPagesForLocationDidFinish object:nil];	
}

- (void)viewWillDisappear:(BOOL)animated {
	//[[NSNotificationCenter defaultCenter] removeObserver: self];	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UISegmentedControl *tmpSegementedControl = [[UISegmentedControl alloc] init];
	tmpSegementedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	tmpSegementedControl.tintColor = [UIColor darkGrayColor];
	tmpSegementedControl.frame = CGRectMake(0.0, 0.0, 200.0, 30.0);
	[tmpSegementedControl addTarget:self action:@selector(segmentedControlWasChanged:) forControlEvents:UIControlEventValueChanged];
	[tmpSegementedControl insertSegmentWithTitle:@"Nearby" atIndex:0 animated:NO];
	[tmpSegementedControl insertSegmentWithTitle:@"Favorites" atIndex:1 animated:NO];
	[tmpSegementedControl insertSegmentWithTitle:@"Map" atIndex:2 animated:NO];
	tmpSegementedControl.selectedSegmentIndex = kGamesSegmentedControl_Nearby;
	
	UIBarButtonItem *tmpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tmpSegementedControl];
	[tmpSegementedControl release];
	self.navigationItem.leftBarButtonItem = tmpBarButtonItem;
	[tmpBarButtonItem release];
	
	UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 83.0, 30.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/bozukoLogo"];
	tmpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tmpImageView];
	[tmpImageView release];
	self.navigationItem.rightBarButtonItem = tmpBarButtonItem;
	[tmpBarButtonItem release];
	
	[self segmentedControlWasChanged:tmpSegementedControl];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ReturnUser"] == NO)
	{
		HowToPlayViewController *tmpViewController = [[HowToPlayViewController alloc] init];
		UINavigationController *tmpNavigationController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
		tmpNavigationController.navigationBar.tintColor = [UIColor blackColor];
		[tmpViewController release];
		
		[self.navigationController presentModalViewController:tmpNavigationController animated:YES];
		[tmpNavigationController release];
		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ReturnUser"];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
