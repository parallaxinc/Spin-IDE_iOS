//
//  SpinCompilerOptionsView.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/8/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "SpinCompilerOptionsView.h"

@implementation SpinCompilerOptionsView

@synthesize compilerOptionsTextField;
@synthesize delegate;

#pragma mark - Actions

/*!
 * Handle a change to the contents of the options UITextField.
 *
 * @param sender		The UITextField that triggered this call.
 */

- (IBAction) optionsEditingChanged: (UITextField *) sender {
    if ([delegate respondsToSelector: @selector(spinCompilerOptionsViewOptionsChanged:)])
        [delegate spinCompilerOptionsViewOptionsChanged: sender.text];
}

#pragma mark - UITextFieldDelegate

/*!
 * Asks the delegate if the specified text should be changed.
 *
 * The text field calls this method whenever the user types a new character in the text field or deletes an existing character.
 *
 * @param textField		The text field containing the text.
 * @param range			The range of characters to be replaced
 * @param string		The replacement string.
 *
 * @return				YES if the specified text range should be replaced; otherwise, NO to keep the old text.
 */

- (BOOL) textField: (UITextField *) textField
shouldChangeCharactersInRange: (NSRange) range
 replacementString: (NSString *) string
{
    if ([delegate respondsToSelector: @selector(spinCompilerOptionsViewOptionsChanged:)]) {
        NSString *text = [textField.text stringByReplacingCharactersInRange: range withString: string];
        text = [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        [delegate spinCompilerOptionsViewOptionsChanged: text];
    }
    return YES;
}

/*!
 * Asks the delegate if the text field should process the pressing of the return button. We use this
 * to dismiss the keyboard when the user is entering text in one of the UITextField objects.
 *
 * @param textField		The text field whose return button was pressed.
 */

- (BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return NO;
}

@end
