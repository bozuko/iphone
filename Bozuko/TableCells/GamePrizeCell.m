//
//  GamePrizeCell.m
//  Bozuko
//
//  Created by Tom Corwine on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamePrizeCell.h"
#import "ImageHandler.h"
#import "BozukoGamePrize.h"

@implementation GamePrizeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier];
    
	if (self)
	{
        _prizeIcon = [[UIImageView alloc] init];
		_prizeIcon.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_prizeIcon];
		[_prizeIcon release];
		
		_prizeNameLabel = [[UILabel alloc] init];
		_prizeNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
		_prizeNameLabel.minimumFontSize = 10.0;
		_prizeNameLabel.adjustsFontSizeToFitWidth = YES;
		[self addSubview:_prizeNameLabel];
		[_prizeNameLabel release];
		
		self.accessoryType = UITableViewCellAccessoryNone;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prizeIconWasUpdated:) name:kImageHandler_ImageWasUpdatedNotification object:nil];
    }
    
	return self;
}

- (void)populateContentForGamePrize:(BozukoGamePrize *)inBozukoGamePrize
{
	//DLog(@"%@", inBozukoGamePrize);
	_prizeNameLabel.text = [inBozukoGamePrize name];
	_prizeIcon.image = nil;
	
	[_imageURL release];
	_imageURL = [[inBozukoGamePrize resultIcon] retain];
	
	UIImage *tmpImage = [[ImageHandler sharedInstance] permanentCachedImageForURL:_imageURL];

	if (tmpImage != nil)
	{
		CGFloat tmpImageHeight = tmpImage.size.height / 2;
		CGFloat tmpImageWidth = (tmpImage.size.width / 2) * (40 / tmpImageHeight);
		
		_prizeIcon.frame = CGRectMake(17.0, 7.0, tmpImageWidth, 40.0);
		_prizeIcon.image = tmpImage;
		_prizeNameLabel.frame = CGRectMake(25.0 + tmpImageWidth, 17.0, 270.0 - tmpImageWidth, 20.0);
	}
	else
	{
		_prizeIcon.frame = CGRectMake(17.0, 7.0, 0.0, 0.0);
		_prizeIcon.image = nil;
		_prizeNameLabel.frame = CGRectMake(25.0, 17.0, 270.0, 20.0);
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

#pragma mark ImageHandler Notification Methods

- (void)prizeIconWasUpdated:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[NSString class]] == NO)
		return;
	
	if ([[inNotification object] isEqualToString:_imageURL] == YES)
	{
		UIImage *tmpImage = [[ImageHandler sharedInstance] permanentCachedImageForURL:_imageURL];
		
		if (tmpImage != nil)
		{
			CGFloat tmpImageWidth = tmpImage.size.width / 2;
			_prizeIcon.frame = CGRectMake(17.0, 7.0, tmpImageWidth, 40.0);
			_prizeIcon.image = tmpImage;
			_prizeNameLabel.frame = CGRectMake(25.0 + tmpImageWidth, 17.0, 270.0 - tmpImageWidth, 20.0);
		}
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_imageURL release];
	
    [super dealloc];
}

@end
