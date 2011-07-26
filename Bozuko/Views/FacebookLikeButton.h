//
//  FacebookLikeButton.h
//  Bozuko
//
//  Created by Tom Corwine on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FacebookLikeButton;
@class BozukoPage;

@interface FacebookLikeButton : UIView <UIWebViewDelegate>
{
    BOOL _isDoneLoading;
	UIImageView *_likeButtonLoadingImageView;
	UIButton *_likeButtonPlaceholder;
	UIWebView *_webView;
	BozukoPage *_bozukoPage;
}

@property (readonly) BOOL isDoneLoading;
@property (retain) BozukoPage *bozukoPage;

- (id)initWithBozukoPage:(BozukoPage *)inBozukoPage;
- (void)load;

@end
