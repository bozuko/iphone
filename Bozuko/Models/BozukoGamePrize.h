//
//  GamePrize.h
//  Bozuko
//
//  Created by Tom Corwine on 5/5/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BozukoGamePrize : NSObject {
	NSDictionary *_properties;
}

@property (nonatomic, retain) NSDictionary *properties;

+ (BozukoGamePrize *)objectWithProperties: (NSDictionary *)inDictionary;
- (id)initWithProperties: (NSDictionary *)inDictionary;

- (NSString *)name;
- (NSString *)prizeDescription;
- (NSInteger)total;
- (NSInteger)available;
- (NSString *)resultIcon;

@end
