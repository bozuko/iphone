//
//  WebViewController.h
//  Bozuko
//
//  Created by Sarah Lensing on 5/2/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"

@protocol FacebookLikeWebViewControllerDelegate <NSObject>

- (void)facebookPageWasLiked;

@end

@interface FacebookLikeWebViewController : WebViewController {
	id <FacebookLikeWebViewControllerDelegate> _delegate;
}

@property (assign) id delegate;

@end
