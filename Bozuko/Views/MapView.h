//
//  MapView.h
//  Bozuko
//
//  Created by Tom Corwine on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapView : UIView <MKMapViewDelegate> {
	UINavigationController *_controller;
    MKMapView *_mapView;
	UIImageView *_noGamesView;
}

@property (assign) UINavigationController *controller;

- (void)userLocationWasUpdated;
- (void)pagesAreDoneForRegion;

@end
