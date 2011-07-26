//
//  GamePlayViewController.h
//  Bozuko
//
//  Created by Tom Corwine on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrizeDetailsViewController.h"

@class SlotMachineWheel;
@class GameTermsViewController;
@class BozukoPage;
@class BozukoGame;
@class BozukoGameResult;
@class LoadingView;

@interface GamePlaySlotsViewController : UIViewController <PrizeDetailsViewControllerDelegate, UIAlertViewDelegate> {
	GameTermsViewController *_delegate;
	BozukoPage *_bozukoPage;
    BozukoGame *_bozukoGame;
	BozukoGameResult *_bozukoGameResult;
	
	SlotMachineWheel *_wheel1;
	SlotMachineWheel *_wheel2;
	SlotMachineWheel *_wheel3;
	
	UILabel *_creditsLabel;
	UIImageView *_pageIcon;
	UIButton *_spinButton;
	
	LoadingView *_loadingOverlay;
	
	UIImageView *_bannerImageView;
	NSArray *_goodLuckSequence;
	NSArray *_youWonSequence;
	NSArray *_youLoseSequence;
	NSArray *_playAgainSequence;
	NSArray *_freeSpinSequence;

	BOOL _areGameResultsIn;
	NSArray *_slotItemsArray;
	
	UIBarButtonItem *_backButton;
	UIBarButtonItem *_closeButton;
	
	UIView *_detailsView;
	
	NSTimer *_spinTimeoutTimer;
	NSTimer *_animationTimer;
}

@property (assign) GameTermsViewController *delegate;
@property (retain) BozukoPage *bozukoPage;
@property (retain) BozukoGame *bozukoGame;

- (NSArray *)goodLuckSequence;
- (NSArray *)youWonSequence;
- (NSArray *)youLoseSequence;
- (NSArray *)playAgainSequence;
- (NSArray *)freeSpinSequence;
- (void)prizesButtonWasPressed;
- (void)rulesButtonWasPressed;
- (void)backButtonWasPressed;
- (void)spinWheels;
- (void)stopWheels;
- (void)stopWheel2;
- (void)stopWheel3;
- (void)displayResults;
- (void)youWin;
- (void)youLose;
- (void)freePlay;
- (void)blinkCreditsLabel;
//- (void)userDidTapScreen;
- (void)playDoneMessage;
- (BOOL)areAllIconsLoaded;
- (void)startGame;

- (void)gameEntryDidFinish:(NSNotification *)inNotification;
- (void)gameEntryDidFail:(NSNotification *)inNotification;

- (void)gameResultsDidFinish:(NSNotification *)inNotification;
- (void)gameResultsDidFail:(NSNotification *)inNotification;

- (void)updateBusinessIcon:(NSNotification *)inNotification;

- (void)iconImageWasUpdated:(NSNotification *)inNotification;

@end
