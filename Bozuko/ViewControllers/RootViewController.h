//
//  RootViewController.h
//  Bozuko
//
//  Created by Tom Corwine on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GamesHomeViewController;

@interface RootViewController : UIViewController <UITabBarControllerDelegate, UIAlertViewDelegate> {
	UINavigationController *_gamesNavigationController;
	UINavigationController *_prizesNavigationController;
	UINavigationController *_bozukoNavigationController;
    UITabBarController *_tabBarController;
	UIAlertView *_alertView;
	GamesHomeViewController *_gamesHomeViewController;
}

- (void)presentUserLoginWebView:(NSNotification *)inNotificaiton;
- (void)userLocationUnavailableNotification;
- (void)networkErrorNotification:(NSNotification *)inNotification;
- (void)networkUnavailableNotification;
- (void)applicationNeedsUpdateNotification:(NSNotification *)inNotification;
- (void)alertViewDismiss;
- (void)userDidLogout;

@end
