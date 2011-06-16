//
//  BozukoBozuko.h
//  Bozuko
//
//  Created by Tom Corwine on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BozukoBozuko : NSObject {
	NSDictionary *_properties;
}

@property (nonatomic, retain) NSDictionary *properties;

+ (BozukoBozuko *)objectWithProperties: (NSDictionary *)inDictionary;
- (id)initWithProperties: (NSDictionary *)inDictionary;

- (NSString *)privacyPolicy;
- (NSString *)howToPlay;
- (NSString *)termsOfUse;
- (NSString *)about;
- (NSString *)bozukoForBusiness;
- (NSString *)bozukoPageLink;

@end
