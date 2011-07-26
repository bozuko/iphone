//
//  FZCustomSearchBar.h
//  Test
//
//  Created by Tom Corwine on 7/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FZCustomSearchBar;
@protocol FZCustomSearchBarDelegate <NSObject>
@optional

- (void)searchBarTextDidBeginEditing:(FZCustomSearchBar *)searchBar;
- (void)searchBarTextDidEndEditing:(FZCustomSearchBar *)searchBar;
- (void)searchBarSearchButtonClicked:(FZCustomSearchBar *)searchBar;
- (void)searchBar:(FZCustomSearchBar *)searchBar textDidChange:(NSString *)searchText;
- (void)searchBarCancelButtonClicked:(FZCustomSearchBar *)searchBar;

@end

@interface FZCustomSearchBar : UIView <UITextFieldDelegate>
{
	id <FZCustomSearchBarDelegate> _delegate;
	UIImageView *_textBackgroundImage;
	UITextField *_textField;
	UIButton *_cancelButton;
	BOOL _showsCancelButton;
}

@property (assign) id <FZCustomSearchBarDelegate> delegate;
@property (retain) NSString *text;
@property (retain) NSString *placeholder;
@property (readwrite) BOOL showsCancelButton;

- (void)cancelButtonWasPressed;
- (BOOL)resignFirstResponder;
- (BOOL)becomeFirstResponder;

@end
