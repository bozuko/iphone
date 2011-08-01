//
//  BozukoPage.h
//  Bozuko
//
//  Created by Sarah Lensing on 5/3/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class BozukoLocation;
@class FacebookLikeButton;

@interface BozukoPage : NSObject <MKAnnotation> {
	NSMutableDictionary *_properties;
	CLLocationCoordinate2D _coordinate;
	NSMutableArray *_gamesArray;
	FacebookLikeButton *_facebookLikeButton;
}

@property (nonatomic, retain) NSMutableDictionary *properties;
//@property (retain) FacebookLikeButton *facebookLikeButton;

+ (BozukoPage *)objectWithProperties: (NSDictionary *)inDictionary;
- (id)initWithProperties: (NSDictionary *)inDictionary;

- (NSString *)pageID;
- (NSString *)pageName;
- (NSString *)pageImage;
- (NSString *)facebookPage;
- (NSString *)category;
- (NSString *)website;
- (BOOL)featured;
- (BOOL)isPlace;
- (BOOL)favorite;
- (void)setFavorite:(BOOL)inBool;
- (BOOL)liked;
- (void)setLiked:(BOOL)inBool;
- (BOOL)registered;
- (NSString *)announcement;
- (NSString *)distance;
- (BozukoLocation *)location;
- (NSString *)phone;
- (int)checkins;
- (NSMutableArray *)games;
- (NSString *)shareURL;
- (NSString *)likeURL;
- (NSString *)facebookLikeButtonLink;
- (FacebookLikeButton *)facebookLikeButton;
- (void)unloadFacebookLikeButton;

- (NSDictionary *)links;
- (NSString *)recommend;
- (NSString *)facebookCheckin;
//- (NSString *)facebookLike;
- (NSString *)feedback;
- (NSString *)favoriteLink;
- (NSString *)page;

@end


