//
//  Highlighter.m
//  SimpleIDE
//
//	This highlighter provides regular expression based highlighting of NSStrings.
//
//	Setup:
//		Create one or more Rule objecs and add them to the rule list. Text is painted
//		in the opposite of the order rules are added.
//
//		Optionally add a multiline comment rule by specifying the multilineCommentFormat,
//		commentStartExpression and commentEndExpression. These are always evaluated before
//		regular expressions are matched.
//
//	Use:
//		Pass format an NSString to format. It returns an NSAttributedString suitable for
//		display in a UITextObject.
//
//  Created by Mike Westerfield on 4/30/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "Highlighter.h"

#import "Common.h"
#import "SpinBackgroundHighlighter.h"



@interface Highlighter ()

@property (nonatomic, retain) SpinBackgroundHighlighter *spinBackgroundHighlighter;

@end



@implementation Highlighter

@synthesize multiLineCommentAttributes;
@synthesize multilineCommentEndExpression;
@synthesize multilineCommentStartExpression;
@synthesize rules;
@synthesize spinBackgroundHighlighter;

/*!
 * Returns an initialized highlighter object for C.
 *
 * @return			The initialized object.
 */

- (id) init {
    self = [super init];
    
    if (self) {
        rules = [[NSMutableArray alloc] init];
    }
    
    return self;
}

/*!
 * Returns YES for spin syntax highlighting, or NO for other languages. Overridden in the SpinHighlighter subclass.
 *
 * @return			YES for spin highloghting, else NO.
 */

- (BOOL) isSpin {
    return NO;
}

/*!
 * Format a block of text.
 *
 * @param text		The text to format.
 *
 * @return			A formatted attributable string suitable for use in a UITextView.
 */

- (NSAttributedString *) format: (NSString *) text {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString: text];
    
    // Set the font throughout the text to the code font.
    NSRange textRange = {0, text.length - 0};
    [attributedText addAttribute: NSFontAttributeName value: [Common textFont] range: textRange];
    
    // Add background highlighting for Spin files.
    if ([self isSpin]) {
        if (spinBackgroundHighlighter == nil)
            spinBackgroundHighlighter = [[SpinBackgroundHighlighter alloc] init];
        [spinBackgroundHighlighter highlightBlocks: attributedText];
    }

    // Handle the various "normal" rules.
    for (HighlighterRule *rule in rules) {
        NSRange textRange = {0, text.length};
        NSArray *matches = [rule.rule matchesInString: text options: 0 range: textRange];
        for (NSTextCheckingResult *result in matches) {
            if (result.range.location != NSNotFound) {
                [attributedText addAttributes: rule.attributes range: result.range];
            }
        }
    }
    
    // Handle multiline comments.
    if (multilineCommentStartExpression != nil && multilineCommentEndExpression != nil && multiLineCommentAttributes != nil) {
        int start = 0;
        while (start < text.length) {
            NSRange textRange = {start, text.length - start};
            NSTextCheckingResult *result = [multilineCommentStartExpression firstMatchInString: text options: 0 range: textRange];
            if (result && result.range.location != NSNotFound) {
                start = result.range.location + result.range.length;
                NSRange endTextRange = {start, text.length - start};
                NSTextCheckingResult *endResult = [multilineCommentEndExpression firstMatchInString: text options: 0 range: endTextRange];
                if (endResult && endResult.range.location != NSNotFound) {
                    textRange.location = result.range.location;
                    textRange.length = endResult.range.location + endResult.range.length - textRange.location;
                    [attributedText addAttributes: multiLineCommentAttributes range: textRange];
                    start = endResult.range.location + endResult.range.length;
                } else
                    start = text.length;
            } else
                start = text.length;
        }
    }

    return attributedText;
}

@end
