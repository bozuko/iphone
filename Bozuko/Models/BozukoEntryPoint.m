//
//  EntryObject.m
//  Bozuko
//
//  Created by Sarah Lensing on 5/3/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import "BozukoEntryPoint.h"


@implementation BozukoEntryPoint

@synthesize properties = _properties;

+ (BozukoEntryPoint *)objectWithProperties:(NSDictionary *)inDictionary {
	return [[[BozukoEntryPoint alloc] initWithProperties:inDictionary] autorelease];
}

- (id)initWithProperties:(NSDictionary *)inDictionary {

	self = [super init];
	if (self) {
		[self setProperties:inDictionary];
	}
	return self;
}

- (void)dealloc {
	[_properties release];
	[super dealloc];
}

- (NSString *)pages
{
	return [_properties objectForKey:@"pages"];
}

- (NSString *)login
{
	return [_properties objectForKey:@"login"];
}

- (NSString *)bozuko
{
	return [_properties objectForKey:@"bozuko"];
}

- (NSString *)user
{
	return [_properties objectForKey:@"user"];
}

- (NSString *)prizes
{
	return [_properties objectForKey:@"prizes"];
}

@end
