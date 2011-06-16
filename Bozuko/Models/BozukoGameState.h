//
//  BozukoGameState.h
//  Bozuko
//
//  Created by Tom Corwine on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BozukoGameState : NSObject {
	NSDictionary *_properties;
}

@property (nonatomic, retain) NSDictionary *properties;

+ (BozukoGameState *)objectWithProperties: (NSDictionary *)inDictionary;
- (id)initWithProperties: (NSDictionary *)inDictionary;

- (NSInteger)userTokens;
- (NSString *)nextEnterTime;
- (NSString *)buttonText;
- (BOOL)buttonEnabled;
- (NSString *)buttonAction;

- (NSDictionary *)links;
- (NSString *)gameResultLink;
- (NSString *)gameEntryLink;
- (NSString *)gameStateLink;

@end
