//
//  TerminalOutputView.m
//  SpinIDE
//
//  Created by Mike Westerfield on 6/9/15.
//  Copyright (c) 2015 Parallax, Inc. All rights reserved.
//

#import "TerminalOutputView.h"

#import "CodeRect.h"


@interface TerminalOutputView () {
    float charWidth;						// Initial character width.
    float charHeight;						// Iniital line height.
    BOOL trackingScrolling;					// If YES, we are tracking a scroll via touch.
}

@property (nonatomic, retain) UIColor *localBackgroundColor;

@end


@implementation TerminalOutputView

@synthesize localBackgroundColor;
@synthesize scrollIndicatorColor;
@synthesize showScrollDownIndicator;
@synthesize showScrollLeftIndicator;
@synthesize showScrollRightIndicator;
@synthesize showScrollUpIndicator;

#pragma mark - Misc

/*!
 * Checks to see if characters were inserted beyond the visible range of the view. If so, the appropriate
 * scroll indicator is displayed.
 */

- (void) checkScrolling {
    NSRange range = {self.selectedRange.location, 0};
    if (range.location < self.text.length) {
        NSArray *rects = [self selectionRectsForRange: range];
        CGRect rect = ((CodeRect *) rects[0]).rect;
        if (rect.origin.x + rect.size.width < self.contentOffset.x)
            showScrollLeftIndicator = YES;
        if (rect.origin.x > self.contentOffset.x + self.bounds.size.width)
            showScrollRightIndicator = YES;
        if (rect.origin.y + rect.size.height < self.contentOffset.y)
            showScrollUpIndicator = YES;
        if (rect.origin.y > self.contentOffset.y + self.bounds.size.height)
            showScrollDownIndicator = YES;
    }
}

/*!
 * Do initializetion common to all initialization methods.
 */

- (void) initTerminalOutputViewCommon {
    [super setBackgroundColor: [UIColor clearColor]];
    self.localBackgroundColor = [UIColor whiteColor];
    self.scrollIndicatorColor = [UIColor lightGrayColor];
    
    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.font, NSFontAttributeName, 
                                    nil];
    charWidth = [@"W" sizeWithAttributes: fontAttributes].width;
    charHeight = self.font.lineHeight;
    
    showScrollDownIndicator = NO;
    showScrollLeftIndicator = NO;
    showScrollRightIndicator = NO;
    showScrollUpIndicator = NO;
}

#pragma mark - Getters & Setters

/*!
 * Set the background volor.
 *
 * @param theBackgroundColor	The new background color.
 */

- (void) setBackgroundColor: (UIColor *) theBackgroundColor {
    self.localBackgroundColor = theBackgroundColor;
}

/*
 * Specifies receiver’s frame rectangle in the super-layer’s coordinate space.
 *
 * @param frame			The new frame.
 */

- (void) setBounds: (CGRect) bounds {
    if (trackingScrolling) {
        if (self.bounds.origin.x < bounds.origin.x)
            showScrollRightIndicator = NO;
        if (self.bounds.origin.x > bounds.origin.x)
            showScrollLeftIndicator = NO;
        if (self.bounds.origin.y < bounds.origin.y)
            showScrollDownIndicator = NO;
        if (self.bounds.origin.y > bounds.origin.y)
            showScrollUpIndicator = NO;
    }
    [super setBounds: bounds];
}

/*!
 * The frame rectangle, which describes the view’s location and size in its superview’s coordinate system.
 *
 * @param frame			The new frame.
 */

- (void) setFrame: (CGRect) frame {
    showScrollDownIndicator = NO;
    showScrollLeftIndicator = NO;
    showScrollRightIndicator = NO;
    showScrollUpIndicator = NO;
    [super setFrame: frame];
}

/*!
 * Set the text contents for the view.
 *
 * @param theText		The new text contents.
 */

- (void) setText: (NSString *) theText {
    [super setText: theText];
    if (theText.length == 0) {
        showScrollDownIndicator = NO;
        showScrollLeftIndicator = NO;
        showScrollRightIndicator = NO;
        showScrollUpIndicator = NO;
    }
}

#pragma mark - UIView overrides

/*!
 * Draws the receiver’s image within the passed-in rectangle.
 *
 * @param rect			The portion of the view’s bounds that needs to be updated.
 */

- (void) drawRect: (CGRect) rect {
    // Draw the background.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self.localBackgroundColor CGColor]);
    CGContextFillRect(context, rect);
    
    // Draw any scroll indicators.
    CGContextSetFillColorWithColor(context, [self.scrollIndicatorColor CGColor]);
    CGContextSetStrokeColorWithColor(context, [self.scrollIndicatorColor CGColor]);
    if (showScrollDownIndicator) {
        float x = self.frame.size.width/2 + self.contentOffset.x;
        float y = self.frame.size.height - charHeight/2.0 + self.contentOffset.y;
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, x + 4*charWidth, y - 1.2*charHeight);
        CGContextAddLineToPoint(context, x - 4*charWidth, y - 1.2*charHeight);
        CGContextAddLineToPoint(context, x, y);
        CGContextFillPath(context);
        CGContextStrokePath(context);
    }
    if (showScrollLeftIndicator) {
        float x = charHeight/2.0 + self.contentOffset.x;
        float y = self.frame.size.height/2 + self.contentOffset.y;
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, x + 1.2*charHeight, y + 4*charWidth);
        CGContextAddLineToPoint(context, x + 1.2*charHeight, y - 4*charWidth);
        CGContextAddLineToPoint(context, x, y);
        CGContextFillPath(context);
        CGContextStrokePath(context);
    }
    if (showScrollRightIndicator) {
        float x = self.frame.size.width - charHeight/2.0 + self.contentOffset.x;
        float y = self.frame.size.height/2 + self.contentOffset.y;
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, x - 1.2*charHeight, y + 4*charWidth);
        CGContextAddLineToPoint(context, x - 1.2*charHeight, y - 4*charWidth);
        CGContextAddLineToPoint(context, x, y);
        CGContextFillPath(context);
        CGContextStrokePath(context);
    }
    if (showScrollUpIndicator) {
        float x = self.frame.size.width/2 + self.contentOffset.x;
        float y = charHeight/2.0 + self.contentOffset.y;
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, x + 4*charWidth, y + 1.2*charHeight);
        CGContextAddLineToPoint(context, x - 4*charWidth, y + 1.2*charHeight);
        CGContextAddLineToPoint(context, x, y);
        CGContextFillPath(context);
        CGContextStrokePath(context);
    }
    
    // Draw the text.
    [super drawRect: rect];
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
        [self initTerminalOutputViewCommon];
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
        [self initTerminalOutputViewCommon];
    }
    return self;
}

#pragma mark - UIKeyInput

/*!
 * Delete a character from the displayed text. (required)
 *
 * Remove the character just before the cursor from your class’s backing store and redisplay the text.
 */

- (void) deleteBackward {
    [super deleteBackward];
    [self checkScrolling];
}

/*!
 * Insert a character into the displayed text. (required)
 *
 * @param theText	A string object representing the character typed on the system keyboard.
 */

- (void) insertText: (NSString *) theText {
    [super insertText: theText];
    [self checkScrolling];
}

#pragma mark - UIScrollViewDelegate

/*!
 * Tells the delegate when the scroll view is about to start scrolling the content.
 *
 * The delegate might not receive this message until dragging has occurred over a small distance.
 *
 * @param scrollView	The scroll-view object that is about to scroll the content view.
 */

- (void) scrollViewWillBeginDragging: (UIScrollView *) scrollView {
    trackingScrolling = YES;
    [super scrollViewWillBeginDragging: scrollView];
}

- (void) scrollViewDidEndDragging: (UIScrollView *)scrollView willDecelerate: (BOOL)decelerate {
    trackingScrolling = NO;
}

@end
