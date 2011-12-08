//
//  BusinessTableCell.h
//  Bozuko
//
//  Created by Tom Corwine on 4/18/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BozukoPrize;

@interface PrizesTableCell : UITableViewCell {
	UIImageView *_prizeIcon;
	UILabel *_itemNameLabel;
	UILabel *_storeNameLabel;
	UILabel *_expireLabel;
	UILabel *_expireDateLabel;
	UILabel *_wonDateLabel;
}

- (void)setContentForPrize:(BozukoPrize *)inBozukoGamePrize;

@end
