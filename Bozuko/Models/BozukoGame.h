//
//  BozukoGame.h
//  Bozuko
//
//  Created by Tom Corwine on 5/5/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BozukoGameState;

@interface BozukoGame : NSObject {
	NSMutableDictionary *_properties;
	BozukoGameState *_bozukoGameState;
}

@property (nonatomic, retain) NSMutableDictionary *properties;


+ (BozukoGame *)objectWithProperties: (NSDictionary *)inDictionary;
- (id)initWithProperties: (NSDictionary *)inDictionary;

- (NSString *)gameID;
- (NSString *)name;
- (NSString *)image;
- (NSArray *)prizes;
- (NSArray *)consolationPrizes;
- (NSString *)listMessage;
- (NSString *)rules;
- (NSDictionary *)links;
- (NSString *)gameLink;
- (NSString *)pageLink;
- (NSString *)entryMethodType;
- (NSString *)entryMethodImage;
- (NSString *)entryMethodDescription;
- (NSString *)gameType;
- (id)config;
- (BozukoGameState *)gameState;

- (void)setGameState:(BozukoGameState *)inGameState;

@end
