    //
//  WebViewController.m
//  Bozuko
//
//  Created by Sarah Lensing on 5/2/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import "FacebookLikeWebViewController.h"
#import "UserHandler.h"
#import "BozukoHandler.h"
#import "BozukoEntryPoint.h"

@implementation FacebookLikeWebViewController

@synthesize delegate = _delegate;

- (id)init
{
	self = [super init];
	
	if (self)
	{
	}
	
	return self;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)inWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	//DLog(@"Webview to load request: %@", request);	
	
	if([[[request URL] absoluteString] hasPrefix:@"bozuko://webview.close"] == YES)
	{
		if ([_delegate respondsToSelector:@selector(facebookPageWasLiked)] == YES)
			[_delegate facebookPageWasLiked];
		
		[self dismissModalViewControllerAnimated:YES];
		
		return NO;
	}
	else
		return YES;
}

- (void)dealloc {
	
    [super dealloc];
}


@end
