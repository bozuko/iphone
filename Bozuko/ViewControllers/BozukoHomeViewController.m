//
//  BozukoHomeViewController.m
//  Bozuko
//
//  Created by Tom Corwine on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoHomeViewController.h"
#import "WebViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "BozukoHandler.h"
#import "BozukoBozuko.h"
#import "HowToPlayViewController.h"
#import "BozukoUser.h"
#import "ImageHandler.h"
#import "GamesDetailViewController.h"
#import "UserHandler.h"

#define kBozukoHomeViewController_ProfileSection				0
#define kBozukoHomeViewController_LoginSection					1
#define kBozukoHomeViewController_HowToPlaySection				2
#define kBozukoHomeViewController_AboutBozukoSection			3
#define kBozukoHomeViewController_BozukoForBusinessSection		4
#define kBozukoHomeViewController_PrivacyPolicySection			5
#define kBozukoHomeViewController_TermsOfUseSection				6
#define kBozukoHomeViewController_DemoGameSection				7
#define kBozukoHomeViewController_PlayOurGameSection			8

@implementation BozukoHomeViewController

- (id)init
{
    self = [super init];
    
	if (self)
	{
        // Custom initialization
    }
    
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
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
	return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == kBozukoHomeViewController_ProfileSection || section == kBozukoHomeViewController_HowToPlaySection)
		return 25.0;
	
	return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kBozukoHomeViewController_ProfileSection)
		return ([[UserHandler sharedInstance] loggedIn] ? 100.0f : 64.0f);
	
	return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *tmpView = nil;
	UILabel *tmpLabel = nil;
	
	switch (section)
	{
		case kBozukoHomeViewController_ProfileSection:
			tmpView = [[UIView alloc] init];
			tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, 100.0, 25.0)];
			tmpLabel.font = [UIFont boldSystemFontOfSize:16.0];
			tmpLabel.backgroundColor = [UIColor clearColor];
			tmpLabel.text = @"Profile";
			[tmpView addSubview:tmpLabel];
			[tmpLabel release];
			return [tmpView autorelease];
			break;
			
		case kBozukoHomeViewController_HowToPlaySection:
			tmpView = [[UIView alloc] init];
			tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, 100.0, 25.0)];
			tmpLabel.font = [UIFont boldSystemFontOfSize:16.0];
			tmpLabel.backgroundColor = [UIColor clearColor];
			tmpLabel.text = @"Bozuko";
			[tmpView addSubview:tmpLabel];
			[tmpLabel release];
			return [tmpView autorelease];
			break;
			
		default:
			return nil;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kBozukoHomeViewController_ProfileSection && [[UserHandler sharedInstance] loggedIn])
	{
		BozukoUser *tmpUser = [[UserHandler sharedInstance] apiUser];
		
		static NSString *profileCellIdentifier = @"profileCellIdentifier";
		UITableViewCell *tmpCell = [tableView dequeueReusableCellWithIdentifier:profileCellIdentifier];
		if (!tmpCell)
		{
			tmpCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profileCellIdentifier] autorelease];
			[tmpCell setSelectionStyle:UITableViewCellEditingStyleNone];

			// Profile Image View
			_profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 82, 82)];
			[_profileImageView setBackgroundColor:[UIColor darkGrayColor]];
			[_profileImageView setTag:100];
			[_profileImageView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
			[_profileImageView.layer setBorderWidth:4.0f];
			[tmpCell.contentView addSubview:_profileImageView];
			[_profileImageView release];

			// Name label
			UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(101, 9, 190, 20)];
			[tmpLabel setFont:[UIFont boldSystemFontOfSize:16]];
			[tmpLabel setTag:200];
			[tmpCell.contentView addSubview:tmpLabel];
			[tmpLabel release];

			// Email label
			tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(101, 30, 190, 20)];
			[tmpLabel setFont:[UIFont boldSystemFontOfSize:12]];
			[tmpLabel setTextColor:[UIColor darkGrayColor]];
			[tmpLabel setTag:300];
			[tmpCell.contentView addSubview:tmpLabel];
			[tmpLabel release];
		}

		[(UILabel *)[tmpCell.contentView viewWithTag:200] setText:[tmpUser name]];
		[(UILabel *)[tmpCell.contentView viewWithTag:300] setText:[tmpUser email]];
		
		_profileImageView.image = [[ImageHandler sharedInstance] nonCachedImageForURL:[tmpUser image]];

		return tmpCell;
	}

	UITableViewCell *tmpCell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];	
	if (tmpCell == nil)
		tmpCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"] autorelease];

	tmpCell.selectionStyle = UITableViewCellSelectionStyleBlue;
	tmpCell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	switch (indexPath.section)
	{
		case kBozukoHomeViewController_ProfileSection:
			tmpCell.textLabel.text = @"Please login with Facebook to create\nyour Bozuko account";
			tmpCell.textLabel.font = [UIFont systemFontOfSize:14];
			tmpCell.textLabel.textColor = [UIColor blackColor];
			tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
			tmpCell.textLabel.numberOfLines = 2;
			tmpCell.backgroundColor = [UIColor whiteColor];
			tmpCell.selectionStyle = UITableViewCellSelectionStyleNone;
			tmpCell.imageView.image = nil;
			break;

		case kBozukoHomeViewController_LoginSection:
			if ([[UserHandler sharedInstance] loggedIn] == YES)
				tmpCell.textLabel.text = @"Facebook Log Out";
			else
				tmpCell.textLabel.text = @"Facebook Log In";

			tmpCell.textLabel.textColor = [UIColor blackColor];
			tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
			tmpCell.backgroundColor = [UIColor whiteColor];
			tmpCell.imageView.image = [UIImage imageNamed:@"images/facebookIcon"];
			break;
			
		case kBozukoHomeViewController_PrivacyPolicySection:
			tmpCell.textLabel.text = @"Privacy Policy";
			tmpCell.textLabel.textColor = [UIColor blackColor];
			tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
			tmpCell.backgroundColor = [UIColor whiteColor];
			tmpCell.imageView.image = nil;
			break;
			
		case kBozukoHomeViewController_HowToPlaySection:
			tmpCell.textLabel.text = @"How to Play";
			tmpCell.textLabel.textColor = [UIColor blackColor];
			tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
			tmpCell.backgroundColor = [UIColor whiteColor];
			tmpCell.imageView.image = nil;
			break;
			
		case kBozukoHomeViewController_AboutBozukoSection:
			tmpCell.textLabel.text = @"About Bozuko";
			tmpCell.textLabel.textColor = [UIColor blackColor];
			tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
			tmpCell.backgroundColor = [UIColor whiteColor];
			tmpCell.imageView.image = nil;
			break;
			
		case kBozukoHomeViewController_BozukoForBusinessSection:
			tmpCell.textLabel.text = @"Bozuko for Business";
			tmpCell.textLabel.textColor = [UIColor blackColor];
			tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
			tmpCell.backgroundColor = [UIColor whiteColor];
			tmpCell.imageView.image = nil;
			break;
			
		case kBozukoHomeViewController_TermsOfUseSection:
			tmpCell.textLabel.text = @"Terms of Use";
			tmpCell.textLabel.textColor = [UIColor blackColor];
			tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
			tmpCell.backgroundColor = [UIColor whiteColor];
			tmpCell.imageView.image = nil;
			break;
			
		case kBozukoHomeViewController_PlayOurGameSection:
			tmpCell.textLabel.text = @"Play Our Game!";
			tmpCell.textLabel.textColor = [UIColor whiteColor];
			tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
			tmpCell.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0];
			tmpCell.imageView.image = nil;
			break;
			
		case kBozukoHomeViewController_DemoGameSection:
			tmpCell.textLabel.text = @"Demo Games";
			tmpCell.textLabel.textColor = [UIColor blackColor];
			tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
			tmpCell.backgroundColor = [UIColor whiteColor];
			tmpCell.imageView.image = nil;
			break;
	}
	
	return tmpCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == kBozukoHomeViewController_ProfileSection)
		return;
	else if (indexPath.section == kBozukoHomeViewController_LoginSection)
	{
		if ([[UserHandler sharedInstance] loggedIn] == YES)
		{
			[[BozukoHandler sharedInstance] bozukoLogout];
			[[BozukoHandler sharedInstance] bozukoEntryPoint];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserAttemptLogin object:nil];
		}
		
		return;
	}
	else if (indexPath.section == kBozukoHomeViewController_PlayOurGameSection)
	{
		if ([[BozukoHandler sharedInstance] defaultBozukoGame] != nil)
		{
			GamesDetailViewController *tmpViewController = [[GamesDetailViewController alloc] init];
			tmpViewController.bozukoPage = [[BozukoHandler sharedInstance] defaultBozukoGame];
			[self.navigationController pushViewController:tmpViewController animated:YES];
			[tmpViewController release];
		}
		
		return;
	}
	else if (indexPath.section == kBozukoHomeViewController_DemoGameSection)
	{
		if ([[BozukoHandler sharedInstance] demoBozukoGame] != nil)
		{
			GamesDetailViewController *tmpViewController = [[GamesDetailViewController alloc] init];
			tmpViewController.bozukoPage = [[BozukoHandler sharedInstance] demoBozukoGame];
			[self.navigationController pushViewController:tmpViewController animated:YES];
			[tmpViewController release];
		}
		
		return;
	}
	else if (indexPath.section == kBozukoHomeViewController_HowToPlaySection)
	{
		HowToPlayViewController *tmpViewController = [[HowToPlayViewController alloc] init];
		UINavigationController *tmpNavigationController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
		tmpNavigationController.navigationBar.tintColor = [UIColor blackColor];
		[tmpViewController release];
		
		[self presentModalViewController:tmpNavigationController animated:YES];
		[tmpNavigationController release];
		
		return;
	}
	
	NSString *tmpTitle = nil;
	NSString *tmpURI = nil;
	
	switch (indexPath.section)
	{
		case kBozukoHomeViewController_PrivacyPolicySection:
			tmpTitle = @"Privacy Policy";
			tmpURI = [[[BozukoHandler sharedInstance] apiBozuko] privacyPolicy];
			break;
			
//		case kBozukoHomeViewController_HowToPlaySection:
//			tmpTitle = @"How to Play?";
//			tmpURI = [[[BozukoHandler sharedInstance] apiBozuko] howToPlay];
//			break;
			
		case kBozukoHomeViewController_AboutBozukoSection:
			tmpTitle = @"About Bozuko";
			tmpURI = [[[BozukoHandler sharedInstance] apiBozuko] about];
			break;
			
		case kBozukoHomeViewController_BozukoForBusinessSection:
			tmpTitle = @"Bozuko for Business";
			tmpURI = [[[BozukoHandler sharedInstance] apiBozuko] bozukoForBusiness];
			break;
			
		case kBozukoHomeViewController_TermsOfUseSection:
			tmpTitle = @"Terms of Use";
			tmpURI = [[[BozukoHandler sharedInstance] apiBozuko] termsOfUse];
			break;
	}
	
	if (tmpURI == nil || [tmpURI isEqualToString:@""] == YES)
		return; // Don't even bother opening a web view if URL is nil.
	
	NSString *tmpRequestString = [NSString stringWithFormat:@"%@%@?mobile_version=%@", [[BozukoHandler sharedInstance] baseURL], tmpURI, kApplicationVersion];
	
	WebViewController *tmpViewController = [[WebViewController alloc] initWithRequest:tmpRequestString];
	
	UIBarButtonItem *tmpBarButtonItem = [[UIBarButtonItem alloc] init];
	tmpBarButtonItem.target = self;
	tmpBarButtonItem.action = @selector(dismissModalViewControllerAnimated:);
	tmpBarButtonItem.title = @"Close";
	tmpViewController.navigationItem.leftBarButtonItem = tmpBarButtonItem;
	tmpViewController.navigationItem.title = tmpTitle;
	[tmpBarButtonItem release];
	
	UINavigationController *tmpNavigationController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
	tmpNavigationController.navigationBar.tintColor = [UIColor blackColor];
	[tmpViewController release];
	
	[self presentModalViewController:tmpNavigationController animated:YES];
	[tmpNavigationController release];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_profileImageView.image = [[ImageHandler sharedInstance] nonCachedImageForURL:[[[UserHandler sharedInstance] apiUser] image]];
}

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
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 367.0) style:UITableViewStyleGrouped];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	[_tableView release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogginStatusChanged) name:kBozukoHandler_UserLoginStatusChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageWasUpdated:) name:kImageHandler_ImageWasUpdatedNotification object:nil];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Notification Methods

- (void)imageWasUpdated:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[NSString class]] == NO)
		return;
	
	if ([[inNotification object] isEqualToString:[[[UserHandler sharedInstance] apiUser] image]] == YES)
		_profileImageView.image = [[ImageHandler sharedInstance] nonCachedImageForURL:[[[UserHandler sharedInstance] apiUser] image]];
}

- (void)userLogginStatusChanged
{
	_profileImageView.image = nil;
	[_tableView reloadData];
}

@end
