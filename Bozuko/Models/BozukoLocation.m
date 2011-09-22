//
//  BozukoLocation.m
//  Bozuko
//
//  Created by Tom Corwine on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoLocation.h"


@implementation BozukoLocation

@synthesize properties = _properties;

+ (BozukoLocation *)objectWithProperties:(NSDictionary *)inDictionary {
	return [[[BozukoLocation alloc] initWithProperties:inDictionary] autorelease];
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

- (NSString *)street
{
	return [_properties objectForKey: @"street"];
}

- (NSString *)city
{
	return [_properties objectForKey: @"city"];
}

- (NSString *)state
{
	return [_properties objectForKey: @"state"];
}

- (NSString *)country
{
	return [_properties objectForKey: @"country"];
}

- (NSString *)zip
{
	return [_properties objectForKey: @"zip"];
}

- (CLLocationCoordinate2D)latitudeAndLongitude
{
	CLLocationCoordinate2D tmpCoordinate;
	if ([[_properties objectForKey:@"lat"] isKindOfClass:[NSNumber class]] == YES && [[_properties objectForKey:@"lng"] isKindOfClass:[NSNumber class]] == YES)
		tmpCoordinate = CLLocationCoordinate2DMake([[_properties objectForKey: @"lat"] floatValue], [[_properties objectForKey: @"lng"] floatValue]);
	else
		tmpCoordinate = CLLocationCoordinate2DMake(0, 0);
	
	return tmpCoordinate;
}

@end
