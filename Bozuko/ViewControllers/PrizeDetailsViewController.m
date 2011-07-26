//
//  PrizeDetailsViewController.m
//  Bozuko
//
//  Created by Christopher Luu on 5/18/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import "PrizeDetailsViewController.h"
#import "BozukoRedemption.h"
#import "BozukoHandler.h"
#import "ImageHandler.h"
#import "UserHandler.h"
#import "BozukoUser.h"
#import "UIView+OriginSize.h"
#import "NSDate+Formatter.h"
#import "GamePrizeDetailView.h"

@interface PrizeDetailsViewController (Private)
- (void)doClose;
@end

@implementation PrizeDetailsViewController

@synthesize delegate = _delegate;
@synthesize bozukoRedemption = _bozukoRedemption;
@synthesize countdownTimer = _countdownTimer;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_bozukoPrize release];
	[_bozukoRedemption release];
	[_closeBarButton release];
	[_doneBarButton release];
	
	[_countdownTimer invalidate];
	self.countdownTimer = nil;
	
	[super dealloc];
}

- (id)initWithBozukoPrize:(BozukoPrize *)inPrize
{
	if ((self = [super init]))
	{
		_bozukoPrize = [inPrize retain];
		[self setTitle:[_bozukoPrize pageName]];
	}
	return self;
}

- (void)loadView
{
	UIImageView *tmpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"images/profileBG.png"]];
	[tmpImageView setUserInteractionEnabled:YES];
	[self setView:tmpImageView];
	[tmpImageView release];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.hidesBackButton = YES;
	
	_closeBarButton = [[UIBarButtonItem alloc] init];
	_closeBarButton.target = _delegate;
	_closeBarButton.action = @selector(closeView);
	_closeBarButton.title = @"Close";
	self.navigationItem.leftBarButtonItem = _closeBarButton;
	
	_doneBarButton = [[UIBarButtonItem alloc] init];
	_doneBarButton.target = self;
	_doneBarButton.action = @selector(doneButtonWasPressed);
	_doneBarButton.title = @"Done";

	[self refreshView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageWasUpdated:) name:kImageHandler_ImageWasUpdatedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeInactive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)refreshView
{
	for (UIView *tmpView in [self.view subviews])
		[tmpView removeFromSuperview];
	
	_countdownLabel = nil; // Prevent NSTimer from trying to update this as view is refreshed.
	
	UIImageView *tmpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"images/bozukoLogo.png"]];
	[tmpImageView setOrigin:CGPointMake(17, 20)];
	[[self view] addSubview:tmpImageView];
	[tmpImageView release];
	
	_chipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(263, 18, 34, 34)];
	[_chipImageView setContentMode:UIViewContentModeScaleAspectFill];
	[[self view] addSubview:_chipImageView];
	[_chipImageView release];
	
	// Horizontal divider
	UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(15, 59, 282, 1)];
	[tmpView setBackgroundColor:[UIColor colorWithRed:(164.0/255.0) green:(164.0/255.0) blue:(164.0/255.0) alpha:1.0]];
	[[self view] addSubview:tmpView];
	[tmpView release];
	
	UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 66, 50, 21)];
	[tmpLabel setBackgroundColor:[UIColor clearColor]];
	[tmpLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[tmpLabel setTextColor:[UIColor colorWithRed:(153.0/255.0) green:(153.0/255.0) blue:(153.0/255.0) alpha:1.0]];
	[tmpLabel setText:@"Prize:"];
	[[self view] addSubview:tmpLabel];
	[tmpLabel release];
	
	UILabel *tmpPrizeLabel = nil;

	if ((_bozukoRedemption == nil && [_bozukoPrize isEmail] == NO && [_bozukoPrize isBarcode] == NO) || [_bozukoPrize isEmail] == YES || [_bozukoPrize isBarcode] == YES)
	{
		CGSize tmpSize = [[_bozukoPrize name] sizeWithFont:[UIFont systemFontOfSize:20.0] constrainedToSize:CGSizeMake(277.0, 50.0)];
		tmpPrizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 86, 277, tmpSize.height)];
		
		// Underline
//		UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(19.0, 84.0 + 20, tmpSize.width, 1.0)];
//		tmpView.backgroundColor = [UIColor blackColor];
//		[self.view addSubview:tmpView];
//		[tmpView release];
		
//		UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		tmpButton.frame = CGRectMake(19, 86, 277, tmpSize.height);
//		[tmpButton addTarget:self action:@selector(prizeDetailsButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
//		[self.view addSubview:tmpButton];
	}
	else
	{
		// Vertical divider
		UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(200, 64, 1, 130)];
		[tmpView setBackgroundColor:[UIColor colorWithRed:(164.0/255.0) green:(164.0/255.0) blue:(164.0/255.0) alpha:1.0]];
		[[self view] addSubview:tmpView];
		[tmpView release];
		
		UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(215, 65, 100, 21)];
		[tmpLabel setBackgroundColor:[UIColor clearColor]];
		[tmpLabel setFont:[UIFont boldSystemFontOfSize:16]];
		[tmpLabel setTextColor:[UIColor darkGrayColor]];
		[tmpLabel setText:@"Expires in"];
		[[self view] addSubview:tmpLabel];
		[tmpLabel release];
		
		_countdownLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 70, 90, 100)];
		[_countdownLabel setBackgroundColor:[UIColor clearColor]];
		[_countdownLabel setFont:[UIFont boldSystemFontOfSize:80.0]];
		_countdownLabel.textAlignment = UITextAlignmentRight;
		_countdownLabel.minimumFontSize = 40.0;
		[_countdownLabel setTextColor:[UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0]];
		[_countdownLabel setText:[NSString stringWithFormat:@"%d", [_bozukoPrize redemptionDuration]]];
		[[self view] addSubview:_countdownLabel];
		[_countdownLabel release];
		
		tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(215, 160, 100, 21)];
		[tmpLabel setBackgroundColor:[UIColor clearColor]];
		[tmpLabel setFont:[UIFont systemFontOfSize:20.0]];
		[tmpLabel setTextColor:[UIColor grayColor]];
		[tmpLabel setText:@"Seconds"];
		[[self view] addSubview:tmpLabel];
		[tmpLabel release];
		
		CGSize tmpSize = [[_bozukoPrize name] sizeWithFont:[UIFont systemFontOfSize:20.0] constrainedToSize:CGSizeMake(170.0, 50.0)];
		tmpPrizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 86, 170, tmpSize.height)];
		
		// Underline
//		UIView *tmpLineView = [[UIView alloc] initWithFrame:CGRectMake(19.0, 84.0 + 20, tmpSize.width, 1.0)];
//		tmpLineView.backgroundColor = [UIColor blackColor];
//		[self.view addSubview:tmpLineView];
//		[tmpLineView release];
		
//		UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		tmpButton.frame = CGRectMake(19, 86, 170, tmpSize.height);
//		[tmpButton addTarget:self action:@selector(prizeDetailsButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
//		[self.view addSubview:tmpButton];
	}
	
	[tmpPrizeLabel setBackgroundColor:[UIColor clearColor]];
	[tmpPrizeLabel setFont:[UIFont boldSystemFontOfSize:20]];
	[tmpPrizeLabel setText:[_bozukoPrize name]];
	[tmpPrizeLabel setNumberOfLines:0];
	tmpPrizeLabel.lineBreakMode = UILineBreakModeWordWrap;
	[[self view] addSubview:tmpPrizeLabel];
	[tmpPrizeLabel release];
	
	tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 140, 50, 21)];
	[tmpLabel setBackgroundColor:[UIColor clearColor]];
	[tmpLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[tmpLabel setTextColor:[UIColor colorWithRed:(153.0/255.0) green:(153.0/255.0) blue:(153.0/255.0) alpha:1.0]];
	[tmpLabel setText:@"Code:"];
	[[self view] addSubview:tmpLabel];
	[tmpLabel release];
	
	UILabel *tmpCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 162, 277, 25)];
	[tmpCodeLabel setBackgroundColor:[UIColor clearColor]];
	[tmpCodeLabel setFont:[UIFont boldSystemFontOfSize:20]];
	[tmpCodeLabel setText:[_bozukoPrize code]];
	[[self view] addSubview:tmpCodeLabel];
	[tmpCodeLabel release];
	
	// Horizontal divider
	tmpView = [[UIView alloc] initWithFrame:CGRectMake(15, 198, 282, 1)];
	[tmpView setBackgroundColor:[UIColor colorWithRed:(164.0/255.0) green:(164.0/255.0) blue:(164.0/255.0) alpha:1.0]];
	[[self view] addSubview:tmpView];
	[tmpView release];
	
	if ([_bozukoPrize isBarcode] == YES && [_bozukoPrize state] != BozukoPrizeStateExpired)
	{
		UILabel *tmpStatusDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 210, 174, 48)];
		[tmpStatusDescriptionLabel setBackgroundColor:[UIColor clearColor]];
		[tmpStatusDescriptionLabel setFont:[UIFont boldSystemFontOfSize:20]];
		[tmpStatusDescriptionLabel setTextAlignment:UITextAlignmentCenter];
		[tmpStatusDescriptionLabel setNumberOfLines:2];
		[[self view] addSubview:tmpStatusDescriptionLabel];
		[tmpStatusDescriptionLabel release];
		
		NSDate *tmpDate = [NSDate dateFromString:[_bozukoPrize redeemedTimestamp] format:BozukoPrizeStandardTimestamp];
		[tmpStatusDescriptionLabel setText:[NSString stringWithFormat:@"REDEEMED\n%@", [tmpDate stringWithDateFormat:@"h:mma MM/dd/yy"]]];
		[tmpStatusDescriptionLabel setTextColor:[UIColor blueColor]];
		
		tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 208, 52, 52)];
		[tmpImageView setImage:[UIImage imageNamed:@"images/photoDefaultLarge.png"]];
		[[self view] addSubview:tmpImageView];
		[tmpImageView release];
		
		_userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 209.0, 50.0, 50.0)];
		_userImageView.image = [[ImageHandler sharedInstance] nonCachedImageForURL:[_bozukoPrize userImage]];
		[[self view] addSubview:_userImageView];
		[_userImageView release];
		
		tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(249, 208, 52, 52)];
		[tmpImageView setImage:[UIImage imageNamed:@"images/photoDefaultLarge.png"]];
		[[self view] addSubview:tmpImageView];
		[tmpImageView release];
		
		_pageIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(250.0, 209.0, 50.0, 50.0)];
		_pageIconImageView.image = [[ImageHandler sharedInstance] nonCachedImageForURL:[_bozukoPrize businessImage]];
		
		[self.view addSubview:_pageIconImageView];
		[_pageIconImageView release];
	}
	else
	{
		tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 212, 85, 85)];
		[tmpImageView setImage:[UIImage imageNamed:@"images/photoDefaultLarge.png"]];
		[[self view] addSubview:tmpImageView];
		[tmpImageView release];
		
		_userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(21.0, 213.0, 81.0, 81.0)];
		_userImageView.image = [[ImageHandler sharedInstance] nonCachedImageForURL:[_bozukoPrize userImage]];
		[[self view] addSubview:_userImageView];
		[_userImageView release];
		
		tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19, 311, 85, 85)];
		[tmpImageView setImage:[UIImage imageNamed:@"images/photoDefaultLarge.png"]];
		[[self view] addSubview:tmpImageView];
		[tmpImageView release];
		
		_pageIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(21.0, 313.0, 81.0, 81.0)];
		_pageIconImageView.image = [[ImageHandler sharedInstance] nonCachedImageForURL:[_bozukoPrize businessImage]];
		
		[self.view addSubview:_pageIconImageView];
		[_pageIconImageView release];
	}
	
	if ((_bozukoRedemption == nil && [_bozukoPrize isEmail] == NO && [_bozukoPrize isBarcode] == NO) ||
		([_bozukoPrize isBarcode] == YES && [_bozukoPrize state] == BozukoPrizeStateExpired) ||
		[_bozukoPrize isEmail] == YES)
	{
		UILabel *tmpStatusDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(117, 230, 174, 48)];
		[tmpStatusDescriptionLabel setBackgroundColor:[UIColor clearColor]];
		[tmpStatusDescriptionLabel setFont:[UIFont boldSystemFontOfSize:20]];
		[tmpStatusDescriptionLabel setTextAlignment:UITextAlignmentCenter];
		[tmpStatusDescriptionLabel setNumberOfLines:2];
		[[self view] addSubview:tmpStatusDescriptionLabel];
		[tmpStatusDescriptionLabel release];
		
		UILabel *tmpActionDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(117, 327, 183, 21)];
		[tmpActionDescriptionLabel setBackgroundColor:[UIColor clearColor]];
		[tmpActionDescriptionLabel setFont:[UIFont boldSystemFontOfSize:12]];
		[tmpActionDescriptionLabel setTextAlignment:UITextAlignmentCenter];
		[tmpActionDescriptionLabel setTextColor:[UIColor colorWithRed:(103.0/255.0) green:(103.0/255.0) blue:(103.0/255.0) alpha:1.0]];
		[[self view] addSubview:tmpActionDescriptionLabel];
		[tmpActionDescriptionLabel release];
		
		UILabel *tmpEmailLabel = [[UILabel alloc] initWithFrame:CGRectMake(117, 346, 183, 21)];
		[tmpEmailLabel setBackgroundColor:[UIColor clearColor]];
		[tmpEmailLabel setFont:[UIFont systemFontOfSize:14]];
		[tmpEmailLabel setTextAlignment:UITextAlignmentCenter];
		[[self view] addSubview:tmpEmailLabel];
		[tmpEmailLabel release];
		
		switch ([_bozukoPrize state])
		{
			case BozukoPrizeStateActive:
				[_chipImageView setImage:[UIImage imageNamed:@"images/prizesIconG.png"]];
				[tmpStatusDescriptionLabel setTextColor:[UIColor greenColor]];
				break;
				
			case BozukoPrizeStateExpired:
				[_chipImageView setImage:[UIImage imageNamed:@"images/prizesIconR.png"]];
				
				NSDate *tmpDate = [NSDate dateFromString:[_bozukoPrize expirationTimestamp] format:BozukoPrizeStandardTimestamp];
				[tmpStatusDescriptionLabel setText:[NSString stringWithFormat:@"EXPIRED\n%@", [tmpDate stringWithDateFormat:@"h:mma MM/dd/yy"]]];
				[tmpStatusDescriptionLabel setTextColor:[UIColor redColor]];
				
				[tmpActionDescriptionLabel setText:@"Sorry, this prize has expired"];
				[tmpEmailLabel setFont:[UIFont boldSystemFontOfSize:14]];
				[tmpEmailLabel setText:@"THANK YOU"];
				break;
				
			case BozukoPrizeStateRedeemed:
				[_chipImageView setImage:[UIImage imageNamed:@"images/prizesIconB.png"]];
				
				if ([_bozukoPrize isEmail] == YES)
				{
					tmpDate = [NSDate dateFromString:[_bozukoPrize redeemedTimestamp] format:BozukoPrizeStandardTimestamp];
					[tmpStatusDescriptionLabel setText:[NSString stringWithFormat:@"EMAILED\n%@", [tmpDate stringWithDateFormat:@"h:mma MM/dd/yy"]]];
					[tmpStatusDescriptionLabel setTextColor:[UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0]];
					
					[tmpActionDescriptionLabel setText:@"This prize has been emailed to:"];
					[tmpEmailLabel setFont:[UIFont boldSystemFontOfSize:12]];
					[tmpEmailLabel setText:[[[UserHandler sharedInstance] apiUser] email]];
				}
				else
				{
					tmpDate = [NSDate dateFromString:[_bozukoPrize redeemedTimestamp] format:BozukoPrizeStandardTimestamp];
					[tmpStatusDescriptionLabel setText:[NSString stringWithFormat:@"REDEEMED\n%@", [tmpDate stringWithDateFormat:@"h:mma MM/dd/yy"]]];
					[tmpStatusDescriptionLabel setTextColor:[UIColor blueColor]];
					
					[tmpActionDescriptionLabel setText:@"This prize has been redeemed"];
					[tmpEmailLabel setFont:[UIFont boldSystemFontOfSize:14]];
					[tmpEmailLabel setText:@"THANK YOU"];
				}
				break;
				
			case BozukoPrizeStateUnknown:
				break;
		}
	}
	else if ([_bozukoPrize isBarcode] == YES)
	{
		_securityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 270, 300, 140)];
		//_securityImageView.backgroundColor = [UIColor whiteColor];
		_securityImageView.contentMode = UIViewContentModeScaleAspectFit;
		
		UIImage *tmpImage = [[ImageHandler sharedInstance] nonCachedImageForURL:[_bozukoPrize barcodeImage]];
		_securityImageView.image = tmpImage;
		
		[self.view addSubview:_securityImageView];
		[_securityImageView release];
	}
	else
	{
		_securityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(115, 213, 180, 180)];
		_securityImageView.contentMode = UIViewContentModeScaleAspectFill;
		
		UIImage *tmpImage = [[ImageHandler sharedInstance] nonCachedImageForURL:[_bozukoRedemption securityImageURLString]];
		[self updateSecurityImage:tmpImage];
		
		[self.view addSubview:_securityImageView];
		[_securityImageView release];
	}
	
	//DLog(@"%@", _bozukoPrize);
	//DLog(@"%@", _bozukoRedemption);
}

- (void)countdown
{
	NSInteger tmpSeconds = (_countdownBeginUnixTime + [_bozukoPrize redemptionDuration] + 1) - [[NSDate date] timeIntervalSince1970];
	
	if (tmpSeconds < 1)
	{
		[_countdownTimer invalidate];
		self.countdownTimer = nil;
		
		self.bozukoRedemption = nil;
		[self refreshView];
	}
	
	[_countdownLabel setText:[NSString stringWithFormat:@"%d", tmpSeconds]];
	_securityLabel.text = [[NSDate date] stringWithDateFormat:@"h:mm:ss a"];
}

#pragma mark Notification Methods

- (void)appDidBecomeInactive
{
	_countdownLabel.text = @"";
}

- (void)imageWasUpdated:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[NSString class]] == NO)
		return;
	
	if ([[inNotification object] isEqualToString:[_bozukoPrize businessImage]] == YES)
	{
		UIImage *tmpImage = [[ImageHandler sharedInstance] imageForURL:[_bozukoPrize businessImage]];
		
		if (tmpImage != nil)
			_pageIconImageView.image = tmpImage;
	}
	else if ([[inNotification object] isEqualToString:[_bozukoPrize userImage]] == YES)
	{
		UIImage *tmpImage = [[ImageHandler sharedInstance] imageForURL:[_bozukoPrize userImage]];
		
		if (tmpImage != nil)
			_userImageView.image = tmpImage;
	}
	else if ([[inNotification object] isEqualToString:[_bozukoRedemption securityImageURLString]] == YES)
	{
		UIImage *tmpImage = [[ImageHandler sharedInstance] nonCachedImageForURL:[_bozukoRedemption securityImageURLString]];
		[self updateSecurityImage:tmpImage];
	}
	else if ([[inNotification object] isEqualToString:[_bozukoPrize barcodeImage]] == YES)
	{
		UIImage *tmpImage = [[ImageHandler sharedInstance] nonCachedImageForURL:[_bozukoPrize barcodeImage]];
		_securityImageView.image = tmpImage;
	}
}

- (void)updateSecurityImage:(UIImage *)inImage
{
	DLog(@"%@", [_bozukoRedemption securityImageURLString]);
	
	if (inImage != nil)
	{
		_securityImageView.image = inImage;
		
		_securityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 180.0, 180.0)];
		_securityLabel.font = [UIFont boldSystemFontOfSize:30.0];
		_securityLabel.backgroundColor = [UIColor clearColor];
		_securityLabel.textAlignment = UITextAlignmentCenter;
		_securityLabel.textColor = [UIColor grayColor];
		_securityLabel.alpha = 0.6;
		_securityLabel.text = [[NSDate date] stringWithDateFormat:@"h:mm:ss a"];
		[_securityImageView addSubview:_securityLabel];
		[_securityLabel release];
		
		if (_countdownTimer == nil)
		{
			_countdownBeginUnixTime = [[NSDate date] timeIntervalSince1970];
			self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
		}
	}
	// If there's no security image URL, go ahead and start timer
	else if ([_bozukoRedemption securityImageURLString] == nil || [[_bozukoRedemption securityImageURLString] length] == 0)
	{
		if (_countdownTimer == nil)
		{
			_countdownBeginUnixTime = [[NSDate date] timeIntervalSince1970];
			self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
		}
	}
}

#pragma mark -
#pragma mark Button action functions

- (void)prizeDetailsButtonWasPressed
{
	self.navigationItem.rightBarButtonItem = nil;
	[self.navigationItem performSelector:@selector(setLeftBarButtonItem:) withObject:_doneBarButton afterDelay:1.0];
	
	_prizeDetailsView = [[GamePrizeDetailView alloc] initWithBozukoPrize:_bozukoPrize];
	[UIView transitionFromView:self.view toView:_prizeDetailsView duration:1.0 options:UIViewAnimationOptionTransitionCurlUp completion:^(BOOL done){}];
	[_prizeDetailsView release];
}

- (void)doneButtonWasPressed
{
	self.navigationItem.rightBarButtonItem = nil;
	[self.navigationItem performSelector:@selector(setLeftBarButtonItem:) withObject:_closeBarButton afterDelay:1.0];
	
	[UIView transitionFromView:_prizeDetailsView toView:self.view duration:1.0 options:UIViewAnimationOptionTransitionCurlDown completion:^(BOOL done){}];
}

- (void)doClose
{
	if ([_delegate respondsToSelector:@selector(closeView)] == YES)
		[_delegate closeView];
	else
		[self dismissModalViewControllerAnimated:YES];
}

@end
