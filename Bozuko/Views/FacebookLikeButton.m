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

- (void)retryLoadWebView;
- (void)likeButtonPlaceholderWasPressed;

@property (retain) NSString *likeButtonURLString;
@property (retain) NSString *pageLikeURLString;

@end

@implementation FacebookLikeButton

@synthesize isDoneLoading = _isDoneLoading;
@synthesize facebookLikedStatus = _facebookLikedStatus;

- (void)dealloc
{
	self.likeButtonURLString = nil;
	self.pageLikeURLString = nil;
	[_webView stopLoading];
	_webView.delegate = nil;
	
	[super dealloc];
}

- (id)initWithBozukoPage:(BozukoPage *)inBozukoPage
{
	self = [super initWithFrame:CGRectMake(0, 0, 51, 24)];
	
	if (self && [inBozukoPage isFacebook] == YES)
	{
		_isDoneLoading = NO;
		
		self.likeButtonURLString = [inBozukoPage facebookLikeButtonLink];
		self.pageLikeURLString = [inBozukoPage page];
		
		_likeButtonLoadingImageView = [[UIImageView alloc] initWithFrame:self.frame];
		_likeButtonLoadingImageView.image = [UIImage imageNamed:@"images/like/like-loader-1"];
		[self addSubview:_likeButtonLoadingImageView];
		[_likeButtonLoadingImageView release];
		
		NSMutableArray *tmpLikeButtonImages = [[NSMutableArray alloc] init];
		for (int i = 1; i < 7; i++)
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
			
			if ([inBozukoPage liked] == YES)
			{
				_likedImageView.hidden = NO;
				_facebookLikedStatus = FacebookLikedStatus_Liked;
			}
			else
			{
				[self load];
				_likedImageView.hidden = YES;
				_facebookLikedStatus = FacebookLikedStatus_NotLiked;
			}
		}
		else
		{
			_likeButtonPlaceholder.hidden = NO;
			_facebookLikedStatus = FacebookLikedStatus_NotLoggedIn;
		}
		
		//DLog(@"Init Liked Button Status: %d", _facebookLikedStatus);
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
	_webView.hidden = YES;
	
	[_loadingTimer invalidate];
	_loadingTimer = nil;
	
	// Check if facebookLikeButtonLink has token= parameter. If it doesn't, it isn't going to be of any use to us.
	NSArray *tmpURLArray = [self.likeButtonURLString componentsSeparatedByString:@"?"];
	NSArray *tmpParametersArray = nil;
		BOOL tmpURLHasToken = NO;
	
	if ([tmpURLArray count] > 1)
		tmpParametersArray = [[tmpURLArray objectAtIndex:1] componentsSeparatedByString:@"&"];
	else
		tmpParametersArray = [NSArray array];
	
	for (NSString *tmpString in tmpParametersArray)
	{
		if ([tmpString hasPrefix:@"token="] == YES)
		{
			tmpURLHasToken = YES;
			break;
		}
	}
	
	//DLog(@"Is Logged In: %d", [[UserHandler sharedInstance] loggedIn]);
	//DLog(@"%@", self.likeButtonURLString);
	
	if ([[UserHandler sharedInstance] loggedIn] == YES)
	{
		//DLog(@"Loading...");
		_isDoneLoading = NO;
		_likeButtonPlaceholder.hidden = YES;
		[_likeButtonLoadingImageView startAnimating];
		
		NSMutableString *tmpURLString = nil;
		
		if (tmpURLHasToken == YES)
			tmpURLString = [NSString stringWithFormat:@"%@&mobile_version=%@", self.likeButtonURLString, kApplicationVersion];
		else
			tmpURLString = [NSString stringWithFormat:@"%@?token=%@&mobile_version=%@", self.likeButtonURLString, [[UserHandler sharedInstance] userToken], kApplicationVersion];
		
		//DLog(@"%@", tmpURLString);
		
		NSURL *tmpURL = [NSURL URLWithString:tmpURLString];
		NSURLRequest *tmpURLRequest = [NSURLRequest requestWithURL:tmpURL];
		[_webView loadRequest:tmpURLRequest];
		
		_loadingTimer = [NSTimer scheduledTimerWithTimeInterval:kLikeButton_ReloadInterval target:self selector:@selector(retryLoadWebView) userInfo:nil repeats:NO];
	}
	else
	{
		//DLog(@"Nope");
		[_likeButtonLoadingImageView stopAnimating];
		_likeButtonPlaceholder.hidden = NO;
	}
}

- (void)retryLoadWebView
{
	//DLog(@"Retrying webView");
	_loadingTimer = nil;
	[_webView stopLoading];
	[self load];
}

#pragma mark - Button Actions

- (void)likeButtonPlaceholderWasPressed
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserAttemptLogin object:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)inWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	//DLog(@"%@", request);

	if ([[[request URL] absoluteString] hasPrefix:@"bozuko://"] == YES)
	{
		if([[[request URL] absoluteString] hasPrefix:@"bozuko://facebook/like_loaded"] == YES)
		{
			//DLog(@"Done");
			[_loadingTimer invalidate];
			_loadingTimer = nil;
			_isDoneLoading = YES;
			_webView.hidden = NO;
			[_likeButtonLoadingImageView stopAnimating];
		}
		else if ([[[request URL] absoluteString] hasPrefix:@"bozuko://facebook/liked"] == YES)
		{
			//DLog(@"Page Liked!");
			_likedImageView.hidden = NO;
			_webView.hidden = YES;
			_facebookLikedStatus = FacebookLikedStatus_Liked;

			[[BozukoHandler sharedInstance] bozukoPageRefreshForPageLink:self.pageLikeURLString];
		}
		else if([[[request URL] absoluteString] hasPrefix:@"bozuko://facebook/no_session"] == YES)
		{
			//DLog(@"Like button no_session");
			// reload like button web view
			[self load];
		}
		
		return NO; // Prevent all bozuko:// urls from reloading web view
	}
	else
		return YES;
}

#pragma mark - Private Accessors

- (void)setLikeButtonURLString:(NSString *)likeButtonURLString
{
	if (_likeButtonURLString == likeButtonURLString)
		return;
	
	[_likeButtonURLString release];
	_likeButtonURLString = [likeButtonURLString retain];
}

- (NSString *)likeButtonURLString
{
	return _likeButtonURLString;
}

- (void)setPageLikeURLString:(NSString *)pageLikeURLString
{
	if (_pageLinkURLString == pageLikeURLString)
		return;
	
	[_pageLinkURLString release];
	_pageLinkURLString = [pageLikeURLString retain];
}

- (NSString *)pageLikeURLString
{
	return _pageLinkURLString;
}

@end
