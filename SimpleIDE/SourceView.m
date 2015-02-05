//
//  SourceView.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/30/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "SourceView.h"

#import "Common.h"
#import "CHighlighter.h"
#import "Highlighter.h"
#import "SpinHighlighter.h"


@interface SourceView () {
    BOOL dirty;												// YES if the file has changed since the last save or open.
}

@property (nonatomic, retain) Highlighter *highlighter;		// The highlighter to use for the current file.

@end


@implementation SourceView

@synthesize highlighter;
@synthesize language;
@synthesize path;

#pragma mark - Misc

/*!
 * Do initializetion common to all initialization methods.
 */

- (void) initCommon {
    self.language = languageC;
    self.highlighter = [[CHighlighter alloc] init];
    self.delegate = self;
}

/*!
 * Implemented by subclasses to initialize a new object (the receiver) immediately
 * after memory for it has been allocated.
 *
 * @param aDecoder		The decoder.
 *
 * @return				An initialized object or nil if the object could not be initialized.
 */

- (id) initWithCoder: (NSCoder *) aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self initCommon];
    }
    return self;
}

/*!
 * Returns an initialized object.
 *
 * @param frame			A rectangle defining the frame of the UISwitch object.
 *
 * @return				An initialized object or nil if the object could not be initialized.
 */

- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame: frame];
    if (self) {
        [self initCommon];
    }
    return self;
}

/*!
 * Save the current source file.
 *
 * This call does nothing, and flags no error, if self.path == nil.
 */

- (void) save {
    if (path && dirty) {
        NSError *error;
        [self.text writeToFile: path atomically: YES encoding: NSUTF8StringEncoding error: &error];
        if (error)
            [Common reportError: error];
        else
            dirty = NO;
    }
}

/*!
 * Sets the source displayed in the view and highlights it. This is treated as opening a new file.
 *
 * @param text			The new text.
 * @param path			The full path of the file the text belongs to. Pass nil if there is no
 *						file, in which case an error is flagged if the user tried to edit.
 */

- (void) setSource: (NSString *) text forPath: (NSString *) thePath {
    [self save];
    [self setAttributedText: [highlighter format: text]];
    dirty = NO;
    self.path = thePath;
}

#pragma mark - Getters and setters

/*!
 * Sets the text using the text highlighter.
 *
 * @param text			The new text.
 * @param path			The full path of the file the text belongs to. Pass nil if there is no
 *						file, in which case an error is flagged of the user tried to edit.
 */

- (void) setHighlightedText: (NSString *) text {
    [self save];
    [self setAttributedText: [highlighter format: text]];
    dirty = NO;
}

/*!
 * Set the current language. This selects the highlighter used.
 *
 * @param theLanguage		The new language.
 */

- (void) setLanguage: (languageType) theLanguage {
    language = theLanguage;
    switch (language) {
        case languageC:
        case languageCPP:
            self.highlighter = [[CHighlighter alloc] init];
            break;
            
        case languageSpin:
            self.highlighter = [[SpinHighlighter alloc] init];
            break;
    }
    NSRange selectedRange = self.selectedRange;
    [self setAttributedText: [highlighter format: self.text]];
    self.selectedRange = selectedRange;
}

#pragma mark - UITextViewDelegate

/*!
 * Tells the delegate that the text or attributes in the specified text view were changed by the user.
 *
 * The text view calls this method in response to user-initiated changes to the text. This method is not 
 * called in response to programmatically initiated changes.
 *
 * Implementation of this method is optional.
 *
 * This implementation reapplies syntax highlighting as the user types. It is not especially efficient,
 * and may need to be reworked to support large files. It also marks the file as dirty.
 *
 * @param textView		The text view containing the changes.
 */

- (void) textViewDidChange: (UITextView *) textView {
    // Reapply syntax highlighting.
    NSRange selectedRange = self.selectedRange;
    [self setAttributedText: [highlighter format: textView.text]];
    self.selectedRange = selectedRange;
    
    // Mark the file as dirty.
    dirty = YES;
}

@end
