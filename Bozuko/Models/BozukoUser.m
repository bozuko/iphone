//
//  BozukoUser.m
//  Bozuko
//
//  Created by Tom Corwine on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoUser.h"


@implementation BozukoUser

@synthesize properties = _properties;

+ (BozukoUser *)objectWithProperties:(NSDictionary *)inDictionary {
	return [[[BozukoUser alloc] initWithProperties:inDictionary] autorelease];
}

- (id)initWithProperties:(NSDictionary *)inDictionary {
	self = [super init];
	if (self) {
		[self setProperties:inDictionary];
	}
	return self;
}

- (NSString *)userID
{
	return [_properties objectForKey:@"id"];
}

- (NSString *)token
{
	return [_properties objectForKey:@"token"];
}

- (NSString *)name
{
	return [_properties objectForKey:@"name"];
}

- (NSString *)firstName
{
	return [_properties objectForKey:@"first_name"];
}

- (NSString *)lastName
{
	return [_properties objectForKey:@"last_name"];
}

- (NSString *)gender
{
	return [_properties objectForKey:@"gender"];
}

- (NSString *)email
{
	return [_properties objectForKey:@"email"];
}

- (NSString *)challenge
{
	return [_properties objectForKey:@"challenge"];
}

- (NSString *)image
{
	return [_properties objectForKey:@"image"];
}

- (NSDictionary *)links
{
	return [_properties objectForKey:@"links"];
}

- (NSString *)logoutLink
{
	return [[_properties objectForKey:@"links"] objectForKey:@"logout"];
}

- (NSString *)favoritesLink
{
	return [[_properties objectForKey:@"links"] objectForKey:@"favorites"];
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
