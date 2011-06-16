//
//  GameHomeViewController.h
//  Bozuko
//
//  Created by Tom Corwine on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GamesView;
@class MapView;

@interface GamesHomeViewController : UIViewController {
    GamesView *_gamesView;
	MapView *_mapView;
}

- (void)hideAllViews;
- (void)segmentedControlWasChanged:(id)sender;

@end
