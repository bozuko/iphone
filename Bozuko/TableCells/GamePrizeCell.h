//
//  GamePrizeCell.h
//  Bozuko
//
//  Created by Tom Corwine on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BozukoGamePrize;

@interface GamePrizeCell : UITableViewCell {
    UIImageView *_prizeIcon;
	UILabel *_prizeNameLabel;
	
	NSString *_imageURL;
}

- (void)populateContentForGamePrize:(BozukoGamePrize *)inBozukoGamePrize;
- (void)prizeIconWasUpdated:(NSNotification *)inNotification;

@end
