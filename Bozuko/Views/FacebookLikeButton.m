//
//  FacebookLikeButton.m
//  Bozuko
//
//  Created by Tom Corwine on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookLikeButton.h"
#import "BozukoPage.h"
#import "UserHandler.h"
#import "BozukoHandler.h"

#define kLikeButton_ReloadInterval			30

@interface FacebookLikeButton (Private)

- (void)updateButton;
- (void)likeButtonPlaceholderWasPressed;

@end

@implementation FacebookLikeButton

@synthesize isDoneLoading = _isDoneLoading;
@synthesize bozukoPage = _bozukoPage;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.bozukoPage = nil;
	
	[super dealloc];
}

- (id)initWithBozukoPage:(BozukoPage *)inBozukoPage
{
	self = [super initWithFrame:CGRectMake(1, 1, 48, 20)];
	
	if (self)
	{
		_isDoneLoading = NO;
		
		self.bozukoPage = inBozukoPage;
		
		_likeButtonLoadingImageView = [[UIImageView alloc] initWithFrame:self.frame];
		_likeButtonLoadingImageView.image = [UIImage imageNamed:@"images/like/like-loader-1"];
		[self addSubview:_likeButtonLoadingImageView];
		[_likeButtonLoadingImageView release];
		
		NSMutableArray *tmpLikeButtonImages = [[NSMutableArray alloc] init];
		for (int i = 1; i < 9; i++)
			[tmpLikeButtonImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"images/like/like-loader-%d", i]]];
		_likeButtonLoadingImageView.animationImages = tmpLikeButtonImages;
		[tmpLikeButtonImages release];
		_likeButtonLoadingImageView.animationDuration = 1.0;
		
		_webView = [[UIWebView alloc] initWithFrame:self.frame];
		[self addSubview:_webView];
		[_webView release];
		_webView.hidden = YES;
		
		_webView.backgroundColor = [UIColor clearColor];
		_webView.scalesPageToFit = NO;
		_webView.delegate = self;
		
		_likedImageView = [[UIImageView alloc] initWithFrame:self.frame];
		_likedImageView.image = [UIImage imageNamed:@"images/facebookLiked"];
		[self addSubview:_likedImageView];
		[_likedImageView release];
		_likedImageView.hidden = YES;
		
		_likeButtonPlaceholder = [UIButton buttonWithType:UIButtonTypeCustom];
		_likeButtonPlaceholder.frame = self.frame;
		[_likeButtonPlaceholder setImage:[UIImage imageNamed:@"images/FacebookLikeButton"] forState:UIControlStateNormal];
		[_likeButtonPlaceholder addTarget:self action:@selector(likeButtonPlaceholderWasPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_likeButtonPlaceholder];
		
		if ([[UserHandler sharedInstance] loggedIn] == YES)
		{
			_likeButtonPlaceholder.hidden = YES;
			
			if ([self.bozukoPage liked] == YES)
			{
				_likedImageView.hidden = NO;
			}
			else
			{
				[self load];
				_likedImageView.hidden = YES;
			}
		}
		else
		{
			_likeButtonPlaceholder.hidden = NO;
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateButton) name:kBozukoHandler_UserLoginStatusChanged object:nil];
	}
	
	return self;
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	
	if (_isDoneLoading == NO)
		[_likeButtonLoadingImageView startAnimating];
}

- (void)load
{
	_loadingTimer = nil;
	_webView.hidden = YES;
	
	// Check if facebookLikeButtonLink has token= parameter. If it doesn't, it isn't going to be of any use to us.
	NSArray *tmpArray = [[self.bozukoPage facebookLikeButtonLink] componentsSeparatedByString:@"?"];
	NSString *tmpString = nil;
	
	if ([tmpArray count] > 1)
		tmpString = [tmpArray objectAtIndex:1];
	
	DLog(@"Is Logged In: %d", [[UserHandler sharedInstance] loggedIn]);
	DLog(@"%@", [self.bozukoPage facebookLikeButtonLink]);
	
	if ([[UserHandler sharedInstance] loggedIn] == YES && [tmpString hasPrefix:@"token="] == YES)
	{
		DLog(@"Loading...");
		_isDoneLoading = NO;
		_likeButtonPlaceholder.hidden = YES;
		[_likeButtonLoadingImageView startAnimating];
		
		NSString *tmpString = [NSString stringWithFormat:@"%@&mobile_version=%@", [self.bozukoPage facebookLikeButtonLink], kApplicationVersion];
		NSURL *tmpURL = [NSURL URLWithString:tmpString];
		NSURLRequest *tmpURLRequest = [NSURLRequest requestWithURL:tmpURL];
		[_webView loadRequest:tmpURLRequest];
		
		DLog(@"%@", tmpString);
		
		_loadingTimer = [NSTimer scheduledTimerWithTimeInterval:kLikeButton_ReloadInterval target:self selector:@selector(load) userInfo:nil repeats:NO];
	}
	else
	{
		DLog(@"Nope");
		[_likeButtonLoadingImageView stopAnimating];
		_likeButtonPlaceholder.hidden = NO;
	}
}

#pragma mark - Button Actions

- (void)likeButtonPlaceholderWasPressed
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserAttemptLogin object:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)inWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	DLog(@"%@", request);

	if ([[[request URL] absoluteString] hasPrefix:@"bozuko://"] == YES)
	{
		if([[[request URL] absoluteString] hasPrefix:@"bozuko://facebook/like_loaded"] == YES)
		{
			DLog(@"Done");
			[_loadingTimer invalidate];
			_loadingTimer = nil;
			
			_isDoneLoading = YES;
			_webView.hidden = NO;
			[_likeButtonLoadingImageView stopAnimating];
		}
		else if ([[[request URL] absoluteString] hasPrefix:@"bozuko://facebook/liked"] == YES)
		{
			_likedImageView.hidden = NO;
			_webView.hidden = YES;
			
			[[BozukoHandler sharedInstance] bozukoPageRefreshForPage:self.bozukoPage];
		}
		else if([[[request URL] absoluteString] hasPrefix:@"bozuko://facebook/no_session"] == YES)
		{
			// reload like button web view
			[self.bozukoPage unloadFacebookLikeButton];
			[self load];
		}
		
		return NO; // Prevent all bozuko:// urls from reloading web view
	}
	else
		return YES;
}

#pragma mark - Notification Methods

- (void)updateButton
{
	DLog(@"Update");
	[self load];
}

@end
