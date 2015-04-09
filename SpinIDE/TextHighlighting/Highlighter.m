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
//		Implement highlightBlocks: if the language needs background highlighting.
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
#import "ColoredRange.h"
#import "SpinBackgroundHighlighter.h"



@implementation Highlighter

@synthesize multiLineCommentColor;
@synthesize multilineCommentEndExpression;
@synthesize multilineCommentStartExpression;
@synthesize rules;

/*!
 * Apply background highlighting.
 *
 * This default implementation returns nil. Subclasses should override this implementation if background highlighting 
 * is needed.
 *
 * @param theText		The text to highlight.
 *
 * @return				An array of ColoredRange objects that describe how to color the background, or nil.
 */

- (NSArray *) highlightBlocks: (NSString *) theText {
    return nil;
}

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
 * Format a block of text. This handles formatting that does not extend beyond one line, generally word level formatting.
 *
 * @param theText	The text to format.
 * @param range		The range of text to format.
 *
 * @return			A formatted attributable string suitable for use in a UITextView.
 */

- (NSArray *) wordHighlights: (NSString *) theText forRange: (NSRange) range {
    NSMutableArray *coloredRanges = [[NSMutableArray alloc] init];
    
    for (HighlighterRule *rule in rules) {
        NSArray *matches = [rule.rule matchesInString: theText options: 0 range: range];
        for (NSTextCheckingResult *result in matches) {
            if (result.range.location != NSNotFound) {
                ColoredRange *coloredRange = [[ColoredRange alloc] init];
                coloredRange.color = rule.color;
                coloredRange.range = result.range;
                [coloredRanges addObject: coloredRange];
            }
        }
    }
    
    return coloredRanges;
}

/*!
 * Apply highlighting that may span multiple lines, such as multiline comments.
 *
 * These highlights are typically performed once per change in the text, but applied after highlights that cannot span multiple lines.
 *
 * @param theText		The text to highlight.
 *
 * @return				An array of ColoredRange objects that describe how to color the background. The array may be empty or nil.
 */

- (NSArray *) multilineHighlights: (NSString *) theText {
    NSMutableArray *coloredRanges = nil;
    
    if (multilineCommentStartExpression != nil && multilineCommentEndExpression != nil && multiLineCommentColor != nil) {
        coloredRanges = [[NSMutableArray alloc] init];
        int start = 0;
        while (start < theText.length) {
            NSRange textRange = {start, theText.length - start};
            NSTextCheckingResult *result = [multilineCommentStartExpression firstMatchInString: theText options: 0 range: textRange];
            if (result && result.range.location != NSNotFound) {
                start = result.range.location + result.range.length;
                NSRange endTextRange = {start, theText.length - start};
                NSTextCheckingResult *endResult = [multilineCommentEndExpression firstMatchInString: theText options: 0 range: endTextRange];
                if (endResult && endResult.range.location != NSNotFound) {
                    textRange.location = result.range.location;
                    textRange.length = endResult.range.location + endResult.range.length - textRange.location;
                    
                    ColoredRange *coloredRange = [[ColoredRange alloc] init];
                    coloredRange.color = multiLineCommentColor;
                    coloredRange.range = textRange;
                    [coloredRanges addObject: coloredRange];

                    start = endResult.range.location + endResult.range.length;
                } else
                    start = theText.length;
            } else
                start = theText.length;
        }
    }
    
    return coloredRanges;
}

@end
