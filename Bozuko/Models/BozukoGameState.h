//
//  BozukoGameState.h
//  Bozuko
//
//  Created by Tom Corwine on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BozukoGameState : NSObject
{
	NSDictionary *_properties;
	NSInteger _nextEnterInterval;
}

@property (nonatomic, retain) NSDictionary *properties;
@property (readonly) NSInteger nextEnterInterval;

+ (BozukoGameState *)objectWithProperties: (NSDictionary *)inDictionary;
- (id)initWithProperties: (NSDictionary *)inDictionary;

- (NSString *)gameId;
- (NSInteger)userTokens;
- (NSString *)buttonText;
- (BOOL)buttonEnabled;
- (NSString *)buttonAction;

- (NSDictionary *)links;
- (NSString *)gameResultLink;
- (NSString *)gameEntryLink;
- (NSString *)gameStateLink;

@end
