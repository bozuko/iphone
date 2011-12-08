//
//  LoadingView.h
//  Bozuko
//
//  Created by Tom Corwine on 5/31/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingView : UIView
{
	UILabel *_messageLabel;
}

@property (retain) NSString *messageTextString;

@end
