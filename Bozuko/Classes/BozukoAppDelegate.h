//
//  BozukoAppDelegate.h
//  Bozuko
//
//  Created by Tom Corwine on 4/14/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface BozukoAppDelegate : NSObject <UIApplicationDelegate> {
	RootViewController *_rootViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
