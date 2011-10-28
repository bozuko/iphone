//
//  BozukoHandler.m
//  Bozuko
//
//  Created by Tom Corwine on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoHandler.h"
#import "UserHandler.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "BozukoGame.h"
#import "BozukoGameResult.h"
#import "BozukoEntryPoint.h"
#import "BozukoPage.h"
#import "BozukoUser.h"
#import "BozukoBozuko.h"
#import "BozukoRedemption.h"
#import "BozukoPrize.h"
#import "BozukoGameState.h"
#import "BozukoFavoriteResponse.h"
#import "Reachability.h"
#import "FacebookLikeButton.h"
#import <CommonCrypto/CommonDigest.h>

#define kBozukoHandler_LocationStaleCoordinatesTime	120
#define kBozukoHandler_LocationFindingTimeout		10
#define kBozukoHandler_LocationAccuracyRequirement	1000
#define kBozukoHandler_GettingLocationString		@"Getting Location..."
#define kBozukoHandler_LoadingPlacesString			@"Loading Places..."

static BozukoHandler *instance;
static NSString *_bozukoServerBaseURLString;

@implementation BozukoHandler

@synthesize isLocationServiceAvailable = _isLocationServiceAvailable;
@synthesize apiEntryPoint = _apiEntryPoint;
@synthesize apiBozuko = _apiBozuko;
@synthesize searchQueryString = _searchQueryString;
@synthesize favoritesSearchQueryString = _favoritesSearchQueryString;
@synthesize pagesNextURL = _pagesNextURL;
@synthesize prizesNextURL = _prizesNextURL;
@synthesize favoritesNextURL = _favoritesNextURL;
@synthesize bozukoGamePageID = _bozukoGamePageID;
@synthesize demoGamePageID = _demoGamePageID;

@synthesize locationManager = _locationManager;

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	_locationManager.delegate = nil;
	[_locationManager stopUpdatingLocation];

	[_locationManager release];
	
	[_businessesArray release];
	[_gamesArray release];
	[_favoritesArray release];
	[_featuredArray release];
	[_allPagesDictionary release];
	[_likeButtonDictionary release];
	
	[_gamesInRegionArray release];
	[_bozukoGamePageID release];
	[_demoGamePageID release];
	
	[_apiEntryPoint release];
	[_apiBozuko release];
	[_searchQueryString release];
	
	[_prizesNextURL release];
	[_pagesNextURL release];
	
	[_bozukoServerBaseURLString release];
	
    [super dealloc];
}

-(id)init {
	self = [super init];
	
	if (self)
	{
		if ([CLLocationManager locationServicesEnabled] == YES)
		{
			_locationManager = [[CLLocationManager alloc] init];
			_locationManager.purpose = @"Bozuko needs your location in order to provide a list of local businesses.";
			_locationManager.delegate = self;
			_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
			_locationManager.distanceFilter = 1; // 1 meter
			[_locationManager startUpdatingLocation];
			_locationTimer = [NSTimer scheduledTimerWithTimeInterval:kBozukoHandler_LocationFindingTimeout target:self selector:@selector(locationTimerElapsed) userInfo:nil repeats:NO];
			
			_shouldAcceptInaccurateCoordinates = NO;
			_locationNeedsUpdating = YES;
			_isLocationServiceAvailable = YES;
		}
		else
		{
			_isLocationServiceAvailable = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserLocationNotAvailable object:nil];
		}
		
#ifdef BOZUKO_DEV
		NSDictionary *tmpAppDefaultsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kBozukoDevBaseURL, @"server_url", nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:tmpAppDefaultsDictionary];
		[tmpAppDefaultsDictionary release];
		
		NSString *tmpBaseURLString = [[NSUserDefaults standardUserDefaults] stringForKey:@"server_url"];
		
		// Strip the trailing "/", as it exists at the begining of all the relative paths
		if ([tmpBaseURLString hasSuffix:@"/"] == YES)
			tmpBaseURLString = [tmpBaseURLString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
		
		_bozukoServerBaseURLString = [tmpBaseURLString retain];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBaseURL) name:NSUserDefaultsDidChangeNotification object:nil];
#else
		_bozukoServerBaseURLString = [[NSString alloc] initWithString:kBozukoProductionBaseURL];
#endif
		
		_businessesArray = [[NSMutableArray alloc] init];
		_gamesArray = [[NSMutableArray alloc] init];
		_favoritesArray = [[NSMutableArray alloc] init];
		_featuredArray = [[NSMutableArray alloc] init];
		_gamesInRegionArray = [[NSMutableArray alloc] init];
		_allPagesDictionary = [[NSMutableDictionary alloc] init];
		_likeButtonDictionary = [[NSMutableDictionary alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
		
		//[self bozukoEntryPoint];
	}
	
	return self;
}

- (NSString *)baseURL
{
	return _bozukoServerBaseURLString;
}

- (void)updateBaseURL
{
	//DLog(@"================");
	NSString *tmpOldBaseURLString = [NSString stringWithString:_bozukoServerBaseURLString];

	// If URL has been changed in settings, log user out as session token won't be valid on new server
	if ([tmpOldBaseURLString isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"server_url"]] == NO)
	{
		//DLog(@"************** New URL **********************");
		BOOL isLoggedIn = [[UserHandler sharedInstance] loggedIn];
		
		if (isLoggedIn == YES)
			[self bozukoLogout]; // This call being made to old server
		
		[_bozukoServerBaseURLString release];
		_bozukoServerBaseURLString = [[[NSUserDefaults standardUserDefaults] stringForKey:@"server_url"] retain];
		
		if (isLoggedIn == NO)
			[self bozukoEntryPoint]; // Call to new server
	}
}

- (void)reachabilityTest
{
	NSString *tmpString = [_bozukoServerBaseURLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
	NSString *tmpString2 = [tmpString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
	NSArray *tmpURLArray = [tmpString2 componentsSeparatedByString:@":"];
	NSString *tmpHostNameString = [tmpURLArray objectAtIndex:0];
	//DLog(@"Ping: %@", tmpHostNameString);
	Reachability *tmpReachability = [Reachability reachabilityWithHostName:tmpHostNameString];
	
	if ([tmpReachability currentReachabilityStatus] == NotReachable)
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_NetworkNotAvailable object:nil];
}

- (FacebookLikeButton *)facebookLikeButtonForPage:(BozukoPage *)inBozukoPage
{
	if (inBozukoPage == nil)
		return nil;
	
	NSString *tmpBozukoPageID = [inBozukoPage pageID];
	
	FacebookLikeButton *tmpFacebookLikeButton = [_likeButtonDictionary objectForKey:tmpBozukoPageID];
	
	//DLog(@"Page Liked: %d", [inBozukoPage liked]);
	
//	if (tmpFacebookLikeButton)
//		DLog(@"Like Button State: %d", tmpFacebookLikeButton.facebookLikedStatus);
//	else
//		DLog(@"No Button");
	
	// Unload cached button if its Liked state doesn't match page's Liked state.
	if (tmpFacebookLikeButton != nil)
	{
		if (([[UserHandler sharedInstance] loggedIn] == YES && [inBozukoPage liked] != tmpFacebookLikeButton.facebookLikedStatus) ||
			([[UserHandler sharedInstance] loggedIn] == NO && tmpFacebookLikeButton.facebookLikedStatus != FacebookLikedStatus_NotLoggedIn))
		{
			//DLog(@"Reloading Like button for page: %@", [inBozukoPage pageName]);
			[_likeButtonDictionary removeObjectForKey:tmpBozukoPageID];
			tmpFacebookLikeButton = nil;
		}
	}
	
	if (tmpFacebookLikeButton == nil && [inBozukoPage isFacebook] == YES)
	{
		//DLog(@"Creating Button");
		tmpFacebookLikeButton = [[FacebookLikeButton alloc] initWithBozukoPage:inBozukoPage];
		[_likeButtonDictionary setObject:tmpFacebookLikeButton forKey:tmpBozukoPageID];
		[tmpFacebookLikeButton release];
	}
	
	return tmpFacebookLikeButton;
}

- (void)dumpFacebookLikeButtonCache
{
	[_likeButtonDictionary removeAllObjects];
}

- (BozukoPage *)defaultBozukoGame
{
	if (_bozukoGamePageID != nil)
		return [_allPagesDictionary objectForKey:_bozukoGamePageID];
	else
		return nil;
}

- (BozukoPage *)demoBozukoGame
{
	if (_demoGamePageID != nil)
		return [_allPagesDictionary objectForKey:_demoGamePageID];
	else
		return nil;
}

- (void)bozukoServerErrorCode:(NSInteger)inErrorCode forResponse:(NSString *)inResponseString
{
	if (inErrorCode == 0)
		return;
	
	id tmpObject = [self jsonObject:inResponseString];
	NSDictionary *tmpResponseDictionary = nil;
	
	if ([tmpObject isKindOfClass:[NSDictionary class]] == YES)
		tmpResponseDictionary = tmpObject;
	
	if (inErrorCode == 403 && [[tmpResponseDictionary objectForKey:@"name"] isEqualToString:@"bozuko/update"] == YES)
	{
		// Force update
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_ApplicationNeedsUpdate object:tmpResponseDictionary];
	}
	else if (inErrorCode == 403 && [[tmpResponseDictionary objectForKey:@"name"] isEqualToString:@"facebook/auth"] == YES)
	{
		[self bozukoLogout];
		
		DLog(@"Server Error: %d %@ - %@", inErrorCode, [tmpResponseDictionary objectForKey:@"title"], [tmpResponseDictionary objectForKey:@"message"]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_ServerLogoutNotfication object:tmpResponseDictionary];
	}
	else
	{
		DLog(@"Server Error: %d %@ - %@", inErrorCode, [tmpResponseDictionary objectForKey:@"title"], [tmpResponseDictionary objectForKey:@"message"]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_ServerErrorNotfication object:tmpResponseDictionary];
	}
}

- (void)bozukoEntryPoint
{
	static BOOL _isRequestInProgress;
	
	[self reachabilityTest]; // The entry point is the first request, so might as well do a reachability test in parallel.
	
	//The entry point object of the application. If a user token is passed, the user and prizes links will be provided, otherwise, the login link will be present.
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?%@", _bozukoServerBaseURLString, kBozukoAPIEntryPoint, [self urlSuffix]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
	{
		_isRequestInProgress = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PageDidStart object:nil];
	}
	
	[tmpRequest setCompletionBlock:^{
		_isRequestInProgress = NO;
		//DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == NO)
			return;
		
		self.apiEntryPoint = [BozukoEntryPoint objectWithProperties:[tmpObject objectForKey:@"links"]];
		
		if ([[UserHandler sharedInstance] loggedIn] == YES)
			[self bozukoUser];
		else
			[self bozukoPages];
		
		if (_apiBozuko == nil)
			[self bozukoBozuko];
	}];
	
	[tmpRequest setFailedBlock:^{
		_isRequestInProgress = NO;
		DLog(@"%i", [tmpRequest responseStatusCode]);
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoLogout
{
	if ([[UserHandler sharedInstance] loggedIn] == NO)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?%@", _bozukoServerBaseURLString, [[UserHandler sharedInstance].apiUser logoutLink], [self urlSuffix]];
	
	// Kill the user session info now, no need to wait for request to come back
	[[UserHandler sharedInstance] logUserOut];
	[self dumpFacebookLikeButtonCache];
	[_favoritesArray removeAllObjects];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserLoginStatusChanged object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserLoggedOut object:nil];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
	}];
	
	[tmpRequest setFailedBlock:^{
		DLog(@"%i", [tmpRequest responseStatusCode]);
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoGame
{
	static BOOL _isRequestInProgress;
	
	if (_apiBozuko == nil)
	{
		[self bozukoBozuko];
		return;
	}
	
	if ([_apiBozuko bozukoPageLink] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?ll=%f%%2C%f&accuracy=%f", _bozukoServerBaseURLString, [_apiBozuko bozukoPageLink], _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude, _locationManager.location.horizontalAccuracy];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
		_isRequestInProgress = YES;
	
	[tmpRequest setCompletionBlock:^{
		_isRequestInProgress = NO;
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		//DLog(@"%@", [tmpRequest responseString]);
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == YES)
		{
			BozukoPage *tmpBozukoPage = [BozukoPage objectWithProperties:tmpObject];
		
			//DLog(@"%@", [tmpBozukoPage description]);
			
			[_allPagesDictionary setObject:tmpBozukoPage forKey:[tmpBozukoPage pageID]];
			self.bozukoGamePageID = [tmpBozukoPage pageID];
		}
	}];
	
	[tmpRequest setFailedBlock:^{
		_isRequestInProgress = NO;
		DLog(@"%i", [tmpRequest responseStatusCode]);
		
		[self reachabilityTest];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)demoGame
{
	static BOOL _isRequestInProgress;
	
	if (_apiBozuko == nil)
	{
		[self bozukoBozuko];
		return;
	}
	
	if ([_apiBozuko demoPageLink] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?ll=%f%%2C%f&accuracy=%f", _bozukoServerBaseURLString, [_apiBozuko demoPageLink], _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude, _locationManager.location.horizontalAccuracy];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
		_isRequestInProgress = YES;
	
	[tmpRequest setCompletionBlock:^{
		_isRequestInProgress = NO;
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		//DLog(@"%@", [tmpRequest responseString]);
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == YES)
		{
			BozukoPage *tmpBozukoPage = [BozukoPage objectWithProperties:tmpObject];
			
			//DLog(@"%@", [tmpBozukoPage description]);
			
			[_allPagesDictionary setObject:tmpBozukoPage forKey:[tmpBozukoPage pageID]];
			self.demoGamePageID = [tmpBozukoPage pageID];
		}
	}];
	
	[tmpRequest setFailedBlock:^{
		_isRequestInProgress = NO;
		DLog(@"%i", [tmpRequest responseStatusCode]);
		
		[self reachabilityTest];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoBozuko
{
	static BOOL _isRequestInProgress;
	
	if ([_apiEntryPoint bozuko] == nil)
	{
		[self bozukoEntryPoint];
		return;
	}
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", _bozukoServerBaseURLString, [_apiEntryPoint bozuko]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
		_isRequestInProgress = YES;
	
	[tmpRequest setCompletionBlock:^{
		_isRequestInProgress = NO;
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		//DLog(@"%@", [tmpRequest responseString]);
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == YES && [[tmpObject objectForKey:@"links"] isKindOfClass:[NSDictionary class]] == YES)
		{
			self.apiBozuko = [BozukoBozuko objectWithProperties:[tmpObject objectForKey:@"links"]];
			
			[self bozukoGame];
			[self demoGame];
		}
	}];
	
	[tmpRequest setFailedBlock:^{
		_isRequestInProgress = NO;
		DLog(@"%i", [tmpRequest responseStatusCode]);
		
		[self reachabilityTest];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoEnterGame:(BozukoGame *)inBozukoGame
{
	if ([[UserHandler sharedInstance] loggedIn] == NO || [[inBozukoGame gameState] gameEntryLink] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", _bozukoServerBaseURLString, [[inBozukoGame gameState] gameEntryLink]];
	NSString *tmpChallengeResponse = [self challengeResponseForURL:tmpString];
	
	if (tmpChallengeResponse == nil)
	{
		return;
	}
	
	//DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[NSString stringWithFormat:@"%f,%f", _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude] forKey:@"ll"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:tmpChallengeResponse forKey:@"challenge_response"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] userToken] forKey:@"token"];
	[tmpRequest setPostValue:kApplicationVersion forKey:@"mobile_version"];
	
	[tmpRequest setCompletionBlock:^{
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		//DLog(@"%@", [tmpRequest responseString]);
		
		BozukoGameState *tmpBozukoGameState = nil;
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSArray class]] == YES)
		{
			//DLog(@"Game Entry (array): %@", tmpObject);
			
			for (NSDictionary *tmpDictionary in tmpObject)
			{
				if ([[tmpDictionary objectForKey:@"game_id"] isEqualToString:[inBozukoGame gameID]] == YES && [tmpDictionary objectForKey:@"message"] == nil)
				{
					tmpBozukoGameState = [BozukoGameState objectWithProperties:tmpDictionary];
					break;
				}
			}
			
			if (tmpBozukoGameState != nil)
			{
				//[self bozukoGameResultsForGame:inBozukoGame];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameEntryDidFinish object:tmpBozukoGameState];
			}
			else
				[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameEntryDidFail object:nil];
		}
		else if ([tmpObject isKindOfClass:[NSDictionary class]] == YES && [tmpObject objectForKey:@"message"] == nil)
		{
			//DLog(@"Game Entry (dictionary): %@", tmpObject);
			
			tmpBozukoGameState = [BozukoGameState objectWithProperties:tmpObject];
			
			//[self bozukoGameResultsForGame:inBozukoGame];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameEntryDidFinish object:tmpBozukoGameState];
		}
		else
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameEntryDidFail object:nil];
	}];
	
	[tmpRequest setFailedBlock:^{
		DLog(@"%i", [tmpRequest responseStatusCode]);
		
		[self reachabilityTest];
		
		//DLog(@"%@", [tmpRequest responseStatusMessage]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameEntryDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoRefreshGameStateForGame:(BozukoGame *)inBozukoGame
{
	//static BOOL _isRequestInProgress;
	
	if ([[UserHandler sharedInstance] loggedIn] == NO || [[inBozukoGame gameState] gameStateLink] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?ll=%f%%2C%f&accuracy=%f&%@", _bozukoServerBaseURLString, [[inBozukoGame gameState] gameStateLink], _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude, _locationManager.location.horizontalAccuracy, [self urlSuffix]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	//if (tmpRequest != nil)
		//_isRequestInProgress = YES;
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		BozukoGameState *tmpBozukoGameState = nil;
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == YES)
		{
			//DLog(@"GameState: %@", tmpObject);
			
			tmpBozukoGameState = [BozukoGameState objectWithProperties:tmpObject];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameStateDidFinish object:tmpBozukoGameState];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameStateDidFail object:nil];
		}
		
		//_isRequestInProgress = NO;
	}];
	
	[tmpRequest setFailedBlock:^{
		//_isRequestInProgress = NO;
		
		[self reachabilityTest];
		
		DLog(@"%d", [tmpRequest responseStatusCode]);
		DLog(@"%@", [tmpRequest responseStatusMessage]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameStateDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}

/*
- (void)bozukoRefreshGameForGame:(BozukoGame *)aBozukoGame
{
	//static BOOL _isRequestInProgress;
	
	__block BozukoGame *inBozukoGame = aBozukoGame;
	
	if ([[UserHandler sharedInstance] loggedIn] == NO || [inBozukoGame gameLink] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?ll=%f%%2C%f&accuracy=%f&%@", _bozukoServerBaseURLString, [inBozukoGame gameLink], _locationManager.location.coordinate..latitude, _locationManager.location.coordinate..longitude, _locationManager.location.horizontalAccuracy, [self urlSuffix]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	//if (tmpRequest != nil)
	//_isRequestInProgress = YES;
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		BozukoGame *tmpBozukoGame = nil;
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == YES)
		{
			//DLog(@"GameState: %@", tmpObject);
			
			tmpBozukoGame = [BozukoGame objectWithProperties:tmpObject];
			
			//TODO insert game object into page
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameDidFinish object:nil];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameDidFail object:nil];
		}
		
		//_isRequestInProgress = NO;
	}];
	
	[tmpRequest setFailedBlock:^{
		//_isRequestInProgress = NO;
		
		[self reachabilityTest];
		
		DLog(@"%d", [tmpRequest responseStatusCode]);
		DLog(@"%@", [tmpRequest responseStatusMessage]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}
*/

- (void)bozukoGameResultsForGame:(BozukoGame *)inBozukoGame
{
	static BOOL _isRequestInProgress;
	
	if ([[UserHandler sharedInstance] loggedIn] == NO || [[inBozukoGame gameState] gameResultLink] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", _bozukoServerBaseURLString, [[inBozukoGame gameState] gameResultLink]];
	NSString *tmpChallengeResponse = [self challengeResponseForURL:tmpString];
	
	if (tmpChallengeResponse == nil)
	{
		return;
	}
	
	//DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];

	if (tmpRequest != nil)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameResultsRequestInProgress object:nil];
		_isRequestInProgress = YES;
	}
	
	[tmpRequest setPostValue:[NSString stringWithFormat:@"%f,%f", _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude] forKey:@"ll"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:tmpChallengeResponse forKey:@"challenge_response"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] userToken] forKey:@"token"];
	[tmpRequest setPostValue:kApplicationVersion forKey:@"mobile_version"];
	
	[tmpRequest setCompletionBlock:^{
		if ([tmpRequest responseStatusCode] != 200)
		{
			_isRequestInProgress = NO;
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		//DLog(@"%@", [tmpRequest responseString]);
		
		BozukoGameResult *tmpBozukoGameResult = nil;
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == YES)
		{
			//DLog(@"Game Result: %@", tmpObject);
			
			tmpBozukoGameResult = [BozukoGameResult objectWithProperties:tmpObject];
			
			if ([[inBozukoGame gameType] isEqualToString:@"scratch"] == YES)
			{
				[tmpBozukoGameResult setGameID:[inBozukoGame gameID]];
				[tmpBozukoGameResult saveObjectToDisk]; // Persist to disk in case user leaves game during play
				//DLog(@"%@", [inBozukoGame gameId]);
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameResultsDidFinish object:tmpBozukoGameResult];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameResultsDidFail object:nil];
		}
		_isRequestInProgress = NO;
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		_isRequestInProgress = NO;
		DLog(@"%d", [tmpRequest responseStatusCode]);
		//DLog(@"%@", [tmpRequest responseStatusMessage]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameResultsDidFail object:nil];
	}];

	[tmpRequest startAsynchronous];
}

- (void)bozukoUser
{
	static BOOL _isRequestInProgress;
	
	if ([_apiEntryPoint user] == nil)
	{
		[self bozukoEntryPoint];
		return;
	}
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?%@", _bozukoServerBaseURLString, [_apiEntryPoint user], [self urlSuffix]];

	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
		_isRequestInProgress = YES;
	
	[tmpRequest setCompletionBlock:^{
		_isRequestInProgress = NO;
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		//DLog(@"%@", [tmpRequest responseString]);
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == YES)
		{
			[UserHandler sharedInstance].apiUser = [BozukoUser objectWithProperties:tmpObject];
		
			[self bozukoFavorites];
			[self bozukoPages];
			[self bozukoPrizes];

			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserLoginStatusChanged object:nil];
		}
	}];
	
	[tmpRequest setFailedBlock:^{
		_isRequestInProgress = NO;
		
		[self reachabilityTest];
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoRedeemPrize:(BozukoPrize *)inBozukoPrize withMessage:(NSString *)inMessage postToWall:(BOOL)inBool
{
	if ([[UserHandler sharedInstance] loggedIn] == NO || [inBozukoPrize redeem] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", _bozukoServerBaseURLString, [inBozukoPrize redeem]];
	NSString *tmpChallengeResponse = [self challengeResponseForURL:tmpString];
	
	if (tmpChallengeResponse == nil)
	{
		return;
	}
	
	//DLog(@"%@", tmpString);
	//DLog(@"%@", inMessage);
	//DLog(@"%d", inBool);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:tmpChallengeResponse forKey:@"challenge_response"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] userToken] forKey:@"token"];
	[tmpRequest setPostValue:kApplicationVersion forKey:@"mobile_version"];
	
	if (inBool == YES)
	{
		[tmpRequest setPostValue:@"true" forKey:@"share"];
		
		if (inMessage != nil)
			[tmpRequest setPostValue:inMessage forKey:@"message"];
	}
	else
		[tmpRequest setPostValue:@"false" forKey:@"share"];
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"%@", [tmpRequest responseString]);
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == YES)
		{
			//DLog(@"Prize Redemption: %@", tmpObject);

			BozukoRedemption *tmpBozukoRedemption = [BozukoRedemption objectWithProperties:tmpObject];
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PrizeRedemptionDidFinish object:tmpBozukoRedemption];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PrizeRedemptionDidFail object:nil];
		}
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		DLog(@"%d", [tmpRequest responseStatusCode]);
		//DLog(@"%@", [tmpRequest responseStatusMessage]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PrizeRedemptionDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoPrizes
{
	static BOOL _isRequestInProgress;
	
	if (_isRequestInProgress == YES)
		return;
	
	if ([_apiEntryPoint prizes] == nil)
	{
		[self bozukoEntryPoint];
		return;
	}
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?%@", _bozukoServerBaseURLString, [_apiEntryPoint prizes], [self urlSuffix]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
		_isRequestInProgress = YES;
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"Prizes Complete");
		//DLog(@"%@", [tmpRequest responseString]);
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"next"];
		
		if ([tmpObject isKindOfClass:[NSString class]] == YES)
			self.prizesNextURL = tmpObject;
		
		tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"prizes"];
		
		if ([tmpObject isKindOfClass:[NSArray class]] == YES)
		{
			[[UserHandler sharedInstance] clearPrizes];
			
			for (NSDictionary *tmpDictionary in tmpObject)
			{
				BozukoPrize *tmpBozukoPrize = [BozukoPrize objectWithProperties:tmpDictionary];
				[[UserHandler sharedInstance] addPrize:tmpBozukoPrize];
				
				//DLog(@"Prize: %@", tmpBozukoPrize);
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PrizesDidFinish object:nil];
		}
		else
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PrizesDidFail object:nil];
		
		_isRequestInProgress = NO;
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		_isRequestInProgress = NO;
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PrizesDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoPrizesNextPage
{
	static BOOL _isRequestInProgress;
	
	if (_prizesNextURL == nil || _isRequestInProgress == YES)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", _bozukoServerBaseURLString, [self prizesNextURL]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
		_isRequestInProgress = YES;
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"Prizes Complete");
		//DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			_isRequestInProgress = NO;
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"next"];
		
		if ([tmpObject isKindOfClass:[NSString class]] == YES)
			self.prizesNextURL = tmpObject;
		
		tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"prizes"];
		
		if ([tmpObject isKindOfClass:[NSArray class]] == YES)
		{
			for (NSDictionary *tmpDictionary in tmpObject)
			{
				BozukoPrize *tmpBozukoPrize = [BozukoPrize objectWithProperties:tmpDictionary];
				[[UserHandler sharedInstance] addPrize:tmpBozukoPrize];
				
				//DLog(@"Prize: %@", tmpBozukoPrize);
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PrizesDidFinish object:nil];
		}
		else
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PrizesDidFail object:nil];
		
		_isRequestInProgress = NO;
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		_isRequestInProgress = NO;
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PrizesDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}

- (BozukoPage *)currentPageForPage:(BozukoPage *)inBozukoPage
{
	return [_allPagesDictionary objectForKey:[inBozukoPage pageID]];
}

- (void)bozukoPageRefreshForPage:(BozukoPage *)inBozukoPage
{
	[self bozukoPageRefreshForPageLink:[inBozukoPage page]];
}

- (void)bozukoPageRefreshForPageLink:(NSString *)inBozukoPageLink
{
	static BOOL _isRequestInProgress;
	
	if (inBozukoPageLink == nil || _isRequestInProgress == YES)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?%@", _bozukoServerBaseURLString, inBozukoPageLink, [self urlSuffix]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GameResultsRequestInProgress object:nil];
		_isRequestInProgress = YES;
	}
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			_isRequestInProgress = NO;
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == YES)
		{
			BozukoPage *tmpBozukoPage = [BozukoPage objectWithProperties:tmpObject];
			
			[_allPagesDictionary setObject:tmpBozukoPage forKey:[tmpBozukoPage pageID]];
			
			//DLog(@"%@", [tmpBozukoPage description]);
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PageDidFinish object:tmpBozukoPage];
		}
		else
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PageDidFail object:nil];
		
		_isRequestInProgress = NO;
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		_isRequestInProgress = NO;
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PrizesDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoRegisteredPagesInRegion:(MKCoordinateRegion)inRegion
{
	//static ASIHTTPRequest *tmpRequest = nil;
	static BOOL isRequestInProgress;
	
	if ([_apiEntryPoint pages] == nil)
	{
		[self bozukoEntryPoint];
		return;
	}

	float upperRightBoundsLatitude = inRegion.center.latitude - (inRegion.span.latitudeDelta * 0.5);
	float lowerLeftBoundsLatitude = inRegion.center.latitude + (inRegion.span.latitudeDelta * 0.5);
	float upperRightBoundsLongitude = inRegion.center.longitude - (inRegion.span.longitudeDelta * 0.5);
	float lowerLeftBoundsLongitude = inRegion.center.longitude + (inRegion.span.longitudeDelta * 0.5);
	
	// Bozuko's server doesn't seem to like the 180.0 longitude number.
	if (upperRightBoundsLongitude <= -180.0)
		upperRightBoundsLongitude = -179.9999;
	
	if (lowerLeftBoundsLongitude >= 180.0)
		lowerLeftBoundsLongitude = 179.9999;
	
	NSString *tmpBoundsString = [NSString stringWithFormat:@"%f%%2C%f%%2C%f%%2C%f", upperRightBoundsLatitude, upperRightBoundsLongitude, lowerLeftBoundsLatitude, lowerLeftBoundsLongitude];
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?ll=%f%%2C%f&accuracy=%f&bounds=%@&%@", _bozukoServerBaseURLString, [_apiEntryPoint pages], _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude, _locationManager.location.horizontalAccuracy, tmpBoundsString, [self urlSuffix]];
	
	//DLog(@"%@", tmpString);
	
	//[tmpRequest cancel];
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
		isRequestInProgress = YES;

	[tmpRequest setCompletionBlock:^{
		//DLog(@"Pages Request Complete");
		//DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"pages"];
		
		if ([tmpObject isKindOfClass:[NSArray class]] == YES)
		{
			[_gamesInRegionArray removeAllObjects];
			
			for (NSDictionary *tmpDictionary in tmpObject)
			{
				//DLog(@"%@", tmpDictionary);
				
				BozukoPage *tmpBozukoPage = [BozukoPage objectWithProperties:tmpDictionary];
				
				[_allPagesDictionary setObject:tmpBozukoPage forKey:[tmpBozukoPage pageID]];
				
				if ([tmpBozukoPage registered] == YES)
					[_gamesInRegionArray addObject:[tmpBozukoPage pageID]];
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GetPagesForRegionDidFinish object:nil];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GetPagesForRegionDidFail object:nil];
		}
		
		isRequestInProgress = NO;
		
		//tmpRequest = nil;
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
		DLog(@"%@", [tmpRequest responseStatusMessage]);
		
		//tmpRequest = nil;
		isRequestInProgress = NO;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GetPagesForLocationDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoPagesNextPage
{
	static BOOL _isRequestInProgress;

	if (_isRequestInProgress == YES || _pagesNextURL == nil)
		return; // Prevent more than one request from happening at a time.
	
	NSMutableString *tmpString = [NSMutableString stringWithFormat:@"%@%@", _bozukoServerBaseURLString, [self pagesNextURL]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PageDidStart object:kBozukoHandler_LoadingPlacesString];
		_isRequestInProgress = YES;
	}
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"Pages Request Complete");
		//DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			_isRequestInProgress = NO;
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"next"];
		
		if ([tmpObject isKindOfClass:[NSString class]] == YES)
			self.pagesNextURL = tmpObject;
		
		tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"pages"];
		
		if ([tmpObject isKindOfClass:[NSArray class]] == YES)
		{
			for (NSDictionary *tmpDictionary in tmpObject)
			{
				//DLog(@"%@", tmpDictionary);
				
				BozukoPage *tmpBozukoPage = [BozukoPage objectWithProperties:tmpDictionary];
				
				[_allPagesDictionary setObject:tmpBozukoPage forKey:[tmpBozukoPage pageID]];
				
				if ([tmpBozukoPage featured] == YES)
					[_featuredArray addObject:[tmpBozukoPage pageID]];
				else if ([tmpBozukoPage registered] == YES)
					[_gamesArray addObject:[tmpBozukoPage pageID]];
				else
					[_businessesArray addObject:[tmpBozukoPage pageID]];
				
				//if ([tmpBozukoPage favorite] == YES)
					//[_favoritesArray addObject:tmpBozukoPage];
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GetPagesForLocationDidFinish object:nil];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GetPagesForLocationDidFail object:nil];
		}
		
		_isRequestInProgress = NO;
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		_isRequestInProgress = NO;
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GetPagesForLocationDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoPages
{
	[self bozukoPagesSearchFor:_searchQueryString];
}

- (void)bozukoPagesSearchFor:(NSString *)inSearchString
{
	if (_locationNeedsUpdating == YES)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PageDidStart object:kBozukoHandler_GettingLocationString];
		return;
	}
	
	[_locationTimer invalidate];
	_locationTimer = nil;
	
	static BOOL _isRequestInProgress;
	
	self.searchQueryString = inSearchString;
	
	if (_isRequestInProgress == YES)
		return; // Prevent more than one request from happening at a time.
	
	if ([_apiEntryPoint pages] == nil)
	{
		[self bozukoEntryPoint];
		return;
	}
	
	NSMutableString *tmpString = [NSMutableString stringWithFormat:@"%@%@?ll=%f%%2C%f&accuracy=%f&%@", _bozukoServerBaseURLString, [_apiEntryPoint pages], _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude, _locationManager.location.horizontalAccuracy, [self urlSuffix]];
	
	if (inSearchString != nil)
		[tmpString appendFormat:@"&query=%@", [inSearchString stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding]];
	
	//DLog(@"%@", tmpString);

	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PageDidStart object:kBozukoHandler_LoadingPlacesString];
		_isRequestInProgress = YES;
	}
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"Pages Request Complete");
		//DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			_isRequestInProgress = NO;
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"next"];
		
		if ([tmpObject isKindOfClass:[NSString class]] == YES)
			self.pagesNextURL = tmpObject;
		
		tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"pages"];
		
		if ([tmpObject isKindOfClass:[NSArray class]] == YES)
		{
			[_featuredArray removeAllObjects];
			[_gamesArray removeAllObjects];
			[_businessesArray removeAllObjects];

			for (NSDictionary *tmpDictionary in tmpObject)
			{
				//DLog(@"%@", tmpDictionary);

				BozukoPage *tmpBozukoPage = [BozukoPage objectWithProperties:tmpDictionary];
				
				[_allPagesDictionary setObject:tmpBozukoPage forKey:[tmpBozukoPage pageID]];

				if ([tmpBozukoPage featured] == YES)
					[_featuredArray addObject:[tmpBozukoPage pageID]];
				else if ([tmpBozukoPage registered] == YES)
					[_gamesArray addObject:[tmpBozukoPage pageID]];
				else
					[_businessesArray addObject:[tmpBozukoPage pageID]];
			}
			
			if ([_favoritesArray count] < 1 && [[UserHandler sharedInstance] loggedIn] == YES)
				[self bozukoFavorites];
		
			//DLog(@"Finished");
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GetPagesForLocationDidFinish object:nil];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GetPagesForLocationDidFail object:nil];
		}
		
		_isRequestInProgress = NO;
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		_isRequestInProgress = NO;
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
		DLog(@"%@", [tmpRequest responseStatusMessage]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_GetPagesForLocationDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoFavorites
{
	[self bozukoFavoritesSearchFor:_favoritesSearchQueryString];
}

- (void)bozukoFavoritesSearchFor:(NSString *)inSearchString
{
	//static ASIHTTPRequest *tmpRequest = nil;
	
	self.favoritesSearchQueryString = inSearchString;
	
	if ([_apiEntryPoint pages] == nil)
	{
		[self bozukoEntryPoint];
		return;
	}
	
	NSMutableString *tmpString = [NSMutableString stringWithFormat:@"%@%@?favorites=true&ll=%f%%2C%f&accuracy=%f&%@", _bozukoServerBaseURLString, [_apiEntryPoint pages], _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude, _locationManager.location.horizontalAccuracy, [self urlSuffix]];
	
	if (inSearchString != nil)
		[tmpString appendFormat:@"&query=%@", [inSearchString stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding]];
	
	DLog(@"%@", tmpString);
	
	//[tmpRequest cancel]; // Cancel any request that may be in progress.
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_FavoritesDidStart object:nil];
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"Favorites Complete");
		DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"next"];
		
		if ([tmpObject isKindOfClass:[NSString class]] == YES)
			self.favoritesNextURL = tmpObject;
		
		tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"pages"];
		
		if ([tmpObject isKindOfClass:[NSArray class]] == YES)
		{
			[_favoritesArray removeAllObjects];
			
			for (NSDictionary *tmpDictionary in tmpObject)
			{
				//DLog(@"%@", tmpDictionary);
				
				BozukoPage *tmpBozukoPage = [BozukoPage objectWithProperties:tmpDictionary];
				
				[_allPagesDictionary setObject:tmpBozukoPage forKey:[tmpBozukoPage pageID]];
				[_favoritesArray addObject:[tmpBozukoPage pageID]];
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_FavoritesDidFinish object:nil];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_FavoritesDidFail object:nil];
		}
		
		tmpRequest = nil;
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
		DLog(@"%@", [tmpRequest responseStatusMessage]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_FavoritesDidFail object:nil];
		
		tmpRequest = nil;
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoFavoritesNextPage
{
	static BOOL isRequestInProgress;
	
	if (isRequestInProgress == YES || _favoritesNextURL == nil)
		return; // Prevent more than one request from happening at a time.
	
	NSMutableString *tmpString = [NSMutableString stringWithFormat:@"%@%@", _bozukoServerBaseURLString, [self favoritesNextURL]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_FavoritesDidStart object:nil];
		isRequestInProgress = YES;
	}
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"Favorites Request Complete");
		//DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			isRequestInProgress = NO;
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"next"];
		
		if ([tmpObject isKindOfClass:[NSString class]] == YES)
			self.favoritesNextURL = tmpObject;
		
		tmpObject = [[self jsonObject:[tmpRequest responseString]] objectForKey:@"pages"];
		
		if ([tmpObject isKindOfClass:[NSArray class]] == YES)
		{
			for (NSDictionary *tmpDictionary in tmpObject)
			{
				//DLog(@"%@", tmpDictionary);
				
				BozukoPage *tmpBozukoPage = [BozukoPage objectWithProperties:tmpDictionary];
				
				[_allPagesDictionary setObject:tmpBozukoPage forKey:[tmpBozukoPage pageID]];
				[_favoritesArray addObject:[tmpBozukoPage pageID]];
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_FavoritesDidFinish object:nil];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_FavoritesDidFail object:nil];
		}
		
		isRequestInProgress = NO;
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		isRequestInProgress = NO;
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_FavoritesDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoFeedback:(NSString *)inText forPage:(BozukoPage *)inBozukoPage
{
	if ([[UserHandler sharedInstance] loggedIn] == NO || [inBozukoPage feedback] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", _bozukoServerBaseURLString, [inBozukoPage feedback]];
	NSString *tmpChallengeResponse = [self challengeResponseForURL:tmpString];
	
	if (tmpChallengeResponse == nil)
	{
		return;
	}
	
	//DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPUTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:tmpChallengeResponse forKey:@"challenge_response"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] userToken] forKey:@"token"];
	[tmpRequest setPostValue:inText forKey:@"message"];
	[tmpRequest setPostValue:kApplicationVersion forKey:@"mobile_version"];

	[tmpRequest setCompletionBlock:^{
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		//DLog(@"%@", [tmpRequest responseString]);
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoFacebookCheckInMessage:(NSString *)inText forPage:(BozukoPage *)inBozukoPage
{
	if ([[UserHandler sharedInstance] loggedIn] == NO || [inBozukoPage facebookCheckin] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", _bozukoServerBaseURLString, [inBozukoPage facebookCheckin]];
	NSString *tmpChallengeResponse = [self challengeResponseForURL:tmpString];
	
	if (tmpChallengeResponse == nil)
	{
		return;
	}
	
	DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[NSString stringWithFormat:@"%f,%f", _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude] forKey:@"ll"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:tmpChallengeResponse forKey:@"challenge_response"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] userToken] forKey:@"token"];
	[tmpRequest setPostValue:inText forKey:@"message"];
	[tmpRequest setPostValue:kApplicationVersion forKey:@"mobile_version"];
	
	[tmpRequest setCompletionBlock:^{
		DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSArray class]] == YES)
		{
			DLog(@"Check In Successful");
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_FacebookCheckInDidFinish object:tmpObject];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_FacebookCheckInDidFail object:nil];
		}
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_FacebookCheckInDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoRecommendMessage:(NSString *)inText forPage:(BozukoPage *)inBozukoPage
{
	if ([[UserHandler sharedInstance] loggedIn] == NO || [inBozukoPage recommend] == nil || inText == nil || [inText isEqualToString:@""] == YES)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", _bozukoServerBaseURLString, [inBozukoPage recommend]];
	NSString *tmpChallengeResponse = [self challengeResponseForURL:tmpString];
	
	if (tmpChallengeResponse == nil)
	{
		return;
	}
	
	//DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:tmpChallengeResponse forKey:@"challenge_response"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] userToken] forKey:@"token"];
	[tmpRequest setPostValue:inText forKey:@"message"];
	[tmpRequest setPostValue:kApplicationVersion forKey:@"mobile_version"];
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"%@", [tmpRequest responseString]);
		
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == YES && [[tmpObject objectForKey:@"success"] intValue] == 1)
		{
			DLog(@"Recommend Successful");
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_RecommendDidFinish object:nil];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_RecommendDidFail object:nil];
		}
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_RecommendDidFail object:nil];
	}];
	
	[tmpRequest startAsynchronous];
}

- (void)bozukoToggleFavoriteForPage:(BozukoPage *)inBozukoPage
{
	// Make sure we're dealing with the most recent version of the page
	BozukoPage *tmpBozukoPage = [_allPagesDictionary objectForKey:[inBozukoPage pageID]];
	
	if ([[UserHandler sharedInstance] loggedIn] == NO || [tmpBozukoPage favoriteLink] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", _bozukoServerBaseURLString, [tmpBozukoPage favoriteLink]];

	//DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[[UserHandler sharedInstance] userToken] forKey:@"token"];
	[tmpRequest setPostValue:kApplicationVersion forKey:@"mobile_version"];
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"%@", [tmpRequest responseString]);
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == YES)
		{
			BozukoFavoriteResponse *tmpBozukoFavoriteResponse = [BozukoFavoriteResponse objectWithProperties:tmpObject];
			
			// Make sure this response is for the right page. Probably unessessary, but might as well check
			if ([[tmpBozukoPage pageID] isEqualToString:[tmpBozukoFavoriteResponse pageID]] == YES)
			{
				if ([tmpBozukoFavoriteResponse added] == YES)
					[tmpBozukoPage setFavorite:YES];
				else if ([tmpBozukoFavoriteResponse removed] == YES)
					[tmpBozukoPage setFavorite:NO];

				[self bozukoFavorites];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_SetFavoriteDidFinish object:tmpBozukoFavoriteResponse];
			}
		}
	}];
	
	[tmpRequest setFailedBlock:^{
		[self reachabilityTest];
		
		DLog(@"%i", [tmpRequest responseStatusCode]);
	}];
	
	[tmpRequest startAsynchronous];
}

/*
- (void)bozukoLikePage:(BozukoPage *)inBozukoPage
{	
	if ([[UserHandler sharedInstance] loggedIn] == NO || [inBozukoPage facebookLike] == nil || [inBozukoPage liked] == YES)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", kBozukoBaseURL, [inBozukoPage facebookLike]];
	NSString *tmpChallengeResponse = [self challengeResponseForURL:tmpString];
 
	if (tmpChallengeResponse == nil)
	{
		return;
	}
	
	DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:tmpChallengeResponse forKey:@"challenge_response"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] userToken] forKey:@"token"];
	[tmpRequest setPostValue:kApplicationVersion forKey:@"mobile_version"];
	
	[tmpRequest setCompletionBlock:^{
		DLog(@"%@", [tmpRequest responseString]);
		
		id tmpObject = [self jsonObject:[tmpRequest responseString]];
		
		if ([tmpObject isKindOfClass:[NSDictionary class]] == YES)
		{
			if ([[tmpObject objectForKey:@"success"] intValue] == 1)
			{
				[inBozukoPage setLiked:YES];
				[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_SuccessResponseNotification object:nil];
			}
		}
	}];
	
	[tmpRequest setFailedBlock:^{
		DLog(@"%i", [tmpRequest responseStatusCode]);
	}];
	
	[tmpRequest startAsynchronous];
}
 */

#pragma mark - Helper Methods

- (ASIHTTPRequest *)httpGETRequestWithURL:(NSURL *)inURL
{
	ASIHTTPRequest *tmpRequest = [ASIHTTPRequest requestWithURL:inURL];
	tmpRequest.useCookiePersistence = NO;
	tmpRequest.cachePolicy = (ASIDoNotWriteToCacheCachePolicy | ASIDoNotReadFromCacheCachePolicy);
	tmpRequest.timeOutSeconds = 20;
	tmpRequest.numberOfTimesToRetryOnTimeout = 3;
	
	return tmpRequest;
}

- (ASIFormDataRequest *)httpPOSTRequestWithURL:(NSURL *)inURL
{
	ASIFormDataRequest *tmpRequest = [ASIFormDataRequest requestWithURL:inURL];
	tmpRequest.useCookiePersistence = NO;
	tmpRequest.requestMethod = @"POST";
	[tmpRequest setPostFormat:ASIURLEncodedPostFormat];
	tmpRequest.cachePolicy = (ASIDoNotWriteToCacheCachePolicy | ASIDoNotReadFromCacheCachePolicy);
	tmpRequest.timeOutSeconds = 20;
	tmpRequest.numberOfTimesToRetryOnTimeout = 3;
	
	return tmpRequest;
}

- (ASIFormDataRequest *)httpPUTRequestWithURL:(NSURL *)inURL
{
	ASIFormDataRequest *tmpRequest = [ASIFormDataRequest requestWithURL:inURL];
	tmpRequest.useCookiePersistence = NO;
	tmpRequest.requestMethod = @"PUT";
	[tmpRequest setPostFormat:ASIURLEncodedPostFormat];
	tmpRequest.cachePolicy = (ASIDoNotWriteToCacheCachePolicy | ASIDoNotReadFromCacheCachePolicy);
	tmpRequest.timeOutSeconds = 20;
	tmpRequest.numberOfTimesToRetryOnTimeout = 3;
	
	return tmpRequest;
}

- (NSString *)urlSuffix
{
	NSMutableString *tmpString = [[NSMutableString alloc] init];
	
	if ([[UserHandler sharedInstance] loggedIn] == YES)
		[tmpString appendString:[NSString stringWithFormat:@"token=%@&", [[UserHandler sharedInstance] userToken]]];
	
	[tmpString appendString:[NSString stringWithFormat:@"mobile_version=%@", kApplicationVersion]];
	
	return [tmpString autorelease];
}

- (NSString *)challengeResponseForURL:(NSString *)inURL
{
	if ([UserHandler sharedInstance].apiUser == nil)
	{
		[self bozukoUser];
		return nil;
	}
	
	NSString *tmpPath = [inURL stringByReplacingOccurrencesOfString:_bozukoServerBaseURLString withString:@""]; // Remove protocol / hostname / port
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", tmpPath, [[UserHandler sharedInstance].apiUser challenge]];
	NSString *tmpHashString = [self sha1:tmpString];
	
	//DLog(@"Challenge Input URL: %@", tmpString);
	//DLog(@"Hash: %@", tmpHashString);
	
	return tmpHashString;
}

- (NSString*)sha1:(NSString*)input
{
	const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
	NSData *data = [NSData dataWithBytes:cstr length:input.length];
	
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	
	CC_SHA1(data.bytes, data.length, digest);
	
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	
	for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", digest[i]];
	
	return output;
}
 
- (id)jsonObject:(NSString *)inString
{
	SBJsonParser *tmpJSONParser = [SBJsonParser new];
	
	id tmpObject = [tmpJSONParser objectWithString:inString];
	
	[tmpJSONParser release];
	
	return tmpObject;
}

#pragma mark - Notification Methods

- (void)applicationDidEnterBackground
{
	_shouldAcceptInaccurateCoordinates = NO;
	
	[_businessesArray removeAllObjects];
	[_gamesArray removeAllObjects];
	[_favoritesArray removeAllObjects];
	[_featuredArray removeAllObjects];
	[_allPagesDictionary removeAllObjects];
	
	[_locationTimer invalidate];
	_locationTimer = nil;
	
	[_locationManager stopUpdatingLocation];
}

- (void)applicationWillEnterForeground
{
	_shouldAcceptInaccurateCoordinates = NO;
	_locationNeedsUpdating = YES;
	[_locationManager startUpdatingLocation];
	_locationTimer = [NSTimer scheduledTimerWithTimeInterval:kBozukoHandler_LocationFindingTimeout target:self selector:@selector(locationTimerElapsed) userInfo:nil repeats:NO];
	
	if (_apiEntryPoint == nil)
		[self bozukoEntryPoint];
	
	if (_apiBozuko == nil)
		[self bozukoBozuko];
	else
	{
		[self bozukoGame];
		[self demoGame];
	}
	
	//[self bozukoPages];
}

- (void)applicationDidReceiveMemoryWarning
{
}

#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{	
	if ((newLocation.coordinate.longitude == 0.0 && newLocation.coordinate.latitude == 0.0) || newLocation.horizontalAccuracy < 0)
	{
		_isLocationServiceAvailable = NO;
		_locationNeedsUpdating = YES;
		
		return;
	}
	else
		_isLocationServiceAvailable = YES;
	
	if ((newLocation.horizontalAccuracy > kBozukoHandler_LocationAccuracyRequirement && _shouldAcceptInaccurateCoordinates == NO) || [newLocation.timestamp timeIntervalSinceNow] < -kBozukoHandler_LocationStaleCoordinatesTime)
	{
		//DLog(@"Not accurate enough or too old: %f time: %@", newLocation.horizontalAccuracy, newLocation.timestamp);
		_locationNeedsUpdating = YES;
		
		if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PageDidStart object:kBozukoHandler_GettingLocationString];
	}
	else if (_locationNeedsUpdating == YES)
	{
		//DLog(@"Reloading - Is accurate enough: %f", newLocation.horizontalAccuracy);
		_locationNeedsUpdating = NO;
		
		if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
			[self bozukoPages]; // Refresh pages for new location if application is in foreground
	}
	else
	{
		//DLog(@"Is accurate enough: %f", newLocation.horizontalAccuracy);
		_locationNeedsUpdating = NO;
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if ([error code] == kCLErrorDenied)
	{
		//DLog(@"Location Error");
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserLocationNotAvailable object:nil];
		_isLocationServiceAvailable = NO;
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
	{
		//DLog(@"Location Status");
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserLocationNotAvailable object:nil];
		_isLocationServiceAvailable = NO;
	}
	else
		_isLocationServiceAvailable = YES;
}

#pragma mark - Location Helper Method

- (void)locationTimerElapsed
{
	[_locationTimer invalidate];
	_locationTimer = nil;
	
	_locationNeedsUpdating = NO;
	_shouldAcceptInaccurateCoordinates = YES;
	
	[self bozukoPages];
}

#pragma mark - Data

- (BozukoPage *)businessAtIndex:(NSInteger)inIndex
{
	if (inIndex < 0 || inIndex > [_businessesArray count] - 1 || [_businessesArray count] == 0)
		return nil;
	
	return [_allPagesDictionary objectForKey:[_businessesArray objectAtIndex:inIndex]];
}

- (BozukoPage *)gamesAtIndex:(NSInteger)inIndex
{
	if (inIndex < 0 || inIndex > [_gamesArray count] - 1 || [_gamesArray count] == 0)
		return nil;
	
	return [_allPagesDictionary objectForKey:[_gamesArray objectAtIndex:inIndex]];
}

- (BozukoPage *)featuredBusinessAtIndex:(NSInteger)inIndex
{
	if (inIndex < 0 || inIndex > [_featuredArray count] - 1 || [_featuredArray count] == 0)
		return nil;
	
	return [_allPagesDictionary objectForKey:[_featuredArray objectAtIndex:inIndex]];
}

- (BozukoPage *)favoriteBusinessAtIndex:(NSInteger)inIndex
{
	if (inIndex < 0 || inIndex > [_favoritesArray count] - 1 || [_favoritesArray count] == 0)
		return nil;
	
	return [_allPagesDictionary objectForKey:[_favoritesArray objectAtIndex:inIndex]];
}

- (NSInteger)numberOfBusinesses
{
	return [_businessesArray count];
}

- (NSInteger)numberOfNearbyGames
{
	return [_gamesArray count];
}

- (NSInteger)numberOfFeaturedGames
{
	return [_featuredArray count];
}

- (NSInteger)numberOfFavoriteGames
{
	return [_favoritesArray count];
}

- (NSInteger)numberOfRegisteredGamesInRegion
{
	return [_gamesInRegionArray count];
}

- (NSArray *)allRegisterdGamesInRegion
{
	NSMutableArray *tmpMutableArray = [[NSMutableArray alloc] init];
	
	for (NSString *tmpBozukoPageIDString in _gamesInRegionArray)
		[tmpMutableArray addObject:[_allPagesDictionary objectForKey:tmpBozukoPageIDString]];
	
	NSArray *tmpArray = [NSArray arrayWithArray:tmpMutableArray];
	[tmpMutableArray release];
	
	return tmpArray;
}


#pragma mark -
#pragma mark Plumbing

+(BozukoHandler *) sharedInstance {
	
	@synchronized(self)
	{
		if (!instance)
		{
			instance = [[BozukoHandler alloc] init];

		}
	}
	return instance;
}

+(id) allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if (!instance)
		{
			instance = [super allocWithZone:zone];
		}
	}
	return instance;
}

- (id) copyWithZone:(NSZone *)zone {	return self; } 
- (id) retain { return self; } 
- (void) release { }
- (NSUInteger) retainCount {	return NSUIntegerMax; } 
- (id) autorelease { return self; }




@end
