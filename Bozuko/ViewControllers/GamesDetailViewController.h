//
//  BozukoHomeViewController.h
//  Bozuko
//
//  Created by Tom Corwine on 4/25/11.
//  Copyright 2011 Fuzz Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "GameFeedbackViewController.h"

@class BozukoPage;

@interface GamesDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>
{
    UITableView *_tableView;
	BozukoPage *_bozukoPage;
	BOOL _isPushing;
}

@property (retain) BozukoPage *bozukoPage;

- (void)favoriteButtonWasPressed:(id)sender;

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;

- (void)pageUpdateDidFinish:(NSNotification *)inNotification;
- (void)pageUpdateDidFail:(NSNotification *)inNotification;
- (void)updatePage;

//- (void)facebookPageWasLiked;

@end
