//
//  GameFeedbackViewController.m
//  Bozuko
//
//  Created by Tom Corwine on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameFeedbackViewController.h"

@implementation GameFeedbackViewController

@synthesize textView = _textView;
@synthesize placeholderText = _placeholderText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
	[_completionBlock release];
	
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
	
	self.view.backgroundColor = [UIColor blackColor];
	
	UIBarButtonItem *tmpbarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(doCancel)];
	[self.navigationItem setLeftBarButtonItem:tmpbarButtonItem];
	[tmpbarButtonItem release];
	
	_submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(doSubmit)];
	[self.navigationItem setRightBarButtonItem:_submitButton];
	[_submitButton release];
	
	_submitButton.enabled = NO;
	
	_textView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 5.0, 300.0, 400.0)];
	_textView.backgroundColor = [UIColor whiteColor];
	_textView.delegate = self;
	_textView.text = _placeholderText;
	_textView.textColor = [UIColor lightGrayColor];
	_textView.font = [UIFont systemFontOfSize:18.0];
	[self.view addSubview:_textView];
	[_textView release];
	[_textView becomeFirstResponder];
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

- (void)setCompletionBlock:(Block)inBlock
{
	[inBlock release];
	_completionBlock = [inBlock copy];
}

#pragma mark Button action functions
- (void)doCancel
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)doSubmit
{
	if (_completionBlock)
		_completionBlock();
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark TextView Delegates

//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//	if (textView.textColor == [UIColor lightGrayColor])
//		textView.text = @"";
//	
//	textView.textColor = [UIColor blackColor];
//}
//
//- (void)textViewDidEndEditing:(UITextView *)textView
//{
//	if ([textView.text isEqualToString:@""] == YES)
//	{
//		textView.textColor = [UIColor lightGrayColor];
//		textView.text = _placeholderText;
//	}
//}

- (void)textViewDidChange:(UITextView *)textView
{
	if ([textView.text length] > 0)
		_submitButton.enabled = YES;
	else
		_submitButton.enabled = NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if (textView.textColor == [UIColor lightGrayColor])
		textView.text = @"";
	
	textView.textColor = [UIColor blackColor];
	
 	return YES;
}

@end
