//
//  BusinessDetailGamesTableCell.h
//  Bozuko
//
//  Created by Tom Corwine on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GamesDetailViewController;
@class BozukoGame;

@interface BusinessDetailGamesTableCell : UITableViewCell {
    UIImageView *_gameIcon;
	UILabel *_gameNameLabel;
	UILabel *_gameDetailLabel;
	
	NSString *_imageURL;
}

- (void)populateContentForGame:(BozukoGame *)inBozukoGame;
- (void)gameIconWasUpdated:(NSNotification *)inNotification;

@end
