//
//  BozukoHandler.h
//  Bozuko
//
//  Created by Tom Corwine on 4/18/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define kBozukoDevBaseURL								@"https://playground.bozuko.com:443"
#define kBozukoProductionBaseURL						@"https://api.bozuko.com:443"

//#define kBozukoAPIRedirectPath_UserLoginSuccessfully	@"/user/mobile?token=" // For login webView

#define kBozukoAPIEntryPoint							@"/api"
#define kBozukoAppVersion								@"1.5.2"
#define kApplicationVersion								@"iphone-1.5"
#define kBozukoAppStoreURL								@"http://itunes.apple.com/us/app/bozuko/id444496922?mt=8"

#define kBozukoHandler_UserLocationWasUpdated			@"BozukoHandler_UserLocationWasUpdated"
#define kBozukoHandler_UserLocationNotAvailable			@"BozukoHandler_UserLocationNotAvailable"

#define kBozukoHandler_NetworkNotAvailable				@"BozukoHandler_NetworkNotAvailable"
#define kBozukoHandler_ApplicationNeedsUpdate			@"BozukoHandler_ApplicationNeedsUpdate"
#define kBozukoHandler_ServerErrorNotfication			@"BozukoHandler_ServerErrorNotfication"
#define kBozukoHandler_ServerLogoutNotfication			@"BozukoHandler_ServerLogoutNotfication"

#define kBozukoHandler_GameResultsRequestInProgress		@"BozukoHandler_GameResultsRequestInProgress"
#define kBozukoHandler_GameResultsDidFinish				@"BozukoHandler_GameResultsDidFinish"
#define kBozukoHandler_GameResultsDidFail				@"BozukoHandler_GameResultsDidFail"

#define kBozukoHandler_PrizesDidFinish					@"BozukoHandler_PrizesDidFinish"
#define kBozukoHandler_PrizesDidFail					@"BozukoHandler_PrizesDidFail"

#define kBozukoHandler_PageDidStart						@"BozukoHandler_PageDidStart"
#define kBozukoHandler_PageDidFinish					@"BozukoHandler_PageDidFinish"
#define kBozukoHandler_PageDidFail						@"BozukoHandler_PageDidFail"

#define kBozukoHandler_FavoritesDidStart				@"BozukoHandler_FavoritesDidStart"
#define kBozukoHandler_FavoritesDidFinish				@"BozukoHandler_FavoritesDidFinish"
#define kBozukoHandler_FavoritesDidFail					@"BozukoHandler_FavoritesDidFail"

#define kBozukoHandler_FacebookCheckInDidFinish			@"BozukoHandler_FacebookCheckInDidFinish"
#define kBozukoHandler_FacebookCheckInDidFail			@"BozukoHandler_FacebookCheckInDidFail"

#define kBozukoHandler_RecommendDidFinish				@"BozukoHandler_RecommendDidFinish"
#define kBozukoHandler_RecommendDidFail					@"BozukoHandler_RecommendDidFail"

#define kBozukoHandler_GameStateDidFinish				@"BozukoHandler_GameStateDidFinish"
#define kBozukoHandler_GameStateDidFail					@"BozukoHandler_GameStateDidFail"

#define kBozukoHandler_GameDidFinish					@"BozukoHandler_GameDidFinish"
#define kBozukoHandler_GameDidFail						@"BozukoHandler_GameDidFail"

#define kBozukoHandler_PrizeRedemptionDidFinish			@"BozukoHandler_PrizeRedemptionDidFinish"
#define kBozukoHandler_PrizeRedemptionDidFail			@"BozukoHandler_PrizeRedemptionDidFail"

#define kBozukoHandler_GameEntryDidFinish				@"BozukoHandler_GameEntryDidFinish"
#define kBozukoHandler_GameEntryDidFail					@"BozukoHandler_GameEntryDidFail"

#define kBozukoHandler_GetPagesForLocationDidFinish		@"BozukoHandler_GetPagesForLocationDidFinish"
#define kBozukoHandler_GetPagesForLocationDidFail		@"BozukoHandler_GetPagesForLocationDidFail"

#define kBozukoHandler_GetPagesForRegionDidFinish		@"BozukoHandler_GetPagesForRegionDidFinish"
#define kBozukoHandler_GetPagesForRegionDidFail			@"BozukoHandler_GetPagesForRegionDidFail"

#define kBozukoHandler_SetFavoriteDidFinish				@"BozukoHandler_SetFavoriteDidFinish"
#define kBozukoHandler_SuccessResponseNotification		@"BozukoHandler_SuccessResponseNotification"

@class BozukoPage;
@class BozukoGame;
@class BozukoPrize;
@class BozukoPage;
@class BozukoGameResult;
@class BozukoEntryPoint;
@class BozukoBozuko;
@class ASIHTTPRequest;
@class ASIFormDataRequest;
@class FacebookLikeButton;

@interface BozukoHandler : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *_locationManager;
	BOOL _isLocationServiceAvailable;
	BOOL _shouldAcceptInaccurateCoordinates;
	NSTimer *_locationTimer;
	BOOL _locationNeedsUpdating;
	
	BozukoEntryPoint *_apiEntryPoint;
	BozukoBozuko *_apiBozuko;
	
	NSMutableArray *_businessesArray;
	NSMutableArray *_gamesArray;
	NSMutableArray *_favoritesArray;
	NSMutableArray *_featuredArray;
	NSMutableArray *_gamesInRegionArray;
	NSMutableDictionary *_allPagesDictionary;
	NSMutableDictionary *_likeButtonDictionary;
	
	NSString *_searchQueryString;
	NSString *_favoritesSearchQueryString;
	NSString *_pagesNextURL;
	NSString *_prizesNextURL;
	NSString *_favoritesNextURL;
	
	NSString *_bozukoGamePageID;
	NSString *_demoGamePageID;
}

@property (readonly) BOOL isLocationServiceAvailable;
@property (retain) BozukoEntryPoint *apiEntryPoint;
@property (retain) BozukoBozuko *apiBozuko;
@property (retain) NSString *searchQueryString;
@property (retain) NSString *favoritesSearchQueryString;
@property (retain) NSString *pagesNextURL;
@property (retain) NSString *prizesNextURL;
@property (retain) NSString *favoritesNextURL;
@property (retain) NSString *bozukoGamePageID;
@property (retain) NSString *demoGamePageID;
@property (readonly) CLLocationManager *locationManager;

- (NSString *)baseURL;
- (void)updateBaseURL;
- (void)bozukoServerErrorCode:(NSInteger)inErrorCode forResponse:(NSString *)inResponseString;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
- (void)applicationDidReceiveMemoryWarning;
- (FacebookLikeButton *)facebookLikeButtonForPage:(BozukoPage *)inBozukoPage;
- (void)dumpFacebookLikeButtonCache;
- (BozukoPage *)defaultBozukoGame;
- (BozukoPage *)demoBozukoGame;
- (void)bozukoEntryPoint;
- (void)bozukoLogout;
- (void)bozukoGame;
- (void)demoGame;
- (void)bozukoBozuko;
- (void)bozukoRefreshGameStateForGame:(BozukoGame *)inBozukoGame;
//- (void)bozukoRefreshGameForGame:(BozukoGame *)aBozukoGame;
- (void)bozukoEnterGame:(BozukoGame *)inBozukoGame;
- (void)bozukoGameResultsForGame:(BozukoGame *)inBozukoGame;
- (void)bozukoUser;
- (void)bozukoRedeemPrize:(BozukoPrize *)inBozukoPrize withMessage:(NSString *)inMessage postToWall:(BOOL)inBool;
- (void)bozukoPrizes;
- (void)bozukoPrizesNextPage;
- (BozukoPage *)currentPageForPage:(BozukoPage *)inBozukoPage;
- (void)bozukoPageRefreshForPageLink:(NSString *)inBozukoPageLink;
- (void)bozukoPageRefreshForPage:(BozukoPage *)inBozukoPage;
- (void)bozukoPagesNextPage;
- (void)bozukoPages;
- (void)bozukoPagesSearchFor:(NSString *)inSearchString;
- (void)bozukoFavorites;
- (void)bozukoFavoritesSearchFor:(NSString *)inSearchString;
- (void)bozukoFavoritesNextPage;
- (void)bozukoRegisteredPagesInRegion:(MKCoordinateRegion)inRegion;
- (void)bozukoFeedback:(NSString *)inText forPage:(BozukoPage *)inPage;
- (void)bozukoFacebookCheckInMessage:(NSString *)inText forPage:(BozukoPage *)inBozukoPage;
- (void)bozukoRecommendMessage:(NSString *)inText forPage:(BozukoPage *)inBozukoPage;
- (void)bozukoToggleFavoriteForPage:(BozukoPage *)inBozukoPage;
//- (void)bozukoLikePage:(BozukoPage *)inBozukoPage;
- (id)jsonObject:(NSString *)inString;
- (void)locationTimerElapsed;
- (BozukoPage *)businessAtIndex:(NSInteger)inIndex;
- (BozukoPage *)gamesAtIndex:(NSInteger)inIndex;
- (BozukoPage *)featuredBusinessAtIndex:(NSInteger)inIndex;
- (BozukoPage *)favoriteBusinessAtIndex:(NSInteger)inIndex;
- (NSInteger)numberOfBusinesses;
- (NSInteger)numberOfNearbyGames;
- (NSInteger)numberOfFeaturedGames;
- (NSInteger)numberOfFavoriteGames;
- (NSInteger)numberOfRegisteredGamesInRegion;
- (NSArray *)allRegisterdGamesInRegion;

- (ASIHTTPRequest *)httpGETRequestWithURL:(NSURL *)inURL;
- (ASIFormDataRequest *)httpPOSTRequestWithURL:(NSURL *)inURL;
- (ASIFormDataRequest *)httpPUTRequestWithURL:(NSURL *)inURL;
- (NSString *)urlSuffix;

- (NSString *)challengeResponseForURL:(NSString *)inURL;
- (NSString*)sha1:(NSString*)input;

+ (BozukoHandler *)sharedInstance;

@end
