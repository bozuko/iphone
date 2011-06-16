//
//  GamePrizeDetailsViewController.h
//  Bozuko
//
//  Created by Tom Corwine on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BozukoGamePrize;

@interface GamePrizeDetailsViewController : UIViewController {
    UILabel *_prizeName;
	UITextView *_prizeDescription;
	BozukoGamePrize *_bozukoGamePrize;
}

@property (retain) BozukoGamePrize *bozukoGamePrize;

@end
