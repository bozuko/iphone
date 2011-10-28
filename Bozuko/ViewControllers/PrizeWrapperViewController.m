//
//  PrizeDetailsViewController.m
//  Bozuko
//
//  Created by Christopher Luu on 5/18/11.
//  Copyright 2011 Fuzz Productions. All rights reserved.
//

#import "PrizeWrapperViewController.h"
#import "ImageHandler.h"
#import "BozukoHandler.h"
#import "LoadingView.h"
#import "GamePrizeDetailView.h"
#import "BozukoRedemption.h"
#import "UIView+OriginSize.h"
#import "NSDate+Formatter.h"

#define kPrizeWrapper_AreYouSureAlert		0
#define kPrizeWrapper_PrizeExpired			1

@interface PrizeWrapperViewController (Private)
- (void)doClose;
@end

@implementation PrizeWrapperViewController

@synthesize delegate = _delegate;

- (id)initWithBozukoPrize:(BozukoPrize *)inPrize
{
	if ((self = [super init]))
	{
		_bozukoPrize = [inPrize retain];
		[self setTitle:[_bozukoPrize pageName]];
	}
	return self;
}

- (void)loadView
{
	UIImageView *tmpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"images/profileBG.png"]];
	[tmpImageView setUserInteractionEnabled:YES];
	[self setView:tmpImageView];
	[tmpImageView release];
}

- (void)applicationDidEnterBackground
{
	[_alertView dismissWithClickedButtonIndex:0 animated:NO];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.hidesBackButton = YES;

	_backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_backgroundView];
	[_backgroundView release];

	UIImageView *tmpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"images/bozukoLogo.png"]];
	[tmpImageView setOrigin:CGPointMake(17, 20)];
	[_backgroundView addSubview:tmpImageView];
	[tmpImageView release];

	tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(263, 18, 34, 34)];
	[tmpImageView setContentMode:UIViewContentModeScaleAspectFill];
	[tmpImageView setImage:[UIImage imageNamed:@"images/prizesIconG.png"]];
	[_backgroundView addSubview:tmpImageView];
	[tmpImageView release];

	UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 320, 21)];
	[tmpLabel setBackgroundColor:[UIColor clearColor]];
	tmpLabel.textAlignment = UITextAlignmentCenter;
	[tmpLabel setFont:[UIFont boldSystemFontOfSize:25.0]];
	[tmpLabel setTextColor:[UIColor colorWithRed:0.0 green:(153.0/255.0) blue:0.0 alpha:1.0]];
	[tmpLabel setText:@"YOU WIN!"];
	[_backgroundView addSubview:tmpLabel];
	[tmpLabel release];
	
	tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 320, 28)];
	[tmpLabel setBackgroundColor:[UIColor clearColor]];
	tmpLabel.textAlignment = UITextAlignmentCenter;
	[tmpLabel setFont:[UIFont boldSystemFontOfSize:25.0]];
	[tmpLabel setTextColor:[UIColor blackColor]];
	tmpLabel.text = [_bozukoPrize name];
	[_backgroundView addSubview:tmpLabel];
	[tmpLabel release];
	
	// Underline
	CGSize tmpSize = [[_bozukoPrize name] sizeWithFont:[UIFont boldSystemFontOfSize:25.0]];
	UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(160.0 - (tmpSize.width / 2), 100.0, tmpSize.width, 1.0)];
	tmpView.backgroundColor = [UIColor blackColor];
	[_backgroundView addSubview:tmpView];
	[tmpView release];
	
	UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
	tmpButton.frame = CGRectMake(0, 70, 320, 40);
	[tmpButton addTarget:self action:@selector(prizeDetailsButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	[_backgroundView addSubview:tmpButton];

	UILabel *tmpPrizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 105, 290, 70)];
	[tmpPrizeLabel setBackgroundColor:[UIColor clearColor]];
	[tmpPrizeLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
	[tmpPrizeLabel setText:[_bozukoPrize wrapperMessage]];
	[tmpPrizeLabel setNumberOfLines:0];
	tmpPrizeLabel.lineBreakMode = UILineBreakModeWordWrap;
	[_backgroundView addSubview:tmpPrizeLabel];
	[tmpPrizeLabel release];
	
	tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 185, 288, 63)];
	[tmpImageView setContentMode:UIViewContentModeScaleAspectFill];
	[tmpImageView setImage:[UIImage imageNamed:@"images/winTextInput"]];
	[_backgroundView addSubview:tmpImageView];
	[tmpImageView release];
	
	_textView = [[UITextView alloc] initWithFrame:CGRectMake(16, 185, 288, 63)];
	_textView.dataDetectorTypes = UIDataDetectorTypeNone;
	_textView.backgroundColor = [UIColor clearColor];
	_textView.delegate = self;
	_textView.textColor = [UIColor lightGrayColor];
	_textView.text = @"Share with your friends.";
	[_backgroundView addSubview:_textView];
	[_textView release];
	
	tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 260, 100, 20)];
	tmpLabel.backgroundColor = [UIColor clearColor];
	tmpLabel.font = [UIFont systemFontOfSize:12.0];
	tmpLabel.text = @"Post to your wall";
	[_backgroundView addSubview:tmpLabel];
	[tmpLabel release];
	
	_checkmarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_checkmarkButton.frame = CGRectMake(277, 255, 30, 30);
	_checkmarkButton.selected = YES;
	[_checkmarkButton addTarget:self action:@selector(checkmarkWasPressed) forControlEvents:UIControlEventTouchUpInside];
	[_checkmarkButton setImage:[UIImage imageNamed:@"images/checkBoxEmpty"] forState:UIControlStateNormal];
	[_checkmarkButton setImage:[UIImage imageNamed:@"images/checkBoxFilled"] forState:UIControlStateSelected];
	[_backgroundView addSubview:_checkmarkButton];
	
	tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
	tmpButton.frame = CGRectMake(21, 290, 278, 45);
	[tmpButton setBackgroundImage:[UIImage imageNamed:@"images/greenBtn"] forState:UIControlStateNormal];
	[tmpButton setBackgroundImage:[UIImage imageNamed:@"images/greenBtnPress"] forState:UIControlStateNormal];
	tmpButton.titleLabel.font = [UIFont boldSystemFontOfSize:22.0];
	tmpButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	[tmpButton setTitle:@"Redeem" forState:UIControlStateNormal];
	[tmpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[tmpButton addTarget:self action:@selector(redeemPrizeButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	[_backgroundView addSubview:tmpButton];
	
	tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
	tmpButton.frame = CGRectMake(21, 350, 278, 45);
	[tmpButton setBackgroundImage:[UIImage imageNamed:@"images/yellowBtn"] forState:UIControlStateNormal];
	[tmpButton setBackgroundImage:[UIImage imageNamed:@"images/yellowBtnPress"] forState:UIControlStateNormal];
	tmpButton.titleLabel.font = [UIFont boldSystemFontOfSize:22.0];
	//tmpButton.titleLabel.shadowColor = [UIColor whiteColor];
	//tmpButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	[tmpButton setTitle:@"Save for Later" forState:UIControlStateNormal];
	[tmpButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[tmpButton addTarget:self action:@selector(doClose) forControlEvents:UIControlEventTouchUpInside];
	[_backgroundView addSubview:tmpButton];
	
	_loadingOverlay = [[LoadingView alloc] init];
	_loadingOverlay.hidden = YES;
	[self.view addSubview:_loadingOverlay];
	[_loadingOverlay release];
	
	_doneBarButton = [[UIBarButtonItem alloc] init];
	_doneBarButton.target = self;
	_doneBarButton.action = @selector(prizeDetailsDoneButtonWasPressed);
	_doneBarButton.title = @"Done";
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prizeRedemptionDidFinish:) name:kBozukoHandler_PrizeRedemptionDidFinish object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prizeRedemptionDidFail:) name:kBozukoHandler_PrizeRedemptionDidFail object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	//DLog(@"%@", _bozukoPrize);
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)redeemPrize
{
	NSString *tmpMessage = nil;
	
	if (_checkmarkButton.selected == YES && _textView.textColor == [UIColor blackColor]) // If text color is not black, then it's placeholder text and we don't want it
		tmpMessage = _textView.text;
	
	[[BozukoHandler sharedInstance] bozukoRedeemPrize:_bozukoPrize withMessage:tmpMessage postToWall:_checkmarkButton.selected];
	_loadingOverlay.hidden = NO;
}

#pragma mark TextView Delegates

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if (textView.textColor == [UIColor lightGrayColor])
		textView.text = @"";
	
	textView.textColor = [UIColor blackColor];
	
	[UIView animateWithDuration:0.3 animations:^{
		_backgroundView.center = CGPointMake(_backgroundView.center.x, _backgroundView.center.y - 90);
	}];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if ([textView.text isEqualToString:@""] == YES)
	{
		textView.textColor = [UIColor lightGrayColor];
		textView.text = @"Share with your friends."; // Placeholder text
	}
	
	[UIView animateWithDuration:0.3 animations:^{
		_backgroundView.center = CGPointMake(_backgroundView.center.x, _backgroundView.center.y + 90);
	}];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([text isEqualToString:@"\n"] == YES)
		[textView resignFirstResponder];
	
 	return YES;
}

#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	_alertView = nil;
	
	if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"] == YES && alertView.tag == kPrizeWrapper_AreYouSureAlert)
		[self redeemPrize];
	else if (alertView.tag == kPrizeWrapper_PrizeExpired)
		[self doClose];
}

#pragma mark -
#pragma mark Button action functions

- (void)prizeDetailsButtonWasPressed
{
	[self.navigationItem performSelector:@selector(setLeftBarButtonItem:) withObject:_doneBarButton afterDelay:1.0];
	
	_prizeDetailsView = [[GamePrizeDetailView alloc] initWithBozukoPrize:_bozukoPrize];
	[UIView transitionFromView:self.view toView:_prizeDetailsView duration:1.0 options:UIViewAnimationOptionTransitionCurlUp completion:^(BOOL done){}];
	[_prizeDetailsView release];
}

- (void)prizeDetailsDoneButtonWasPressed
{
	self.navigationItem.leftBarButtonItem = nil;
	
	[UIView transitionFromView:_prizeDetailsView toView:self.view duration:1.0 options:UIViewAnimationOptionTransitionCurlDown completion:^(BOOL done){}];
}

- (void)doClose
{
	if ([_delegate respondsToSelector:@selector(closeView)] == YES)
		[_delegate closeView];
	else
		[self dismissModalViewControllerAnimated:YES];
}

- (void)redeemPrizeButtonWasPressed
{
	if ([_bozukoPrize isEmail] == YES || [_bozukoPrize isBarcode] == YES)
		[self redeemPrize];
	else
	{
		NSString *tmpString = [NSString stringWithFormat:@"This prize will be permanently disabled after a %d second claim period. Press OK to continue or CANCEL to save this prize for later.", [_bozukoPrize redemptionDuration]];
		_alertView = [[UIAlertView alloc] initWithTitle:@"ARE YOU SURE?"
															   message:tmpString
															  delegate:self
													 cancelButtonTitle:@"Cancel"
													 otherButtonTitles:@"OK", nil];
		
		_alertView.tag = kPrizeWrapper_AreYouSureAlert;
		[_alertView show];
		[_alertView release];
	}
}

- (void)checkmarkWasPressed
{
	if (_checkmarkButton.selected == YES)
		_checkmarkButton.selected = NO;
	else
		_checkmarkButton.selected = YES;
}

#pragma mark Notification Methods

- (void)prizeRedemptionDidFinish:(NSNotification *)inNotification
{
	_loadingOverlay.hidden = YES;
	
	if ([[inNotification object] isKindOfClass:[NSString class]] == YES && [[inNotification object] isEqualToString:@"prize/expired"] == YES)
	{
		_alertView = [[UIAlertView alloc] initWithTitle:@"Prize Expired"
												message:@"Sorry, but this prize has expired."
											   delegate:self
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
		
		_alertView.tag = kPrizeWrapper_PrizeExpired;
		[_alertView show];
		[_alertView release];
		
		return;
	}
	
	if ([[inNotification object] isKindOfClass:[BozukoRedemption class]] == NO)
		return;
	
	[_bozukoPrize release];
	_bozukoPrize = [[[inNotification object] prize] retain];
	
	PrizeDetailsViewController *tmpViewController = [[PrizeDetailsViewController alloc] initWithBozukoPrize:_bozukoPrize];
	tmpViewController.delegate = _delegate;
	tmpViewController.bozukoRedemption = [inNotification object];
	[self.navigationController pushViewController:tmpViewController animated:YES];
	DLog(@"Push");
	[tmpViewController release];
}

- (void)prizeRedemptionDidFail:(NSNotification *)inNotification
{
	_loadingOverlay.hidden = YES;
	
	UIAlertView *tmpAlertView = [[UIAlertView alloc] initWithTitle:@"Redemption Failed"
							   message:@"Sorry, we were unable to redeem your prize at this time. Please try again later."
							  delegate:nil
					 cancelButtonTitle:@"Okay"
					 otherButtonTitles:nil];
	
	[tmpAlertView show];
	[tmpAlertView release];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_doneBarButton release];
	[_bozukoPrize release];
	
	self.delegate = nil;
	
	[super dealloc];
}

@end
