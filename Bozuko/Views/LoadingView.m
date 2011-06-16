//
//  LoadingView.m
//  Bozuko
//
//  Created by Tom Corwine on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"


@implementation LoadingView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
    
	if (self)
	{
		UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
		tmpView.backgroundColor = [UIColor blackColor];
		tmpView.alpha = 0.8;
		[self addSubview:tmpView];
		[tmpView release];
		
		UIActivityIndicatorView *tmpActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		tmpActivityIndicator.frame = CGRectMake(144.0, 160.0, 37.0, 37.0);
		tmpActivityIndicator.hidesWhenStopped = YES;
		[tmpActivityIndicator startAnimating];
		[self addSubview:tmpActivityIndicator];
		[tmpActivityIndicator release];
    }
    
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

@end
