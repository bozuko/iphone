    //
//  WebViewController.m
//  Bozuko
//
//  Created by Sarah Lensing on 5/2/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import "WebViewController.h"
#import "UserHandler.h"
#import "BozukoHandler.h"
#import "BozukoEntryPoint.h"

@implementation WebViewController

- (id)initWithRequest:(NSString *)inRequest
{
	self = [super init];
	
	if (self)
	{
		_requestString = [inRequest retain];
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//NSString *tmpRequestString = [NSString stringWithFormat:@"%@%@?phone_type=%@&phone_id=%@&mobile_version=%@", kBozukoBaseURL, [[[BozukoHandler sharedInstance] apiEntryPoint] login], [[UserHandler sharedInstance] phoneType], [[UserHandler sharedInstance] phoneID], kApplicationVersion];
	
	//DLog(@"Request String: %@", _requestString);

	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 436)];
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_requestString stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding]]]];
	[_webView setScalesPageToFit:YES];
    [_webView setContentScaleFactor:1.5];
	[_webView setDelegate:self];
	[self.view addSubview:_webView];
	[_webView release];
	
	_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[_activityView setCenter:CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f)];
	[_activityView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
	[_activityView setHidesWhenStopped:YES];
	[self.view addSubview:_activityView];
	[_activityView release];
	
	//DLog(@"String: %@", _requestString);
	//DLog(@"URL: %@", [NSURL URLWithString:[_requestString stringByAddingPercentEscapesUsingEncoding:kCFStringEncodingUTF8]]);
	//DLog(@"Request: %@", [NSURLRequest requestWithURL:[NSURL URLWithString:_requestString]]);
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	_webView.delegate = nil;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)inWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	//DLog(@"Webview to load request: %@", request);	

	return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)inWebView {
	[_activityView stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)webView:(UIWebView *)inWebView didFailLoadWithError:(NSError *)error {
	[_activityView stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)webViewDidStartLoad:(UIWebView *)inWebView {
	[_activityView startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)dealloc {
	[_requestString release];
	_webView.delegate = nil;
	
    [super dealloc];
}


@end
