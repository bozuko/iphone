//
//  GamePrize.m
//  Bozuko
//
//  Created by Tom Corwine on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoGamePrize.h"


@implementation BozukoGamePrize

@synthesize properties = _properties;

+ (BozukoGamePrize *)objectWithProperties:(NSDictionary *)inDictionary {
	return [[[BozukoGamePrize alloc] initWithProperties:inDictionary] autorelease];
}

- (id)initWithProperties:(NSDictionary *)inDictionary {
	self = [super init];
	
	if (self)
	{
		[self setProperties:inDictionary];
	}
	
	return self;
}

- (void)dealloc
{
	[_properties release];
	[super dealloc];
}

- (NSString *)name
{
	return [_properties objectForKey:@"name"];
}

- (NSString *)prizeDescription
{
	return [_properties objectForKey:@"description"];
}

- (NSInteger)total
{
	return [[_properties objectForKey:@"total"] intValue];
}

- (NSInteger)available
{
	return [[_properties objectForKey:@"available"] intValue];
}

- (NSString *)resultIcon
{
	return [_properties objectForKey:@"result_image"];
}

- (NSString *)description
{
	return [[super description] stringByAppendingFormat:@": properties=%@", _properties];
}

@end
