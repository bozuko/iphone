//
//  BozukoHomeViewController.h
//  Bozuko
//
//  Created by Tom Corwine on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBozukoHomeViewController_PlayBozukoGameNotification		@"BozukoHomeViewController_PlayBozukoGameNotification"
#define kBozukoHomeViewController_PlayDemoGameNotification			@"BozukoHomeViewController_PlayDemoGameNotification"

@interface BozukoHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
	UIImageView *_profileImageView;
}

- (void)imageWasUpdated:(NSNotification *)inNotification;
- (void)userLogginStatusChanged;

@end
