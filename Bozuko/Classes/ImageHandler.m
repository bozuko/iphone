//
//  ImageHandler.m
//  Bozuko
//
//  Created by Tom Corwine on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageHandler.h"
#import "UserHandler.h"
#import "BozukoHandler.h"
#import "ASIHTTPRequest.h"
#import "BozukoPage.h"
#import "ScaleImage.h"
#import <CommonCrypto/CommonDigest.h>

static ImageHandler *instance;

@implementation ImageHandler

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_imageCache release];
	[_thumbnailCache release];
	
    [super dealloc];
}

-(id)init
{
	self = [super init];
	
	if (self)
	{
		_imageCache = [[NSMutableDictionary alloc] init];
		_thumbnailCache = [[NSMutableDictionary alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dumpCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dumpCache) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	
	return self;
}

- (void)dumpCache
{
	[_imageCache removeAllObjects];
	[_thumbnailCache removeAllObjects];
}

- (UIImage *)imageForURL:(NSString *)inURLString
{
	//DLog(@"%@", inURLString);
	
	if (inURLString == nil)
		return nil;
	
	// Attempt to load image from memory cache
	__block UIImage *tmpImage = [_imageCache objectForKey:inURLString];
	
	NSString *tmpDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	// Attempt to load image from disk cache
	if (tmpImage == nil)
	{
		NSString *tmpPathString = [[NSString alloc] initWithFormat:@"%@/imageCache/%@.png", tmpDocumentsDirectory, [self md5StringFromString:inURLString]];
		NSDictionary *tmpDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDate date], NSFileCreationDate, nil]; // Touch file
		[[NSFileManager defaultManager] setAttributes:tmpDictionary ofItemAtPath:tmpPathString error:nil];
		[tmpDictionary release];
		tmpImage = [UIImage imageWithContentsOfFile:tmpPathString];
		[tmpPathString release];
	}
	
	// Load image from Internet
	if (tmpImage == nil)
	{
		__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:inURLString]];
		
		[tmpRequest setCompletionBlock:^{
			tmpImage = [UIImage imageWithData:[tmpRequest rawResponseData]];
			
			if (tmpImage != nil)
			{
				if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/imageCache", tmpDocumentsDirectory] isDirectory:NULL] == NO)
					[[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/imageCache", tmpDocumentsDirectory] withIntermediateDirectories:NO attributes:nil error:nil];
				
				//DLog(@"URL: %@", [NSString stringWithFormat:@"%@/imageCache/%@.png", tmpDocumentsDirectory, [self md5StringFromString:inURLString]]);
				
				[_imageCache setObject:tmpImage forKey:inURLString];
				[[NSNotificationCenter defaultCenter] postNotificationName:kImageHandler_ImageWasUpdatedNotification object:inURLString];
				
				dispatch_queue_t tmpQueue = dispatch_queue_create("saveImage", NULL);
				dispatch_async(tmpQueue, ^{
					[UIImagePNGRepresentation(tmpImage) writeToFile:[NSString stringWithFormat:@"%@/imageCache/%@.png", tmpDocumentsDirectory, [self md5StringFromString:inURLString]] atomically:YES];
				});
				dispatch_release(tmpQueue);
			}
		}];
		
		[tmpRequest setFailedBlock:^{
			DLog(@"%i", [tmpRequest responseStatusCode]);
			DLog(@"%@", [tmpRequest responseStatusMessage]);
		}];
		
		[tmpRequest startAsynchronous];
	}
	
	return tmpImage;
}

- (UIImage *)nonCachedImageForURL:(NSString *)inURLString
{
	//DLog(@"%@", inURLString);
	
	if (inURLString == nil)
		return nil;
	
	// Attempt to load image from memory cache
	__block UIImage *tmpImage = [_imageCache objectForKey:inURLString];
	
	// Load image from Internet
	if (tmpImage == nil)
	{
		NSMutableString *tmpString = [NSMutableString stringWithString:inURLString];
									  
		if ([inURLString hasPrefix:[[BozukoHandler sharedInstance] baseURL]] == YES) // If this image is coming from Bozuko's servers, add mobile authentication parameters
		{
			[tmpString appendFormat:@"?%@&phone_id=%@&phone_type=%@", [[BozukoHandler sharedInstance] urlSuffix], [[UserHandler sharedInstance] phoneID], [[[UserHandler sharedInstance] phoneType] stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding]];
			[tmpString appendFormat:@"&challenge_response=%@", [[BozukoHandler sharedInstance] challengeResponseForURL:tmpString]];
		}
		
		//DLog(@"%@", tmpString);
		
		__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:tmpString]];
		
		[tmpRequest setCompletionBlock:^{
			tmpImage = [UIImage imageWithData:[tmpRequest rawResponseData]];
			
			if (tmpImage != nil)
			{
				[_imageCache setObject:tmpImage forKey:inURLString];
				[[NSNotificationCenter defaultCenter] postNotificationName:kImageHandler_ImageWasUpdatedNotification object:inURLString];
			}
		}];
		
		[tmpRequest setFailedBlock:^{
			DLog(@"%i", [tmpRequest responseStatusCode]);
			DLog(@"%@", [tmpRequest responseStatusMessage]);
		}];
		
		[tmpRequest startAsynchronous];
	}
	
	return tmpImage;
}

- (UIImage *)thumbnailForBusiness:(BozukoPage *)inBozukoPage
{
	if ([inBozukoPage pageImage] == nil)
		return nil;
	
	UIImage *tmpImage = [_thumbnailCache objectForKey:[inBozukoPage pageImage]];
	
	if (tmpImage == nil)
	{
		__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:[inBozukoPage pageImage]]];
		
		//DLog(@"%@", [inBozukoPage pageName]);
		//DLog(@"%@", [inBozukoPage pageImage]);
		
		[tmpRequest setCompletionBlock:^{
			//DLog(@"%@ Success", [inBozukoPage pageName]);
			
			//for (NSString *tmpString in [tmpRequest responseHeaders])
				//DLog(@"%@: %@", tmpString, [[tmpRequest responseHeaders] objectForKey:tmpString]);
			
			//DLog(@"========================================");
			
			UIImage *tmpImage = [UIImage imageWithData:[tmpRequest rawResponseData]];
			
			dispatch_queue_t imageQueue = dispatch_queue_create("thumbResize", NULL);
			
			dispatch_async(imageQueue, ^{
				CGFloat tmpScreenScale = [UIScreen mainScreen].scale;
				UIImage *tmpResizedImage = [tmpImage imageByScalingToSize:CGSizeMake(42.0 * tmpScreenScale, 42.0 * tmpScreenScale)];
				
				dispatch_async(dispatch_get_main_queue(), ^{
					if (tmpResizedImage != nil)
					{
						[_thumbnailCache setObject:tmpResizedImage forKey:[inBozukoPage pageImage]];
						
						[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_ThumbnailImageWasUpdated object:inBozukoPage];
					}
				});
			});
			
			dispatch_release(imageQueue);
		}];
		
		[tmpRequest setFailedBlock:^{
			DLog(@"%i", [tmpRequest responseStatusCode]);
			DLog(@"%@", [tmpRequest responseStatusMessage]);
		}];
		
		[tmpRequest startAsynchronous];
	}
	
	return tmpImage;
}

- (UIImage *)imageForBusiness:(BozukoPage *)inBozukoPage
{
	if ([inBozukoPage pageImage] == nil)
		return nil;
	
	UIImage *tmpImage = [_imageCache objectForKey:[inBozukoPage pageImage]];
	
	if (tmpImage == nil)
	{
		__block ASIHTTPRequest *tmpRequest = [self httpGETRequestWithURL:[NSURL URLWithString:[inBozukoPage pageImage]]];
		
		//DLog(@"%@", [inBozukoPage pageName]);
		//DLog(@"%@", [inBozukoPage pageImage]);
		
		[tmpRequest setCompletionBlock:^{
			//DLog(@"%@ Success", [inBozukoPage pageName]);
			
			//for (NSString *tmpString in [tmpRequest responseHeaders])
				//DLog(@"%@: %@", tmpString, [[tmpRequest responseHeaders] objectForKey:tmpString]);
			
			//DLog(@"========================================");
			
			UIImage *tmpImage = [UIImage imageWithData:[tmpRequest rawResponseData]];
			
			dispatch_queue_t thumbnailQueue = dispatch_queue_create("imageResize", NULL);
			
			dispatch_async(thumbnailQueue, ^{
				CGFloat tmpScreenScale = [UIScreen mainScreen].scale;
				UIImage *tmpResizedImage = [tmpImage imageByScalingToSize:CGSizeMake(140.0 * tmpScreenScale, 140.0 * tmpScreenScale)];
				
				dispatch_async(dispatch_get_main_queue(), ^{
					if (tmpResizedImage != nil)
					{
						[_imageCache setObject:tmpResizedImage forKey:[inBozukoPage pageImage]];
						
						[[NSNotificationCenter defaultCenter] postNotificationName:kBozukoHandler_PageImageWasUpdated object:inBozukoPage];
					}
				});
			});
			
			dispatch_release(thumbnailQueue);
		}];
		
		[tmpRequest setFailedBlock:^{
			DLog(@"%i", [tmpRequest responseStatusCode]);
			DLog(@"%@", [tmpRequest responseStatusMessage]);
		}];
		
		[tmpRequest startAsynchronous];
	}
	
	return tmpImage;
}

#pragma mark - Helper Methods

- (ASIHTTPRequest *)httpGETRequestWithURL:(NSURL *)inURL
{
	ASIHTTPRequest *tmpRequest = [ASIHTTPRequest requestWithURL:inURL];
	tmpRequest.useCookiePersistence = NO;
	tmpRequest.allowCompressedResponse = YES;
	tmpRequest.shouldWaitToInflateCompressedResponses = NO;
	tmpRequest.timeOutSeconds = 30;
	
	return tmpRequest;
}

- (NSString *)md5StringFromString:(NSString *)inString
{
	const char *tmpString = [inString UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(tmpString, strlen(tmpString), result);
	return [NSString 
			stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]
			];
}

#pragma mark -
#pragma mark Plumbing

+(ImageHandler *)sharedInstance {
	
	@synchronized(self)
	{
		if (!instance)
		{
			instance = [[ImageHandler alloc] init];
		}
	}
	return instance;
}

+(id) allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if (!instance)
		{
			instance = [super allocWithZone:zone];
		}
	}
	return instance;
}

- (id) copyWithZone:(NSZone *)zone {	return self; } 
- (id) retain { return self; } 
- (void) release { }
- (NSUInteger) retainCount {	return NSUIntegerMax; } 
- (id) autorelease { return self; }

@end
