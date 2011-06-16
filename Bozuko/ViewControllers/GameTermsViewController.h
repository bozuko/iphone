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
}

@property (retain) BozukoPage *bozukoPage;
@property (retain) BozukoGame *bozukoGame;

- (void)updateView;
- (void)playButtonWasPressed;

- (void)bozukoGameStateDidFinish:(NSNotification *)inNotification;
- (void)bozukoGameStateDidFail:(NSNotification *)inNotification;

@end
