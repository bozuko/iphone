//
//  GamePrizesView.m
//  Bozuko
//
//  Created by Tom Corwine on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamePrizesView.h"
#import "BozukoGame.h"
#import "BozukoGamePrize.h"
#import "ImageHandler.h"

@implementation GamePrizesView

- (id)initWithGame:(BozukoGame *)inBozukoGame
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 417.0)];
    
	if (self)
	{
		_prizeIconURLS = [[NSMutableDictionary alloc] init];
		_prizeNameLabels = [[NSMutableDictionary alloc] init];
		
		UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 417.0)];
		tmpImageView.image = [UIImage imageNamed:@"images/profileBG"];
		[self addSubview:tmpImageView];
		[tmpImageView release];
		
		UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, 320.0, 30.0)];
		tmpLabel.backgroundColor = [UIColor clearColor];
		tmpLabel.textAlignment = UITextAlignmentCenter;
		tmpLabel.font = [UIFont boldSystemFontOfSize:30.0];
		tmpLabel.text = @"Prizes";
		[self addSubview:tmpLabel];
		[tmpLabel release];
		
		NSInteger tmpPrizesCount = [[inBozukoGame prizes] count] + [[inBozukoGame consolationPrizes] count];
		//DLog(@"Prizes: %d", tmpPrizesCount);
		
		for (int i = 0; i < tmpPrizesCount; i++)
		{
			BozukoGamePrize *tmpBozukoGamePrize = nil;
			
			if (i < [[inBozukoGame prizes] count])
			{
				// Regular prize
				tmpBozukoGamePrize = [BozukoGamePrize objectWithProperties:[[inBozukoGame prizes] objectAtIndex:i]];
				//DLog(@"%@", [tmpBozukoGamePrize name]);
			}
			else
			{
				// Consolation prize
				int tmpIndex = i - [[inBozukoGame prizes] count];
				tmpBozukoGamePrize = [BozukoGamePrize objectWithProperties:[[inBozukoGame consolationPrizes] objectAtIndex:tmpIndex]];
				//DLog(@"%@", [tmpBozukoGamePrize name]);
			}
			
			CGFloat tmpImageWidth = 0.0;
			
			if ([tmpBozukoGamePrize resultIcon] != nil)
			{
				UIImage *tmpImage = [[ImageHandler sharedInstance] imageForURL:[tmpBozukoGamePrize resultIcon]];
				CGFloat tmpImageHeight = tmpImage.size.height / 2;
				tmpImageWidth = (tmpImage.size.width / 2) * (40 / tmpImageHeight);
				
				UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 60.0 + (i * 45.0), tmpImageWidth, 40.0)];
				tmpImageView.contentMode = UIViewContentModeScaleAspectFit;
				tmpImageView.image = tmpImage;
				[self addSubview:tmpImageView];
				[tmpImageView release];
			
				[_prizeIconURLS setObject:tmpImageView forKey:[tmpBozukoGamePrize resultIcon]];
				[_prizeNameLabels setObject:tmpLabel forKey:[tmpBozukoGamePrize resultIcon]];
			}
			
			UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(tmpImageWidth + 25.0, 60.0 + (i * 45.0), 300.0, 40.0)];
			tmpLabel.backgroundColor = [UIColor clearColor];
			tmpLabel.textAlignment = UITextAlignmentLeft;
			tmpLabel.font = [UIFont boldSystemFontOfSize:20.0];
			tmpLabel.text = [tmpBozukoGamePrize name];
			[self addSubview:tmpLabel];
			[tmpLabel release];
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prizeIconWasUpdated:) name:kImageHandler_ImageWasUpdatedNotification object:nil];
    }
    
	return self;
}

#pragma mark ImageHandler Notification Methods

- (void)prizeIconWasUpdated:(NSNotification *)inNotification
{
	if ([[inNotification object] isKindOfClass:[NSString class]] == NO)
		return;
	
	for (NSString *tmpString in [_prizeNameLabels allKeys])
	{
		if ([[inNotification object] isEqualToString:tmpString] == YES)
		{
			UIImage *tmpImage = [[ImageHandler sharedInstance] imageForURL:tmpString];
		
			if (tmpImage != nil)
			{
				UIImageView *tmpImageView = (UIImageView *)[_prizeIconURLS objectForKey:tmpString];
				UILabel *tmpLabel = (UILabel *)[_prizeNameLabels objectForKey:tmpString];
				
				CGFloat tmpImageWidth = tmpImage.size.width / 2;
				tmpImageView.frame = CGRectMake(17.0, 7.0, tmpImageWidth, 40.0);
				tmpImageView.image = tmpImage;
				tmpLabel.frame = CGRectMake(25.0 + tmpImageWidth, 17.0, 270.0 - tmpImageWidth, 20.0);
			}
		}
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_prizeIconURLS release];
	[_prizeNameLabels release];
	
    [super dealloc];
}

@end
