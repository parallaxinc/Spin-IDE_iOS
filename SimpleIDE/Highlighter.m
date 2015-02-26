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



@interface Highlighter () {
    BOOL abort;					// Used to abort foramtting the text.
    BOOL formatting;			// True while a formatting operation is in progress.
}

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
 * The operation may take some time, so it is done on another thread and the completion handler is called when the 
 * task is complete. The formatted string is passed to the completion block.
 *
 * Multiple sequential calls may be made to this method before it returns the first formatted block of text. If a 
 * subsequent call is made while an older block of text is being processed, that calculataion is aborted and the new 
 * one starts. This allows rapid typing in a file that is too long to format between keypresses: the text retains 
 * the old formatting while the typing is underway, then the correct formatting is applied when the typist slows 
 * down enough for it to complete.
 *
 * If a format operation is aborted, the completion handler is not called.
 *
 * @param text					The text to format.
 * @param completionHandler		A block called when the formatting is complete (unless it is aborted).
 */

- (void) format: (NSString *) text completionHandler: (void (^)(NSAttributedString *)) callbackBlock {
    // If formatting is underway, abort it and block until the abort takes hold.
    abort = YES;
    while (formatting)
        [NSThread sleepForTimeInterval: 0.01];
    
    // Format the text asychronously.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSAttributedString *attributedText = nil;
        
        attributedText = [self format: text];
        
        if (attributedText) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callbackBlock(attributedText);
            });
        }
    });
}

/*!
 * Format a block of text.
 *
 * @param text		The text to format.
 *
 * @return			A formatted attributable string suitable for use in a UITextView.
 */

- (NSAttributedString *) format: (NSString *) text {
    // Set the formatting flag.
    formatting = YES;
    
    // Clear the abort flag. (It is only used for asyncronous calls.)
    abort = NO;
    
    // Form the attributed string.
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
        if (abort) 
            break;
        NSRange textRange = {0, text.length};
        NSArray *matches = [rule.rule matchesInString: text options: 0 range: textRange];
        for (NSTextCheckingResult *result in matches) {
            if (abort) 
                break;
            if (result.range.location != NSNotFound) {
                [attributedText addAttributes: rule.attributes range: result.range];
            }
        }
    }
    
    // Handle multiline comments.
    if (multilineCommentStartExpression != nil && multilineCommentEndExpression != nil && multiLineCommentAttributes != nil) {
        int start = 0;
        while (start < text.length) {
            if (abort) 
                break;
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
    
    if (abort)
        attributedText = nil;

    // Clear the formatting flag.
    formatting = NO;
    
    return attributedText;
}

/*!
 * Returns an attributed text string with the correct font, but no other highlihghing. This can be used when a file is initially loaded
 * to rapidly display the correct text without using hte time needd for proper highlighting.
 *
 * @param text		The text to format.
 *
 * @return			A formatted attributable string suitable for use in a UITextView.
 */

- (NSAttributedString *) setFont: (NSString *) text {
    // If formatting is underway, abort it and block until the abort takes hold.
    abort = YES;
    while (formatting)
        [NSThread sleepForTimeInterval: 0.01];

    // Create the attributed string.
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString: text];

    // Set the font throughout the text to the code font.
    NSRange textRange = {0, text.length - 0};
    [attributedText addAttribute: NSFontAttributeName value: [Common textFont] range: textRange];
    
    // Return the string.
    return attributedText;
}

@end
