//
//  DownloadResizeRequest.m
//  LMKMaster
//
//  Created by Christopher Luu on 7/26/10.
//  Copyright 2010 Fuzz Productions. All rights reserved.
//

#import "DownloadResizeRequest.h"

@implementation DownloadResizeRequest

@synthesize thumbDestinationPath, maxSize;

- (void)requestFinished
{
	if (downloadDestinationPath && thumbDestinationPath && maxSize.width > 0 && maxSize.height > 0)
	{
		UIImage *tmpImage = [UIImage imageWithContentsOfFile:[self downloadDestinationPath]];

		if (tmpImage && tmpImage.size.width > maxSize.width || tmpImage.size.height > maxSize.height)
		{
			UIImage *tmpThumbImage = [tmpImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:maxSize interpolationQuality:kCGInterpolationHigh];
			NSData *tmpData = UIImageJPEGRepresentation(tmpThumbImage, 0.9f);
			[tmpData writeToFile:thumbDestinationPath atomically:YES];
		}
		else if (tmpImage) // if the size is smaller than the requested thumb size, just copy the image
			[[NSFileManager defaultManager] copyItemAtPath:[self downloadDestinationPath] toPath:[self thumbDestinationPath] error:nil];
	}

	[super requestFinished];
}

- (void)dealloc
{
	[super dealloc];
}

@end
