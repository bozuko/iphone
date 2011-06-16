//
//  BozukoGameResult.h
//  Bozuko
//
//  Created by Tom Corwine on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kScratchTicket1		1
#define kScratchTicket2		2
#define kScratchTicket3		4
#define kScratchTicket4		8
#define kScratchTicket5		16
#define kScratchTicket6		32

typedef int ScratchTicketMask;

@class BozukoPrize;
@class BozukoGameState;

@interface BozukoGameResult : NSObject {
	NSString *_gameID;
	NSMutableDictionary *_properties;
}

@property (retain) NSString *gameID;
@property (nonatomic, retain) NSMutableDictionary *properties;

+ (BozukoGameResult *)objectWithProperties: (NSMutableDictionary *)inDictionary;
- (id)initWithProperties: (NSMutableDictionary *)inDictionary;

- (NSInteger)code;
- (BOOL)win;
- (id)result;
- (BOOL)freePlay;
- (BOOL)consolation;
- (NSString *)message;
- (NSString *)redemptionType;
- (BozukoPrize *)prize;
- (BozukoGameState *)gameState;

- (NSDictionary *)links;

+ (id)loadObjectFromDiskForPageID:(NSString *)inPageID;
- (void)saveObjectToDisk;
- (void)deleteObjectFromDisk;
- (void)setScratchedAreas:(ScratchTicketMask)inScratchAreasBitmask;
- (ScratchTicketMask)scratchedAreas;

@end
