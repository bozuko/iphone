//
//  BozukoHomeViewController.h
//  Bozuko
//
//  Created by Tom Corwine on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BozukoPage;
@class BozukoGame;

@interface GameTermsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
	BozukoPage *_bozukoPage;
	BozukoGame *_bozukoGame;
	UIView *_bottomBarView;
	UIButton *_gameEntryButton;
	NSInteger _bozukoGameIndex;
	NSTimer *_refreshTimer;
}

@property (retain) BozukoPage *bozukoPage;
@property (retain) BozukoGame *bozukoGame;
@property (readwrite) NSInteger bozukoGameIndex;

- (void)updateView;
- (void)updateGameState;
- (void)playButtonWasPressed;

- (void)bozukoGameResultsInProgress:(NSNotification *)inNotification;
- (void)bozukoGameResultsDidFinish:(NSNotification *)inNotification;
- (void)bozukoGameResultsDidFail:(NSNotification *)inNotification;
- (void)bozukoGameStateDidFinish:(NSNotification *)inNotification;
- (void)bozukoGameStateDidFail:(NSNotification *)inNotification;
- (void)pageUpdateDidFinish:(NSNotification *)inNotification;
- (void)pageUpdateDidFail:(NSNotification *)inNotification;

@end
