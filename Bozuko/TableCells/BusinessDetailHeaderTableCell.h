//
//  BusinessDetailHeaderTableCell.h
//  Bozuko
//
//  Created by Tom Corwine on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GamesDetailViewController;

@interface BusinessDetailHeaderTableCell : UITableViewCell {
	UIImageView *_pageIcon;
    UILabel *_pageNameLabel;
	UILabel *_pageTypeLabel;
	UIView *_horizontalDivider;
	UILabel *_pageAddressLabel;
	UILabel *_pageCityLabel;
	UIButton *_favoriteButton;
	UIImageView *_arrowImageView;
	
	GamesDetailViewController *_controller;
}

@property (assign) GamesDetailViewController *controller;

- (void)populateContent;
- (void)updateImage:(NSNotification *)inNotification;
- (void)updateFavoriteButtonState:(NSNotification *)inNotification;

@end
