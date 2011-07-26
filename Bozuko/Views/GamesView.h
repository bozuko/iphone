//
//  GamesView.h
//  Bozuko
//
//  Created by Tom Corwine on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "FZCustomSearchBar.h"

@class GamesHomeViewController;
@class LoadingView;

@interface GamesView : UIView <UITableViewDataSource, UITableViewDelegate, FZCustomSearchBarDelegate, EGORefreshTableHeaderDelegate> {
	UINavigationController *_controller;
    UITableView *_tableView;
	UIView *_noFavoritesView;
	BOOL _favorites;
	FZCustomSearchBar *_searchBar;
	LoadingView *_loadingOverlay;
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _isTableViewRefreshing;
}

@property (assign) UINavigationController *controller;

- (void)setFavorites:(BOOL)inBool;
- (void)refreshView;
- (void)didReceiveMemoryWarning;
- (void)showTableView;
- (void)showNoFavoritesView;
- (void)viewWillDisappear;
- (void)showLoadingOverlay;
- (void)hideLoadingOverlay;

@end
