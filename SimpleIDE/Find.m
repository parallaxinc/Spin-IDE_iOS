//
//  Find.m
//  iosBASIC
//
//  A singleton class that stores information and provides utilities used by the Find command.
//
//  Created by Mike Westerfield on 6/8/11 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "Find.h"
#include "wctype.h"

static Find *this;

@implementation Find

@synthesize caseSensitive;
@synthesize findString;
@synthesize replaceString;
@synthesize wholeWord;
@synthesize wrap;

/*!
 * Return the singleton instance of this class.
 *
 * @return			An instance of htis class.
 */

+ (Find *) defaultFind {
    if (!this) {
        this = [[Find alloc] init];
        this.caseSensitive = YES;
        this.wholeWord = NO;
        this.wrap = YES;
        this.findString = nil;
        this.replaceString = nil;
    }
    return this;
}

/*!
 * Find the current findString in the given UITextField. The search starts at the selection end
 * and proceeds to the end of the text. If findString has not been found by the end of the text,
 * and wrap == YES, the search continues from the start of the text.
 *
 * Upon return, the selection is set to the first located occurrance of findString. If no string
 * was found, the selection is not changed.
 *
 * @return			The number of strings found: 1 if the selection was found, else 0.
 */

- (int) find: (UITextView *) text {
    if (findString != nil && findString.length > 0) {
        NSStringCompareOptions options = 0;
        if (!caseSensitive)
            options = NSCaseInsensitiveSearch;
        
        NSRange startSearchRange = [text selectedRange];
        if (startSearchRange.location > [[text text] length])
            startSearchRange.location = 0;
        else
            startSearchRange.location += startSearchRange.length;
        startSearchRange.length = [[text text] length] - startSearchRange.location;

        BOOL done = NO;
        NSRange searchRange = startSearchRange;
        while (!done) {
            NSRange foundRange = [[text text] rangeOfString: findString options: options range: searchRange];
            
            if (foundRange.location != NSNotFound) {
                if ([self wholeWordOK: text atSelection: foundRange]) {
                    [text setSelectedRange: foundRange];
                    return 1;
                } else {
                    searchRange.location = foundRange.location + foundRange.length;
                    searchRange.length = [[text text] length] - searchRange.location;
                    done = searchRange.length <= 0;
                }
            } else
                done = YES;
        }
        
        if (wrap && startSearchRange.location > 0) {
            searchRange.location = 0;
            searchRange.length = startSearchRange.location;

            done = NO;
            while (!done) {
                NSRange foundRange = [[text text] rangeOfString: findString options: options range: searchRange];
                
                if (foundRange.location != NSNotFound) {
                    if ([self wholeWordOK: text atSelection: foundRange]) {
                        [text setSelectedRange: foundRange];
                        return 1;
                    } else {
                        searchRange.location = foundRange.location + foundRange.length;
                        searchRange.length = startSearchRange.location - searchRange.location;
                        done = searchRange.length <= 0;
                    }
                } else
                    done = YES;
            }
        }
    }
    
    return 0;
}

/*!
 * Returns an initialized highlighter object for C.
 *
 * @return			The initialized object.
 */

- (id) init {
    self = [super init];
    
    if (self) {
        this = self;
    }
    
    return self;
}

/*!
 * Replace the current selection with replaceString.
 *
 * Upon return, the selection is set to the replaced string.
 *
 * @param text		The UITextView it which to search.
 *
 * @return			The number of strings replaced: 1 if there was a replace string, else 0.
 */

- (int) replace: (UITextView *) text {
    if (replaceString != nil && [replaceString length] > 0) {
        NSRange selection = [text selectedRange];
        
        UITextRange *selectionRange = [text selectedTextRange];
        [text replaceRange: selectionRange withText: replaceString];
        
        selection.length = [replaceString length];
        [text setSelectedRange: selection];
        return 1;
    }
    return 0;
}

/*!
 * Replace each occurrance of findString with replaceString.
 *
 * Overlapping findString values to not replace recursively. For example, if findString == "aa"
 * and replaceString == "aba", the result of a call on the text "aaa" is "abaa", not "ababa".
 *
 * The search starts at the beginning of the file and proceeds to the end. The selection is left
 * on the last replace string. If no replaces were done, the selection is not changed.
 *
 * @param text		The UITextView it which to search.
 *
 * @return			The number of findString occurrances that were replaced.
 */

- (int) replaceAll: (UITextView *) text {
    int count = 0;
    
    NSRange originalSelection = [text selectedRange];
    NSRange currentSelection = {0, 0};
    [text setSelectedRange: currentSelection];
    int found = [self find: text];
    while (found == 1) {
        ++count;
        [self replace: text];
        currentSelection = [text selectedRange];
        found = [self find: text];
        NSRange foundSelection = [text selectedRange];
        if (foundSelection.location < currentSelection.location)
            found = FALSE;
    }
    
    if (count == 0)
        [text setSelectedRange: originalSelection];
    else
        [text setSelectedRange: currentSelection];
    
    return count;
}

/*!
 * Replace the current selection with replaceString, then search for the next occurrance
 * of findString.
 *
 * This behaves exactly as if a call to replace is followed by a call to find.
 *
 * @param text		The UITextView it which to search.
 *
 * @return			1 if findString was found, else 0.
 */

- (int) replaceAndFind: (UITextView *) text {
    [self replace: text];
    return [self find: text];
}

/*!
 * Check to see if a selection meets the word wrap criteria.
 *
 * If wholeWord is NO, YES is returned. If wholeWord is YES, and the selection is bounded by
 * the end of the text or a non-alphanumeric character, YES is returned. Otherwise, NO is
 * returned.
 *
 * @param text		The text containing the selection.
 * @param selection	The selection.
 *
 * @return			YES if the selection is acceptable using the whole word rules, else NO.
 */

- (BOOL) wholeWordOK: (UITextView *) text atSelection: (NSRange) selection {
    if (wholeWord) {
        if (selection.location > 0) {
            int ch = [[text text] characterAtIndex: selection.location - 1];
            if (iswalnum(ch))
                return NO;
        }
        int pos = selection.location + selection.length;
        if (pos < [[text text] length]) {
            int ch = [[text text] characterAtIndex: pos];
            if (iswalnum(ch))
                return NO;
        }
    }
    return YES;
}

@end
