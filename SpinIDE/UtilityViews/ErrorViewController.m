//
//  ErrorViewController.m
//  Spin IDE
//
//  Created by Mike Westerfield on 2/25/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "ErrorViewController.h"

@implementation ErrorViewController

@synthesize errorMessage;
@synthesize errorTextView;

#pragma mark - Setters

/*!
 * Set the error message.
 *
 * @param theErrorMessage		The new error message.
 */

- (void) setErrorMessage: (NSString *) theErrorMessage {
    errorMessage = theErrorMessage;
    errorTextView.text = errorMessage;
    errorTextView.font = [UIFont systemFontOfSize: 24];
}

/*!
 * Set the error text view.
 *
 * @param theErrorTextView		The UITextView for the error message.
 */

- (void) setErrorTextView: (UITextView *) theErrorTextView {
    errorTextView = theErrorTextView;
    if (errorMessage) {
        errorTextView.text = errorMessage;
        errorTextView.font = [UIFont systemFontOfSize: 18];
    }
}

@end
