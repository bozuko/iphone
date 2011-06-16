//
//  NSDate+Formatter.h
//  Bozuko
//
//  Created by Christopher Luu on 5/18/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatter)
+ (NSDate *)dateFromString:(NSString *)inString format:(NSString *)inFormat;
- (NSString *)stringWithDateFormat:(NSString *)inFormat;
@end
