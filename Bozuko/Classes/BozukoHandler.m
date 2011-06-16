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
#import <CommonCrypto/CommonDigest.h>

#define kBozukoChallengeNumber		5127	// Not used anymore

static BozukoHandler *instance;

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

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_locationManager stopUpdatingLocation];
	[_locationManager release];
	
	[_businessesArray release];
	[_gamesArray release];
	[_favoritesArray release];
	[_featuredArray release];
	[_allPagesDictionary release];
	
	[_gamesInRegionArray release];
	[_bozukoGamePageID release];
	
	[_apiEntryPoint release];
	[_apiBozuko release];
	[_searchQueryString release];
	
	[_prizesNextURL release];
	[_pagesNextURL release];
	
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
			_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
			[_locationManager startUpdatingLocation];
			
			_isLocationServiceAvailable = YES;
		}
		else
		{
			DLog(@"Location Class");
			_isLocationServiceAvailable = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserLocationNotAvailable object:nil];
		}
		
		_businessesArray = [[NSMutableArray alloc] init];
		_gamesArray = [[NSMutableArray alloc] init];
		_favoritesArray = [[NSMutableArray alloc] init];
		_featuredArray = [[NSMutableArray alloc] init];
		_gamesInRegionArray = [[NSMutableArray alloc] init];
		_allPagesDictionary = [[NSMutableDictionary alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
		
		[self bozukoEntryPoint];
	}
	
	return self;
}

- (void)reachabilityTest
{
	Reachability *tmpReachability = [Reachability reachabilityWithHostName:kBozukoHost];
	
	if ([tmpReachability currentReachabilityStatus] == NotReachable)
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_NetworkNotAvailable object:nil];
}

- (BozukoPage *)defaultBozukoGame
{
	if (_bozukoGamePageID != nil)
		return [_allPagesDictionary objectForKey:_bozukoGamePageID];
	else
		return nil;
}

- (void)bozukoServerErrorCode:(NSInteger)inErrorCode forResponse:(NSString *)inResponseString
{
	id tmpObject = [self jsonObject:inResponseString];
	NSDictionary *tmpResponseDictionary = nil;
	
	if ([tmpObject isKindOfClass:[NSDictionary class]] == YES)
		tmpResponseDictionary = tmpObject;
	
	if (inErrorCode == 403 && [[tmpResponseDictionary objectForKey:@"name"] isEqualToString:@"bozuko/update"] == YES)
	{
		// Force update
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_ApplicationNeedsUpdate object:tmpResponseDictionary];
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
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?%@", kBozukoBaseURL, kBozukoAPIEntryPoint, [self urlSuffix]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
		_isRequestInProgress = YES;

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
	// Kill the user session info now, no need to wait for request to come back
	[[UserHandler sharedInstance] setUserToken:nil];
	[[UserHandler sharedInstance] setApiUser:nil];
	[_favoritesArray removeAllObjects];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserLoginStatusChanged object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserLoggedOut object:nil];
	
	if ([[UserHandler sharedInstance] loggedIn] == NO || [[[UserHandler sharedInstance] apiUser] logoutLink] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?%@", kBozukoBaseURL, [[[UserHandler sharedInstance] apiUser] logoutLink], [self urlSuffix]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setCompletionBlock:^{
		if ([tmpRequest responseStatusCode] != 200)
		{
			[self bozukoServerErrorCode:[tmpRequest responseStatusCode] forResponse:[tmpRequest responseString]];
			return;
		}
		
		//DLog(@"%@", [tmpRequest responseString]);
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
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?ll=%f%%2C%f", kBozukoBaseURL, [_apiBozuko bozukoPageLink], [self location].latitude, [self location].longitude];
	
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

- (void)bozukoBozuko
{
	static BOOL _isRequestInProgress;
	
	if ([_apiEntryPoint bozuko] == nil)
	{
		[self bozukoEntryPoint];
		return;
	}
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", kBozukoBaseURL, [_apiEntryPoint bozuko]];
	
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
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", kBozukoBaseURL, [[inBozukoGame gameState] gameEntryLink]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[NSString stringWithFormat:@"%f,%f", [self location].latitude, [self location].longitude] forKey:@"ll"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:[self challengeResponseForURL:tmpString] forKey:@"challenge_response"];
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
				if ([[tmpDictionary objectForKey:@"game_id"] isEqualToString:[inBozukoGame gameId]] == YES && [tmpDictionary objectForKey:@"message"] == nil)
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
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?ll=%f%%2C%f&%@", kBozukoBaseURL, [[inBozukoGame gameState] gameStateLink], [self location].latitude, [self location].longitude, [self urlSuffix]];
	
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

- (void)bozukoGameResultsForGame:(BozukoGame *)inBozukoGame
{
	static BOOL _isRequestInProgress;
	
	if ([[UserHandler sharedInstance] loggedIn] == NO || [[inBozukoGame gameState] gameResultLink] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", kBozukoBaseURL, [[inBozukoGame gameState] gameResultLink]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];

	if (tmpRequest != nil)
		_isRequestInProgress = YES;
	
	[tmpRequest setPostValue:[NSString stringWithFormat:@"%f,%f", [self location].latitude, [self location].longitude] forKey:@"ll"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:[self challengeResponseForURL:tmpString] forKey:@"challenge_response"];
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
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?%@", kBozukoBaseURL, [_apiEntryPoint user], [self urlSuffix]];

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

- (void)bozukoRedeemPrize:(BozukoPrize *)inBozukoPrize withMessage:(NSString *)inMessage
{
	if ([[UserHandler sharedInstance] loggedIn] == NO || [inBozukoPrize redeem] == nil)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", kBozukoBaseURL, [inBozukoPrize redeem]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:[self challengeResponseForURL:tmpString] forKey:@"challenge_response"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] userToken] forKey:@"token"];
	[tmpRequest setPostValue:kApplicationVersion forKey:@"mobile_version"];
	
	if (inMessage != nil)
		[tmpRequest setPostValue:inMessage forKey:@"message"];
	
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
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?%@", kBozukoBaseURL, [_apiEntryPoint prizes], [self urlSuffix]];
	
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
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", kBozukoBaseURL, [self prizesNextURL]];
	
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

- (void)bozukoPageRefreshForPage:(BozukoPage *)inBozukoPage
{
	static BOOL _isRequestInProgress;
	
	if ([inBozukoPage page] == nil || _isRequestInProgress == YES)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?%@", kBozukoBaseURL, [inBozukoPage page], [self urlSuffix]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
		_isRequestInProgress = YES;
	
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
			
			//DLog(@"%@", tmpBozukoPage);
			
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
	
	NSString *tmpBoundsString = [NSString stringWithFormat:@"%f%%2C%f%%2C%f%%2C%f", upperRightBoundsLatitude, upperRightBoundsLongitude, lowerLeftBoundsLatitude, lowerLeftBoundsLongitude];
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@?ll=%f%%2C%f&bounds=%@&%@", kBozukoBaseURL, [_apiEntryPoint pages], [self location].latitude, [self location].longitude, tmpBoundsString, [self urlSuffix]];

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
	
	NSMutableString *tmpString = [NSMutableString stringWithFormat:@"%@%@", kBozukoBaseURL, [self pagesNextURL]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PageDidStart object:nil];
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
	static BOOL _isRequestInProgress;
	
	self.searchQueryString = inSearchString;
	
	if (_isRequestInProgress == YES)
		return; // Prevent more than one request from happening at a time.
	
	if ([_apiEntryPoint pages] == nil)
	{
		[self bozukoEntryPoint];
		return;
	}
	
	NSMutableString *tmpString = [NSMutableString stringWithFormat:@"%@%@?ll=%f%%2C%f&%@", kBozukoBaseURL, [_apiEntryPoint pages], [self location].latitude, [self location].longitude, [self urlSuffix]];
	
	if (inSearchString != nil)
		[tmpString appendFormat:@"&query=%@", [inSearchString stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding]];
	
	//DLog(@"%@", tmpString);

	__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PageDidStart object:nil];
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
	static ASIHTTPRequest *tmpRequest = nil;
	
	self.favoritesSearchQueryString = inSearchString;
	
	if ([_apiEntryPoint pages] == nil)
	{
		[self bozukoEntryPoint];
		return;
	}
	
	NSMutableString *tmpString = [NSMutableString stringWithFormat:@"%@%@?favorites=true&ll=%f%%2C%f&%@", kBozukoBaseURL, [_apiEntryPoint pages], [self location].latitude, [self location].longitude, [self urlSuffix]];
	
	if (inSearchString != nil)
		[tmpString appendFormat:@"&query=%@", [inSearchString stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding]];
	
	//DLog(@"%@", tmpString);
	
	[tmpRequest cancel]; // Cancel any request that may be in progress.
	tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
	
	if (tmpRequest != nil)
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_FavoritesDidStart object:nil];
	
	[tmpRequest setCompletionBlock:^{
		//DLog(@"Favorites Complete");
		//DLog(@"%@", [tmpRequest responseString]);
		
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
	
	NSMutableString *tmpString = [NSMutableString stringWithFormat:@"%@%@", kBozukoBaseURL, [self favoritesNextURL]];
	
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
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", kBozukoBaseURL, [inBozukoPage feedback]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPUTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:[self challengeResponseForURL:tmpString] forKey:@"challenge_response"];
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
	if ([[UserHandler sharedInstance] loggedIn] == NO || [inBozukoPage facebookCheckin] == nil || inText == nil || [inText isEqualToString:@""] == YES)
		return;
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", kBozukoBaseURL, [inBozukoPage facebookCheckin]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[NSString stringWithFormat:@"%f,%f", [self location].latitude, [self location].longitude] forKey:@"ll"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:[self challengeResponseForURL:tmpString] forKey:@"challenge_response"];
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
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", kBozukoBaseURL, [inBozukoPage recommend]];
	
	//DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:[self challengeResponseForURL:tmpString] forKey:@"challenge_response"];
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
	
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", kBozukoBaseURL, [tmpBozukoPage favoriteLink]];

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
	
	DLog(@"%@", tmpString);
	
	__block ASIFormDataRequest *tmpRequest = [self httpPOSTRequestWithURL:[NSURL URLWithString:tmpString]];
	
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneType] forKey:@"phone_type"];
	[tmpRequest setPostValue:[[UserHandler sharedInstance] phoneID] forKey:@"phone_id"];
	[tmpRequest setPostValue:[self challengeResponseForURL:tmpString] forKey:@"challenge_response"];
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
	tmpRequest.timeOutSeconds = 30;
	
	return tmpRequest;
}

- (ASIFormDataRequest *)httpPOSTRequestWithURL:(NSURL *)inURL
{
	ASIFormDataRequest *tmpRequest = [ASIFormDataRequest requestWithURL:inURL];
	tmpRequest.useCookiePersistence = NO;
	tmpRequest.requestMethod = @"POST";
	[tmpRequest setPostFormat:ASIURLEncodedPostFormat];
	tmpRequest.timeOutSeconds = 30;
	
	return tmpRequest;
}

- (ASIFormDataRequest *)httpPUTRequestWithURL:(NSURL *)inURL
{
	ASIFormDataRequest *tmpRequest = [ASIFormDataRequest requestWithURL:inURL];
	tmpRequest.useCookiePersistence = NO;
	tmpRequest.requestMethod = @"PUT";
	[tmpRequest setPostFormat:ASIURLEncodedPostFormat];
	tmpRequest.timeOutSeconds = 30;
	
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

//- (void)rebuildFavoritesArray
//{
//	[_favoritesArray removeAllObjects];
//	
//	for (BozukoPage *tmpBozukoPage in _featuredArray)
//	{
//		if ([tmpBozukoPage favorite] == YES){
//			[_favoritesArray addObject:tmpBozukoPage];
//		}
//	}
//	
//	for (BozukoPage *tmpBozukoPage in _gamesArray)
//	{
//		if ([tmpBozukoPage favorite] == YES){
//			[_favoritesArray addObject:tmpBozukoPage];
//		}
//	}
//}

// Not used anymore
- (NSString *)challengeResponse
{
	NSInteger tmpChallenge = [[[[UserHandler sharedInstance] apiUser] challenge] intValue];
	return [NSString stringWithFormat:@"%d", tmpChallenge + kBozukoChallengeNumber];
}

- (NSString *)challengeResponseForURL:(NSString *)inURL
{
	NSString *tmpPath = [inURL stringByReplacingOccurrencesOfString:kBozukoBaseURL withString:@""]; // Remove protocol / hostname
	NSString *tmpString = [NSString stringWithFormat:@"%@%@", tmpPath, [[[UserHandler sharedInstance] apiUser] challenge]];
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

#pragma mark -
 
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
	[_locationManager stopUpdatingLocation];
}

- (void)applicationWillEnterForeground
{
	[_locationManager startUpdatingLocation];

	if (_apiEntryPoint == nil)
		[self bozukoEntryPoint];
	
	if (_apiBozuko == nil)
		[self bozukoBozuko];
	
	[self bozukoPages];
}

- (void)applicationDidReceiveMemoryWarning
{
}

#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	//DLog(@"Location Update Received");
	
	if (newLocation.coordinate.longitude == 0.0 && newLocation.coordinate.latitude == 0.0)
		_isLocationServiceAvailable = NO;
	else
		_isLocationServiceAvailable = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserLocationWasUpdated object:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if ([error code] == kCLErrorDenied)
	{
		DLog(@"Location Error");
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserLocationNotAvailable object:nil];
		_isLocationServiceAvailable = NO;
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
	{
		DLog(@"Location Status");
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserLocationNotAvailable object:nil];
		_isLocationServiceAvailable = NO;
	}
	else
		_isLocationServiceAvailable = YES;
}

#pragma mark - Data

- (CLLocationCoordinate2D)location
{
	return _locationManager.location.coordinate;
}

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

/*
- (NSArray *)allFeaturedPages
{
	return [[_featuredArray copy] autorelease];
}

- (NSArray *)allRegisteredPages
{
	return [[_gamesArray copy] autorelease];
}

- (NSArray *)allOtherPages
{
	return [[_businessesArray copy] autorelease];
}
*/
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
