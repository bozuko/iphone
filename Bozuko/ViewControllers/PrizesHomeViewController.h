//
//  PrizesHomeViewController.h
//  Bozuko
//
//  Created by Tom Corwine on 4/25/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrizeDetailsViewController.h"

@class LoadingView;

@interface PrizesHomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PrizeDetailsViewControllerDelegate> {
    UITableView *_tableView;
	UIImageView *_notLoggedInView;
	UIImageView *_noPrizesView;
	
	LoadingView *_loadingOverlay;
}

- (void)showNotLoggedInView;
- (void)howToButtonWasPressed;
- (void)refreshView;
- (void)showTableView;
- (void)showNoPrizesView;
- (void)prizesDidFinish;
- (void)prizesDidFail;

@end
