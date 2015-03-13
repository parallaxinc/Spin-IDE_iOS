//
//  CodeView.m
//  Spin IDE
//
//	This class is similar to UITextView, but it is optimized for displaying syntax colored source code
//	and fixes a number of scrolling bugs in UITextView that have persisted in one form or another since 
//	iOS 7.
//
//  Created by Mike Westerfield on 3/4/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "CodeView.h"

#import "CHighlighter.h"
#import "CodeRect.h"
#import "ColoredRange.h"
#import "SpinHighlighter.h"


@interface CodeView () {
    float charWidth;											// The width of a character.
    int cursorState;											// A value form 0 to 2 indicating if the cursor is on or off. 0 is off.
}

@property (nonatomic, retain) Highlighter *highlighter;			// The current code highlighter.
@property (nonatomic, retain) NSArray *backgroundHighlights;	// Array of ColoredRange objects indicating ranges of text backgrounds to highlight.
@property (nonatomic, retain) NSTimer *cursorTimer;				// A timer used to bling the cursor.
@property (nonatomic, retain) NSArray *multilineHighlights;		// Array of ColoredRange objects indicating ranges of text to highlight.
@property (nonatomic, retain) NSArray *lines;					// The text content, broken up into lines.

@property (nonatomic, retain) NSMutableArray *attributes;		// The attributes used to draw text. Indexes match colors.
@property (nonatomic, retain) NSMutableArray *colors;			// The colors used to highlight text. Indexes match attributes.

@end


@implementation CodeView

@synthesize attributes;
@synthesize backgroundHighlights;
@synthesize colors;
@synthesize cursorTimer;
@synthesize font;
@synthesize highlighter;
@synthesize language;
@synthesize lines;
@synthesize multilineHighlights;
@synthesize selectedRange;
@synthesize text;

#pragma mark - Misc

/*!
 * Blink the cursor.
 *
 * This method determines if the cursor is currently visible, then moves it to the next state, blinking it if needed. If
 * the cursor is visible, but should not be, it's state is moved to the hidden state.
 *
 * @param timer		The timer that fired this action.
 */

- (void) blinkCursor: (NSTimer *) timer {
    // See if we need to do anything.
    if (!(cursorState == 0 && selectedRange.length > 0)) {
        // Determine the new state of the cursor.
        if (selectedRange.length > 0)
            cursorState = 0;
        else
	        cursorState = (cursorState + 1)%3;
        
        if (cursorState != 2) {
            // Find the update rectangle.
            CGRect r = [self firstRectForRange: selectedRange];
            r.origin.x += self.contentOffset.x;
            r.origin.y += self.contentOffset.y;
            
            // If the rectangle is visible in the view, update the rectangle's area.
            if (CGRectContainsRect(self.frame, r)) {
                [self setNeedsDisplayInRect: r];
            }
        }
    }
}

/*!
 * Get the index for the color (and by inference the character attribute) for use in highlighting syntax colored text.
 *
 * @param color			The color whose index is returned.
 *
 * @return				The index.
 */

- (int) colorIndexForColor: (UIColor *) color {
    int colorIndex = -1;
    
    for (int i = 1; i < colors.count; ++i)
        if ([color isEqual: colors[i]]) {
            colorIndex = i;
            break;
        }
    
    if (colorIndex == -1) {
        colorIndex = colors.count;
        [colors addObject: color];
        NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:
                                   font, NSFontAttributeName, 
                                   color, NSForegroundColorAttributeName,
                                   nil];
        [attributes addObject: attribute];
    }
    
    return colorIndex;
}

/*!
 * Do initializetion common to all initialization methods.
 */

- (void) initCodeViewCommon {
    self.text = @"";
    self.font = [UIFont fontWithName: @"Menlo-Regular" size: 13];
    self.language = languageSpin;
    self.highlighter = [[SpinHighlighter alloc] init];
    self.delegate = self;
    
    // Set up a cursor timer.
    self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval: 0.333
                                                        target: self
                                                      selector: @selector(blinkCursor:)
                                                      userInfo: nil
                                                       repeats: YES];
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
        [self initCodeViewCommon];
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
        [self initCodeViewCommon];
    }
    return self;
}

/*!
 * Update the view size so scrolling is properly represented.
 */

- (void) updateViewSize {
    CGSize size;
    size.height = lines.count*font.lineHeight;
    int maxChars = 0;
    for (NSString *line in lines)
        if (line.length > maxChars)
            maxChars = line.length;
    size.width = maxChars*charWidth;
    self.contentSize = size;
}


#pragma mark - Getters and setters

/*!
 * Set the font for the view. This must be a monospaced font.
 *
 * @param theFont		The new font.
 */

- (void) setFont: (UIFont *) theFont {
    font = theFont;

    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    font, NSFontAttributeName, 
                                    nil];
    charWidth = [@"W" sizeWithAttributes: fontAttributes].width;
    
    [self updateViewSize];
}

/*!
 * Set the current language. This selects the highlighter used.
 *
 * @param theLanguage		The new language.
 */

- (void) setLanguage: (languageType) theLanguage {
    if (language != theLanguage) {
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
        self.backgroundHighlights = [highlighter highlightBlocks: text];
        self.multilineHighlights = [highlighter multilineHighlights: text];
    }
}

/*!
 * Set the text contents for the view.
 *
 * @param theText		The new text contents.
 */

- (void) setText: (NSString *) theText {
    text = [theText stringByReplacingOccurrencesOfString: @"\r\n" withString: @"\n"];
    lines = [text componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    [self updateViewSize];
    [self setNeedsDisplay];
    self.backgroundHighlights = [highlighter highlightBlocks: text];
    self.multilineHighlights = [highlighter multilineHighlights: text];
}

#pragma mark - Text Rendering

/*!
 * Draws the receiver’s image within the passed-in rectangle.
 *
 * @param rect			The portion of the view’s bounds that needs to be updated.
 */

- (void) drawRect: (CGRect) rect {
    // Draw the background.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    
    // Draw any blocks of background color.
    if (backgroundHighlights) {
        for (ColoredRange *coloredRange in backgroundHighlights) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [coloredRange.color CGColor]);
            NSArray *rects = [self selectionRectsForRange: coloredRange.range];
            for (CodeRect *rect in rects) {
                CGContextFillRect(context, rect.rect);
            }
        }
    }
    
    // Find the range of lines to draw.
    int firstLine = self.contentOffset.y/font.lineHeight;
    if (firstLine < 0)
        firstLine = 0;
    int lastLine = 1 + firstLine + self.frame.size.height/font.lineHeight;
    if (lastLine > lines.count)
        lastLine = lines.count;
        
    // Set up the arrays used to track syntax highlighting.
    NSDictionary *defaultAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                       font, NSFontAttributeName, 
                                       nil];
    self.attributes = [NSMutableArray arrayWithObject: defaultAttributes];
    self.colors = [NSMutableArray arrayWithObject: [UIColor blackColor]];
    
    int highlightIndexSize = 0;
    for (int i = firstLine; i <= lastLine && lines.count > i; ++i)
        highlightIndexSize += 1 + ((NSString *) lines[i]).length;
    UInt8 *highlightIndexes = (UInt8 *) calloc(1, highlightIndexSize);
    
    // Get the line based highlights.
    int initialOffset = [self offsetFromLine: firstLine offset: 0];
    NSRange range = {initialOffset, highlightIndexSize};
    if (range.location + range.length > text.length)
        range.length = text.length - range.location;
    for (ColoredRange *coloredRange in [highlighter wordHighlights: text forRange: range])
        if (coloredRange.range.location < initialOffset + highlightIndexSize 
            && coloredRange.range.location + coloredRange.range.length > initialOffset)
        {
            int colorIndex = [self colorIndexForColor: coloredRange.color];
            int start = coloredRange.range.location < initialOffset ? 0 : coloredRange.range.location - initialOffset;
            int end = coloredRange.range.location + coloredRange.range.length > initialOffset + highlightIndexSize 
                ? highlightIndexSize 
                : coloredRange.range.location + coloredRange.range.length - initialOffset;
            for (int i = start; i < end; ++i)
                highlightIndexes[i] = colorIndex;
        }

    // Track multiline highlights through the visible text.
    for (ColoredRange *coloredRange in multilineHighlights)
        if (coloredRange.range.location < initialOffset + highlightIndexSize 
            && coloredRange.range.location + coloredRange.range.length > initialOffset)
        {
            int colorIndex = [self colorIndexForColor: coloredRange.color];
            int start = coloredRange.range.location < initialOffset ? 0 : coloredRange.range.location - initialOffset;
            int end = coloredRange.range.location + coloredRange.range.length > initialOffset + highlightIndexSize 
            	? highlightIndexSize 
            	: coloredRange.range.location + coloredRange.range.length - initialOffset;
            for (int i = start; i < end; ++i)
                highlightIndexes[i] = colorIndex;
        }
    
    
    // Draw the visible lines.
    float y = firstLine*font.lineHeight;
    
    int firstChar = self.contentOffset.x/charWidth;
    if (firstChar < 0)
        firstChar = 0;
    int maxChars = 1 + self.frame.size.width/charWidth;
    
    float x = firstChar*charWidth;
    
    int highlightIndex = 0;
    for (int i = firstLine; i < lastLine; ++i) {
        NSString *line = lines[i];
        if (line.length > firstChar) {
            line = [line substringFromIndex: firstChar];            
            if (line.length > maxChars)
                line = [line substringToIndex: maxChars];
            
            int index = 0;
            while (index < line.length) {
                int endIndex = index + 1;
                while (endIndex < line.length && highlightIndexes[highlightIndex + firstChar + endIndex] == highlightIndexes[highlightIndex + firstChar + index])
                    ++endIndex;
                NSRange colorRange = {index, endIndex - index};
                [[line substringWithRange: colorRange] drawAtPoint: CGPointMake(x + index*charWidth, y) 
                                                    withAttributes: attributes[highlightIndexes[highlightIndex + firstChar + index]]];
                index = endIndex;
            }
        }
        
        highlightIndex += 1 + ((NSString *) lines[i]).length;
        y += font.lineHeight;
    }
    
    free(highlightIndexes);
    
    // Draw the cursor.
    if (cursorState) {
        CGRect r = [self firstRectForRange: selectedRange];
        r.origin.x += self.contentOffset.x;
        r.origin.y += self.contentOffset.y;
        CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
        CGContextFillRect(context, r);
    }
}

#pragma mark - Scrolling and Selections

/*!
 * Return the first rectangle that encloses a range of text in a document.
 *
 * @param range			The range of text for which to return a rectangle.
 */

- (CGRect) firstRectForRange: (NSRange) range {
    NSArray *rects = [self selectionRectsForRange: range];
    return ((CodeRect *) rects[0]).rect;
}

/*!
 * Get the character offset in the text corresponding to a line and character offset within the line.
 *
 * @param line			The line index.
 * @param offset		The character index in the line. It is assumed the indicated line has this many characters.
 *
 * @return				The offset in the text of the indicatd character.
 */

- (int) offsetFromLine: (int) line offset: (int) offset {
    UInt16 *buffer = (UInt16 *) malloc(2*text.length);
    NSRange substringRange;
    substringRange.location = 0;
    substringRange.length = text.length;
    [text getBytes: buffer maxLength: 2*text.length usedLength: nil encoding: NSUnicodeStringEncoding options: 0 range: substringRange remainingRange: nil];
    // TODO: Make sure highlighter is returning proper offsets for characters past 16 bit characters.
    
    int textLine = 0;
    int i = 0;
    while (textLine < line)
        if (buffer[i++] == '\n')
            ++textLine;
    
    free(buffer);

    return i + offset;
}

/*!
 * Get the line and character positions corresponding to a text range.
 *
 * @param range			The text range.
 * @param line0			(output) The initial line index.
 * @param offset0		(output) The initial character index in the intial line.
 * @param line1			(output) The final line index.
 * @param offset1		(output) The final character index in the final line.
 */

- (void) offsetsFromRange: (NSRange) range line0: (int *) line0 offset0: (int *) offset0 line1: (int *) line1 offset1: (int *) offset1 {
    int offset = 0;
    int line = 0;
    int length = 2*(range.location + range.length);
    
    UInt16 *buffer = (UInt16 *) malloc(length);
    NSRange substringRange;
    substringRange.location = 0;
    substringRange.length = range.location + range.length;
    [text getBytes: buffer maxLength: length usedLength: nil encoding: NSUnicodeStringEncoding options: 0 range: substringRange remainingRange: nil];

    for (int i = 0; i < range.location; ++i) {
        if (buffer[i] == '\n') {
            ++line;
            offset = 0;
        } else
            ++offset;
    }
    
    *line0 = line;
    *offset0 = offset;
    
    for (int i = range.location; i < range.location + range.length; ++i) {
        if (buffer[i] == '\n') {
            ++line;
            offset = 0;
        } else
            ++offset;
    }
    
    free(buffer);
    *line1 = line;
    *offset1 = offset;
}

/*!
 * Scrolls the receiver until the text in the specified range is visible.
 *
 * @param range			The range of text to scroll into view.
 */

- (void) scrollRangeToVisible: (NSRange) range {
    printf("Implement scrollRangeToVisible\n"); // TODO: Implement
}

/*!
 * Get the rectangles that enclose a range.
 *
 * The returned array will contain one to three rectangles, depending on the number of lines the selection encompasses. If
 * the range has zero length, the rectangle will have a width of 1 and a location to the left of the indicated character.
 *
 * @param range			The range of text for which to fond the selection rectangles.
 *
 * @return				An array of one to three CodeRect objects.
 */

- (NSArray *) selectionRectsForRange: (NSRange) range {
    NSMutableArray *selectionRects = [[NSMutableArray alloc] init];
    
    int line0, line1, offset0, offset1;
    [self offsetsFromRange: range line0: &line0 offset0: &offset0 line1: &line1 offset1: &offset1];
    CGFloat x0 = offset0*charWidth;
    CGFloat y0 = line0*font.lineHeight;
    CGFloat x1 = offset1*charWidth;
    if (line0 == line1) {
        if (offset0 == offset1)
            x1 += 1;
        CodeRect *rect = [[CodeRect alloc] initWithX: x0 y: y0 width: x1 - x0 height: font.lineHeight];
        [selectionRects addObject: rect];
    } else if (line0 + 1 == line1) {
        CodeRect *rect = [[CodeRect alloc] initWithX: x0 y: y0 width: self.self.contentSize.width - x0 height: font.lineHeight];
        [selectionRects addObject: rect];
        if (offset1 > 0) {
            rect = [[CodeRect alloc] initWithX: 0 y: y0 + font.lineHeight width: x1 height: font.lineHeight];
            [selectionRects addObject: rect];
        }
    } else {
        CodeRect *rect = [[CodeRect alloc] initWithX: x0 y: y0 width: self.self.contentSize.width - x0 height: font.lineHeight];
        [selectionRects addObject: rect];
        CGFloat centerHeight = font.lineHeight*(line1 - line0 - 1);
        rect = [[CodeRect alloc] initWithX: 0 y: y0 + font.lineHeight width: self.self.contentSize.width height: centerHeight];
        [selectionRects addObject: rect];
        if (offset1 > 0) {
            rect = [[CodeRect alloc] initWithX: 0 y: y0 + font.lineHeight + centerHeight width: x1 height: font.lineHeight];
            [selectionRects addObject: rect];
        }
    }
    
    return selectionRects;
}

#pragma mark - UIResponder overrides

/*!
 * Returns a Boolean value indicating whether the receiver can become first responder.
 *
 * @return			Returns YES.
 */

- (BOOL) canBecomeFirstResponder {
    printf("canBecomeFirstResponder\n"); // TODO: Remove
    return YES;
}

- (BOOL)becomeFirstResponder {
    printf("becomeFirstResponder\n"); // TODO: Remove
    return [super becomeFirstResponder];
}

#pragma mark - UIScrollViewDelegate

/*!
 * Tells the delegate when the user scrolls the content view within the receiver.
 *
 * @param scrollView	The scroll-view object in which the scrolling occurred.
 */

- (void) scrollViewDidScroll: (UIScrollView *) scrollView {
    [self setNeedsDisplay];
}

@end
