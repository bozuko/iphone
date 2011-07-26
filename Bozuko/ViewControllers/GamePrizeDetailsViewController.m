//
//  GamePrizeDetailsViewController.m
//  Bozuko
//
//  Created by Tom Corwine on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamePrizeDetailsViewController.h"
#import "BozukoGamePrize.h"

@implementation GamePrizeDetailsViewController

@synthesize bozukoGamePrize = _bozukoGamePrize;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
	if (self)
	{
        // Custom initialization
    }
    
	return self;
}

- (void)dealloc
{
	[_bozukoGamePrize release];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 417.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/profileBG"];
	[self.view addSubview:tmpImageView];
	[tmpImageView release];
	
	tmpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"images/bozukoLogo.png"]];
	[tmpImageView setFrame:CGRectMake(17, 20, 83, 30)];
	[[self view] addSubview:tmpImageView];
	[tmpImageView release];
	
	tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(263, 18, 34, 34)];
	[tmpImageView setContentMode:UIViewContentModeScaleAspectFill];
	[tmpImageView setImage:[UIImage imageNamed:@"images/prizesIconG.png"]];
	[[self view] addSubview:tmpImageView];
	[tmpImageView release];
	
	tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 83.0, 30.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/bozukoLogo"];
	UIBarButtonItem *tmpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tmpImageView];
	[tmpImageView release];
	self.navigationItem.rightBarButtonItem = tmpBarButtonItem;
	[tmpBarButtonItem release];
	
	_prizeName = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 50.0, 320.0, 50.0)];
	_prizeName.textAlignment = UITextAlignmentCenter;
	_prizeName.numberOfLines = 0;
	_prizeName.lineBreakMode = UILineBreakModeWordWrap;
	_prizeName.backgroundColor = [UIColor clearColor];
	_prizeName.font = [UIFont boldSystemFontOfSize:20.0];
	_prizeName.text = [_bozukoGamePrize name];
	[self.view addSubview:_prizeName];
	[_prizeName release];
	
	_prizeDescription = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 110.0, 300.0, 250.0)];
	_prizeDescription.editable = NO;
	_prizeDescription.backgroundColor = [UIColor clearColor];
	_prizeDescription.font = [UIFont systemFontOfSize:16.0];
	_prizeDescription.text = [_bozukoGamePrize prizeDescription];
	[self.view addSubview:_prizeDescription];
	[_prizeDescription release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
