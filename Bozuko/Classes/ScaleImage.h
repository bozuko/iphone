//
//  ScaleImage.h
//  EpiTracker
//
//  Created by Tom Corwine on 3/23/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (ScaleImage)

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;

@end
