//
//  BozukoPage.m
//  Bozuko
//
//  Created by Sarah Lensing on 5/3/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import "BozukoPage.h"
#import "BozukoGame.h"
#import "BozukoLocation.h"
#import "FacebookLikeButton.h"

@implementation BozukoPage

@synthesize properties = _properties;
@synthesize coordinate = _coordinate;
@synthesize facebookLikeButton = _facebookLikeButton;

+ (BozukoPage *)objectWithProperties:(NSDictionary *)inDictionary
{
	return [[[BozukoPage alloc] initWithProperties:inDictionary] autorelease];
}

- (id)initWithProperties:(NSDictionary *)inDictionary
{
	self = [super init];
	
	if (self)
	{
		[self setProperties:(NSMutableDictionary *)inDictionary];
		_coordinate = [[self location] latitudeAndLongitude];
		
		id tmpObject = [_properties objectForKey: @"games"];
		
		if ([tmpObject isKindOfClass:[NSArray class]] == YES && [tmpObject count] > 0)
		{
			[_gamesArray release];
			_gamesArray = [[NSMutableArray alloc] init];
			
			for (int i = 0; i < [tmpObject count]; i++)
			{
				id tmpGameObject = [tmpObject objectAtIndex:i];
				
				if ([tmpGameObject isKindOfClass:[NSDictionary class]] == YES)
					[_gamesArray addObject:[BozukoGame objectWithProperties:tmpGameObject]];
			}
		}
		
		self.facebookLikeButton = [[FacebookLikeButton alloc] initWithBozukoPage:self];
	}
	
	return self;
}

- (NSString *)pageID {
	// I'm using the recommend URL for the id when the business is not registered with Bozuko as there is no other unique id to use
	if ([_properties objectForKey: @"id"] == nil)
		return [[self links] objectForKey:@"recommend"];

	return [_properties objectForKey: @"id"];
}

- (NSString *)pageName {
	return [_properties objectForKey: @"name"];
}

- (NSString *)pageImage {
	return [_properties objectForKey: @"image"];
}

- (NSString *)facebookPage {
	return [_properties objectForKey: @"page"];
}

- (NSString *)category {
	return [_properties objectForKey: @"category"];
}

- (NSString *)website {
	return [_properties objectForKey: @"website"];
}

- (BOOL)featured {
	if ([[_properties objectForKey: @"featured"] intValue] == 1)
		return YES;

	return NO;
}

- (BOOL)isPlace {
	if ([[_properties objectForKey: @"is_place"] intValue] == 1)
		return YES;
	
	return NO;
}

- (BOOL)favorite {
	if ([[_properties objectForKey: @"favorite"] intValue] == 1)
		return YES;
	
	return NO;
}

- (void)setFavorite:(BOOL)inBool
{
	if (inBool == YES)
		[_properties setValue:@"1" forKey:@"favorite"];
	else
		[_properties setValue:@"0" forKey:@"favorite"];
}

- (BOOL)liked {
	if ([[_properties objectForKey: @"liked"] intValue] == 1)
		return YES;
	
	return NO;
}

- (void)setLiked:(BOOL)inBool
{
	if (inBool == YES)
		[_properties setObject:@"1" forKey:@"liked"];
	else
		[_properties setObject:@"0" forKey:@"liked"];
}

- (BOOL)registered {
	if ([[_properties objectForKey: @"registered"] intValue] == 1)
		return YES;
	
	return NO;
}
					
- (NSString *)announcement {
	return [_properties objectForKey: @"announcement"];
}

- (NSString *)distance {
	return [_properties objectForKey: @"distance"];	
}

- (BozukoLocation *)location {
	return [BozukoLocation objectWithProperties:[_properties objectForKey: @"location"]];
}

- (NSString *)phone {
	return [_properties objectForKey: @"phone"];
}

- (int)checkins {
	return (int)[_properties objectForKey: @"checkins"];
}

- (NSArray *)games {
	return _gamesArray;
}

- (NSString *)shareURL
{
	return [_properties objectForKey: @"share_url"];
}

- (NSString *)likeURL
{
	return [_properties objectForKey: @"like_url"];
}

- (NSString *)facebookLikeButtonLink
{
	return [_properties objectForKey:@"like_button_url"];
}

- (NSDictionary *)links {
	return [_properties objectForKey: @"links"];
}

- (NSString *)recommend
{
	return [[_properties objectForKey: @"links"] objectForKey:@"recommend"];
}

- (NSString *)facebookCheckin
{
	return [[_properties objectForKey: @"links"] objectForKey:@"facebook_checkin"];
}

/*
- (NSString *)facebookLike
{
	return [[_properties objectForKey: @"links"] objectForKey:@"facebook_like"];
}
 */

- (NSString *)feedback
{
	return [[_properties objectForKey: @"links"] objectForKey:@"feedback"];
}

- (NSString *)favoriteLink
{
	return [[_properties objectForKey: @"links"] objectForKey:@"favorite"];
}

- (NSString *)page
{
	return [[_properties objectForKey: @"links"] objectForKey:@"page"];
}

- (NSString *)description
{
	return [[super description] stringByAppendingFormat:@": properties=%@", _properties];
}

#pragma mark - MKAnnotation Protocol Delegate methods

- (NSString *)title
{
	return [self pageName];
}

- (NSString *)subtitle
{
	return [self category];
}

- (void)dealloc {
	[_properties release];
	[_gamesArray release];
	self.facebookLikeButton = nil;
	
	[super dealloc];
}

@end
