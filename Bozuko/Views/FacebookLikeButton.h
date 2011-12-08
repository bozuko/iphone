//
//  FacebookLikeButton.h
//  Bozuko
//
//  Created by Tom Corwine on 7/25/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FacebookLikeButton;
@class BozukoPage;

typedef enum {
	FacebookLikedStatus_NotLoggedIn = -1,
	FacebookLikedStatus_NotLiked,
	FacebookLikedStatus_Liked
} FacebookLikedStatus;

@interface FacebookLikeButton : UIView <UIWebViewDelegate>
{
    BOOL _isDoneLoading;
	FacebookLikedStatus _facebookLikedStatus;
	UIImageView *_likeButtonLoadingImageView;
	UIImageView *_likedImageView;
	UIButton *_likeButtonPlaceholder;
	UIWebView *_webView;
	NSString *_likeButtonURLString;
	NSString *_pageLinkURLString;
	
	NSTimer *_loadingTimer;
}

@property (readonly) BOOL isDoneLoading;
@property (readonly) FacebookLikedStatus facebookLikedStatus;

- (id)initWithBozukoPage:(BozukoPage *)inBozukoPage;
- (void)load;

@end
