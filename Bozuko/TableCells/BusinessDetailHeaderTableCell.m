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

@implementation BusinessDetailHeaderTableCell

@synthesize controller = _controller;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
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
		
		_pageNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 10.0, 160.0, 20.0)]; // Last number (height) will change below.
		_pageNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
		_pageNameLabel.numberOfLines = 0;
		_pageNameLabel.lineBreakMode = UILineBreakModeWordWrap;
		[self addSubview:_pageNameLabel];
		[_pageNameLabel release];
		
		_pageTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 35.0, 160.0, 15.0)];
		_pageTypeLabel.font = [UIFont systemFontOfSize:12.0];
		_pageTypeLabel.textColor = [UIColor lightGrayColor];
		[self addSubview:_pageTypeLabel];
		[_pageTypeLabel release];
		
		// Horizontal divider
		_horizontalDivider = [[UIView alloc] initWithFrame:CGRectMake(110.0, 52.0, 190.0, 1.0)];
		[_horizontalDivider setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
		[self addSubview:_horizontalDivider];
		[_horizontalDivider release];
		
		_pageAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 60.0, 170.0, 12.0)];
		_pageAddressLabel.font = [UIFont boldSystemFontOfSize:12.0];
		_pageAddressLabel.textColor = [UIColor grayColor];
		[self addSubview:_pageAddressLabel];
		[_pageAddressLabel release];
		
		_pageCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 75.0, 170.0, 12.0)];
		_pageCityLabel.font = [UIFont boldSystemFontOfSize:12.0];
		_pageCityLabel.textColor = [UIColor grayColor];
		[self addSubview:_pageCityLabel];
		[_pageCityLabel release];
		
		_favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_favoriteButton.frame = CGRectMake(270.0, 5.0, 40.0, 40.0);
		[_favoriteButton setImage:[UIImage imageNamed:@"images/starEmpty"] forState:UIControlStateNormal];
		[_favoriteButton setImage:[UIImage imageNamed:@"images/starFull"] forState:UIControlStateSelected];
		[_favoriteButton addTarget:_controller action:@selector(favoriteButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_favoriteButton];
		
		_arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(290.0, 70.0, 9.0, 13.0)];
		_arrowImageView.image = [UIImage imageNamed:@"images/arrowBtn"];
		[self addSubview:_arrowImageView];
		[_arrowImageView release];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImage:) name:kBozukoHandler_PageImageWasUpdated object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavoriteButtonState:) name:kBozukoHandler_SetFavoriteDidFinish object:nil];
    }
    
	return self;
}

- (void)populateContent
{
	CGSize tmpSize = [[_controller.bozukoPage pageName] sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(160.0, 300.0)];

	_pageIcon.image = [[ImageHandler sharedInstance] imageForBusiness:_controller.bozukoPage];
	_pageNameLabel.text = [_controller.bozukoPage pageName];
	_pageTypeLabel.text = [_controller.bozukoPage category];
	
	// Adjust contents to fit Page Name
	_pageNameLabel.frame = CGRectMake(110.0, 10.0, 160.0, tmpSize.height);
	_pageTypeLabel.frame = CGRectMake(110.0, 15.0 + tmpSize.height, 160.0, 15.0);
	_horizontalDivider.frame = CGRectMake(110.0, 32.0 + tmpSize.height, 190.0, 1.0);
	_pageAddressLabel.frame = CGRectMake(110.0, 40.0 + tmpSize.height, 170.0, 12.0);
	_pageCityLabel.frame = CGRectMake(110.0, 55.0 + tmpSize.height, 170.0, 12.0);
	_arrowImageView.frame = CGRectMake(290.0, 50.0 + tmpSize.height, 9.0, 13.0);
	
	BozukoLocation *tmpBozukoLocation = [_controller.bozukoPage location];
	_pageAddressLabel.text = [tmpBozukoLocation street];
	_pageCityLabel.text = [NSString stringWithFormat:@"%@, %@", [tmpBozukoLocation city], [tmpBozukoLocation state]];
	
	if ([_controller.bozukoPage registered] == YES)
		_favoriteButton.hidden = NO;
	else
		_favoriteButton.hidden = YES;
	
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

@end
