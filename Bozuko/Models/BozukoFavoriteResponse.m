//
//  BozukoFavoriteResponse.m
//  Bozuko
//
//  Created by Tom Corwine on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoFavoriteResponse.h"


@implementation BozukoFavoriteResponse

@synthesize properties = _properties;

+ (BozukoFavoriteResponse *)objectWithProperties:(NSDictionary *)inDictionary {
	return [[[BozukoFavoriteResponse alloc] initWithProperties:inDictionary] autorelease];
}

- (id)initWithProperties:(NSDictionary *)inDictionary {
	self = [super init];
	
	if (self)
	{
		[self setProperties:inDictionary];
	}
	
	return self;
}

- (BOOL)added
{
	if ([[_properties objectForKey:@"added"] intValue] == 1)
		return YES;
	
	return NO;
}

- (BOOL)removed
{
	if ([[_properties objectForKey:@"removed"] intValue] == 1)
		return YES;
	
	return NO;
}

- (NSString *)pageID
{
	return [_properties objectForKey:@"page_id"];
}

- (void)dealloc
{
	[_properties release];
	[super dealloc];
}

@end
