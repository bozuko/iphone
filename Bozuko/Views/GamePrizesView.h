//
//  GamePrizesView.h
//  Bozuko
//
//  Created by Tom Corwine on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BozukoGame;

@interface GamePrizesView : UIView {
	NSMutableDictionary *_prizeIconURLS;
	NSMutableDictionary *_prizeNameLabels;
}

- (id)initWithGame:(BozukoGame *)inBozukoGame;
- (void)prizeIconWasUpdated:(NSNotification *)inNotification;

@end
