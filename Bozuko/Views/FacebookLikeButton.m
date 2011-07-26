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

@interface FacebookLikeButton (Private)

- (void)loginStatusWasChanged;
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
		
		_likeButtonPlaceholder = [UIButton buttonWithType:UIButtonTypeCustom];
		_likeButtonPlaceholder.frame = self.frame;
		[_likeButtonPlaceholder setImage:[UIImage imageNamed:@"images/FacebookLikeButton"] forState:UIControlStateNormal];
		[_likeButtonPlaceholder addTarget:self action:@selector(likeButtonPlaceholderWasPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_likeButtonPlaceholder];
		
		if ([[UserHandler sharedInstance] loggedIn] == YES)
		{
			_likeButtonPlaceholder.hidden = YES;
			[_likeButtonLoadingImageView startAnimating];
		}
		else
		{
			_likeButtonPlaceholder.hidden = NO;
			[_likeButtonLoadingImageView stopAnimating];
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusWasChanged) name:kBozukoHandler_UserLoginStatusChanged object:nil];
	}
	
	return self;
}

- (void)load
{
	if (_isDoneLoading == YES)
		return;
	
	NSURL *tmpURL = [NSURL URLWithString:[self.bozukoPage facebookLikeButtonLink]];
	NSURLRequest *tmpURLRequest = [NSURLRequest requestWithURL:tmpURL];
	[_webView loadRequest:tmpURLRequest];
}

#pragma mark - Button Actions

- (void)likeButtonPlaceholderWasPressed
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserAttemptLogin object:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)inWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if([[[request URL] absoluteString] hasPrefix:@"bozuko://facebook/like_loaded"] == YES)
	{
		_isDoneLoading = YES;
		_webView.hidden = NO;
		[_likeButtonLoadingImageView stopAnimating];
		
		return NO;
	}
	else if([[[request URL] absoluteString] hasPrefix:@"bozuko://facebook/"] == YES)
	{
		[[BozukoHandler sharedInstance] bozukoPageRefreshForPage:self.bozukoPage];
		
		return NO;
	}
	else
		return YES;
}

#pragma mark - Notification Methods

- (void)loginStatusWasChanged
{
	if ([[UserHandler sharedInstance] loggedIn] == YES)
		_likeButtonPlaceholder.hidden = YES;
	else
		_likeButtonPlaceholder.hidden = NO;
}

@end
