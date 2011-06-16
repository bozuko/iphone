//
//  MapViewController.m
//  Bozuko
//
//  Created by Tom Corwine on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "BozukoPage.h"
#import "BozukoLocation.h"

@implementation MapViewController

- (id)initWithPage:(BozukoPage *)inBozukoPage
{
    self = [super init];
    
	if (self)
	{
		self.navigationItem.title = [inBozukoPage pageName];
		
		_mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
		_mapView.delegate = self;
		_mapView.userInteractionEnabled = NO;
		_mapView.showsUserLocation = YES;
		[self.view addSubview:_mapView];
		[_mapView release];
		
		MKCoordinateSpan tmpSpan = MKCoordinateSpanMake(0.02, 0.02);
		MKCoordinateRegion tmpRegion = MKCoordinateRegionMake([[inBozukoPage location] latitudeAndLongitude], tmpSpan);
		
		_mapView.region = tmpRegion;
		
		[_mapView addAnnotation:inBozukoPage];
    }
    
	return self;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKUserLocation class]] == YES)
		return nil;
	else
	{
		MKAnnotationView *tmpAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"BozukoAnnotation"];
		
		if (tmpAnnotationView == nil)
		{
			tmpAnnotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BozukoAnnotation"] autorelease];
			tmpAnnotationView.image = [UIImage imageNamed:@"images/mapPinShadow"];
			tmpAnnotationView.centerOffset = CGPointMake(0.0, -18.0);
		}
		
		return tmpAnnotationView;
	}
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
