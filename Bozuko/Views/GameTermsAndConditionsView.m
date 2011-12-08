//
//  GameTermsAndConditionsView.m
//  Bozuko
//
//  Created by Tom Corwine on 6/2/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import "GameTermsAndConditionsView.h"
#import "BozukoGame.h"

@implementation GameTermsAndConditionsView

- (id)initWithGame:(BozukoGame *)inBozukoGame
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 417.0)];
    
	if (self)
	{
        UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 417.0)];
		tmpImageView.image = [UIImage imageNamed:@"images/profileBG"];
		[self addSubview:tmpImageView];
		[tmpImageView release];
		
		UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, 320.0, 30.0)];
		tmpLabel.backgroundColor = [UIColor clearColor];
		tmpLabel.textAlignment = UITextAlignmentCenter;
		tmpLabel.font = [UIFont boldSystemFontOfSize:25.0];
		tmpLabel.text = @"Official Rules";
		[self addSubview:tmpLabel];
		[tmpLabel release];
		
		UITextView *tmpTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 60.0, 320.0, 355.0)];
		tmpTextView.editable = NO;
		tmpTextView.backgroundColor = [UIColor clearColor];
		tmpTextView.text = [inBozukoGame rules];
		[self addSubview:tmpTextView];
		[tmpTextView release];
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
