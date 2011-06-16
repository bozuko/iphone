//
//  BozukoRedemption.h
//  Bozuko
//
//  Created by Tom Corwine on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BozukoPrize;

@interface BozukoRedemption : NSObject
{
	NSString *_securityImageURLString;
	BozukoPrize *_prize;
	//NSInteger _duration;
}

+ (BozukoRedemption *)objectWithProperties: (NSDictionary *)inDictionary;
- (id)initWithProperties: (NSDictionary *)inDictionary;

@property (readonly) NSString *securityImageURLString;
@property (readonly) BozukoPrize *prize;

@end
