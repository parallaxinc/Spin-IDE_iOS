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

@end
