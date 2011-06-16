//
//  BozukoRedemption.m
//  Bozuko
//
//  Created by Tom Corwine on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoRedemption.h"
#import "BozukoPrize.h"

@implementation BozukoRedemption

@synthesize securityImageURLString = _securityImageURLString;
@synthesize prize = _prize;

+ (BozukoRedemption *)objectWithProperties:(NSDictionary *)inDictionary {
	return [[[BozukoRedemption alloc] initWithProperties:inDictionary] autorelease];
}

- (id)initWithProperties:(NSDictionary *)inDictionary {
	self = [super init];
	
	if (self)
	{
		_securityImageURLString = [[inDictionary objectForKey:@"security_image"] retain];
		_prize = [[BozukoPrize objectWithProperties:[inDictionary objectForKey:@"prize"]] retain];
	}
	
	return self;
}

- (void)dealloc
{
	[_prize release];
	[_securityImageURLString release];
	
	[super dealloc];
}

@end