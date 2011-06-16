//
//  DownloadResizeRequest.h
//  LMKMaster
//
//  Created by Christopher Luu on 7/26/10.
//  Copyright 2010 Fuzz Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface DownloadResizeRequest : ASIHTTPRequest
{
	NSString *thumbDestinationPath;
	CGSize maxSize;
}

@property (nonatomic, retain) NSString *thumbDestinationPath;
@property (nonatomic, readwrite) CGSize maxSize;

@end
