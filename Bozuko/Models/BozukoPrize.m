//
//  BozukoPrize.m
//  Bozuko
//
//  Created by Tom Corwine on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoPrize.h"

@implementation BozukoPrize

NSString *const BozukoPrizeStandardTimestamp = @"EEE MMM d yyyy HH:mm:ss z '('z')'";

@synthesize properties = _properties;
@synthesize redemptionDuration = _redemptionDuration;

+ (BozukoPrize *)objectWithProperties:(NSDictionary *)inDictionary {
	return [[[BozukoPrize alloc] initWithProperties:inDictionary] autorelease];
}

- (id)initWithProperties:(NSDictionary *)inDictionary {
	self = [super init];
	
	if (self)
	{
		[self setProperties:inDictionary];
		_redemptionDuration = [[inDictionary objectForKey:@"redemption_duration"] intValue];
	}
	
	return self;
}

- (NSString *)prizeID
{
	return [_properties objectForKey:@"id"];
}

- (NSString *)pageID
{
	return [_properties objectForKey:@"page_id"];
}

- (NSString *)gameID
{
	return [_properties objectForKey:@"game_id"];
}

- (BozukoPrizeStateType)state
{
	static NSArray *stateDescriptionArray = nil;
	if (!stateDescriptionArray)
		stateDescriptionArray = [[NSArray arrayWithObjects:@"active", @"redeemed", @"expired", nil] retain];

	NSUInteger tmpIndex = [stateDescriptionArray indexOfObject:[_properties objectForKey:@"state"]];
	if (tmpIndex == NSNotFound)
		return BozukoPrizeStateUnknown;
	return tmpIndex;
}

- (NSString *)name
{
	return [_properties objectForKey:@"name"];
}

- (BOOL)isEmail
{
	if ([[_properties objectForKey:@"is_email"] intValue] == 1)
		return YES;
	
	return NO;
}

- (BOOL)isBarcode
{
	if ([[_properties objectForKey:@"is_barcode"] intValue] == 1)
		return YES;
	
	return NO;
}

- (NSString *)pageName
{
	return [_properties objectForKey:@"page_name"];
}

- (NSString *)wrapperMessage
{
	return [_properties objectForKey:@"wrapper_message"];
}

- (NSString *)prizeDescription
{
	return [_properties objectForKey:@"description"];
}

- (NSString *)winTime
{
	return [_properties objectForKey:@"win_time"];
}

- (NSString *)redeemedTimestamp
{
	return [_properties objectForKey:@"redeemed_timestamp"];
}

- (NSString *)expirationTimestamp
{
	return [_properties objectForKey:@"expiration_timestamp"];
}

- (NSString *)businessImage
{
	return [_properties objectForKey:@"business_img"];
}

- (NSString *)userImage
{
	return [_properties objectForKey:@"user_img"];
}

- (NSString *)barcodeImage
{
	return [_properties objectForKey:@"barcode_image"];
}

- (NSString *)code
{
	return [_properties objectForKey:@"code"];
}

- (NSDictionary *)links
{
	return [_properties objectForKey:@"links"];
}

- (NSString *)redeem
{
	return [[_properties objectForKey:@"links"] objectForKey:@"redeem"];
}

- (NSString *)page
{
	return [[_properties objectForKey:@"links"] objectForKey:@"page"];
}

- (NSString *)user
{
	return [[_properties objectForKey:@"links"] objectForKey:@"user"];
}

- (NSString *)prize
{
	return [[_properties objectForKey:@"links"] objectForKey:@"prize"];
}

- (NSString *)description
{
	return [[super description] stringByAppendingFormat:@": properties=%@", _properties];
}

- (void)dealloc
{
	[_properties release];
	[super dealloc];
}

@end
