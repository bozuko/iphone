//
//  FZCustomSearchBar.m
//  Test
//
//  Created by Tom Corwine on 7/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FZCustomSearchBar.h"

@implementation FZCustomSearchBar

@synthesize delegate = _delegate;

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
	self = [self initWithFrame:CGRectZero];
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	CGRect tmpRect = CGRectMake(frame.origin.x, frame.origin.y, 320, 44);
    self = [super initWithFrame:tmpRect];
	
    if (self)
	{
		UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		tmpImageView.image = [UIImage imageNamed:@"FZCustomSearchBar_searchBg"];
		[self addSubview:tmpImageView];
		[tmpImageView release];
		
		_textBackgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 310, 29)];
		UIImage *tmpImage = [UIImage imageNamed:@"FZCustomSearchBar_searchInputBg"];
		_textBackgroundImage.image = [tmpImage stretchableImageWithLeftCapWidth:15 topCapHeight:0];
		[self addSubview:_textBackgroundImage];
		[_textBackgroundImage release];
		
		tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 15, 15, 15)];
		tmpImageView.image = [UIImage imageNamed:@"FZCustomSearchBar_searchMagGlass"];
		[self addSubview:tmpImageView];
		[tmpImageView release];
		
		_textField = [[UITextField alloc] initWithFrame:CGRectMake(30, 13, 280, 20)];
		_textField.delegate = self;
		_textField.font = [UIFont systemFontOfSize:14];
		_textField.returnKeyType = UIReturnKeySearch;
		_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		[self addSubview:_textField];
		[_textField release];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(330, 7, 60, 30);
		[_cancelButton setImage:[UIImage imageNamed:@"FZCustomSearchBar_searchCancelBtn"] forState:UIControlStateNormal];
		[_cancelButton addTarget:self action:@selector(cancelButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cancelButton];
    }
	
    return self;
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated
{
	_showsCancelButton = showsCancelButton;
	
	CGFloat tmpAnimationDuration;
	CGFloat tmpHorizontalPosition;
	
	if (animated == YES)
		tmpAnimationDuration = 0.25;
	else
		tmpAnimationDuration = 0.0;
	
	if (showsCancelButton == YES)
		tmpHorizontalPosition = 205.0;
	else
		tmpHorizontalPosition = 280.0;
		
	[UIView animateWithDuration:tmpAnimationDuration animations:^{
		_textBackgroundImage.frame = CGRectMake(5, 7, tmpHorizontalPosition + 30, 29);
		_textField.frame = CGRectMake(30, 13, tmpHorizontalPosition, 20);
		_cancelButton.frame = CGRectMake(tmpHorizontalPosition + 50, 7, 60, 30);
	}];
}

#pragma mark - Button Actions

- (void)cancelButtonWasPressed
{
	if ([_delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)] == YES)
		[_delegate searchBarCancelButtonClicked:self];
}

- (BOOL)resignFirstResponder
{
	return [_textField resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
	return [_textField becomeFirstResponder];
}

#pragma mark - UITextView Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if ([_delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)] == YES)
		[_delegate searchBarTextDidBeginEditing:self];	
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if ([_delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)] == YES)
		[_delegate searchBarTextDidEndEditing:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([_delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)] == YES)
		[_delegate searchBarSearchButtonClicked:self];
	
	return YES;
}

#pragma mark - Properties

- (NSString *)text
{
	return _textField.text;
}

- (void)setText:(NSString *)inText
{	
	_textField.text = inText;
}

- (NSString *)placeholder
{
	return _textField.placeholder;
}

- (void)setPlaceholder:(NSString *)inText
{	
	_textField.placeholder = inText;
}

- (BOOL)showsCancelButton
{
	return _showsCancelButton;
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
	[self setShowsCancelButton:showsCancelButton animated:NO];
}

@end
