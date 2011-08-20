//
//  SlotMachineWheel.h
//  Bozuko
//
//  Created by Tom Corwine on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SlotMachineWheel : UIView {
    UIScrollView *_scrollView;
	BOOL _isPopulated;
	BOOL _isSpinning;
	BOOL _shouldStop;
	BOOL _isSlowingDown;
	NSInteger _stopIndex;
	//NSTimer *_animateTimer;
	CGFloat _spinPosition;
	NSInteger _numberOfItems;
	NSArray *_slotItemsArray;
	CADisplayLink *_spinDisplayLink;
}

@property (readonly) BOOL isSpinning;

- (id)initWithOrigin:(CGPoint)inOrigin;

- (void)setImages:(NSArray *)inImagesArray;
- (void)setStopIndex:(NSInteger)inStopIndex;
- (void)spin;
- (void)stop;
- (void)randomizeScrollPosition;
- (void)animateWheel;

@end
