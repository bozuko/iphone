//
//  EntryObject.h
//  Bozuko
//
//  Created by Sarah Lensing on 5/3/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BozukoEntryPoint : NSObject {
	NSDictionary *_properties;
}

@property (nonatomic, retain) NSDictionary *properties;

+ (BozukoEntryPoint *)objectWithProperties: (NSDictionary *)inDictionary;
- (id)initWithProperties: (NSDictionary *)inDictionary;

- (NSString *)pages;
- (NSString *)login;
- (NSString *)bozuko;
- (NSString *)user;
- (NSString *)prizes;

@end
