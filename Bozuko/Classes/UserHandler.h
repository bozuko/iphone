//
//  UserHandler.h
//  Bozuko
//
//  Created by Sarah Lensing on 5/3/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BozukoUser.h"

#define kBozukoHandler_UserAttemptLogin					@"BozukoHandler_UserAttemptLogin"
#define kBozukoHandler_UserLoginStatusChanged			@"BozukoHandler_UserLoginStatusChanged"
#define kBozukoHandler_UserLoggedOut					@"BozukoHandler_UserLoggedOut"

@class BozukoPrize;

@interface UserHandler : NSObject {
	NSString *_userToken;
	BozukoUser *_apiUser;
	NSMutableArray *_pastUserPrizes;
	NSMutableArray *_activeUserPrizes;
}

@property (retain) BozukoUser *apiUser;

+ (UserHandler *)sharedInstance;

- (BOOL)loggedIn;
- (void)logUserOut;
- (NSString *)userToken;
- (void)setUserToken:(NSString *)inUserToken;
- (NSString *)phoneType;
- (NSString *)phoneID;

- (void)clearPrizes;
- (void)addPrize:(BozukoPrize *)inBozukoPrize;
- (BOOL)doesPrizeExistForGameID:(NSString *)inGameID;
- (BOOL)doesPrizeExistForPrizeID:(NSString *)inPrizeID;
- (NSInteger)numberOfActivePrizes;
- (NSInteger)numberOfPastPrizes;
- (BozukoPrize *)activePrizeAtIndex:(NSInteger)inIndex;
- (BozukoPrize *)pastPrizeAtIndex:(NSInteger)inIndex;

@end
