//
//  MapView.m
//  Bozuko
//
//  Created by Tom Corwine on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapView.h"
#import "BozukoPage.h"
#import "BozukoHandler.h"
#import "GamesDetailViewController.h"

@implementation MapView

@synthesize controller = _controller;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
	if (self)
	{
        _mapView = [[MKMapView alloc] initWithFrame:self.frame];
		_mapView.delegate = self;
		_mapView.showsUserLocation = YES;
		[self addSubview:_mapView];
		[_mapView release];
		
		_noGamesView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 57.0)];
		_noGamesView.image = [UIImage imageNamed:@"images/mapHighlight"];
		UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 57.0)];
		tmpLabel.numberOfLines = 0;
		tmpLabel.lineBreakMode = UILineBreakModeWordWrap;
		tmpLabel.textAlignment = UITextAlignmentCenter;
		tmpLabel.font = [UIFont boldSystemFontOfSize:18];
		tmpLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
		tmpLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
		tmpLabel.textColor = [UIColor whiteColor];
		tmpLabel.backgroundColor = [UIColor clearColor];
		tmpLabel.text = @"No Bozuko games in your area, try zooming out.";
		[_noGamesView addSubview:tmpLabel];
		[tmpLabel release];
		_noGamesView.alpha = 0.0;
		[self addSubview:_noGamesView];
		[_noGamesView release];
		
		UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
		tmpButton.frame = CGRectMake(0.0, 300.0, 50.0, 50.0);
		[tmpButton setImage:[UIImage imageNamed:@"images/currentLocBtn"] forState:UIControlStateNormal];
		[tmpButton addTarget:self action:@selector(userLocationWasUpdated) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:tmpButton];
		
		MKCoordinateSpan tmpSpan = MKCoordinateSpanMake(0.02, 0.02);
		MKCoordinateRegion tmpRegion = MKCoordinateRegionMake([[BozukoHandler sharedInstance] location], tmpSpan);
		
		_mapView.region = tmpRegion;

		//[self userLocationWasUpdated];
		//[self pagesAreDoneForRegion];
		[[BozukoHandler sharedInstance] bozukoRegisteredPagesInRegion:_mapView.region];
		
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLocationWasUpdated) name:kBozukoHandler_UserLocationWasUpdated object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pagesAreDoneForRegion) name:kBozukoHandler_GetPagesForRegionDidFinish object:nil];
    }
    
	return self;
}

- (void)userLocationWasUpdated
{
	//DLog(@"Setting Map Location %f, %f", [[BozukoHandler sharedInstance] location].latitude, [[BozukoHandler sharedInstance] location].longitude);
	//MKCoordinateSpan tmpSpan = MKCoordinateSpanMake(0.05, 0.05);
	//MKCoordinateRegion tmpRegion = MKCoordinateRegionMake([[BozukoHandler sharedInstance] location], tmpSpan);
	//[_mapView setRegion:tmpRegion animated:YES];
	
	[_mapView setCenterCoordinate:[[BozukoHandler sharedInstance] location] animated:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - MapView Delegate Methods

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	[[BozukoHandler sharedInstance] bozukoRegisteredPagesInRegion:_mapView.region];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	for (MKAnnotationView *tmpView in views)
	{
		if ([tmpView.annotation isKindOfClass:[MKUserLocation class]] == NO)
			tmpView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	}
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
			tmpAnnotationView.canShowCallout = YES;
		}
		
		return tmpAnnotationView;
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if (view.annotation == nil || [view.annotation isKindOfClass:[MKUserLocation class]] == YES)
		return;
	
	GamesDetailViewController *tmpViewController = [[GamesDetailViewController alloc] init];
	tmpViewController.bozukoPage = view.annotation;
	[_controller pushViewController:tmpViewController animated:YES];
	[tmpViewController release];
}

#pragma mark - Notification Methods

- (void)pagesAreDoneForRegion
{
	if ([_mapView.annotations count] > 500) // Prevent too many annotations from appearing on map
		[_mapView removeAnnotations:_mapView.annotations];
	
	BOOL tmpAreThereAnyPages = NO;
	
	for (BozukoPage *tmpBozukoPage in [[BozukoHandler sharedInstance] allRegisterdGamesInRegion])
	{
		tmpAreThereAnyPages = YES;
		
		BOOL isPageAnnotationAlreadyOnMap = NO;
		
		for (BozukoPage *tmpAnnotation in _mapView.annotations)
		{
			if ([tmpAnnotation isKindOfClass:[BozukoPage class]] == YES && [[tmpAnnotation pageID] isEqualToString:[tmpBozukoPage pageID]] == YES)
				isPageAnnotationAlreadyOnMap = YES;
		}
		
		if (isPageAnnotationAlreadyOnMap == NO)
			[_mapView addAnnotation:tmpBozukoPage];
	}

	if (tmpAreThereAnyPages == YES)
	{
		[UIView animateWithDuration:0.5 animations:^{
			_noGamesView.alpha = 0.0;
		}];
	}
	else
	{
		[UIView animateWithDuration:0.5 animations:^{
			_noGamesView.alpha = 1.0;
		}];
	}
}

@end
