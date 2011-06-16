//
//  GamesView.m
//  Bozuko
//
//  Created by Tom Corwine on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamesView.h"
#import "BusinessTableCell.h"
#import "BozukoHandler.h"
#import "BozukoPage.h"
#import "UserHandler.h"
#import "LoadingView.h"
#import "LoadMoreTableCell.h"
#import "GamesDetailViewController.h"

#define kTableViewSection_SearchBox		0

#define kNearbyTableViewSection_Featured		1
#define kNearbyTableViewSection_NearbyGames		2
#define kNearbyTableViewSection_OtherPlaces		3
#define kNearbyTableViewSection_LoadMore		4

#define kFavoritesTableViewSection_Favorites	1
#define kFavoritesTableViewSection_LoadMore		2

@implementation GamesView

@synthesize controller = _controller;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_searchBar release];
	
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
	if (self)
	{		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:kBozukoHandler_UserLoginStatusChanged object:nil];
    }
    
	return self;
}

- (void)didReceiveMemoryWarning
{
	if (_tableView.hidden == YES)
	{
		[_tableView removeFromSuperview];
		_tableView = nil;
		_refreshHeaderView = nil;
	}
	
	if (_noFavoritesView.hidden == YES)
	{
		[_noFavoritesView removeFromSuperview];
		_noFavoritesView = nil;
	}
}

- (void)showTableView
{
	_noFavoritesView.hidden = YES;
	
	if (_tableView == nil)
	{
		_tableView = [[UITableView alloc] initWithFrame:self.frame];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.rowHeight = 65.0;
		[self addSubview:_tableView];
		[_tableView release];
		
		if (_refreshHeaderView == nil)
		{
			EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.bounds.size.height, _tableView.frame.size.width, _tableView.bounds.size.height)];
			view.delegate = self;
			[_tableView addSubview:view];
			_refreshHeaderView = view;
			[view release];
			
			[_refreshHeaderView refreshLastUpdatedDate];
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoadingOverlay) name:kBozukoHandler_PageDidStart object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLoadingOverlay) name:kBozukoHandler_GetPagesForLocationDidFinish object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLoadingOverlay) name:kBozukoHandler_GetPagesForLocationDidFail object:nil];
	}
	else
	{
		_tableView.hidden = NO;
	}
}

- (void)showNoFavoritesView
{
	_tableView.hidden = YES;
	
	if (_noFavoritesView == nil)
	{
		_noFavoritesView = [[UIView alloc] initWithFrame:self.frame];
		
//		[_searchBar release];
//		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
//		_searchBar.tintColor = [UIColor lightGrayColor];
//		_searchBar.showsCancelButton = NO;
//		_searchBar.placeholder = @"Search";
//		_searchBar.text = [BozukoHandler sharedInstance].searchQueryString;
//		[_noFavoritesView addSubview:_searchBar];
		
		UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 23.0)];
		tmpImageView.image = [UIImage imageNamed:@"images/listHeader"];
		[_noFavoritesView addSubview:tmpImageView];
		[tmpImageView release];
		
		UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 320.0, 23.0)];
		tmpLabel.font = [UIFont boldSystemFontOfSize:18];
		tmpLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		tmpLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
		tmpLabel.textColor = [UIColor whiteColor];
		tmpLabel.backgroundColor = [UIColor clearColor];
		tmpLabel.text = @"Favorites";
		[_noFavoritesView addSubview:tmpLabel];
		[tmpLabel release];
		
		tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 23.0, 320.0, 344.0)];
		tmpImageView.image = [UIImage imageNamed:@"images/noFavorites"];
		[_noFavoritesView addSubview:tmpImageView];
		[tmpImageView release];
		
		[self addSubview:_noFavoritesView];
		[_noFavoritesView release];
	}
	else
	{
		_noFavoritesView.hidden = NO;
	}
}

#pragma mark - Button Actions

#pragma mark - Setters

- (void)setFavorites:(BOOL)inBool
{
	_favorites = inBool;
	[self refreshView];
}

- (void)refreshView
{
	if (_favorites == YES)
	{
		if ([[BozukoHandler sharedInstance] numberOfFavoriteGames] > 0 || [BozukoHandler sharedInstance].favoritesSearchQueryString != nil)
		{
			[self showTableView];
		}
		else
		{
			[self showNoFavoritesView];
		}
	}
	else
	{
		[self showTableView];
	}

	[_tableView reloadData];
	
	// We want to refresh the table when a page is de-favorited, if this is the favorites view.
	if (_favorites == YES)
	{
		if (_tableView.bounds.origin.y < 44.0 && [BozukoHandler sharedInstance].favoritesSearchQueryString == nil) // Scroll to hide search bar, but only if tableView is at top
			// and search is nil
			[_tableView scrollRectToVisible:CGRectMake(0.0, 44.0, 320.0, _tableView.bounds.size.height) animated:NO];
		
		_refreshHeaderView.hidden = YES;
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:kBozukoHandler_SetFavoriteDidFinish object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoadingOverlay) name:kBozukoHandler_FavoritesDidStart object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLoadingOverlay) name:kBozukoHandler_FavoritesDidFinish object:nil];
	}
	else
	{
		if (_tableView.bounds.origin.y < 44.0 && [BozukoHandler sharedInstance].searchQueryString == nil) // Scroll to hide search bar, but only if tableView is at top
			// and search is nil
			[_tableView scrollRectToVisible:CGRectMake(0.0, 44.0, 320.0, _tableView.bounds.size.height) animated:NO];
		
		_refreshHeaderView.hidden = NO;
		//[[NSNotificationCenter defaultCenter] removeObserver:self name:kBozukoHandler_SetFavoriteDidFinish object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kBozukoHandler_FavoritesDidStart object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kBozukoHandler_FavoritesDidFinish object:nil];
	}
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (_favorites == NO)
		[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (_favorites == NO)
		[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];	
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	if (_favorites == NO)
	{
		_isTableViewRefreshing = YES;
		[[BozukoHandler sharedInstance] bozukoPages];
		
		if ([[UserHandler sharedInstance] loggedIn] == YES)
			[[BozukoHandler sharedInstance] bozukoFavorites];
	}
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _isTableViewRefreshing; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (_favorites == YES)
		return 3;
	
	return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == kNearbyTableViewSection_LoadMore)
	{
		if ([[BozukoHandler sharedInstance] pagesNextURL] == nil ||
			[[BozukoHandler sharedInstance] numberOfBusinesses] + [[BozukoHandler sharedInstance] numberOfNearbyGames] + [[BozukoHandler sharedInstance] numberOfFeaturedGames] < 25)
			return 0;
		else
			return 1;
	}
	else if (_favorites == YES && section == kFavoritesTableViewSection_LoadMore)
	{
		if ([[BozukoHandler sharedInstance] favoritesNextURL] == nil || [[BozukoHandler sharedInstance] numberOfFavoriteGames] < 25)
			return 0;
		else
			return 1;
	}
	else if (_favorites == YES)
	{
		switch (section)
		{
			default:
			case kTableViewSection_SearchBox:
				return 0;
				break;
				
			case kFavoritesTableViewSection_Favorites:
				return [[BozukoHandler sharedInstance] numberOfFavoriteGames];
				break;
		}
	}
	else
	{
		switch (section)
		{
			default:
			case kTableViewSection_SearchBox:
				return 0;
				break;
			
			case kNearbyTableViewSection_Featured:
				return [[BozukoHandler sharedInstance] numberOfFeaturedGames];
				break;
			
			case kNearbyTableViewSection_NearbyGames:
				return [[BozukoHandler sharedInstance] numberOfNearbyGames];
				break;
				
			case kNearbyTableViewSection_OtherPlaces:
				return [[BozukoHandler sharedInstance] numberOfBusinesses];
				break;
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == kNearbyTableViewSection_LoadMore)
		return 0;
	else if (section == kTableViewSection_SearchBox)
		return 44.0;
	else if (_favorites == YES)
		return 23.0;
	else
	{
		// Don't show table section header if there's no items for that section
		if (section == kNearbyTableViewSection_Featured && [[BozukoHandler sharedInstance] numberOfFeaturedGames] > 0 ||
			section == kNearbyTableViewSection_NearbyGames && [[BozukoHandler sharedInstance] numberOfNearbyGames] > 0 ||
			section == kNearbyTableViewSection_OtherPlaces && [[BozukoHandler sharedInstance] numberOfBusinesses] > 0)
			return 23.0;
		else
			return 0.0;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == kNearbyTableViewSection_LoadMore || (_favorites == YES && section == kFavoritesTableViewSection_LoadMore))
	{
		return nil;
	}
	else if (section == kTableViewSection_SearchBox)
	{
		[_searchBar release];
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
		_searchBar.tintColor = [UIColor lightGrayColor];
		
		_searchBar.placeholder = @"Search";
		
		if (_favorites == YES)
		{
			_searchBar.text = [BozukoHandler sharedInstance].favoritesSearchQueryString;
			
			if ([BozukoHandler sharedInstance].favoritesSearchQueryString == nil)
				_searchBar.showsCancelButton = NO;
			else
				_searchBar.showsCancelButton = YES;
		}
		else
		{
			_searchBar.text = [BozukoHandler sharedInstance].searchQueryString;
			
			if ([BozukoHandler sharedInstance].searchQueryString == nil)
				_searchBar.showsCancelButton = NO;
			else
				_searchBar.showsCancelButton = YES;
		}
		
		_searchBar.delegate = self;

		return _searchBar;
	}
	else
	{
		UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 23.0)];
		tmpImageView.image = [UIImage imageNamed:@"images/listHeader"];
	
		UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 320.0, 23.0)];
		tmpLabel.font = [UIFont boldSystemFontOfSize:18];
		tmpLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		tmpLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
		tmpLabel.textColor = [UIColor whiteColor];
		tmpLabel.backgroundColor = [UIColor clearColor];
		[tmpImageView addSubview:tmpLabel];
		[tmpLabel release];
	
		if (_favorites == YES)
		{
			tmpLabel.text = @"Favorites";
		}
		else
		{
			switch (section)
			{
				case kNearbyTableViewSection_Featured:
					tmpLabel.text = @"Featured";
					break;
					
				case kNearbyTableViewSection_NearbyGames:
					tmpLabel.text = @"Nearby Games";
					break;
					
				case kNearbyTableViewSection_OtherPlaces:
					tmpLabel.text = @"Other Places";
					break;
			}
		}
	
		return [tmpImageView autorelease];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == kNearbyTableViewSection_LoadMore || (_favorites == YES && indexPath.section == kFavoritesTableViewSection_LoadMore))
	{
		LoadMoreTableCell *tmpCell = (LoadMoreTableCell *)[tableView dequeueReusableCellWithIdentifier:@"LoadMoreTableCell"];
		
		if (tmpCell == nil)
			tmpCell = [[[LoadMoreTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoadMoreTableCell"] autorelease];
		
		[tmpCell setActive:NO];
		
		return tmpCell;
	}
	
	BusinessTableCell *tmpCell = (BusinessTableCell *)[tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
	
	if (tmpCell == nil)
		tmpCell = [[[BusinessTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BusinessCell"] autorelease];
	
	BozukoPage *tmpBozukoPage = nil;
	
	if (_favorites == YES)
		tmpBozukoPage = [[BozukoHandler sharedInstance] favoriteBusinessAtIndex:indexPath.row];
	else if (indexPath.section == kNearbyTableViewSection_Featured)
		tmpBozukoPage = [[BozukoHandler sharedInstance] featuredBusinessAtIndex:indexPath.row];
	else if (indexPath.section == kNearbyTableViewSection_NearbyGames)
		tmpBozukoPage = [[BozukoHandler sharedInstance] gamesAtIndex:indexPath.row];
	else
		tmpBozukoPage = [[BozukoHandler sharedInstance] businessAtIndex:indexPath.row];
	
	[tmpCell setContentForBusiness:tmpBozukoPage];
	
	return tmpCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == kNearbyTableViewSection_LoadMore)
	{
		[(LoadMoreTableCell *)[tableView cellForRowAtIndexPath:indexPath] setActive:YES];
		[[BozukoHandler sharedInstance] bozukoPagesNextPage];
		return;
	}
	else if (_favorites == YES && indexPath.section == kFavoritesTableViewSection_LoadMore)
	{
		[(LoadMoreTableCell *)[tableView cellForRowAtIndexPath:indexPath] setActive:YES];
		[[BozukoHandler sharedInstance] bozukoFavoritesNextPage];
		return;
	}
	
	GamesDetailViewController *tmpViewController = [[GamesDetailViewController alloc] init];
	
	if (_favorites == YES)
		tmpViewController.bozukoPage = [[BozukoHandler sharedInstance] favoriteBusinessAtIndex:indexPath.row];
	else if (indexPath.section == kNearbyTableViewSection_Featured)
		tmpViewController.bozukoPage = [[BozukoHandler sharedInstance] featuredBusinessAtIndex:indexPath.row];
	else if (indexPath.section == kNearbyTableViewSection_NearbyGames)
		tmpViewController.bozukoPage = [[BozukoHandler sharedInstance] gamesAtIndex:indexPath.row];
	else
		tmpViewController.bozukoPage = [[BozukoHandler sharedInstance] businessAtIndex:indexPath.row];
	
	[_controller pushViewController:tmpViewController animated:YES];
	[tmpViewController release];
}

#pragma mark - UISearchBar Delegate methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	//[searchBar setShowsCancelButton:NO animated:YES];
	[searchBar resignFirstResponder];
	
	if (_favorites == YES)
		[[BozukoHandler sharedInstance] bozukoFavoritesSearchFor:searchBar.text];
	else
		[[BozukoHandler sharedInstance] bozukoPagesSearchFor:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//	if ([searchText isEqualToString:@""] == YES)
//	{
//		[searchBar resignFirstResponder];
//		[[BozukoHandler sharedInstance] bozukoPagesSearchFor:nil];
//	}
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[searchBar setShowsCancelButton:NO animated:YES];
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	
	if (_favorites == YES)
	{
		if ([BozukoHandler sharedInstance].favoritesSearchQueryString != nil)
			[[BozukoHandler sharedInstance] bozukoFavoritesSearchFor:nil];
	}
	else
	{
		if ([BozukoHandler sharedInstance].searchQueryString != nil)
			[[BozukoHandler sharedInstance] bozukoPagesSearchFor:nil];
	}
}

- (void)viewWillDisappear
{
	[_searchBar resignFirstResponder];
}

#pragma mark Bozukohandler Notification Methods

- (void)showLoadingOverlay
{
	if (_loadingOverlay == nil)
	{
		_loadingOverlay = [[LoadingView alloc] init];
		[self addSubview:_loadingOverlay];
		[_loadingOverlay release];
	}
}

- (void)hideLoadingOverlay
{
	_isTableViewRefreshing = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	
	[self refreshView];
	
	[_loadingOverlay removeFromSuperview];
	_loadingOverlay = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
