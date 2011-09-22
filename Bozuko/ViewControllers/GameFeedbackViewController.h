//
//  GameFeedbackViewController.h
//  Bozuko
//
//  Created by Tom Corwine on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Block)(void);

@interface GameFeedbackViewController : UIViewController <UITextViewDelegate> {
    UITextView *_textView;
	NSString *_placeholderText;
	Block _completionBlock;
	BOOL _requireTextFieldToBePopulated;
	UIBarButtonItem *_submitButton;
	BOOL _textIsPlaceholder;
	NSString *_submitButtonTitle;
}

@property (retain) UITextView *textView;
@property (retain) NSString *placeholderText;
@property (readwrite, getter = shouldRequireTextFieldToBePopulated) BOOL requireTextFieldToBePopulated;
@property (retain) NSString *submitButtonTitle;

- (id)initWithSubmitButtonTitle:(NSString *)inTitle;
- (void)setCompletionBlock:(Block)inBlock;
- (void)doCancel;
- (void)doSubmit;

@end
