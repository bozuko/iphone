//
//  PrizeDetailsViewController.h
//  Bozuko
//
//  Created by Christopher Luu on 5/18/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BozukoPrize.h"

@class BozukoRedemption;
@class GamePrizeDetailView;

@protocol PrizeDetailsViewControllerDelegate <NSObject>

- (void)closeView;

@end

@interface PrizeDetailsViewController : UIViewController
{
	id <PrizeDetailsViewControllerDelegate> _delegate;
	BozukoPrize *_bozukoPrize;
	BozukoRedemption *_bozukoRedemption;

	UIImageView *_chipImageView;
	UIImageView *_pageIconImageView;
	UIImageView *_userImageView;
	UIImageView *_securityImageView;
	UILabel *_countdownLabel;
	NSInteger _countdownBeginUnixTime;
	NSTimer *_countdownTimer;
	UILabel *_securityLabel;
	UIBarButtonItem *_closeBarButton;
	UIBarButtonItem *_doneBarButton;
	
	GamePrizeDetailView *_prizeDetailsView;
}

@property (assign) id <PrizeDetailsViewControllerDelegate> delegate;
@property (retain) BozukoRedemption *bozukoRedemption;
@property (retain) NSTimer *countdownTimer;

- (id)initWithBozukoPrize:(BozukoPrize *)inPrize;
- (void)imageWasUpdated:(NSNotification *)inNotification;
- (void)refreshView;
- (void)countdown;
- (void)prizeDetailsButtonWasPressed;
- (void)appDidBecomeInactive;
- (void)doneButtonWasPressed;
- (void)updateSecurityImage:(UIImage *)inImage;

@end
