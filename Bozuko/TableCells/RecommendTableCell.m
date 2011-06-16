//
//  DetailTableCell.m
//  Bozuko
//
//  Created by Tom Corwine on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecommendTableCell.h"


@implementation RecommendTableCell

@synthesize detailLabel = _detailLabel;
@synthesize mainLabel = _mainLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self)
	{
        _mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, 280.0, 20.0)];

		[self addSubview:_mainLabel];
		[_mainLabel release];
		
		_detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 30.0, 280.0, 40.0)];
		[self addSubview:_detailLabel];
		[_detailLabel release];
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
    [super dealloc];
}

@end
