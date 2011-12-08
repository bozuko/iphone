//
//  ImageHandler.h
//  Bozuko
//
//  Created by Tom Corwine on 5/20/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBozukoHandler_PageImageWasUpdated				@"BozukoHandler_PageImageWasUpdated"
#define kBozukoHandler_ThumbnailImageWasUpdated			@"BozukoHandler_ThumbnialImageWasUpdated"

#define kImageHandler_ImageWasUpdatedNotification		@"ImageHandler_ImageWasUpdatedNotification"

@class ASIHTTPRequest;
@class BozukoPage;

@interface ImageHandler : NSObject {
	NSMutableDictionary *_imageCache;
	NSMutableDictionary *_thumbnailCache;
}

- (void)dumpCache;
- (void)bozukoServerErrorCode:(NSInteger)inErrorCode forResponse:(NSString *)inResponseString;

- (UIImage *)imageForURL:(NSString *)inURLString;
- (UIImage *)permanentCachedImageForURL:(NSString *)inURLString;
- (UIImage *)nonCachedImageForURL:(NSString *)inURLString;

- (UIImage *)thumbnailForBusiness:(BozukoPage *)inBozukoPage;
- (UIImage *)imageForBusiness:(BozukoPage *)inBozukoPage;

- (NSString *)md5StringFromString:(NSString *)inString;
- (ASIHTTPRequest *)httpGETRequestWithURL:(NSURL *)inURL;
- (id)jsonObject:(NSString *)inString;

+(ImageHandler *)sharedInstance;

@end
