//
//  BusinessTableCell.h
//  Bozuko
//
//  Created by Tom Corwine on 4/18/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BozukoPage;

@interface BusinessTableCell : UITableViewCell {
	BozukoPage *_bozukoPage;
    UIButton *_favoriteIcon;
	UIImageView *_businessIcon;
	UILabel *_nameLabel;
	UILabel *_addressLabel;
	UILabel *_distanceLabel;
}

@property (retain) BozukoPage *bozukoPage;

- (void)setContentForBusiness:(BozukoPage *)inBozukoPage;
- (void)updateBusinessIcon:(NSNotification *)inNotification;
- (void)updateFavoriteButtonState:(NSNotification *)inNotification;
- (void)favoriteButtonWasPressed;

@end
