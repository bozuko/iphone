//
//  GameTermsHeaderTableCell.h
//  Bozuko
//
//  Created by Tom Corwine on 5/5/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BozukoGame;
@class GameTermsViewController;
@class FacebookLikeButton;

@interface GameTermsHeaderTableCell : UITableViewCell
{
	BozukoGame *_bozukoGame;
    UILabel *_pageName;
	UIImageView *_gameImageView;
	UILabel *_gameDescription;
	FacebookLikeButton *_facebookLikeButton;
	GameTermsViewController *_controller;
}

@property (assign) GameTermsViewController *controller;
@property (retain) FacebookLikeButton *facebookLikeButton;

- (void)setGame:(BozukoGame *)inBozukoGame;
- (void)updateImage:(NSNotification *)inNotification;

@end
