//
//  BozukoFavoriteResponse.h
//  Bozuko
//
//  Created by Tom Corwine on 5/13/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BozukoFavoriteResponse : NSObject {
	NSDictionary *_properties;
}

@property (nonatomic, retain) NSDictionary *properties;

+ (BozukoFavoriteResponse *)objectWithProperties: (NSDictionary *)inDictionary;
- (id)initWithProperties: (NSDictionary *)inDictionary;

- (BOOL)added;
- (BOOL)removed;
- (NSString *)pageID;

@end
