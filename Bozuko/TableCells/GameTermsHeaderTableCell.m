//
//  GameTermsHeaderTableCell.m
//  Bozuko
//
//  Created by Tom Corwine on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameTermsHeaderTableCell.h"
#import "ImageHandler.h"

@implementation GameTermsHeaderTableCell

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
	
    [super dealloc];
}

- (void)setName:(NSString *)inName description:(NSString *)inDescription andImageURLString:(NSString *)inURLString
{
	[_imageURLString release];
	_imageURLString = [inURLString retain];
	
	CGSize tmpNameSize = [inName sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(280.0, 300.0)];
	CGSize tmpDescriptionSize = [inDescription sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(245.0, 300.0)];

	_pageName.frame = CGRectMake(20.0, 10.0, 280.0, tmpNameSize.height);
	_pageName.text = inName;
	
	_gameImageView.frame = CGRectMake(20.0, 10.0 + tmpNameSize.height, 32.0, 32.0);
	_gameImageView.image = [[ImageHandler sharedInstance] imageForURL:_imageURLString];
	
	_gameDescription.frame = CGRectMake(55.0, 10.0 + tmpNameSize.height, 245.0, tmpDescriptionSize.height);
	_gameDescription.text = inDescription;
}

#pragma mark Notification Methods

- (void)updateImage:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[NSString class]] == NO)
		return;
	
	if ([[inNotification object] isEqualToString:_imageURLString] == YES)
		_gameImageView.image = [[ImageHandler sharedInstance] imageForURL:_imageURLString];
}

@end
