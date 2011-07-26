//
//  UserHandler.m
//  Bozuko
//
//  Created by Sarah Lensing on 5/3/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import "UserHandler.h"
#import "BozukoHandler.h"
#import "BozukoUser.h"
#import "BozukoPrize.h"

static NSString *const UserHandlerUserDefaultsUserTokenKey = @"UserHandlerUserDefaultsUserTokenKey";

@implementation UserHandler

@synthesize apiUser = _apiUser;

static UserHandler *_instance;

- (void)dealloc {
	[_apiUser release];
	[_userToken release];
	[_activeUserPrizes release];
	[_pastUserPrizes release];
	
    [super dealloc];
}

+ (UserHandler *)sharedInstance {
	
	@synchronized(self)
	{
		if (!_instance)
		{
			_instance = [[UserHandler alloc] init];
		}
	}
	return _instance;
}

+ (void) destroyInstance {
	
	if (_instance)
	{
		[_instance	release];
		_instance = nil;
	}
}

- (id)init
{
	self = [super init];
	
	if (self)
	{
		_userToken = [[[NSUserDefaults standardUserDefaults] objectForKey:UserHandlerUserDefaultsUserTokenKey] retain];
		_activeUserPrizes = [[NSMutableArray alloc] init];
		_pastUserPrizes = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (BOOL)loggedIn {
	return (_userToken != nil);
}

- (NSString *)userToken
{
	return _userToken;
}

- (void)setUserToken:(NSString *)inUserToken
{
	if (inUserToken == _userToken)
		return;

	[_userToken release];
	_userToken = [inUserToken retain];

	if (_userToken)
		[[NSUserDefaults standardUserDefaults] setObject:_userToken forKey:UserHandlerUserDefaultsUserTokenKey];
	else
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:UserHandlerUserDefaultsUserTokenKey];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[[BozukoHandler sharedInstance] bozukoEntryPoint]; // Once logged in, we want to make the /entry_point call again.
}

- (NSString *)phoneType {
	return [UIDevice currentDevice].model;
}

- (NSString *)phoneID {
	return [UIDevice currentDevice].uniqueIdentifier;
}

#pragma mark - Prizes Methods

- (void)clearPrizes
{
	[_activeUserPrizes removeAllObjects];
	[_pastUserPrizes removeAllObjects];
}

- (void)addPrize:(BozukoPrize *)inBozukoPrize
{	
	if ([inBozukoPrize state] == BozukoPrizeStateExpired || [inBozukoPrize state] == BozukoPrizeStateRedeemed)
	{
		//DLog(@"Expired: %@", [inBozukoPrize name]);
		[_pastUserPrizes addObject:inBozukoPrize];
	}
	else
	{
		//DLog(@"Active: %@ %@", [inBozukoPrize description], [inBozukoPrize name]);
		[_activeUserPrizes addObject:inBozukoPrize];
	}
}

- (BOOL)doesPrizeExistForGameID:(NSString *)inGameID
{
	for (BozukoPrize *tmpBozukoPrize in _pastUserPrizes)
		if ([[tmpBozukoPrize gameID] isEqualToString:inGameID] == YES)
			return YES;
	
	return NO;
}

- (BOOL)doesPrizeExistForPrizeID:(NSString *)inPrizeID
{
	for (BozukoPrize *tmpBozukoPrize in _pastUserPrizes)
		if ([[tmpBozukoPrize prizeID] isEqualToString:inPrizeID] == YES)
			return YES;
	
	return NO;
}

- (NSInteger)numberOfActivePrizes
{
	return [_activeUserPrizes count];
}

- (NSInteger)numberOfPastPrizes
{
	return [_pastUserPrizes count];
}

- (BozukoPrize *)activePrizeAtIndex:(NSInteger)inIndex
{
	if (inIndex < 0 || inIndex > [_activeUserPrizes count] - 1 || [_activeUserPrizes count] == 0)
		return nil;
	
	return [_activeUserPrizes objectAtIndex:inIndex];
}

- (BozukoPrize *)pastPrizeAtIndex:(NSInteger)inIndex
{
	if (inIndex < 0 || inIndex > [_pastUserPrizes count] - 1 || [_pastUserPrizes count] == 0)
		return nil;
	
	return [_pastUserPrizes objectAtIndex:inIndex];
}

@end
