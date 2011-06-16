//
//  HowToPlayViewController.m
//  Bozuko
//
//  Created by Tom Corwine on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HowToPlayViewController.h"

#define kHowToPlay_ScreenIndicatorTagOffset			60

@implementation HowToPlayViewController

- (id)init
{
    self = [super init];
    
	if (self)
	{
        self.view.backgroundColor = [UIColor blackColor];
		
		UIBarButtonItem *tmpBarButtonItem = [[UIBarButtonItem alloc] init];
		tmpBarButtonItem.title = @"Close";
		tmpBarButtonItem.target = self;
		tmpBarButtonItem.action = @selector(dismissModalViewControllerAnimated:);
		self.navigationItem.rightBarButtonItem = tmpBarButtonItem;
		[tmpBarButtonItem release];
		
		self.navigationItem.title = @"How to Play?";
    }
    
	return self;
}

- (void)dealloc
{
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
	
	UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 415.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/helpBg"];
	[self.view addSubview:tmpImageView];
	[tmpImageView release];
	
	_cloudsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 5.0, 320.0, 143.0)];
	_cloudsScrollView.contentSize = CGSizeMake(678.0, 143.0);
	_cloudsScrollView.showsHorizontalScrollIndicator = NO;
	_cloudsScrollView.bounces = NO;
	[self.view addSubview:_cloudsScrollView];
	[_cloudsScrollView release];
	
	tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 678.0, 143.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/helpScrollCloudsBg"];
	[_cloudsScrollView addSubview:tmpImageView];
	[tmpImageView release];
	
	_backgroundScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 415.0)];
	_backgroundScrollView.contentSize = CGSizeMake(753.0, 415.0);
	_backgroundScrollView.showsHorizontalScrollIndicator = NO;
	_backgroundScrollView.bounces = NO;
	[self.view addSubview:_backgroundScrollView];
	[_backgroundScrollView release];
	
	tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 753.0, 415.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/helpScrollBg"];
	[_backgroundScrollView addSubview:tmpImageView];
	[tmpImageView release];
	
	_foregroundScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 415.0)];
	_foregroundScrollView.contentSize = CGSizeMake(1280.0, 415.0);
	_foregroundScrollView.showsHorizontalScrollIndicator = NO;
	_foregroundScrollView.bounces = NO;
	_foregroundScrollView.pagingEnabled = YES;
	_foregroundScrollView.delegate = self;
	[self.view addSubview:_foregroundScrollView];
	[_foregroundScrollView release];
	
	for (int i = 0; i < 4; i++)
	{
		tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 320.0, 0.0, 320.0, 415.0)];
		tmpImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"images/helpScreen%d", i + 1]];
		[_foregroundScrollView addSubview:tmpImageView];
		[tmpImageView release];
		
		// Page Indicator Dot
		tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(125 + (i * 20.0), 392.0, 10.0, 10.0)];
		
		if (i == 0)
			tmpImageView.image = [UIImage imageNamed:@"images/helpDotFull"];
		else
			tmpImageView.image = [UIImage imageNamed:@"images/helpDotEmpty"];
		
		tmpImageView.tag = kHowToPlay_ScreenIndicatorTagOffset + i;
		[self.view addSubview:tmpImageView];
		[tmpImageView release];
	}
	
	UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 310.0, 40.0)];
	tmpLabel.backgroundColor = [UIColor clearColor];
	tmpLabel.textColor = [UIColor darkGrayColor];
	tmpLabel.font = [UIFont boldSystemFontOfSize:28.0];
	tmpLabel.text = @"Welcome to Bozuko";
	[self.view addSubview:tmpLabel];
	[tmpLabel release];
	
	tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 415.0)];
	tmpImageView.image = [UIImage imageNamed:@"images/helpShadowOverlay"];
	[self.view addSubview:tmpImageView];
	[tmpImageView release];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView == _foregroundScrollView)
	{
		CGFloat tmpHorizontalPosition = _foregroundScrollView.bounds.origin.x;
		[_cloudsScrollView scrollRectToVisible:CGRectMake(tmpHorizontalPosition * 0.1, 0.0, 320.0, 143.0) animated:NO];
		[_backgroundScrollView scrollRectToVisible:CGRectMake(tmpHorizontalPosition * 0.45, 0.0, 320.0, 415.0) animated:NO];
		
		for (int i = 0; i < 4; i++)
		{
			UIImageView *tmpImageView = (UIImageView *)[self.view viewWithTag:kHowToPlay_ScreenIndicatorTagOffset + i];
			
			if (tmpHorizontalPosition > (i * 320) - 160 && tmpHorizontalPosition < 161 + (i * 320))
				tmpImageView.image = [UIImage imageNamed:@"images/helpDotFull"];
			else
				tmpImageView.image = [UIImage imageNamed:@"images/helpDotEmpty"];
		}
	}
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
