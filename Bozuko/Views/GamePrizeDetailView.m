//
//  GamePrizeDetailsViewController.m
//  Bozuko
//
//  Created by Tom Corwine on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamePrizeDetailView.h"
#import "BozukoPrize.h"

@implementation GamePrizeDetailView

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (id)initWithBozukoPrize:(BozukoPrize *)inBozukoPrize
{
	self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 417.0)];
	
	if (self)
	{
		UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 417.0)];
		tmpImageView.image = [UIImage imageNamed:@"images/profileBG"];
		[self addSubview:tmpImageView];
		[tmpImageView release];
		
		tmpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"images/bozukoLogo.png"]];
		[tmpImageView setFrame:CGRectMake(17, 20, 83, 30)];
		[self addSubview:tmpImageView];
		[tmpImageView release];
		
		tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(263, 18, 34, 34)];
		[tmpImageView setContentMode:UIViewContentModeScaleAspectFill];
		[tmpImageView setImage:[UIImage imageNamed:@"images/prizesIconG.png"]];
		[self addSubview:tmpImageView];
		[tmpImageView release];
		
		UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 50.0, 300.0, 50.0)];
		tmpLabel.textAlignment = UITextAlignmentCenter;
		tmpLabel.numberOfLines = 0;
		tmpLabel.lineBreakMode = UILineBreakModeWordWrap;
		tmpLabel.backgroundColor = [UIColor clearColor];
		tmpLabel.font = [UIFont boldSystemFontOfSize:20.0];
		tmpLabel.text = [inBozukoPrize name];
		[self addSubview:tmpLabel];
		[tmpLabel release];
		
		UITextView *tmpTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 110.0, 300.0, 250.0)];
		tmpTextView.userInteractionEnabled = NO;
		tmpTextView.backgroundColor = [UIColor clearColor];
		tmpTextView.font = [UIFont systemFontOfSize:16.0];
		tmpTextView.text = [inBozukoPrize prizeDescription];
		[self addSubview:tmpTextView];
		[tmpTextView release];
	}
	
	return self;
}

@end
