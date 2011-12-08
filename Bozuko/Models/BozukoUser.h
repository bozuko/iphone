//
//  BozukoUser.h
//  Bozuko
//
//  Created by Tom Corwine on 5/6/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BozukoUser : NSObject
{
	NSDictionary *_properties;
}

@property (nonatomic, retain) NSDictionary *properties;


+ (BozukoUser *)objectWithProperties: (NSDictionary *)inDictionary;
- (id)initWithProperties: (NSDictionary *)inDictionary;

- (NSString *)userID;
- (NSString *)token;
- (NSString *)name;
- (NSString *)firstName;
- (NSString *)lastName;
- (NSString *)gender;
- (NSString *)email;
- (NSString *)challenge;
- (NSString *)image;
- (NSDictionary *)links;
- (NSString *)logoutLink;
- (NSString *)favoritesLink;

@end
