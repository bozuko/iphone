//
//  BusinessDetailGamesTableCell.m
//  Bozuko
//
//  Created by Tom Corwine on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BusinessDetailGamesTableCell.h"
#import "BozukoPage.h"
#import "BozukoGame.h"
#import "ImageHandler.h"

@implementation BusinessDetailGamesTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier];
    
	if (self)
	{
        _gameIcon = [[UIImageView alloc] initWithFrame:CGRectMake(17.0, 7.0, 41.0, 41.0)];
		[self addSubview:_gameIcon];
		[_gameIcon release];
		
		_gameNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 15.0, 200.0, 15.0)];
		_gameNameLabel.font = [UIFont boldSystemFontOfSize:14.0];
		[self addSubview:_gameNameLabel];
		[_gameNameLabel release];
		
		_gameDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 30.0, 200.0, 15.0)];
		_gameDetailLabel.font = [UIFont systemFontOfSize:12.0];
		_gameDetailLabel.textColor = [UIColor grayColor];
		[self addSubview:_gameDetailLabel];
		[_gameDetailLabel release];
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameIconWasUpdated:) name:kImageHandler_ImageWasUpdatedNotification object:nil];
    }
    
	return self;
}

- (void)populateContentForGame:(BozukoGame *)inBozukoGame
{
//	if ([[inBozukoGame name] isEqualToString:@"Slots"] == YES)
//		_gameIcon.image = [UIImage imageNamed:@"images/slotsIcon"];
//	else if ([[inBozukoGame name] isEqualToString:@"Scratch"] == YES)
//		_gameIcon.image = [UIImage imageNamed:@"images/scratchIcon"];
	
	//DLog(@"%@: %@", [inBozukoGame name], inBozukoGame);
	
	[_imageURL release];
	_imageURL = [[inBozukoGame image] retain];
	_gameIcon.image = [[ImageHandler sharedInstance] imageForURL:_imageURL];
	
	_gameNameLabel.text = [inBozukoGame name];
	_gameDetailLabel.text = [inBozukoGame listMessage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark ImageHandler Notification Methods

- (void)gameIconWasUpdated:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[NSString class]] == NO)
		return;
	
	if ([[inNotification object] isEqualToString:_imageURL] == YES)
		_gameIcon.image = [[ImageHandler sharedInstance] imageForURL:_imageURL];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_imageURL release];
	
    [super dealloc];
}

@end
