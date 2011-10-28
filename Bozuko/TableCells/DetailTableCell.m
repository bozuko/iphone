//
//  DetailTableCell.m
//  Bozuko
//
//  Created by Tom Corwine on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailTableCell.h"


@implementation DetailTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self)
	{
        _mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 5.0, 280.0, 30.0)];
		_mainLabel.font = [UIFont boldSystemFontOfSize:16.0];
		_mainLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:_mainLabel];
		[_mainLabel release];
		
		_detailLabel = [[UILabel alloc] init];
		_detailLabel.font = [UIFont systemFontOfSize:12.0];
		_detailLabel.lineBreakMode = UILineBreakModeWordWrap;
		_detailLabel.numberOfLines = 0;
		_detailLabel.textColor = [UIColor grayColor];
		[self addSubview:_detailLabel];
		[_detailLabel release];
    }
    
	return self;
}

- (void)setMainLabelText:(NSString *)inText
{
	_mainLabel.text = inText;
}

- (void)setDetailLabelText:(NSString *)inText
{
	CGSize tmpSize = [inText sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(280.0, 3000.0)];

	_detailLabel.frame = CGRectMake(20.0, 40.0, 280.0, tmpSize.height);
	_detailLabel.text = inText;
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
