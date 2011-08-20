//
//  RootViewController.m
//  Bozuko
//
//  Created by Tom Corwine on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "BozukoHandler.h"
#import "UserHandler.h"
#import "BozukoEntryPoint.h"
#import "FacebookLoginViewController.h"
#import "GamesHomeViewController.h"
#import "PrizesHomeViewController.h"
#import "BozukoHomeViewController.h"

#define kRootViewController_NoNetworkAlert		0
#define kRootViewController_NoLocationAlert		1
#define kRootViewController_NeedsUpdateAlert	2
#define kRootViewController_ServerErrorAlert	3
#define kRootViewController_ServerLogoutAlert	4

@implementation RootViewController

- (id)init
{
    self = [super init];
    
	if (self)
	{
		
    }
    
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_tabBarController release];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark NSNotificationCenter delegate methods

- (void)presentUserLoginWebView:(NSNotification *)inNotificaiton
{
	if ([[UserHandler sharedInstance] loggedIn] == YES || [[BozukoHandler sharedInstance].apiEntryPoint login] == nil)
		 return;
		 
	FacebookLoginViewController *tmpViewController = [[FacebookLoginViewController alloc] init];
	
	UIBarButtonItem *tmpBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewControllerAnimated:)];
	tmpViewController.navigationItem.leftBarButtonItem = tmpBarButtonItem;
	tmpViewController.navigationItem.title = @"Login";
	[tmpBarButtonItem release];
	
	UINavigationController *tmpNavigationController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
	tmpNavigationController.navigationBar.tintColor = [UIColor blackColor];
	[tmpViewController release];
	
	[self presentModalViewController:tmpNavigationController animated:YES];
	[tmpNavigationController release];
}

- (void)userLocationUnavailableNotification
{
	if (_alertView != nil)
		return; // Prevent more than one alert from being queued
	
	_alertView = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
											message:@"Bozuko needs your location in order to find local businesses near you."
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
	
	_alertView.tag = kRootViewController_NoLocationAlert;
	[_alertView show];
	[_alertView release];
}

- (void)networkUnavailableNotification
{
	[_gamesNavigationController dismissModalViewControllerAnimated:NO];
	[_prizesNavigationController dismissModalViewControllerAnimated:NO];
	[_bozukoNavigationController dismissModalViewControllerAnimated:NO];
	//[_gamesNavigationController popToRootViewControllerAnimated:NO];
	_tabBarController.selectedIndex = 0;
	//[_gamesHomeViewController hideAllViews]; 
	
	if (_alertView != nil)
		return; // Prevent more than one alert from being queued
	
	_alertView = [[UIAlertView alloc] initWithTitle:@"Network Not Available"
											message:@"Please try again later."
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
	
	_alertView.tag = kRootViewController_NoNetworkAlert;
	_alertView.delegate = self;
	[_alertView show];
	[_alertView release];
}

- (void)networkErrorNotification:(NSNotification *)inNotification
{
	NSString *tmpTitleString = nil;
	NSString *tmpMessageString = nil;
	
	if ([[inNotification object] isKindOfClass:[NSDictionary class]] == YES)
	{
		tmpTitleString = [[inNotification object] objectForKey:@"title"];
		tmpMessageString = [[inNotification object] objectForKey:@"message"];
	}
	else
	{
		tmpTitleString = @"Error";
		tmpMessageString = @"Can not continue";
	}
	
	[_gamesNavigationController dismissModalViewControllerAnimated:NO];
	[_prizesNavigationController dismissModalViewControllerAnimated:NO];
	[_bozukoNavigationController dismissModalViewControllerAnimated:NO];
	[_gamesNavigationController popToRootViewControllerAnimated:NO];
	_tabBarController.selectedIndex = 0; 
	
	if (_alertView != nil)
		return; // Prevent more than one alert from being queued
	
	_alertView = [[UIAlertView alloc] initWithTitle:tmpTitleString
											message:tmpMessageString
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
	
	_alertView.tag = kRootViewController_ServerErrorAlert;
	[_alertView show];
	[_alertView release];
}

- (void)serverLogoutNotification:(NSNotification *)inNotification
{
	NSString *tmpTitleString = nil;
	NSString *tmpMessageString = nil;
	
	if ([[inNotification object] isKindOfClass:[NSDictionary class]] == YES)
	{
		tmpTitleString = [[inNotification object] objectForKey:@"title"];
		tmpMessageString = [[inNotification object] objectForKey:@"message"];
	}
	else
	{
		tmpTitleString = @"Error";
		tmpMessageString = @"Can not continue";
	}
	
	[_gamesNavigationController dismissModalViewControllerAnimated:NO];
	[_prizesNavigationController dismissModalViewControllerAnimated:NO];
	[_bozukoNavigationController dismissModalViewControllerAnimated:NO];
	[_gamesNavigationController popToRootViewControllerAnimated:NO];
	_tabBarController.selectedIndex = 2; 
	
	if (_alertView != nil)
		return; // Prevent more than one alert from being queued
	
	_alertView = [[UIAlertView alloc] initWithTitle:tmpTitleString
											message:tmpMessageString
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
	
	_alertView.tag = kRootViewController_ServerLogoutAlert;
	[_alertView show];
	[_alertView release];
}

- (void)applicationNeedsUpdateNotification:(NSNotification *)inNotification
{
	[_gamesNavigationController dismissModalViewControllerAnimated:NO];
	[_prizesNavigationController dismissModalViewControllerAnimated:NO];
	[_bozukoNavigationController dismissModalViewControllerAnimated:NO];
	[_gamesNavigationController popToRootViewControllerAnimated:NO];
	_tabBarController.selectedIndex = 0;
	[_gamesHomeViewController hideAllViews]; 
	
	if (_alertView != nil && _alertView.tag != kRootViewController_NeedsUpdateAlert)
		[_alertView dismissWithClickedButtonIndex:0 animated:NO]; // Prevent more than one alert from being queued
	else if (_alertView != nil)
		return;
	
	NSString *tmpTitleString = nil;
	NSString *tmpMessageString = nil;
	
	if ([[inNotification object] isKindOfClass:[NSDictionary class]] == YES)
	{
		tmpTitleString = [[inNotification object] objectForKey:@"title"];
		tmpMessageString = [[inNotification object] objectForKey:@"message"];
	}
	else
	{
		tmpTitleString = @"New Version Available";
		tmpMessageString = @"Press OK to download";
	}
	
	_alertView = [[UIAlertView alloc] initWithTitle:tmpTitleString
											message:tmpMessageString
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
	
	_alertView.tag = kRootViewController_NeedsUpdateAlert;
	[_alertView show];
	[_alertView release];
}

- (void)userDidLogout
{
	[_gamesNavigationController popToRootViewControllerAnimated:NO];
}

#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == kRootViewController_NeedsUpdateAlert)
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kBozukoAppStoreURL]];
		DLog(@"Open URL");
	}
	else if (alertView.tag == kRootViewController_ServerLogoutAlert)
	{
		[_gamesNavigationController dismissModalViewControllerAnimated:NO];
		[_prizesNavigationController dismissModalViewControllerAnimated:NO];
		[_bozukoNavigationController dismissModalViewControllerAnimated:NO];
		[_gamesNavigationController popToRootViewControllerAnimated:NO];
		_tabBarController.selectedIndex = 2;
	}
	else
	{
		[_gamesNavigationController dismissModalViewControllerAnimated:NO];
		[_prizesNavigationController dismissModalViewControllerAnimated:NO];
		[_bozukoNavigationController dismissModalViewControllerAnimated:NO];
		[_gamesNavigationController popToRootViewControllerAnimated:NO];
		_tabBarController.selectedIndex = 0;
	}
	
	_alertView = nil;
}

- (void)alertViewDismiss
{
	[_alertView dismissWithClickedButtonIndex:0 animated:NO];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated 
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_gamesHomeViewController = [[GamesHomeViewController alloc] init];
	PrizesHomeViewController *tmpPrizesHomeViewController = [[PrizesHomeViewController alloc] init];
	BozukoHomeViewController *tmpBozukoHomeViewController = [[BozukoHomeViewController alloc] init];
	
	_gamesNavigationController = [[UINavigationController alloc] initWithRootViewController:_gamesHomeViewController];
	_gamesNavigationController.navigationBar.tintColor = [UIColor blackColor];
	_gamesNavigationController.delegate = self;
	
	UITabBarItem *tmpTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Games" image:[UIImage imageNamed:@"images/gamesNav"] tag:0];
	_gamesNavigationController.tabBarItem = tmpTabBarItem;
	[tmpTabBarItem release];
	
	_prizesNavigationController = [[UINavigationController alloc] initWithRootViewController:tmpPrizesHomeViewController];
	_prizesNavigationController.navigationBar.tintColor = [UIColor blackColor];
	_prizesNavigationController.delegate = self;
	
	tmpTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Prizes" image:[UIImage imageNamed:@"images/prizesNav"] tag:0];
	tmpPrizesHomeViewController.tabBarItem = tmpTabBarItem;
	[tmpTabBarItem release];
	
	_bozukoNavigationController = [[UINavigationController alloc] initWithRootViewController:tmpBozukoHomeViewController];
	_bozukoNavigationController.navigationBar.tintColor = [UIColor blackColor];
	_bozukoNavigationController.delegate = self;
	
	tmpTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Bozuko" image:[UIImage imageNamed:@"images/bozukoNav"] tag:0];
	tmpBozukoHomeViewController.tabBarItem = tmpTabBarItem;
	[tmpTabBarItem release];
	
	_tabBarController = [[UITabBarController alloc] init];
	_tabBarController.delegate = self;
	
	NSArray *tmpViewControllersArray = [[NSArray alloc] initWithObjects:_gamesNavigationController, _prizesNavigationController, _bozukoNavigationController, nil];
	_tabBarController.viewControllers = tmpViewControllersArray;
	[tmpViewControllersArray release];
	
	[_gamesHomeViewController release];
	[tmpPrizesHomeViewController release];
	[tmpBozukoHomeViewController release];
	
	[_gamesNavigationController release];
	[_prizesNavigationController release];
	[_bozukoNavigationController release];
	
	self.view = _tabBarController.view;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentUserLoginWebView:) name:kBozukoHandler_UserAttemptLogin object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kBozukoHandler_UserLoggedOut object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLocationUnavailableNotification) name:kBozukoHandler_UserLocationNotAvailable object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertViewDismiss) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkUnavailableNotification) name:kBozukoHandler_NetworkNotAvailable object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationNeedsUpdateNotification:) name:kBozukoHandler_ApplicationNeedsUpdate object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkErrorNotification:) name:kBozukoHandler_ServerErrorNotfication object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverLogoutNotification:) name:kBozukoHandler_ServerLogoutNotfication object:nil];
}

- (void)viewDidUnload
{
	[_tabBarController release];
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITabeBar Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	[viewController viewWillAppear:NO];
}

#pragma mark - UINavigationController Delegates

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[viewController viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[viewController viewDidAppear:animated];
}

@end
