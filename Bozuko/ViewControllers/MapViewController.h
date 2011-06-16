//
//  MapViewController.h
//  Bozuko
//
//  Created by Tom Corwine on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class BozukoPage;

@interface MapViewController : UIViewController <MKMapViewDelegate>
{
	MKMapView *_mapView;
}

- (id)initWithPage:(BozukoPage *)inBozukoPage;

@end
