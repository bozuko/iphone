//
//  PrizeDetailsViewController.h
//  Bozuko
//
//  Created by Christopher Luu on 5/18/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BozukoPrize.h"
#import "PrizeDetailsViewController.h"

@class LoadingView;
@class GamePrizeDetailView;

@interface PrizeWrapperViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate>
{
	id <PrizeDetailsViewControllerDelegate> _delegate;
	LoadingView *_loadingOverlay;
	UIView *_backgroundView;
	BozukoPrize *_bozukoPrize;
	UITextView *_textView;
	UIButton *_checkmarkButton;
	UIAlertView *_alertView;
	GamePrizeDetailView *_prizeDetailsView;
	UIBarButtonItem *_doneBarButton;
}

@property (assign) id <PrizeDetailsViewControllerDelegate> delegate;

- (id)initWithBozukoPrize:(BozukoPrize *)inPrize;
- (void)applicationDidEnterBackground;
- (void)redeemPrize;
- (void)prizeDetailsButtonWasPressed;
- (void)prizeDetailsDoneButtonWasPressed;
- (void)redeemPrizeButtonWasPressed;
- (void)checkmarkWasPressed;
- (void)prizeRedemptionDidFinish:(NSNotification *)inNotification;
- (void)prizeRedemptionDidFail:(NSNotification *)inNotification;

@end
