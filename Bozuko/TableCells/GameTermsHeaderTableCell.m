//
//  GameTermsHeaderTableCell.m
//  Bozuko
//
//  Created by Tom Corwine on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameTermsHeaderTableCell.h"
#import "ImageHandler.h"
#import "BozukoHandler.h"
#import "BozukoGame.h"
#import "GameTermsViewController.h"
#import "FacebookLikeButton.h"
#import "BozukoPage.h"

@implementation GameTermsHeaderTableCell

@synthesize controller = _controller;
@synthesize facebookLikeButton = _facebookLikeButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self)
	{
        _pageName = [[UILabel alloc] init];
		_pageName.font = [UIFont boldSystemFontOfSize:18.0];
		_pageName.lineBreakMode = UILineBreakModeWordWrap;
		_pageName.numberOfLines = 0;
		[self addSubview:_pageName];
		[_pageName release];
		
		_gameImageView = [[UIImageView alloc] init];
		[self addSubview:_gameImageView];
		[_gameImageView release];
		
		_gameDescription = [[UILabel alloc] init];
		_gameDescription.textColor = [UIColor grayColor];
		_gameDescription.font = [UIFont systemFontOfSize:14.0];
		_gameDescription.lineBreakMode = UILineBreakModeWordWrap;
		_gameDescription.numberOfLines = 0;
		[self addSubview:_gameDescription];
		[_gameDescription release];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImage:) name:kImageHandler_ImageWasUpdatedNotification object:nil];
    }
    
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.facebookLikeButton = nil;
	self.controller = nil;
	
    [super dealloc];
}

- (void)setGame:(BozukoGame *)inBozukoGame
{
	[_bozukoGame release];
	_bozukoGame = [inBozukoGame retain];

	CGSize tmpNameSize = [[_bozukoGame name] sizeWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToSize:CGSizeMake(230.0, 300.0)];
	CGSize tmpDescriptionSize = [[_bozukoGame entryMethodDescription] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(245.0, 300.0)];
	
	_pageName.frame = CGRectMake(20.0, 10.0, 230.0, tmpNameSize.height);
	_pageName.text = [_bozukoGame name];
	
	_gameImageView.frame = CGRectMake(20.0, 10.0 + tmpNameSize.height, 32.0, 32.0);
	
	_gameImageView.image = [[ImageHandler sharedInstance] permanentCachedImageForURL:[_bozukoGame entryMethodImage]];
	
	_gameDescription.frame = CGRectMake(55.0, 10.0 + tmpNameSize.height, 245.0, tmpDescriptionSize.height);
	_gameDescription.text = [_bozukoGame entryMethodDescription];
	
	[self.facebookLikeButton removeFromSuperview];
	self.facebookLikeButton = nil;
	//self.facebookLikeButton = [_controller.bozukoPage facebookLikeButton];
	self.facebookLikeButton = [[BozukoHandler sharedInstance] facebookLikeButtonForPage:_controller.bozukoPage];
	self.facebookLikeButton.frame = CGRectMake(245.0, 12.0, 51.0, 24.0);
	[self addSubview:self.facebookLikeButton];
}

#pragma mark Notification Methods

- (void)updateImage:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[NSString class]] == NO)
		return;
	
	if ([[inNotification object] isEqualToString:[_bozukoGame entryMethodImage]] == YES)
		_gameImageView.image = [[ImageHandler sharedInstance] permanentCachedImageForURL:[_bozukoGame entryMethodImage]];
}

@end
