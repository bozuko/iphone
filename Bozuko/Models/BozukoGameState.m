//
//  BozukoGameState.m
//  Bozuko
//
//  Created by Tom Corwine on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoGameState.h"

@implementation BozukoGameState

@synthesize properties = _properties;
@synthesize nextEnterInterval = _nextEnterInterval;

+ (BozukoGameState *)objectWithProperties:(NSDictionary *)inDictionary
{
	return [[[BozukoGameState alloc] initWithProperties:inDictionary] autorelease];
}

- (id)initWithProperties:(NSDictionary *)inDictionary
{
	self = [super init];
	
	if (self)
	{
		[self setProperties:inDictionary];
		
		_nextEnterInterval = [[inDictionary objectForKey:@"next_enter_time_ms"] intValue] / 1000;
	}
	
	return self;
}

- (NSString *)gameID
{
	return [_properties objectForKey:@"game_id"];
}

- (NSInteger)userTokens
{
	return [[_properties objectForKey:@"user_tokens"] intValue];
}

- (NSString *)buttonText
{
	return [_properties objectForKey:@"button_text"];
}

- (BOOL)buttonEnabled
{
	if ([[_properties objectForKey:@"button_enabled"] intValue] == 1)
		return YES;
	
	return NO;
}

- (NSString *)buttonAction
{
	return [_properties objectForKey:@"button_action"];
}

- (NSDictionary *)links
{
	return [_properties objectForKey:@"links"];
}

- (NSString *)gameResultLink
{
	return [[_properties objectForKey:@"links"] objectForKey:@"game_result"];
}

- (NSString *)gameEntryLink
{
	return [[_properties objectForKey:@"links"] objectForKey:@"game_entry"];
}

- (NSString *)gameStateLink
{
	return [[_properties objectForKey:@"links"] objectForKey:@"game_state"];
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
