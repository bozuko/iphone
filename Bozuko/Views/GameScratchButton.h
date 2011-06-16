//
//  GameScratchButton.h
//  Bozuko
//
//  Created by Joseph Hankin on 5/10/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BozukoGameResult.h"

@interface GameScratchButton : UIButton {
	UILabel *_numberLabel;
	UILabel *_textLabel;
	
	ScratchTicketMask _scratchTicketPosition;
	
	int _frameNumber;
}

@property (readwrite) ScratchTicketMask scratchTicketPosition;

-(id)initWithOrigin:(CGPoint)inOrigin;

-(void)setNumber:(NSString *)inNumericalString;
-(void)setLabelText:(NSString *)inLabelText;

- (void)setScratched;
-(void)animate;
-(void)reset;

- (void)animateNextFrame:(NSTimer *)inTimer;

@end
