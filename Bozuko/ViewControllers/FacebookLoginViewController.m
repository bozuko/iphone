    //
//  WebViewController.m
//  Bozuko
//
//  Created by Sarah Lensing on 5/2/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import "FacebookLoginViewController.h"
#import "UserHandler.h"
#import "BozukoHandler.h"
#import "BozukoEntryPoint.h"

@implementation FacebookLoginViewController

- (id)init
{
	self = [super init];
	
	if (self)
	{
	}
	
	return self;
}

- (void)viewDidLoad {
	if ([[BozukoHandler sharedInstance] apiEntryPoint] == nil)
		[[BozukoHandler sharedInstance] bozukoEntryPoint];
	
	_requestString = [[NSString alloc] initWithFormat:@"%@%@?phone_type=%@&phone_id=%@&mobile_version=%@", [[BozukoHandler sharedInstance] baseURL], [[[BozukoHandler sharedInstance] apiEntryPoint] login], [[UserHandler sharedInstance] phoneType], [[UserHandler sharedInstance] phoneID], kApplicationVersion];
	
	for (NSHTTPCookie *tmpCookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
	{
		//DLog(@"Cookie for: %@", [tmpCookie domain]);

		// Get rid of cookies
		if ([[tmpCookie domain] hasSuffix:@".bozuko.com"] == YES ||
			([[tmpCookie domain] hasSuffix:@".facebook.com"] == YES && [[NSUserDefaults standardUserDefaults] boolForKey:@"FacebookReturnUser"]))
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:tmpCookie];
	}
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FacebookReturnUser"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[super viewDidLoad];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)inWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	//DLog(@"Webview to load request: %@", request);
	//DLog(@"Test: %@", [NSString stringWithFormat:@"%@%@", [[BozukoHandler sharedInstance] baseURL], kBozukoAPIRedirectPath_UserLoginSuccessfully]);
	if([[[request URL] absoluteString] hasPrefix:[NSString stringWithFormat:@"%@%@", [[BozukoHandler sharedInstance] baseURL], kBozukoAPIRedirectPath_UserLoginSuccessfully]])
	{
		NSString *tmpToken = [[[[request URL] absoluteString] componentsSeparatedByString:@"="] lastObject];
		[[UserHandler sharedInstance] setUserToken:tmpToken];

		[self dismissModalViewControllerAnimated:YES];
	}
	
	return YES;
}

- (void)dealloc {
    [super dealloc];
}


@end
