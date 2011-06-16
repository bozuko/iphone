//
//  HowToPlayViewController.h
//  Bozuko
//
//  Created by Tom Corwine on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HowToPlayViewController : UIViewController <UIScrollViewDelegate> {
	UIScrollView *_cloudsScrollView;
    UIScrollView *_backgroundScrollView;
	UIScrollView *_foregroundScrollView;
}

@end
