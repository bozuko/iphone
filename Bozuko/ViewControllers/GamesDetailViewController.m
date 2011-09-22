//
//  BozukoHomeViewController.m
//  Bozuko
//
//  Created by Tom Corwine on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamesDetailViewController.h"
#import "BusinessDetailGamesTableCell.h"
#import "BusinessDetailHeaderTableCell.h"
#import "GameTermsViewController.h"
#import "RecommendTableCell.h"
#import "BozukoPage.h"
#import "MapViewController.h"
#import "BozukoGame.h"
#import "UserHandler.h"
#import "BozukoHandler.h"
#import "BozukoLocation.h"

#define kGamesDetailHeaderSection		0
#define kGamesDetailGamesSection		1
#define kGamesDetailAnnouncementSection	2
#define kGamesDetailFacebookSection		3
#define kGamesDetailFeedbackSection		4

@implementation GamesDetailViewController

@synthesize bozukoPage = _bozukoPage;

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
	[[NSNotificationCenter defaultCenter] removeObserver:_tableView];
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	_tableView.delegate = nil;
	_tableView.dataSource = nil;
	[_bozukoPage release];
	
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
	switch ([_bozukoPage registered])
	{
		default:
		case NO:
			return 3;
			break;
			
		case YES:
			{
				NSInteger tmpNumberOfSections = 3;
				
				if ([[_bozukoPage announcement] length] > 0)
					tmpNumberOfSections++;
				
				if ([_bozukoPage isPlace])
					tmpNumberOfSections++;
				
				//DLog(@"%d", tmpNumberOfSections);
				
				return tmpNumberOfSections;
			}
			break;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger tmpSection = section;
	
	if (tmpSection == kGamesDetailGamesSection)
	{
		if ([[_bozukoPage games] count] > 0)
			return [[_bozukoPage games] count];
		else if ([_bozukoPage registered] == YES)
			return 1; // Registered business, but no current contests
		else
			return 2; // Not a registered business, create 2 cells for "Recommend" button
	}
	
	if ([_bozukoPage announcement] == nil || [[_bozukoPage announcement] isEqualToString:@""])
		tmpSection++; // Skip the Announcement section if there's no announcement.
	
	if ([_bozukoPage isPlace] == NO)
		tmpSection++; // Skip Facebook section if this isn't a place.
	
	if (tmpSection == kGamesDetailFacebookSection)
		return 1;
		
	if (tmpSection == kGamesDetailFeedbackSection)
		return 2;
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger tmpSection = indexPath.section;
	BozukoLocation *tmpBozukoLocation = [_bozukoPage location];
	
	if (tmpSection == kGamesDetailHeaderSection)
	{
		CGSize tmpSize = [[_bozukoPage pageName] sizeWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToSize:CGSizeMake(140.0, 300.0)];
		CGFloat tmpVerticalHeight = tmpSize.height;
		
		if (tmpVerticalHeight < 44.0 && [_bozukoPage registered] == YES &&
			([[tmpBozukoLocation city] length] > 0 || [[tmpBozukoLocation state] length] > 0))
			tmpVerticalHeight = 44.0; // Insure cell is big enought for "like" button
		
		return tmpVerticalHeight + 80.0; // +80.0 for rest of content
	}
	
	if (tmpSection == kGamesDetailGamesSection && [[_bozukoPage games] count] == 0)
	{
		if (indexPath.row == 0)
			return 80.0;
		else
			return 44.0;
	}
	
	if (tmpSection == kGamesDetailGamesSection)
		return 55.0;
	
	//if ([[_bozukoPage games] count] == 0)
		//tmpSection = tmpSection + 2; // Skip the Announcement and Feedback/Share section if there's no games.
	
	if ([_bozukoPage announcement] == nil || [[_bozukoPage announcement] isEqualToString:@""])
		tmpSection++; //Skip the announcement if it's empty.
	
	if ([_bozukoPage registered] == NO)
		tmpSection++; // Skip Feedback/Share if not a registered business
	
	if (tmpSection == kGamesDetailAnnouncementSection)
	{
		CGSize tmpSize = [[_bozukoPage announcement] sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(280.0, 300.0)];
		
		return tmpSize.height + 20; // +20.0 for padding
	}
	
	return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger tmpSection = indexPath.section;
	
	if (tmpSection == kGamesDetailHeaderSection)
	{
		BusinessDetailHeaderTableCell *tmpCell = (BusinessDetailHeaderTableCell *)[_tableView dequeueReusableCellWithIdentifier:@"BusinessDetailHeader"];
		
		if (tmpCell == nil)
			tmpCell = [[[BusinessDetailHeaderTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BusinessDetailHeader"] autorelease];
		
		tmpCell.controller = self;
		[tmpCell populateContent];
		
		return tmpCell;
	}
	
	if (tmpSection == kGamesDetailGamesSection)
	{
		if ([[_bozukoPage games] count] > 0)
		{
			BusinessDetailGamesTableCell *tmpCell = (BusinessDetailGamesTableCell *)[_tableView dequeueReusableCellWithIdentifier:@"BusinessDetailGamesTableCell"];
			
			if (tmpCell == nil)
				tmpCell = [[[BusinessDetailGamesTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BusinessDetailGamesTableCell"] autorelease];
			
			[tmpCell populateContentForGame:[[_bozukoPage games] objectAtIndex:indexPath.row]];
			
			return tmpCell;
		}
		else if ([_bozukoPage registered] == YES)
		{
			RecommendTableCell *tmpCell = (RecommendTableCell *)[_tableView dequeueReusableCellWithIdentifier:@"DetailTableCell"];
			
			if (tmpCell == nil)
				tmpCell = [[[RecommendTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DetailTableCell"] autorelease];
			
			tmpCell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			tmpCell.mainLabel.text = @"Bummer!";
			tmpCell.detailLabel.text = @"This place has no current games.\nPlease check back later.";
			
			tmpCell.mainLabel.font = [UIFont boldSystemFontOfSize:18.0];
			tmpCell.mainLabel.textAlignment = UITextAlignmentCenter;
			
			tmpCell.detailLabel.font = [UIFont systemFontOfSize:14.0];
			tmpCell.detailLabel.textAlignment = UITextAlignmentCenter;
			tmpCell.detailLabel.textColor = [UIColor grayColor];
			tmpCell.detailLabel.lineBreakMode = UILineBreakModeWordWrap;
			tmpCell.detailLabel.numberOfLines = 0;
			tmpCell.detailLabel.textColor = [UIColor grayColor];
			
			return tmpCell;
		}
		else
		{			
			if (indexPath.row == 0)
			{
				RecommendTableCell *tmpCell = (RecommendTableCell *)[_tableView dequeueReusableCellWithIdentifier:@"DetailTableCell"];
				
				if (tmpCell == nil)
					tmpCell = [[[RecommendTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DetailTableCell"] autorelease];
				
				tmpCell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				tmpCell.mainLabel.text = @"Bummer!";
				tmpCell.detailLabel.text = @"This place has no games.\nRecommend Bozuko to this business.";

				tmpCell.mainLabel.font = [UIFont boldSystemFontOfSize:18.0];
				tmpCell.mainLabel.textAlignment = UITextAlignmentCenter;
				
				tmpCell.detailLabel.font = [UIFont systemFontOfSize:14.0];
				tmpCell.detailLabel.textAlignment = UITextAlignmentCenter;
				tmpCell.detailLabel.textColor = [UIColor grayColor];
				tmpCell.detailLabel.lineBreakMode = UILineBreakModeWordWrap;
				tmpCell.detailLabel.numberOfLines = 0;
				tmpCell.detailLabel.textColor = [UIColor grayColor];
				
				return tmpCell;
			}
			else
			{
				UITableViewCell *tmpCell = [_tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
				
				if (tmpCell == nil)
					tmpCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"] autorelease];
				
				tmpCell.backgroundColor = [UIColor whiteColor];
				tmpCell.textLabel.textColor = [UIColor blackColor];
				tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
				tmpCell.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
				tmpCell.textLabel.text = @"Recommend";
				
				return tmpCell;
			}
		}
	}
	
	if ([_bozukoPage announcement] == nil || [[_bozukoPage announcement] isEqualToString:@""])
		tmpSection++; // Skip the announcement if it's empty.
	
	if (tmpSection == kGamesDetailAnnouncementSection)
	{
		UITableViewCell *tmpCell = [_tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
		
		if (tmpCell == nil)
			tmpCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"] autorelease];
		
		tmpCell.backgroundColor = [UIColor blackColor];
		tmpCell.imageView.image = nil;
		tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
		tmpCell.textLabel.numberOfLines = 0;
		tmpCell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		tmpCell.textLabel.textColor = [UIColor whiteColor];
		tmpCell.textLabel.font = [UIFont systemFontOfSize:12.0];
		
		tmpCell.textLabel.text = [_bozukoPage announcement];
		tmpCell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return tmpCell;
	}
	
	if ([_bozukoPage isPlace] == NO)
		tmpSection++; // Skip Facebook section if this isn't a place.
	
	if (tmpSection == kGamesDetailFeedbackSection)
	{
		UITableViewCell *tmpCell = [_tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
		
		if (tmpCell == nil)
			tmpCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"] autorelease];
		
		tmpCell.imageView.image = nil;
		tmpCell.backgroundColor = [UIColor whiteColor];
		tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
		tmpCell.textLabel.textColor = [UIColor darkGrayColor];
		tmpCell.selectionStyle = UITableViewCellSelectionStyleBlue;
		
		if (indexPath.row == 0) 
			tmpCell.textLabel.text = @"Feedback";
		else
			tmpCell.textLabel.text = @"Share";
		
		return tmpCell;
	}
	else if (tmpSection == kGamesDetailFacebookSection)
	{
		UITableViewCell *tmpCell = [_tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
		
		if (tmpCell == nil)
			tmpCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"] autorelease];

		tmpCell.backgroundColor = [UIColor whiteColor];
		tmpCell.imageView.image = [UIImage imageNamed:@"images/facebookIcon"];
		tmpCell.textLabel.textAlignment = UITextAlignmentCenter;
		tmpCell.textLabel.textColor = [UIColor darkGrayColor];
		tmpCell.selectionStyle = UITableViewCellSelectionStyleBlue;
		
		//if (indexPath.row == 0 && [_bozukoPage isPlace] == YES)
		tmpCell.textLabel.text = @"Facebook Check In";
		/*
		else
		{
			if ([_bozukoPage liked] == YES)
			{
				tmpCell.textLabel.text = @"You like this place";
				tmpCell.selectionStyle = UITableViewCellEditingStyleNone;
			}
			else
			{
				tmpCell.textLabel.text = @"Like Us on Facebook";
				tmpCell.selectionStyle = UITableViewCellSelectionStyleBlue;
			}
		}
		 */
		
		return tmpCell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSInteger tmpSection = indexPath.section;
	
	if (tmpSection == kGamesDetailHeaderSection && [_bozukoPage isPlace] == YES)
	{
		MapViewController *tmpViewController = [[MapViewController alloc] initWithPage:_bozukoPage];
		[self.navigationController pushViewController:tmpViewController animated:YES];
		[tmpViewController release];
		
		return;
	}
	else if (tmpSection == kGamesDetailGamesSection && [[_bozukoPage games] count] > 0)
	{
		if ([[UserHandler sharedInstance] loggedIn] == YES)
		{
			GameTermsViewController *tmpViewController = [[GameTermsViewController alloc] init];
			tmpViewController.bozukoPage = _bozukoPage;
			//tmpViewController.bozukoGame = [[_bozukoPage games] objectAtIndex:indexPath.row];
			tmpViewController.bozukoGameIndex = indexPath.row;
			[self.navigationController pushViewController:tmpViewController animated:YES];
			[tmpViewController release];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserAttemptLogin object:nil];
		}
		
		return;
	}
	else if (tmpSection == kGamesDetailGamesSection)
	{
		if (indexPath.row == 0)
			return;
		
		if ([[UserHandler sharedInstance] loggedIn] == YES)
		{
			GameFeedbackViewController *tmpViewController = [[GameFeedbackViewController alloc] initWithSubmitButtonTitle:@"Submit"];
			UINavigationController *tmpNavController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
			tmpViewController.navigationItem.title = @"Recommend";
			tmpViewController.placeholderText = @"Think this place should rock Bozuko? Tell them here and hit submit.";
			[tmpViewController setCompletionBlock:^{
				[[BozukoHandler sharedInstance] bozukoRecommendMessage:tmpViewController.textView.text forPage:_bozukoPage];
			}];
			[tmpNavController.navigationBar setBarStyle:UIBarStyleBlack];
			[self presentModalViewController:tmpNavController animated:YES];
			[tmpNavController release];
			[tmpViewController release];
		}
		else
		{
			// User is not logged in
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserAttemptLogin object:nil];
		}
		
		return;
	}
	
	if ([_bozukoPage announcement] == nil || [[_bozukoPage announcement] isEqualToString:@""])
		tmpSection++; // Skip the announcement if it's empty.
	
	if ([_bozukoPage isPlace] == NO)
		tmpSection++; // Skip Facebook section if this isn't a place.
	
	if (tmpSection == kGamesDetailFeedbackSection)
	{
		if (indexPath.row == 0 && [[UserHandler sharedInstance] loggedIn] == YES)
		{
			GameFeedbackViewController *tmpViewController = [[GameFeedbackViewController alloc] initWithSubmitButtonTitle:@"Submit"];
			UINavigationController *tmpNavController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
			tmpViewController.navigationItem.title = @"Feedback";
			tmpViewController.placeholderText = @"Tell us what you think about this game and press \"Submit\"";
			[tmpViewController setCompletionBlock:^{
				[[BozukoHandler sharedInstance] bozukoFeedback:tmpViewController.textView.text forPage:_bozukoPage];
			}];
			[tmpNavController.navigationBar setBarStyle:UIBarStyleBlack];
			[self presentModalViewController:tmpNavController animated:YES];
			[tmpNavController release];
			[tmpViewController release];
		}
		else if (indexPath.row == 0)
		{
			// User is not logged in
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserAttemptLogin object:nil];
		}
		else
		{
			UIActionSheet *tmpActionSheet = nil;
			
			if ([MFMailComposeViewController canSendMail] == YES && [MFMessageComposeViewController canSendText] == YES)
				tmpActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"SMS", nil];
			else if ([MFMailComposeViewController canSendMail] == YES)
				tmpActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", nil];
			else if ([MFMessageComposeViewController canSendText] == YES)
				tmpActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"SMS", nil];
			else
				return;
			
			[tmpActionSheet showFromTabBar:self.tabBarController.tabBar];
			[tmpActionSheet release];
		}
	}
	else if (tmpSection == kGamesDetailFacebookSection)
	{
		if (indexPath.row == 0 && [_bozukoPage isPlace] == YES && [[UserHandler sharedInstance] loggedIn] == YES)
		{
			GameFeedbackViewController *tmpViewController = [[GameFeedbackViewController alloc] initWithSubmitButtonTitle:@"Check In"];
			tmpViewController.requireTextFieldToBePopulated = NO;
			UINavigationController *tmpNavController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
			tmpViewController.navigationItem.title = @"Check In";
			tmpViewController.placeholderText = @"Type a message, then\npress \"Submit\" to Check In";
			[tmpViewController setCompletionBlock:^{
				[[BozukoHandler sharedInstance] bozukoFacebookCheckInMessage:tmpViewController.textView.text forPage:_bozukoPage];
			}];
			[tmpNavController.navigationBar setBarStyle:UIBarStyleBlack];
			[self presentModalViewController:tmpNavController animated:YES];
			[tmpNavController release];
			[tmpViewController release];
		}
		else
		//else if (indexPath.row == 0 && [_bozukoPage isPlace] == YES)
		{
			// User is not logged in
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserAttemptLogin object:nil];
		}
		/*
		else
		{
			if ([_bozukoPage liked] == NO && [[UserHandler sharedInstance] loggedIn] == YES)
			{
				NSString *tmpRequestString = [_bozukoPage likeURL];
				if (tmpRequestString == nil || [tmpRequestString isEqualToString:@""] == YES)
					return; // Don't even bother opening a web view if URL is invalid.
				
				FacebookLikeWebViewController *tmpViewController = [[FacebookLikeWebViewController alloc] initWithRequest:tmpRequestString];
				tmpViewController.delegate = self;
				
				UIBarButtonItem *tmpBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewControllerAnimated:)];
				tmpViewController.navigationItem.rightBarButtonItem = tmpBarButtonItem;
				tmpViewController.navigationItem.title = @"Facebook Like";
				[tmpBarButtonItem release];
				
				UINavigationController *tmpNavigationController = [[UINavigationController alloc] initWithRootViewController:tmpViewController];
				tmpNavigationController.navigationBar.tintColor = [UIColor blackColor];
				[tmpViewController release];
				
				[self presentModalViewController:tmpNavigationController animated:YES];
				[tmpNavigationController release];
			}
			else if ([_bozukoPage liked] == NO)
				[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserAttemptLogin object:nil];
		}
		*/
	}
}

- (void)favoriteButtonWasPressed:(id)sender
{
	if ([[UserHandler sharedInstance] loggedIn] == YES)
	{
		[[BozukoHandler sharedInstance]	bozukoToggleFavoriteForPage:_bozukoPage];
		
		UIButton *tmpButton = sender;
		
		if (tmpButton.selected == YES)
		{
			tmpButton.selected = NO;
			[_bozukoPage setFavorite:NO];
		}
		else
		{
			tmpButton.selected = YES;
			[_bozukoPage setFavorite:YES];
		}
	}
	else
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserAttemptLogin object:nil];
	}
}

- (void)shareViaEmailButtonWasPressed
{
	MFMailComposeViewController* tmpViewController = [[MFMailComposeViewController alloc] init];
	tmpViewController.mailComposeDelegate = self;
	[tmpViewController setSubject:[_bozukoPage pageName]];
	[tmpViewController setMessageBody:[_bozukoPage shareURL] isHTML:NO]; 
	[self presentModalViewController:tmpViewController animated:YES];
	[tmpViewController release];
}

- (void)shareViaSMSButtonWasPressed
{
	MFMessageComposeViewController* tmpViewController = [[MFMessageComposeViewController alloc] init];
	tmpViewController.messageComposeDelegate = self;
	[tmpViewController setBody:[_bozukoPage shareURL]];
	[self presentModalViewController:tmpViewController animated:YES];
	[tmpViewController release];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

#pragma mark UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Email"] == YES)
		[self shareViaEmailButtonWasPressed];
	else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"SMS"] == YES)
		[self shareViaSMSButtonWasPressed];
}

#pragma mark Mail/SMS Composer Delegates

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	if (result == MFMailComposeResultFailed)
	{
		DLog(@"It didn't work!");
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	if (result == MessageComposeResultFailed)
	{
		DLog(@"It didn't work!");
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated
{
	[_tableView reloadData];
	
	// If there are games, make sure they're are updated
	//if ([[_bozukoPage games] count] > 0)
		//[[BozukoHandler sharedInstance] bozukoPageRefreshForPage:_bozukoPage];
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
	
	[[NSNotificationCenter defaultCenter] addObserver:_tableView selector:@selector(reloadData) name:kBozukoHandler_SuccessResponseNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageUpdateDidFinish:) name:kBozukoHandler_PageDidFinish object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageUpdateDidFail:) name:kBozukoHandler_PageDidFail object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePage) name:kBozukoHandler_GetPagesForLocationDidFinish object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark BozukoHandler Notification Methods

- (void)pageUpdateDidFinish:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[BozukoPage class]] == NO)
		return;
	
	if ([[[inNotification object] pageID] isEqualToString:[_bozukoPage pageID]] == NO)
		return;
	
	[_bozukoPage release];
	_bozukoPage = [[inNotification object] retain];
	
	[_tableView reloadData];
}

- (void)pageUpdateDidFail:(NSNotification *)inNotification
{
}

- (void)updatePage
{
	BozukoPage *tmpBozukoPage = [[BozukoHandler sharedInstance] currentPageForPage:_bozukoPage];
	
	[_bozukoPage release];
	_bozukoPage = [tmpBozukoPage retain];
	
	[_tableView reloadData];
}

@end
