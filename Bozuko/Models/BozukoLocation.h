//
//  BozukoLocation.h
//  Bozuko
//
//  Created by Tom Corwine on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BozukoLocation : NSObject {
	NSDictionary *_properties;
}

@property (nonatomic, retain) NSDictionary *properties;


+ (BozukoLocation *)objectWithProperties: (NSDictionary *)inDictionary;
- (id)initWithProperties: (NSDictionary *)inDictionary;

- (NSString *)street;
- (NSString *)city;
- (NSString *)state;
- (NSString *)country;
- (NSString *)zip;
- (CLLocationCoordinate2D)latitudeAndLongitude;

@end
