//
//  BozukoPrize.h
//  Bozuko
//
//  Created by Tom Corwine on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	BozukoPrizeStateUnknown = -1,
	BozukoPrizeStateActive = 0,
	BozukoPrizeStateRedeemed,
	BozukoPrizeStateExpired,
} BozukoPrizeStateType;

@interface BozukoPrize : NSObject
{
	NSDictionary *_properties;
	NSInteger _redemptionDuration;
}

UIKIT_EXTERN NSString *const BozukoPrizeStandardTimestamp;

@property (nonatomic, retain) NSDictionary *properties;
@property (readonly) NSInteger redemptionDuration;

+ (BozukoPrize *)objectWithProperties: (NSDictionary *)inDictionary;
- (id)initWithProperties: (NSDictionary *)inDictionary;

- (NSString *)prizeID;
- (NSString *)pageID;
- (NSString *)gameID;
- (BozukoPrizeStateType)state;
- (NSString *)name;
- (BOOL)isEmail;
- (BOOL)isBarcode;
- (NSString *)pageName;
- (NSString *)wrapperMessage;
- (NSString *)prizeDescription;
- (NSString *)winTime;
- (NSString *)redeemedTimestamp;
- (NSString *)expirationTimestamp;
- (NSString *)businessImage;
- (NSString *)userImage;
- (NSString *)barcodeImage;
- (NSString *)code;

- (NSDictionary *)links;
- (NSString *)redeem;
- (NSString *)page;
- (NSString *)user;
- (NSString *)prize;

@end
