//
//  SlotMachineWheel.m
//  Bozuko
//
//  Created by Tom Corwine on 5/22/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import "SlotMachineWheel.h"
#import "NSArray-Shuffle.h"
#import <QuartzCore/QuartzCore.h>

@implementation SlotMachineWheel

@synthesize isSpinning = _isSpinning;

- (void)dealloc
{
	[_slotItemsArray release];
	//[_animateTimer release];
	
    [super dealloc];
}

- (id)initWithOrigin:(CGPoint)inOrigin
{
	return [self initWithFrame:CGRectMake(inOrigin.x, inOrigin.y, 89.0, 160.0)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
	if (self)
	{
		// Yellow background
		UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 89.0, 160.0)];
		tmpImageView.image = [UIImage imageNamed:@"images/slotYellowBg"];
		[self addSubview:tmpImageView];
		[tmpImageView release];
		
		// Slot items scroll view
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 89.0, 160.0)];
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.bounces = NO;
		_scrollView.userInteractionEnabled = NO;
		[self addSubview:_scrollView];
		[_scrollView release];
		
		// Shadow overlay
		tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 89.0, 160.0)];
		tmpImageView.image = [UIImage imageNamed:@"images/slotShadowOverlay"];
		[self addSubview:tmpImageView];
		[tmpImageView release];
		
		_isPopulated = NO;
		_isSpinning = NO;
		_stopIndex = 0;
    }
    
	return self;
}

- (void)setImages:(NSArray *)inImagesArray
{
	NSMutableDictionary *tmpDictionary = [[NSMutableDictionary alloc] init];
	
	NSInteger i = 0;
	for (UIImage *tmpImage in inImagesArray)
	{
		[tmpDictionary setObject:tmpImage forKey:[NSString stringWithFormat:@"%d", i]];
		i++;
	}
	
	_slotItemsArray = [[[tmpDictionary allKeys] shuffledArray] retain];
	
	_numberOfItems = [_slotItemsArray count];
	_scrollView.contentSize = CGSizeMake(89.0, 80.0 * (_numberOfItems + 4));
	
	for (int i = 0; i < (_numberOfItems + 6); i++)
	{
		UIImageView *tmpSlotItem = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, (i * 80.0) - 33.0, 80.0, 80.0)];
		
		if (i == 0)
			tmpSlotItem.image = [tmpDictionary objectForKey:[_slotItemsArray lastObject]];
		else if (i > _numberOfItems)
			tmpSlotItem.image = [tmpDictionary objectForKey:[_slotItemsArray objectAtIndex:i - 1 - _numberOfItems]];
		else
			tmpSlotItem.image = [tmpDictionary objectForKey:[_slotItemsArray objectAtIndex:i - 1]];
		
		[_scrollView addSubview:tmpSlotItem];
		[tmpSlotItem release];
	}
	
	[tmpDictionary release];
	
	// Set a random start position
	[self randomizeScrollPosition];
	_isPopulated = YES;
}

- (void)setStopIndex:(NSInteger)inStopIndex
{
	NSInteger i = 0;
	
	for (NSString *tmpString in _slotItemsArray)
	{
		if ([tmpString intValue] == inStopIndex)
		{
			_stopIndex = i;
		}
		
		i++;
	}
}

- (void)spin
{
	if (_isSpinning == YES || _isPopulated == NO)
		return;
	
	[self randomizeScrollPosition];

	// 0.02
	//_animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animateWheel) userInfo:nil repeats:YES];
	_spinDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateWheel)];
	_spinDisplayLink.frameInterval = 1;
	[_spinDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	
	_isSpinning = YES;
	_shouldStop = NO;
	_isSlowingDown = NO;
}

- (void)stop
{
	if (_isSpinning == NO)
		return;
	
	//DLog(@"================================================");
	
	_shouldStop = YES;
}

- (void)randomizeScrollPosition
{
	_spinPosition = (arc4random() % _numberOfItems) * 80;
	[_scrollView scrollRectToVisible:CGRectMake(0.0, _spinPosition, 80.0, 160.0) animated:NO];
}

- (void)animateWheel
{
	CGFloat tmpSpinStopPosition = 80.0 * (_stopIndex + 3); // Stop three icons down from actual stopping point, then UIView animate to the actual stopping icon.
	
	//if (_shouldStop == YES)
		//DLog(@"%f %f", _spinPosition, tmpSpinStopPosition);
	
	// Stop the wheel if we're at the stop index
	if (_shouldStop == YES && _spinPosition == tmpSpinStopPosition)
	{
		//[_animateTimer invalidate];
		//_animateTimer = nil;
		[_spinDisplayLink invalidate];
		_spinDisplayLink = nil;
		
		[UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			[_scrollView scrollRectToVisible:CGRectMake(0.0, tmpSpinStopPosition - 240.0, 80.0, 160.0) animated:NO];
		} completion:^(BOOL done){}];
		
		_isSpinning = NO;
		
		return;
	}
	
	_spinPosition = _spinPosition - 20.0;
	
	if (_spinPosition <= 160.0)
		_spinPosition = 80.0 * (_numberOfItems + 2); // Reset scroll view back to bottom
	
	[_scrollView scrollRectToVisible:CGRectMake(0.0, _spinPosition, 80.0, 160.0) animated:NO];
}

@end
