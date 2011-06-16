//
//  LoadMoreTableCell.m
//  Bozuko
//
//  Created by Tom Corwine on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadMoreTableCell.h"


@implementation LoadMoreTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self)
	{
		self.textLabel.textAlignment = UITextAlignmentCenter;
		self.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
		self.textLabel.text = @"Load More";
		
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityIndicator.frame = CGRectMake(30.0, 15.0, 30.0, 30.0);
		_activityIndicator.hidesWhenStopped = YES;
		[self addSubview:_activityIndicator];
		[_activityIndicator release];
    }
    
	return self;
}

- (void)setActive:(BOOL)isActive
{
	if (isActive == YES)
	{
		[_activityIndicator startAnimating];
		self.textLabel.text = @"Loading...";
	}
	else
	{
		[_activityIndicator stopAnimating];
		self.textLabel.text = @"Load More";
	}
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
