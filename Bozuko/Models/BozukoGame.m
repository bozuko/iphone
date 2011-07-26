//
//  BozukoGame.m
//  Bozuko
//
//  Created by Tom Corwine on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoGame.h"
#import "BozukoGameState.h"

@implementation BozukoGame

@synthesize properties = _properties;

+ (BozukoGame *)objectWithProperties:(NSDictionary *)inDictionary {
	return [[[BozukoGame alloc] initWithProperties:inDictionary] autorelease];
}

- (id)initWithProperties:(NSDictionary *)inDictionary {
	self = [super init];
	
	if (self)
	{
		[self setProperties:(NSMutableDictionary *)inDictionary];
	}
	
	return self;
}

- (NSString *)gameId
{
	return [_properties objectForKey:@"id"];
}

- (NSString *)name
{
	return [_properties objectForKey:@"name"];
}

- (NSString *)listMessage
{
	return [_properties objectForKey:@"list_message"];
}

- (NSString *)rules
{
	return [_properties objectForKey:@"rules"];
}

- (NSString *)image
{
	return [_properties objectForKey:@"image"];
}

- (NSArray *)prizes
{
	return [_properties objectForKey:@"prizes"];
}

- (NSArray *)consolationPrizes
{
	return [_properties objectForKey:@"consolation_prizes"];
}

- (NSDictionary *)links
{
	return [_properties objectForKey:@"links"];
}

- (NSString *)gameLink
{
	return [[_properties objectForKey:@"links"] objectForKey:@"game"];
}

- (NSString *)pageLink
{
	return [[_properties objectForKey:@"links"] objectForKey:@"page"];
}

- (NSString *)entryMethodType
{
	return [[_properties objectForKey:@"entry_method"] objectForKey:@"type"];
}

- (NSString *)entryMethodImage
{
	return [[_properties objectForKey:@"entry_method"] objectForKey:@"image"];
}

- (NSString *)entryMethodDescription
{
	return [[_properties objectForKey:@"entry_method"] objectForKey:@"description"];
}

- (NSString *)gameType
{
	return [_properties objectForKey:@"type"];
}

- (id)config // Config is game specific, so just return a generic object here.
{
	return [_properties objectForKey:@"config"];
}

- (BozukoGameState *)gameState
{
	if (_bozukoGameState == nil)
		return [BozukoGameState objectWithProperties:[_properties objectForKey:@"game_state"]];
	else
		return _bozukoGameState;
}

- (void)setGameState:(BozukoGameState *)inGameState
{
	[_properties removeObjectForKey:@"game_state"];
	
	[_bozukoGameState release];
	_bozukoGameState = [inGameState retain];
}

- (NSString *)description
{
	return [[super description] stringByAppendingFormat:@": properties=%@", _properties];
}

- (void)dealloc {
	[_properties release];
	[_bozukoGameState release];
	[super dealloc];
}

@end
