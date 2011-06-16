//
//  BozukoBozuko.m
//  Bozuko
//
//  Created by Tom Corwine on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoBozuko.h"
#import "BozukoPage.h"

@implementation BozukoBozuko

@synthesize properties = _properties;

+ (BozukoBozuko *)objectWithProperties:(NSDictionary *)inDictionary {
	return [[[BozukoBozuko alloc] initWithProperties:inDictionary] autorelease];
}

- (id)initWithProperties:(NSDictionary *)inDictionary {
	self = [super init];
	
	if (self)
	{
		[self setProperties:inDictionary];
	}
	
	return self;
}

- (NSString *)privacyPolicy
{
	return [_properties objectForKey:@"privacy_policy"];
}

- (NSString *)howToPlay
{
	return [_properties objectForKey:@"how_to_play"];
}

- (NSString *)termsOfUse
{
	return [_properties objectForKey:@"terms_of_use"];
}

- (NSString *)about
{
	return [_properties objectForKey:@"about"];
}

- (NSString *)bozukoPageLink
{
	return [_properties objectForKey:@"bozuko_page"];
}

- (NSString *)bozukoForBusiness
{
	return [_properties objectForKey:@"bozuko_for_business"];
}

- (void)dealloc
{
	[_properties release];
	[super dealloc];
}

@end
