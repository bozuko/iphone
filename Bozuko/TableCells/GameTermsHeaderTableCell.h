//
//  GameTermsHeaderTableCell.h
//  Bozuko
//
//  Created by Tom Corwine on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GameTermsHeaderTableCell : UITableViewCell {
    UILabel *_pageName;
	UIImageView *_gameImageView;
	NSString *_imageURLString;
	UILabel *_gameDescription;
}

- (void)setName:(NSString *)inName description:(NSString *)inDescription andImageURLString:(NSString *)inURLString;
- (void)updateImage:(NSNotification *)inNotification;

@end
