//
//  GamePlayScratchViewController.h
//  Bozuko
//
//  Created by Joseph Hankin on 5/10/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrizeDetailsViewController.h"
#import "BozukoGameResult.h"

#define NUMBER_OF_SCRATCH_AREAS 6

@class GameTermsViewController;
@class BozukoPage;
@class BozukoGame;
@class BozukoGameResult;
@class GameScratchButton;
@class LoadingView;

@interface GamePlayScratchViewController : UIViewController <PrizeDetailsViewControllerDelegate, UIAlertViewDelegate> {
	GameTermsViewController *_delegate;
	BozukoPage *_bozukoPage;
    BozukoGame *_bozukoGame;
	BozukoGameResult *_bozukoGameResult;
	ScratchTicketMask _scratchTicketPositions;
	
	LoadingView *_loadingOverlay;
	UIImageView *_pageIcon;
	
	NSString *_backgroundImageURL;
	UILabel *_creditsLabel;
	
	UITapGestureRecognizer *_tapRecognizer;
	UIImageView *_backgroundView;
	UIImageView *_cardBackgroundImageView;
	UIImageView *_cardStarsImageView;
	UIImageView *_cardTextImageView;
	UIView *_scratchableView;
	GameScratchButton *_button[NUMBER_OF_SCRATCH_AREAS];
	
	BOOL _areGameResultsIn;
	BOOL _isBackgroundLoaded;
	BOOL _shouldAnimationStop;
	NSInteger _scratchTotal;
	
	UIBarButtonItem *_backButton;
	UIBarButtonItem *_closeButton;
	
	UIView *_detailsView;
	NSTimer *_animationTimer;
}

@property (assign) GameTermsViewController *delegate;
@property (retain) BozukoPage *bozukoPage;
@property (retain) BozukoGame *bozukoGame;

- (UIImage *)scratchBackgroundImage;

- (void)scratchButtonPress:(GameScratchButton *)sender;
- (void)allButtonsHaveBeenScratched;
- (void)playEndingSequence;
- (void)stopEndingSequence;
- (void)enterGame;
- (void)resetGame;
- (void)startGame;
- (void)userDidTapScreen;

- (void)prizesButtonWasPressed;
- (void)rulesButtonWasPressed;
- (void)backButtonWasPressed;

- (void)backgroundImageWasUpdated:(NSNotification *)inNotification;

- (void)gameEntryDidFinish:(NSNotification *)inNotification;
- (void)gameEntryDidFail:(NSNotification *)inNotification;

- (void)gameResultsDidFinish:(NSNotification *)inNotification;
- (void)gameResultsDidFail:(NSNotification *)inNotification;

- (void)updateBusinessIcon:(NSNotification *)inNotification;
- (void)setGameResult:(BozukoGameResult *)inBozukoGameResult;

@end
