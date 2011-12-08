//
//  LoadingView.m
//  Bozuko
//
//  Created by Tom Corwine on 5/31/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import "LoadingView.h"


@implementation LoadingView

@dynamic messageTextString;

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
		
		_messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 210, 320, 25)];
		_messageLabel.backgroundColor = [UIColor clearColor];
		_messageLabel.textColor = [UIColor whiteColor];
		_messageLabel.textAlignment = UITextAlignmentCenter;
		_messageLabel.font = [UIFont systemFontOfSize:18];
		_messageLabel.text = @"Loading...";
		[self addSubview:_messageLabel];
		[_messageLabel release];
    }
    
	return self;
}

- (void)setMessageTextString:(NSString *)inMessageTextString
{
	if (inMessageTextString == nil)
		_messageLabel.text = @"Loading...";
	else
		_messageLabel.text = inMessageTextString;
}

- (NSString *)messageTextString
{
	return _messageLabel.text;
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
	self.messageTextString = nil;
	
    [super dealloc];
}

@end
