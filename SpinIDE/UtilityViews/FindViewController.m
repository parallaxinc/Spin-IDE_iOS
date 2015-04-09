//
//  FindViewController.m
//  Spin IDE
//
//  Created by Mike Westerfield on 2/17/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "FindViewController.h"

#import "Find.h"

@interface FindViewController ()

@end

static BOOL caseSensitiveSwitchStartingState = NO;
static BOOL wholeWordSwitchStartingState = NO;
static BOOL wrapSwitchStartingState = YES;

@implementation FindViewController

@synthesize caseSensitiveSwitch;
@synthesize findButton;
@synthesize findTextField;
@synthesize referenceTextView;
@synthesize replaceAllButton;
@synthesize replaceAndFindButton;
@synthesize replaceButton;
@synthesize replaceTextField;
@synthesize wholeWordSwitch;
@synthesize wrapSwitch;

#pragma Misc

/*!
 * Check the enabled/isabled state of the buttons, making sure they are set properly for
 * the current contents of the Find and Replace UITextField controls.
 */

- (IBAction) checkButtons {
    BOOL enableFind = NO;
    BOOL enableReplace = NO;
    if ([[findTextField text] length] > 0) {
        enableFind = YES;
        if ([[replaceTextField text] length] > 0)
            enableReplace = YES;
    }
    
    if ([findButton isEnabled] != enableFind)
        [findButton setEnabled: enableFind];
    if ([replaceButton isEnabled] != enableReplace) {
        [replaceButton setEnabled: enableReplace];
        [replaceAndFindButton setEnabled: enableReplace];
        [replaceAllButton setEnabled: enableReplace];
    }
}

/*!
 * Show an alert stating that the search string was not found.
 */

- (void) notFound {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Not Found"
                                                    message: @"The search string was not found." 
                                                   delegate: nil 
                                          cancelButtonTitle: @"OK" 
                                          otherButtonTitles: nil];
    [alert show];
}

/*!
 * Send the state of all find options, including the strings, to the Find class. This
 * gets ready to either do a find/replace action or exit this dialog.
 */

- (void) saveState {
    [[Find defaultFind] setCaseSensitive: [caseSensitiveSwitch isOn]];
    [[Find defaultFind] setWholeWord: [wholeWordSwitch isOn]];
    [[Find defaultFind] setWrap: [wrapSwitch isOn]];
    
    [[Find defaultFind] setFindString: [findTextField text]];
    [[Find defaultFind] setReplaceString: [replaceTextField text]];
}

/*!
 * Called when editing is complete, this method dismisses the keyboard.
 *
 * @param sender		The UITextField that generated the event.
 */

- (IBAction) textFieldDoneEditing: (id) sender {
    [sender resignFirstResponder];
    [referenceTextView becomeFirstResponder];
}

#pragma mark - Actions

/*!
 * Handle a hit on the Find button.
 */

- (IBAction) findButtonAction {
    [self saveState];
    [findTextField resignFirstResponder];
    [replaceTextField resignFirstResponder];
    if ([[Find defaultFind] find: referenceTextView] > 0) {
        [referenceTextView becomeFirstResponder];
        [referenceTextView setSelectedRange: [referenceTextView selectedRange]];
    } else {
        [self notFound];
    }
}

/*!
 * Handle a hit on the Repalce All button.
 */

- (IBAction) replaceAllButtonAction {
    [findTextField resignFirstResponder];
    [replaceTextField resignFirstResponder];
    [self saveState];
    if ([[Find defaultFind] replaceAll: referenceTextView] > 0) {
        [referenceTextView becomeFirstResponder];
        [referenceTextView setSelectedRange: [referenceTextView selectedRange]];
    } else {
        [self notFound];
    }
}

/*!
 * Handle a hit on the Replace and Find button.
 */

- (IBAction) replaceAndFindButtonAction {
    [findTextField resignFirstResponder];
    [replaceTextField resignFirstResponder];
    [self saveState];
    if ([[Find defaultFind] replaceAndFind: referenceTextView] > 0) {
        [referenceTextView becomeFirstResponder];
        [referenceTextView setSelectedRange: [referenceTextView selectedRange]];
    } else {
        if ([[replaceTextField text] length] > 0) {
            [referenceTextView becomeFirstResponder];
            [referenceTextView setSelectedRange: [referenceTextView selectedRange]];
        }
        [self notFound];
    }
}

/*!
 * Handle a hit on the Repalce button.
 */

- (IBAction) replaceButtonAction {
    [findTextField resignFirstResponder];
    [replaceTextField resignFirstResponder];
    [self saveState];
    [[Find defaultFind] replace: referenceTextView];
    [referenceTextView becomeFirstResponder];
    [referenceTextView setSelectedRange: [referenceTextView selectedRange]];
}

#pragma mark - View Maintenance

/*!
 * Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 * @param animated		If YES, the view is being added to the window using an animation.
 */

- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear: animated];
    [findTextField becomeFirstResponder];
}

/*!
 * Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 * @param animated		If YES, the view is being added to the window using an animation.
 */

- (void) viewWillAppear: (BOOL) animated {
    // Call super.
    [super viewWillAppear: animated];
    
    // Record the various settings for future invocations.
    [caseSensitiveSwitch setOn: caseSensitiveSwitchStartingState animated: NO];
    [wholeWordSwitch setOn: wholeWordSwitchStartingState animated: NO];
    [wrapSwitch setOn: wrapSwitchStartingState animated: NO];
    
    if ([[Find defaultFind] findString] != nil)
        [findTextField setText: [[Find defaultFind] findString]];
    if ([[Find defaultFind] replaceString] != nil)
        [replaceTextField setText: [[Find defaultFind] replaceString]];
    [self checkButtons];
}

/*!
 * Notifies the view controller that its view is about to be removed from a view hierarchy.
 *
 * @param animated		If YES, the view is being removed using an animation.
 */

- (void) viewWillDisappear: (BOOL) animated {
    caseSensitiveSwitchStartingState = [caseSensitiveSwitch isOn];
    wholeWordSwitchStartingState = [wholeWordSwitch isOn];
    wrapSwitchStartingState = [wrapSwitch isOn];
    
    [[Find defaultFind] setFindString: [findTextField text]];
    [[Find defaultFind] setReplaceString: [replaceTextField text]];
    
    [super viewWillDisappear: animated];
}

@end
