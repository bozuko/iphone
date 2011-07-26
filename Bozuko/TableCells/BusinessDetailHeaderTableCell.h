//
//  BusinessDetailHeaderTableCell.h
//  Bozuko
//
//  Created by Tom Corwine on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GamesDetailViewController;
@class FacebookLikeButton;

@interface BusinessDetailHeaderTableCell : UITableViewCell
{
	UIImageView *_pageIcon;
    UILabel *_pageNameLabel;
	UILabel *_pageTypeLabel;
	UIView *_horizontalDivider;
	UILabel *_pageAddressLabel;
	UILabel *_pageCityLabel;
	UIButton *_favoriteButton;
	UIImageView *_arrowImageView;
	FacebookLikeButton *_facebookLikeButton;
	GamesDetailViewController *_controller;
}

@property (assign) GamesDetailViewController *controller;
@property (retain) FacebookLikeButton *facebookLikeButton;

- (void)populateContent;
- (void)likeButtonPlaceholderWasPressed;
- (void)updateImage:(NSNotification *)inNotification;
- (void)updateFavoriteButtonState:(NSNotification *)inNotification;
- (void)loginStatusDidChange;

@end
