//
//  DetailTableCell.h
//  Bozuko
//
//  Created by Tom Corwine on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RecommendTableCell : UITableViewCell {
    UILabel *_mainLabel;
	UILabel *_detailLabel;
}

@property (assign) UILabel *mainLabel;
@property (assign) UILabel *detailLabel;

@end
