//
//  BusinessTableCell.m
//  Bozuko
//
//  Created by Tom Corwine on 4/18/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import "BusinessTableCell.h"
#import "BozukoHandler.h"
#import "ImageHandler.h"
#import "UserHandler.h"
#import "BozukoPage.h"
#import "BozukoFavoriteResponse.h"
#import "BozukoLocation.h"

@implementation BusinessTableCell

@synthesize bozukoPage = _bozukoPage;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_bozukoPage release];
	
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self)
	{
        _favoriteIcon = [UIButton buttonWithType:UIButtonTypeCustom];
		_favoriteIcon.frame = CGRectMake(0.0, 0.0, 40.0, 65.0);
		[_favoriteIcon setImage:[UIImage imageNamed:@"images/starEmpty"] forState:UIControlStateNormal];
		[_favoriteIcon setImage:[UIImage imageNamed:@"images/starFull"] forState:UIControlStateSelected];
		[_favoriteIcon addTarget:self action:@selector(favoriteButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_favoriteIcon];
		
		UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35.0, 10.0, 46.0, 46.0)];
		tmpImageView.image = [UIImage imageNamed:@"images/photoDefault"];
		[self addSubview:tmpImageView];
		[tmpImageView release];
		
		_businessIcon = [[UIImageView alloc] initWithFrame:CGRectMake(37.0, 12.0, 42.0, 42.0)];
		[self addSubview:_businessIcon];
		[_businessIcon release];
		
		_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.0, 5.0, 200.0, 20.0)];
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.font = [UIFont boldSystemFontOfSize:16.0];
		[self addSubview:_nameLabel];
		[_nameLabel release];
		
		_addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.0, 26.0, 200.0, 15.0)];
		_addressLabel.textColor = [UIColor darkGrayColor];
		_addressLabel.font = [UIFont boldSystemFontOfSize:14.0];
		[self addSubview:_addressLabel];
		[_addressLabel release];
		
		_distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.0, 43.0, 200.0, 15.0)];
		_distanceLabel.textColor = [UIColor grayColor];
		_distanceLabel.font = [UIFont systemFontOfSize:14.0];
		[self addSubview:_distanceLabel];
		[_distanceLabel release];
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBusinessIcon:) name:kBozukoHandler_ThumbnailImageWasUpdated object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavoriteButtonState:) name:kBozukoHandler_SetFavoriteDidFinish object:nil];
    }
    
	return self;
}

- (void)setContentForBusiness:(BozukoPage *)inBozukoPage
{
	self.bozukoPage = inBozukoPage;
	_nameLabel.text = [inBozukoPage pageName];
	_addressLabel.text = [[inBozukoPage location] street];
	_distanceLabel.text = [inBozukoPage distance];
	
	if ([inBozukoPage registered] == YES)
		_favoriteIcon.hidden = NO;
	else
		_favoriteIcon.hidden = YES;
	
	_favoriteIcon.selected = [inBozukoPage favorite];
	
	_businessIcon.image = [[ImageHandler sharedInstance] thumbnailForBusiness:inBozukoPage];
}

#pragma mark - Notification Methods

- (void)updateBusinessIcon:(NSNotification *)inNotification
{
	if ([inNotification object] == _bozukoPage)
	{
		_businessIcon.image = [[ImageHandler sharedInstance] thumbnailForBusiness:_bozukoPage];
	}
}

- (void)updateFavoriteButtonState:(NSNotification *)inNotification
{
	id tmpObject = [inNotification object];
	
	if ([tmpObject isKindOfClass:[BozukoFavoriteResponse class]] == YES && [[tmpObject pageID] isEqualToString:[_bozukoPage pageID]] == YES)
	{
		if ([tmpObject added] == YES)
			_favoriteIcon.selected = YES;
		else if ([tmpObject removed] == YES)
			_favoriteIcon.selected = NO;
	}
}

#pragma mark - Button Actions

- (void)favoriteButtonWasPressed
{
	if ([[UserHandler sharedInstance] loggedIn] == YES)
	{
		[[BozukoHandler sharedInstance]	bozukoToggleFavoriteForPage:_bozukoPage];

		if (_favoriteIcon.selected == YES)
		{
			_favoriteIcon.selected = NO;
			[_bozukoPage setFavorite:NO];
		}
		else
		{
			_favoriteIcon.selected = YES;
			[_bozukoPage setFavorite:YES];
		}
	}
	else
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_UserAttemptLogin object:nil];
	}
}

#pragma mark -

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
