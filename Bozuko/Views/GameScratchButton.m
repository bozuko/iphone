//
//  GameScratchButton.m
//  Bozuko
//
//  Created by Joseph Hankin on 5/10/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import "GameScratchButton.h"
#import <QuartzCore/QuartzCore.h>

#define ANIMATION_INTERVAL 0.03
#define SCRATCH_MASK_FRAME_COUNT 25

@implementation GameScratchButton

@synthesize scratchTicketPosition = _scratchTicketPosition;

- (id)initWithOrigin:(CGPoint)inOrigin
{
	return [self initWithFrame:CGRectMake(inOrigin.x, inOrigin.y, 92, 115)];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self)
	{
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		_frameNumber = 0;

		_numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, (int)(2.0 *(frame.size.height / 3.0)))];
		_numberLabel.textAlignment = UITextAlignmentCenter;
		_numberLabel.font = [UIFont fontWithName:@"PFTempestaSeven-Bold" size:30];
		_numberLabel.backgroundColor = [UIColor clearColor];
		_numberLabel.textColor = [UIColor blackColor];
		_numberLabel.alpha = 0.0;
		[self addSubview:_numberLabel];
		[_numberLabel release];
		
		_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (int)(frame.size.height / 2.0), frame.size.width, (int)(frame.size.height / 3.0))];
		_textLabel.textAlignment = UITextAlignmentCenter;
		_textLabel.font = [UIFont fontWithName:@"PFTempestaSeven" size:10];
		_textLabel.backgroundColor = [UIColor clearColor];
		_textLabel.textColor = [UIColor blackColor];
		_textLabel.numberOfLines = 2;
		_textLabel.lineBreakMode = UILineBreakModeWordWrap;
		_textLabel.alpha = 0.0;
		[self addSubview:_textLabel];
		[_textLabel release];
    }
	
	return self;
}

- (void)setNumber:(NSString *)inNumericalString 
{
	_numberLabel.text = inNumericalString;
}

- (void)setLabelText:(NSString *)inLabelText
{
	_textLabel.text = inLabelText;
}

- (void)setScratched
{
	self.backgroundColor = [UIColor lightGrayColor];
	
	CALayer *maskLayer = [CALayer layer];
	maskLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	maskLayer.contentsGravity = kCAGravityCenter;
	maskLayer.contentsScale = [[UIScreen mainScreen] scale]; // / .836;
	maskLayer.rasterizationScale = [[UIScreen mainScreen] scale];
	maskLayer.shouldRasterize = NO;
	maskLayer.opaque = YES;	
	self.layer.mask = maskLayer;
	
	_numberLabel.alpha = 1.0;
	_textLabel.alpha = 1.0;
	
	UIImage *tmpImage = [UIImage imageNamed:[NSString stringWithFormat:@"images/scratch/scratchMask/scratchMask_%04d.png", SCRATCH_MASK_FRAME_COUNT - 1]];
	self.layer.mask.contents = (id)tmpImage.CGImage;
}

- (void)animate
{
	if (_frameNumber < SCRATCH_MASK_FRAME_COUNT)
	{
		self.backgroundColor = [UIColor lightGrayColor];
		
		CALayer *maskLayer = [CALayer layer];
		maskLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
		maskLayer.contentsGravity = kCAGravityCenter;
		maskLayer.contentsScale = [[UIScreen mainScreen] scale]; // / .836;
		maskLayer.rasterizationScale = [[UIScreen mainScreen] scale];
		maskLayer.shouldRasterize = NO;
		maskLayer.opaque = YES;	
		self.layer.mask = maskLayer;
		
		_numberLabel.alpha = 1.0;
		_textLabel.alpha = 1.0;
		
		[NSTimer scheduledTimerWithTimeInterval:ANIMATION_INTERVAL target:self selector:@selector(animateNextFrame:) userInfo:nil repeats:NO];
	}
}

- (void)animateNextFrame:(NSTimer *)inTimer
{
	UIImage *tmpImage = [UIImage imageNamed:[NSString stringWithFormat:@"images/scratch/scratchMask/scratchMask_%04d.png", _frameNumber]];
	self.layer.mask.contents = (id)tmpImage.CGImage;
	_frameNumber++;
	if (_frameNumber < SCRATCH_MASK_FRAME_COUNT)
		[NSTimer scheduledTimerWithTimeInterval:ANIMATION_INTERVAL target:self selector:@selector(animateNextFrame:) userInfo:nil repeats:NO];
}

- (void)reset
{
	self.backgroundColor = [UIColor clearColor];
	self.layer.mask.contents = nil;
	_frameNumber = 0;
}


- (void)dealloc {
    [super dealloc];
}


@end
