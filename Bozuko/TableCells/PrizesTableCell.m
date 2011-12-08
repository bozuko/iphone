//
//  BusinessTableCell.m
//  Bozuko
//
//  Created by Tom Corwine on 4/18/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import "PrizesTableCell.h"
#import "BozukoHandler.h"
#import "BozukoPrize.h"

#import "NSDate+Formatter.h"

@implementation PrizesTableCell

- (void)dealloc
{	
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self)
	{
        _prizeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 20.0, 41.0, 41.0)];
		[self addSubview:_prizeIcon];
		[_prizeIcon release];
		
		_itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 3.0, 200.0, 20.0)];
		_itemNameLabel.textColor = [UIColor blackColor];
		_itemNameLabel.font = [UIFont boldSystemFontOfSize:16.0];
		[self addSubview:_itemNameLabel];
		[_itemNameLabel release];
		
		_storeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 23.0, 200.0, 20.0)];
		_storeNameLabel.textColor = [UIColor darkGrayColor];
		_storeNameLabel.font = [UIFont boldSystemFontOfSize:14.0];
		[self addSubview:_storeNameLabel];
		[_storeNameLabel release];
		
		_expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 42.0, 80.0, 20.0)];
		_expireLabel.font = [UIFont boldSystemFontOfSize:14.0];
		[self addSubview:_expireLabel];
		[_expireLabel release];
		
		_expireDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(130.0, 42.0, 200.0, 20.0)];
		_expireDateLabel.textColor = [UIColor grayColor];
		_expireDateLabel.font = [UIFont systemFontOfSize:14.0];
		[self addSubview:_expireDateLabel];
		[_expireDateLabel release];
		
		UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 60.0, 45.0, 20.0)];
		tmpLabel.font = [UIFont boldSystemFontOfSize:14.0];
		tmpLabel.text = @"Won:";
		[self addSubview:tmpLabel];
		[tmpLabel release];
		
		_wonDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 60.0, 200.0, 20.0)];
		_wonDateLabel.textColor = [UIColor grayColor];
		_wonDateLabel.font = [UIFont systemFontOfSize:14.0];
		[self addSubview:_wonDateLabel];
		[_wonDateLabel release];
		
		self.accessoryType = UITableViewCellAccessoryNone;
    }
    
	return self;
}

- (void)setContentForPrize:(BozukoPrize *)inBozukoPrize
{
	_itemNameLabel.text = [inBozukoPrize name];
	_storeNameLabel.text = [inBozukoPrize pageName];

	NSDate *tmpDate = [NSDate dateFromString:[inBozukoPrize winTime] format:BozukoPrizeStandardTimestamp];
	_wonDateLabel.text = [tmpDate stringWithDateFormat:@"MM/dd/yyyy h:mm a"];

	if ([inBozukoPrize state] == BozukoPrizeStateActive)
	{
		_prizeIcon.image = [UIImage imageNamed:@"images/prizesIconG"];
		[_expireLabel setText:@"Expires:"];
		_expireDateLabel.frame = CGRectMake(130.0, 42.0, 200.0, 20.0);
		[_expireDateLabel setTextColor:[UIColor redColor]];
		
		tmpDate = [NSDate dateFromString:[inBozukoPrize expirationTimestamp] format:BozukoPrizeStandardTimestamp];
		_expireDateLabel.text = [tmpDate stringWithDateFormat:@"MM/dd/yyyy h:mm a"];
	}
	else if ([inBozukoPrize state] == BozukoPrizeStateExpired)
	{
		_prizeIcon.image = [UIImage imageNamed:@"images/prizesIconR"];
		[_expireLabel setText:@"Expired:"];
		_expireDateLabel.frame = CGRectMake(130.0, 42.0, 200.0, 20.0);
		[_expireDateLabel setTextColor:[UIColor blackColor]];
		
		tmpDate = [NSDate dateFromString:[inBozukoPrize expirationTimestamp] format:BozukoPrizeStandardTimestamp];
		_expireDateLabel.text = [tmpDate stringWithDateFormat:@"MM/dd/yyyy h:mm a"];
	}
	else if ([inBozukoPrize state] == BozukoPrizeStateRedeemed)
	{
		_prizeIcon.image = [UIImage imageNamed:@"images/prizesIconB"];
		[_expireLabel setText:@"Redeemed:"];
		_expireDateLabel.frame = CGRectMake(150.0, 42.0, 200.0, 20.0);
		[_expireDateLabel setTextColor:[UIColor blackColor]];
		
		tmpDate = [NSDate dateFromString:[inBozukoPrize redeemedTimestamp] format:BozukoPrizeStandardTimestamp];
		_expireDateLabel.text = [tmpDate stringWithDateFormat:@"MM/dd/yyyy h:mm a"];
	}
	else
	{
		_prizeIcon.image = nil;
		[_expireLabel setText:nil];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
