//
//  ScaleImage.m
//  EpiTracker
//
//  Created by Tom Corwine on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScaleImage.h"

@implementation UIImage (ScaleImage)

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)inTargetSize
{
	UIImage *tmpSourceImage = self;
	UIImage *tmpResizedImage = nil;
	
	CGSize tmpImageSize = tmpSourceImage.size;
	CGFloat tmpWidth = tmpImageSize.width;
	CGFloat tmpHeight = tmpImageSize.height;
	
	CGFloat tmpTargetWidth = inTargetSize.width;
	CGFloat tmpTargetHeight = inTargetSize.height;
	
	CGFloat tmpScaleFactor = 0.0;
	CGFloat tmpScaledWidth = tmpTargetWidth;
	CGFloat tmpScaledHeight = tmpTargetHeight;
	
	CGPoint tmpOrigin = CGPointMake(0.0, 0.0);
	
	if (CGSizeEqualToSize(tmpImageSize, inTargetSize) == NO)
	{
        CGFloat tmpWidthFactor = tmpTargetWidth / tmpWidth;
        CGFloat tmpHeightFactor = tmpTargetHeight / tmpHeight;
		
        if (tmpWidthFactor < tmpHeightFactor) 
			tmpScaleFactor = tmpWidthFactor;
        else
			tmpScaleFactor = tmpHeightFactor;
		
        tmpScaledWidth  = tmpWidth * tmpScaleFactor;
        tmpScaledHeight = tmpHeight * tmpScaleFactor;
		
        // Center image
        if (tmpWidthFactor < tmpHeightFactor)
		{
			tmpOrigin.y = (tmpTargetHeight - tmpScaledHeight) * 0.5; 
        }
		else if (tmpWidthFactor > tmpHeightFactor)
		{
			tmpOrigin.x = (tmpTargetWidth - tmpScaledWidth) * 0.5;
        }
	}
	
	UIGraphicsBeginImageContext(inTargetSize);
	
	CGRect tmpResizedImageRect;
	tmpResizedImageRect.origin = tmpOrigin;
	tmpResizedImageRect.size.width  = tmpScaledWidth;
	tmpResizedImageRect.size.height = tmpScaledHeight;
	
	[tmpSourceImage drawInRect:tmpResizedImageRect];
	
	tmpResizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return tmpResizedImage;
}

- (UIImage *)imageByScalingToSize:(CGSize)inTargetSize
{
	UIImage *tmpSourceImage = self;
	UIImage *tmpResizedImage = nil;
	
	CGSize tmpImageSize = tmpSourceImage.size;
	CGFloat tmpWidth = tmpImageSize.width;
	CGFloat tmpHeight = tmpImageSize.height;
	
	CGFloat tmpTargetWidth = inTargetSize.width;
	CGFloat tmpTargetHeight = inTargetSize.height;
	
	CGFloat tmpScaleFactor = 0.0;
	CGFloat tmpScaledWidth = tmpTargetWidth;
	CGFloat tmpScaledHeight = tmpTargetHeight;
	
	CGPoint tmpOrigin = CGPointMake(0.0, 0.0);

	if (CGSizeEqualToSize(tmpImageSize, inTargetSize) == NO)
	{
        CGFloat tmpWidthFactor = tmpTargetWidth / tmpWidth;
        CGFloat tmpHeightFactor = tmpTargetHeight / tmpHeight;
		
        if (tmpWidthFactor < tmpHeightFactor) 
			tmpScaleFactor = tmpHeightFactor;
        else
			tmpScaleFactor = tmpWidthFactor;
		
        tmpScaledWidth  = tmpWidth * tmpScaleFactor;
        tmpScaledHeight = tmpHeight * tmpScaleFactor;
		
		// Center image
		tmpOrigin.y = (tmpTargetHeight - tmpScaledHeight) * 0.5; 
		tmpOrigin.x = (tmpTargetWidth - tmpScaledWidth) * 0.5;
	}
	
	UIGraphicsBeginImageContext(inTargetSize);
	
	CGRect tmpResizedImageRect;
	tmpResizedImageRect.origin = tmpOrigin;
	tmpResizedImageRect.size.width  = tmpScaledWidth;
	tmpResizedImageRect.size.height = tmpScaledHeight;
	
	[tmpSourceImage drawInRect:tmpResizedImageRect];
	
	tmpResizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return tmpResizedImage;
}

@end
