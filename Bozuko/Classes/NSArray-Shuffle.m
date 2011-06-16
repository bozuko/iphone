//
//  NSArray-Shuffle.m
//  Bozuko
//
//  Created by Tom Corwine on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray-Shuffle.h"


@implementation NSArray (Shuffle)

-(NSArray *)shuffledArray
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
	
	NSMutableArray *copy = [self mutableCopy];
	while ([copy count] > 0)
	{
		int index = arc4random() % [copy count];
		id objectToMove = [copy objectAtIndex:index];
		[array addObject:objectToMove];
		[copy removeObjectAtIndex:index];
	}
	
	[copy release];
	return array;
}

@end
