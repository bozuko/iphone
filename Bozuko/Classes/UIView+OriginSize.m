//
//  UIView+OriginSize.m
//  Bozuko
//
//  Created by Christopher Luu on 10/26/10.
//  Copyright 2010 Fuzz Productions, LLC. All rights reserved.
//

#import "UIView+OriginSize.h"

@implementation UIView (OriginSize)

- (void)setOrigin:(CGPoint)inOrigin
{
	[self setFrame:CGRectMake(inOrigin.x, inOrigin.y, self.frame.size.width, self.frame.size.height)];
}

- (void)setSize:(CGSize)inSize
{
	[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, inSize.width, inSize.height)];
}

@end
