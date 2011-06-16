//
//  NSDate+Formatter.m
//  Bozuko
//
//  Created by Christopher Luu on 5/18/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import "NSDate+Formatter.h"

@implementation NSDate (Formatter)

+ (NSDate *)dateFromString:(NSString *)inString format:(NSString *)inFormat
{
	NSDateFormatter *tmpFormatter = [[NSDateFormatter alloc] init];
	[tmpFormatter setDateFormat:inFormat];
	NSDate *tmpDate = [tmpFormatter dateFromString:inString];
	[tmpFormatter release];
	return tmpDate;
}

- (NSString *)stringWithDateFormat:(NSString *)inFormat
{
	NSDateFormatter *tmpFormatter = [[NSDateFormatter alloc] init];
	[tmpFormatter setDateFormat:inFormat];
	NSString *tmpString = [tmpFormatter stringFromDate:self];
	[tmpFormatter release];
	return tmpString;
}

@end
