//
//  DetailTableCell.h
//  Bozuko
//
//  Created by Tom Corwine on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailTableCell : UITableViewCell {
    UILabel *_mainLabel;
	UILabel *_detailLabel;
}

- (void)setMainLabelText:(NSString *)inText;
- (void)setDetailLabelText:(NSString *)inText;

@end
