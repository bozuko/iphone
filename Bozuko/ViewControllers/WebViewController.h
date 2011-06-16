//
//  WebViewController.h
//  Bozuko
//
//  Created by Sarah Lensing on 5/2/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate> {
	NSString *_requestString;
	UIActivityIndicatorView *_activityView;
}

- (id)initWithRequest:(NSString *)inRequest;

@end
