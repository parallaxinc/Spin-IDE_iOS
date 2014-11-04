//
//  SourceView.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/30/14.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "SourceView.h"

#import "Common.h"
#import "CHighlighter.h"
#import "Highlighter.h"
#import "SpinHighlighter.h"


@interface SourceView ()

@property (nonatomic, retain) Highlighter *highlighter;

@end

@implementation SourceView

@synthesize highlighter;
@synthesize language;

/*!
 * Implemented by subclasses to initialize a new object (the receiver) immediately
 * after memory for it has been allocated.
 *
 * @PARAM aDecoder		The decoder.
 */

- (id) initWithCoder: (NSCoder *) aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        self.language = languageC;
        self.highlighter = [[CHighlighter alloc] init];
        self.delegate = self;
    }
    return self;
}

#pragma mark - Getters and setters

/*!
 * Sets the text using the text highlighter.
 *
 * @param text			The new text.
 */

- (void) setHighlightedText: (NSString *) text {
    [self setAttributedText: [highlighter format: text]];
}

/*!
 * Set the current language.
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

// TODO: Reapply formatting rules as you type.

#pragma mark - UITextViewDelegate

/*!
 *
 */

- (void) textViewDidChange: (UITextView *) textView {
    NSRange selectedRange = self.selectedRange;
    [self setAttributedText: [highlighter format: textView.text]];
    self.selectedRange = selectedRange;
}

@end
