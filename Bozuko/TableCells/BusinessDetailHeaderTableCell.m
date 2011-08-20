//
//  BusinessDetailHeaderTableCell.m
//  Bozuko
//
//  Created by Tom Corwine on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BusinessDetailHeaderTableCell.h"
#import "GamesDetailViewController.h"
#import "BozukoPage.h"
#import "BozukoLocation.h"
#import "BozukoFavoriteResponse.h"
#import "BozukoHandler.h"
#import "ImageHandler.h"
#import "UserHandler.h"
#import "FacebookLikeButton.h"

@implementation BusinessDetailHeaderTableCell

@synthesize controller = _controller;
@synthesize facebookLikeButton = _facebookLikeButton;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.facebookLikeButton = nil;
	
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier];
    
	if (self)
	{
        UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18.0, 8.0, 85.0, 85.0)];
		tmpImageView.image = [UIImage imageNamed:@"images/photoDefaultLarge"];
		[self addSubview:tmpImageView];
		[tmpImageView release];

		_pageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 10.0, 81.0, 81.0)];
		[self addSubview:_pageIcon];
		[_pageIcon release];
		
		_pageNameLabel = [[UILabel alloc] init]; // Frame gets set in populateContent
		_pageNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
		_pageNameLabel.numberOfLines = 0;
		_pageNameLabel.lineBreakMode = UILineBreakModeWordWrap;
		[self addSubview:_pageNameLabel];
		[_pageNameLabel release];
		
		_pageTypeLabel = [[UILabel alloc] init]; // Frame gets set in populateContent
		_pageTypeLabel.font = [UIFont systemFontOfSize:12.0];
		_pageTypeLabel.textColor = [UIColor lightGrayColor];
		[self addSubview:_pageTypeLabel];
		[_pageTypeLabel release];
		
		// Horizontal divider
		_horizontalDivider = [[UIView alloc] init]; // Frame gets set in populateContent
		[_horizontalDivider setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
		[self addSubview:_horizontalDivider];
		[_horizontalDivider release];
		
		_pageAddressLabel = [[UILabel alloc] init]; // Frame gets set in populateContent
		_pageAddressLabel.font = [UIFont boldSystemFontOfSize:12.0];
		_pageAddressLabel.textColor = [UIColor grayColor];
		[self addSubview:_pageAddressLabel];
		[_pageAddressLabel release];
		
		_pageCityLabel = [[UILabel alloc] init]; // Frame gets set in populateContent
		_pageCityLabel.font = [UIFont boldSystemFontOfSize:12.0];
		_pageCityLabel.textColor = [UIColor grayColor];
		[self addSubview:_pageCityLabel];
		[_pageCityLabel release];
		
		_favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_favoriteButton.frame = CGRectMake(270.0, 0.0, 40.0, 40.0);
		[_favoriteButton setImage:[UIImage imageNamed:@"images/starEmpty"] forState:UIControlStateNormal];
		[_favoriteButton setImage:[UIImage imageNamed:@"images/starFull"] forState:UIControlStateSelected];
		[_favoriteButton addTarget:_controller action:@selector(favoriteButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_favoriteButton];
			
		_arrowImageView = [[UIImageView alloc] init]; // Frame gets set in populateContent
		_arrowImageView.image = [UIImage imageNamed:@"images/arrowBtn"];
		[self addSubview:_arrowImageView];
		[_arrowImageView release];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImage:) name:kBozukoHandler_PageImageWasUpdated object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavoriteButtonState:) name:kBozukoHandler_SetFavoriteDidFinish object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusDidChange) name:kBozukoHandler_UserLoginStatusChanged object:nil];
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(populateContent) name:kBozukoHandler_GetPagesForLocationDidFinish object:nil];
    }
    
	return self;
}

- (void)populateContent
{
	BozukoLocation *tmpBozukoLocation = [_controller.bozukoPage location];
	
	CGSize tmpSize = [[_controller.bozukoPage pageName] sizeWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToSize:CGSizeMake(140.0, 300.0)];
	CGFloat tmpVerticalPositionOffset = tmpSize.height;
	
	if (tmpVerticalPositionOffset < 44.0 && [_controller.bozukoPage registered] == YES &&
		([[tmpBozukoLocation city] length] > 0 || [[tmpBozukoLocation state] length] > 0))
		tmpVerticalPositionOffset = 44.0; // Insure cell is big enought for "like" button

	_pageIcon.image = [[ImageHandler sharedInstance] imageForBusiness:_controller.bozukoPage];
	_pageNameLabel.text = [_controller.bozukoPage pageName];
	_pageTypeLabel.text = [_controller.bozukoPage category];
	
	// Adjust contents to fit Page Name
	_pageNameLabel.frame = CGRectMake(110.0, 10.0, 140.0, tmpSize.height);
	_pageTypeLabel.frame = CGRectMake(110.0, 15.0 + tmpVerticalPositionOffset, 160.0, 15.0);
	_horizontalDivider.frame = CGRectMake(110.0, 32.0 + tmpVerticalPositionOffset, 190.0, 1.0);
	_pageAddressLabel.frame = CGRectMake(110.0, 40.0 + tmpVerticalPositionOffset, 170.0, 12.0);
	_pageCityLabel.frame = CGRectMake(110.0, 55.0 + tmpVerticalPositionOffset, 170.0, 12.0);
	_arrowImageView.frame = CGRectMake(290.0, 50.0 + tmpVerticalPositionOffset, 9.0, 13.0);
	
	[self.facebookLikeButton removeFromSuperview];
	self.facebookLikeButton = [_controller.bozukoPage facebookLikeButton];
	[self addSubview:self.facebookLikeButton];
	//[self.facebookLikeButton load];
	
	if ([_controller.bozukoPage registered] == YES)
		self.facebookLikeButton.frame = CGRectMake(255.0, 45.0, 48.0, 20.0);
	else
		self.facebookLikeButton.frame = CGRectMake(252.0, 12.0, 48.0, 20.0);

	if ([[tmpBozukoLocation street] length] > 0)
	{
		_pageAddressLabel.hidden = NO;
		_pageAddressLabel.text = [tmpBozukoLocation street];
	}
	else
	{
		_pageAddressLabel.hidden = YES;
		_pageAddressLabel.text = nil;
	}
	
	if ([[tmpBozukoLocation city] length] > 0 && [[tmpBozukoLocation state] length] > 0)
	{
		_pageCityLabel.hidden = NO;
		_pageCityLabel.text = [NSString stringWithFormat:@"%@, %@", [tmpBozukoLocation city], [tmpBozukoLocation state]];
	}
	else
	{
		_pageCityLabel.hidden = YES;
		_pageCityLabel.text = nil;
	}
	
	if ([_controller.bozukoPage isPlace] == YES)
	{
		_arrowImageView.hidden = NO;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else
	{
		_arrowImageView.hidden = YES;
		self.selectionStyle = UITableViewCellEditingStyleNone;
	}
	
	_favoriteButton.selected = [_controller.bozukoPage favorite];
}

- (void)updateImage:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[BozukoPage class]] == YES && [inNotification object] == _controller.bozukoPage)
		_pageIcon.image = [[ImageHandler sharedInstance] imageForBusiness:_controller.bozukoPage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Button Action

- (void)likeButtonPlaceholderWasPressed
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserAttemptLogin object:nil];
}

#pragma mark - Notification methods

- (void)updateFavoriteButtonState:(NSNotification *)inNotification
{
	id tmpObject = [inNotification object];
	
	if ([tmpObject isKindOfClass:[BozukoFavoriteResponse class]] == YES && [[tmpObject pageID] isEqualToString:[_controller.bozukoPage pageID]] == YES)
	{
		if ([tmpObject added] == YES)
			_favoriteButton.selected = YES;
		else if ([tmpObject removed] == YES)
			_favoriteButton.selected = NO;
	}
}

- (void)loginStatusDidChange
{
	//[self populateContent];
}

@end
