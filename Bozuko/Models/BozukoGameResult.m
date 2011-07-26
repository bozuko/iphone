//
//  BozukoGameResult.m
//  Bozuko
//
//  Created by Tom Corwine on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BozukoGameResult.h"
#import "BozukoPrize.h"
#import "BozukoGameState.h"

@implementation BozukoGameResult

@synthesize gameID = _gameID;
@synthesize properties = _properties;

+ (BozukoGameResult *)objectWithProperties:(NSMutableDictionary *)inDictionary {
	return [[[BozukoGameResult alloc] initWithProperties:inDictionary] autorelease];
}

- (id)initWithProperties:(NSMutableDictionary *)inDictionary {
	self = [super init];
	
	if (self)
	{
		if ([[inDictionary objectForKey:@"prize"] isKindOfClass:[NSNull class]] == YES)
			[inDictionary setObject:@"noPrize" forKey:@"prize"];
		
		[self setProperties:inDictionary];
	}
	
	return self;
}

- (void)dealloc
{
	[_properties release];
	[super dealloc];
}

+ (id)loadObjectFromDiskForPageID:(NSString *)inPageID
{
	NSString *tmpPath = [[NSString alloc] initWithFormat:@"%@/%@.plist", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], inPageID];
	NSMutableDictionary *tmpDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:tmpPath];
	[tmpPath release];
	
	if (tmpDictionary == nil) // If load failed, object doesn't exist
	{
		DLog(@"New Object");
		return nil;
	}
	
	DLog(@"Loaded Object with ID: %@", inPageID);
	
	BozukoGameResult *tmpBozukoGameResult = [BozukoGameResult objectWithProperties:tmpDictionary];
	tmpBozukoGameResult.gameID = inPageID;
	[tmpDictionary release];
	
	return tmpBozukoGameResult;
}

- (void)saveObjectToDisk
{
	DLog(@"%@", [self description]);
	NSString *tmpPath = [[NSString alloc] initWithFormat:@"%@/%@.plist", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], _gameID];
	NSData *tmpData = [NSPropertyListSerialization dataWithPropertyList:_properties format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
	[tmpData writeToFile:tmpPath atomically:YES];
	[tmpPath release];
}

- (void)deleteObjectFromDisk
{
	NSString *tmpPath = [[NSString alloc] initWithFormat:@"%@/%@.plist", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], _gameID];
	[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
	[tmpPath release];
}

- (void)setScratchedAreas:(ScratchTicketMask)inScratchAreasBitmask
{
	[_properties setObject:[NSNumber numberWithInt:inScratchAreasBitmask] forKey:@"scratchedAreas"];
}

- (ScratchTicketMask)scratchedAreas
{
	return [[_properties objectForKey:@"scratchedAreas"] intValue];
}

- (NSInteger)code
{
	if ([_properties objectForKey:@"code"] == nil)
		return 0;
	else
		return [[_properties objectForKey:@"code"] intValue];
}

- (BOOL)win
{
	if ([[_properties objectForKey:@"win"] intValue] == 1)
		return YES;
	
	return NO;
}

- (BOOL)freePlay
{
	if ([[_properties objectForKey:@"free_play"] intValue] == 1)
		return YES;
	
	return NO;
}

- (BOOL)consolation
{
	if ([[_properties objectForKey:@"consolation"] intValue] == 1)
		return YES;
	
	return NO;
}

- (NSString *)message
{
	return [_properties objectForKey:@"message"];
}

- (id)result
{
	return [_properties objectForKey:@"result"];
}

- (NSString *)redemptionType
{
	return [_properties objectForKey:@"redemption_type"];
}

- (BozukoPrize *)prize
{
	if ([[_properties objectForKey:@"prize"] isKindOfClass:[NSString class]] == YES && [[_properties objectForKey:@"prize"] isEqualToString:@"noPrize"] == YES)
		return nil;
	else
		return [BozukoPrize objectWithProperties:[_properties objectForKey:@"prize"]];
}

- (BozukoGameState *)gameState
{
	return [BozukoGameState objectWithProperties:[_properties objectForKey:@"game_state"]];
}

- (NSDictionary *)links
{
	return [_properties objectForKey:@"links"];
}

- (NSString *)description
{
	return [[super description] stringByAppendingFormat:@": properties=%@", _properties];
}

@end
