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

#import <MobileCoreServices/UTCoreTypes.h>
#if IS_PARALLAX
#import "CHighlighter.h"
#else
#import "BASICHighlighter.h"
#endif
#import "CodeMagnifierView.h"
#import "CodeRect.h"
#import "CodeUndo.h"
#import "ColoredRange.h"
#if IS_PARALLAX
#import "SpinHighlighter.h"
#endif


#define LOLLIPOP_TOUCH_SIZE (20)								/* Radius of the lollipop touch area. */
#define LOLLIPOP_SIZE (5)										/* Radius of the lollipop candy - 0.5. */
#define DEFAULT_INDENT (2)										/* The number of characters to use for indented code. */
#define MAGNIFIER_SIZE (150)									/* The diameter of the magnifier in pixels. Change art if this is not 150. */
#define MAGNIFIER_TIME (0.5)									/* The number of seconds the touch must be still to start a magnifier tracking session. */
#define MIN_FONT_SIZE (8.0)										/* The mimiumum font size in points. */
#define MAX_FONT_SIZE (20.0)									/* The maxiumum font size in points. */


@interface CodeView () {
    float charWidth;											// The width of a character.
    int cursorColumn;											// The column index for the cursor for the most recent up or down arrow key, or -1 for other keys.
    int cursorState;											// A value form 0 to 2 indicating if the cursor is on or off. 0 is off.
    BOOL firstTap;												// Used to track the first tap at a new selection location.
    int repeatKeyStartCounter;									// A count down timer so the repeat key does not start too fast.
    
    BOOL firstLollipop;											// If trackingSelection, YES for the initial selection mark, or NO for the end selection mark.
    BOOL hardwareKeyboard;										// Have we detected the use of a hardware keyboard?
    NSRange initialRange;										// selectedRange when the drag selection or shift selection started.
    float keyboardWillShowDelta;								// The size of the keyboard when it was last shown.
    float pinchStartFontSize;									// The font size at the start of a pinch gensture.
    float pinchStartDistance;									// Separation distance in points at the start of a pinch gensture.
    CGPoint touchScrollLocation;								// The location of the most recent touch movement.
    BOOL trackingMagnifier;										// YES if we are currently tracking the magnifier.
    BOOL trackingPinch;											// YES if we are currently tracking a pinch operation, else NO.
    BOOL trackingSelection;										// YES if we are currently tracking dragging to change a selection, else NO.
    BOOL trackingTouchScroll;									// YES if tracking a scroll operation with a stationary touch, else NO.
}

@property (nonatomic, retain) Highlighter *highlighter;			// The current code highlighter.
@property (nonatomic, retain) NSArray *backgroundHighlights;	// Array of ColoredRange objects indicating ranges of text backgrounds to highlight.
@property (nonatomic, retain) NSTimer *cursorTimer;				// A timer used to bling the cursor.
@property (nonatomic, retain) NSArray *lines;					// The text content, broken up into lines.
@property (nonatomic, retain) UITouch *magnifierTouch;			// The touch down when we started looking for a magnifier tracking session.
@property (nonatomic, retain) NSTimer *magnifierTimer;			// A timer used to look for the start of a magnifier tracking session.
@property (nonatomic, retain) UIView *magnifierView;			// The magnifier view, if any.
@property (nonatomic, retain) NSArray *multilineHighlights;		// Array of ColoredRange objects indicating ranges of text to highlight.
@property (nonatomic, retain) NSArray *theKeyCommands;			// The key commands supported by this editor.
@property (nonatomic, retain) NSArray *selectionRects;			// The current selection rectangles. Valid only if selectedRange.length > 0.

@property (nonatomic, retain) UIKeyCommand *repeatKeyCommand;	// The key for a repeat key timer to repeat.
@property (nonatomic, retain) NSTimer *repeatKeyTimer;			// A timer used to implement repeat keys.

@property (nonatomic, retain) NSMutableArray *attributes;		// The attributes used to draw text. Indexes match colors.
@property (nonatomic, retain) NSMutableArray *colors;			// The colors used to highlight text. Indexes match attributes.

@property(nonatomic, retain) NSTimer *touchScrollTimer;			// Timer for repeating touch scroll events.

@end


@implementation CodeView

@synthesize allowEditMenu;
@synthesize attributes;
@synthesize backgroundHighlights;
@synthesize codeViewDelegate;
@synthesize colors;
@synthesize cursorTimer;
@synthesize editable;
@synthesize followIndentation;
@synthesize font;
@synthesize highlighter;
@synthesize indentCharacters;
@synthesize inputAccessoryView;
@synthesize language;
@synthesize lines;
@synthesize magnifierTouch;
@synthesize magnifierTimer;
@synthesize magnifierView;
@synthesize multilineHighlights;
@synthesize repeatKeyCommand;
@synthesize repeatKeyTimer;
@synthesize selectedRange;
@synthesize selectionRects;
@synthesize text;
@synthesize theKeyCommands;
@synthesize touchScrollTimer;
@synthesize undoManager;
@synthesize useSyntaxColoring;

@synthesize autocapitalizationType;
@synthesize autocorrectionType;
@synthesize spellCheckingType;
@synthesize enablesReturnKeyAutomatically;
@synthesize keyboardAppearance;
@synthesize keyboardType;
@synthesize returnKeyType;
@synthesize secureTextEntry;

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
    // We use a numeric cursor state. 0 means the cursor is off. 1 means it was just turned on. 2 means it has been on for 
    // a cycle, but is still on. Cycling through these states with a timer gives a cursor that spends 2/3 of its time on 
    // and 1/3 off.
    
    // We don't need to blink the cursor if there is a selection and the cursor is already off.
    if (!(cursorState == 0 && selectedRange.length > 0)) {
        // We don't need to blink the cursor if we are not the first responder and the cursor is off.
        if ([self isFirstResponder] || cursorState != 0) {
            // Determine the new state of the cursor.
            if (selectedRange.length > 0)
                cursorState = 0;
            else
                cursorState = (cursorState + 1)%3;
            
            if (cursorState != 2) {
                // Find the update rectangle.
                CGRect r = [self firstRectForRange: selectedRange];
                
                // If the rectangle is visible in the view, update the rectangle's area.
                CGRect visibleRect = self.bounds;
                if (CGRectContainsRect(visibleRect, r)) {
                    [self setNeedsDisplayInRect: r];
                }
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
        colorIndex = (int) colors.count;
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
 * Temporarily turns the cursor blink timer off and cycles the cursor until it is off.
 *
 * This is used to rest the curosr position. Call cursorOn when the position has been updated.
 */

- (void) cursorOff {
    [cursorTimer invalidate];
    cursorTimer = nil;
    while (cursorState)
        [self blinkCursor: nil];
}

/*!
 * Turn the cursor on. (It will not flash unless this object is the first responder and the selection has zero length.)
 *
 * See cursorOff.
 */

- (void) cursorOn {
    [self initCursorTimer];
}

/*!
 * Turn the cursor on and cycle the timer until it is visible.
 *
 * See cursorOff.
 */

- (void) cursorVisible {
    [self initCursorTimer];
    int maxCount = 6;
    while (cursorState == 0 && selectedRange.length == 0 && --maxCount > 0)
        [self blinkCursor: nil];
}

/*!
 * For each line marked by the current selection, add indentCharacter spaces to the start of the line.
 */

- (void) doIndent {
    [self cursorOff];

    // Save the selection for redo.
    CodeUndo *undoObject = [CodeUndo undoSelection: selectedRange];
    [undoManager registerUndoWithTarget: self selector: @selector(undo:) object: undoObject];
    
    // Form a string with the appropriate number of spaces.
    NSString *indentString = @"";
    for (int i = 0; i < indentCharacters; ++i)
        indentString = [indentString stringByAppendingString: @" "];
    
    // Back up to the start of the selected line.
    int location = (int) selectedRange.location;
    while (location > 0 && [text characterAtIndex: location - 1] != '\n')
        --location;
    
    // While we are not at the end of the selection, insert spaces and move to the next line.
    while (location < text.length && location <= selectedRange.location + selectedRange.length) {
        NSRange oldRange = selectedRange;
        selectedRange.location = location;
        selectedRange.length = 0;
        
        [self insertText: indentString];
        
        if (location < oldRange.location)
            oldRange.location += indentCharacters;
        else if (location < oldRange.location + oldRange.length)
            oldRange.length += indentCharacters;
        selectedRange = oldRange;
        
        while (location < text.length && location < selectedRange.location + selectedRange.length && [text characterAtIndex: location] != '\n')
            ++location;
        if (location < text.length)
            ++location;
    }
    
    [self selectionChanged];
    [self cursorOn];
    [self setNeedsDisplay];
}

/*!
 * For each line marked by the current selection, remove indentCharacter spaces to the start of the line. If there are not
 * indentCharacter spaces at the start of the line, remove any that are there.
 */

- (void) doOutdent {
    [self cursorOff];
    
    // Save the selection for redo.
    CodeUndo *undoObject = [CodeUndo undoSelection: selectedRange];
    [undoManager registerUndoWithTarget: self selector: @selector(undo:) object: undoObject];
    
    // Back up to the start of the selected line.
    int location = (int) selectedRange.location;
    while (location > 0 && [text characterAtIndex: location - 1] != '\n')
        --location;
    
    // While we are not at the end of the selection, remove spaces and move to the next line.
    while (location < text.length && location <= selectedRange.location + selectedRange.length) {
        NSRange oldRange = selectedRange;
        selectedRange.location = location;
        
        int removed = 0;
        while (removed < indentCharacters && location < text.length && [text characterAtIndex: location] == ' ') {
            ++removed;
            ++selectedRange.location;
        }
        selectedRange.location -= removed;
        selectedRange.length = removed;
        [self insertText: @""];
        
        if (location < oldRange.location)
            oldRange.location -= removed;
        else if (location < oldRange.location + oldRange.length)
            oldRange.length -= removed;
        selectedRange = oldRange;
        
        while (location < text.length && location < selectedRange.location + selectedRange.length && [text characterAtIndex: location] != '\n')
            ++location;
        if (location < text.length)
            ++location;
    }
    
    [self selectionChanged];
    [self cursorOn];
    [self setNeedsDisplay];
}

/*!
 * Handle a low memory situation.
 *
 * THis method dumps the undo buffer.
 */

- (void) didReceiveMemoryWarning {
    [undoManager removeAllActions];
}

/*!
 * Find the distance between two touches in points.
 *
 * @param touches		The touches. There must be at least two, preferably exactly two.
 */

- (float) distanceBetweenTouches: (NSSet *) touches {
    int index = 0;
    CGPoint location0, location1;
    for (UITouch *touch in touches) {
        if (index == 0)
            location0 = [touch locationInView: self];
        else
            location1 = [touch locationInView: self];
        ++index;
    }
    float dx = location0.x - location1.x;
    float dy = location0.y - location1.y;
    return sqrtf(dx*dx + dy*dy);
}

/*!
 * Draw a selection lollipop.
 *
 * @param context		The context in which to draw.
 * @param r				The rectangle defining the stem of the lollipop.
 * @param rightSideUp	Yes to draw the candy at the top of the stem, or NO to draw it at the bottom.
 */

- (void) drawLollipopWithContext: (CGContextRef) context at: (CGRect) r rightSideUp: (BOOL) rightSideUp {
    // Set the lollipop color.
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed: 20.0/255.0 green: 111.0/255.0 blue: 225.0/255.0 alpha: 1.0] CGColor]);
    
    // Draw the stem.
    CGContextFillRect(context, r);
    
    // Draw the candy.
    r.origin.x -= LOLLIPOP_SIZE;
    r.size.width = 2*LOLLIPOP_SIZE + 1;
    if (rightSideUp)
        r.origin.y -= 2*LOLLIPOP_SIZE + 1;
    else
        r.origin.y += r.size.height;
    r.size.height = 2*LOLLIPOP_SIZE + 1;
    CGContextFillEllipseInRect(context, r);
}

/*!
 * Starting at a given location in the text, find the end of the current token.
 *
 * Tokens are identifiers or numbers. Any character that cannot be in an identifier or token is skipped
 * until the first qualifying character is found.
 *
 * This method implements a reasonable approximation suitable for editing when some tokens may not be 
 * well formed.
 *
 * @param offset	The offset in the text of the first character to check.
 *
 * @return			The offset of the first character past the token, or the end of the file.
 */

- (int) endOfToken: (int) offset {
    if (offset < text.length) {
        char ch = [text characterAtIndex: offset];
        while (offset < text.length && ![self istoken: ch]) {
            ++offset;
            if (offset < text.length)
	            ch = [text characterAtIndex: offset];
        }
    }
    
    BOOL done = NO;
    BOOL scanningNumber = NO;
    BOOL scanningIdentifier = NO;
    while (!done && offset < text.length) {
        char ch = [text characterAtIndex: offset];
        if (scanningIdentifier || isalpha(ch)) {
            // We're scanning an identifier. Scan to the first character that cannot be a part of
            // an identifier.
            while (offset < text.length && !done) {
                ++offset;
                ch = [text characterAtIndex: offset];
                done = !(isalnum(ch) || ch == '_');
            }
        } else if (ch == '-' || ch == '+' || ch == '.' || scanningNumber) {
            // A sign character or decimal point unabiguously identifies a number.
            
            // Skip any leading sign.
            if ((ch == '+' || ch == '-') && offset < text.length) {
                ++offset;
                ch = [text characterAtIndex: offset];
            }
            // Skip any run of digits or '_' up to a possible decimal point.
            while (offset < text.length && [self isspindigit: [text characterAtIndex: offset]])
                ++offset;
            // Skip any decimal point.
            if (offset < text.length && [text characterAtIndex: offset] == '.')
                ++offset;
            // Skip any run of digits or '_' up to a possible exponent.
            while (offset < text.length && [self isspindigit: [text characterAtIndex: offset]])
                ++offset;
            // Skip any exponent.
            if (offset < text.length && tolower([text characterAtIndex: offset])) {
                ++offset;
                // Skip any sign in the exponent.
                if (offset < text.length)
                    ch = [text characterAtIndex: offset];
                else
                    ch = ' ';
                if ((ch == '+' || ch == '-') && offset < text.length) {
                    ++offset;
                    // Skip any digits in the exponent.
                    while (offset < text.length && isnumber([text characterAtIndex: offset]))
                        ++offset;
                }
            }
            done = YES;
        } else if ([self isspindigit: ch]) {
            // These characters are ambiguous ('_' due to spin). Just skip it.
            ++offset;
        } else if (tolower(ch) == 'e') {
            // This could be the exponent in a number or part of an identifier. Skip right if the
            // previous character can be part of an identifier, then continue scanning.
            ++offset;
            if (offset < text.length) {
                ch = [text characterAtIndex: offset];
                while (offset < text.length && [self isspindigit: [text characterAtIndex: offset]]) {
                    ++offset;
                    ch = [text characterAtIndex: offset];
                }
                if (isalpha(ch))
                    scanningIdentifier = YES;
                else if (ch == '-' || ch == '+' || ch == '.')
                    scanningNumber = YES;
                else {
                    ++offset;
                    done = YES;
                }
            }
        } else
            done = YES;
    }
    return offset;
}

/*!
 * Gets the location of the end of the selection (i.e. the other end from the anchor) from which 
 * selections are extended using the shift key.
 *
 * @return				The tail point for the extension.
 */

- (int) extendSelectionTailLocation {
    if (selectedRange.length == 0)
        return (int) selectedRange.location;
    if (selectedRange.location == initialRange.location)
        return (int) (selectedRange.location + selectedRange.length);
    return (int) selectedRange.location;
}

/*!
 * Gets the range of the end of the selection (i.e. the other end from the anchor) from which 
 * selections are extended using the shift key.
 *
 * @return				The pivot range for the extension.
 */

- (NSRange) extendSelectionTailRange {
    NSRange range;
    range.location = [self extendSelectionTailLocation];
    range.length = 0;
    return range;
}

/*!
 * Extend the selection to a new text offset.
 *
 * @param offset		The offset in the text to which to extend the selection.
 */

- (void) extendSelectionTo: (int) offset {
    // Remember or use the initial anchor point.
    if (selectedRange.length == 0)
        initialRange = selectedRange;
    else
        selectedRange.location = initialRange.location;
    
    // Extend the selection.
    if (offset < selectedRange.location) {
        selectedRange.length = selectedRange.location - offset;
        selectedRange.location = offset;
    } else
        selectedRange.length = offset - selectedRange.location;

    [self selectionChanged];
}

/*!
 * Do initializetion common to all initialization methods.
 */

- (void) initCodeViewCommon {
    // Iniitalize the various fields.
    self.text = @"";
    selectedRange.location = 0;
    selectedRange.length = 0;
    self.font = [UIFont fontWithName: @"Menlo-Regular" size: 13];
    self.language = languageSpin;
    self.editable = YES;
#if IS_PARALLAX
    self.highlighter = [[SpinHighlighter alloc] init];
#else
    self.highlighter = [[BASICHighlighter alloc] init];
#endif
    self.delegate = self;
    [self initCursorTimer];
    self.undoManager = [[CodeUndoManager alloc] init];
    undoManager.groupsByEvent = NO;
    self.indentCharacters = DEFAULT_INDENT;
    self.followIndentation = YES;
    
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.spellCheckingType = UITextSpellCheckingTypeNo;
    self.enablesReturnKeyAutomatically = NO;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    self.secureTextEntry = NO;
    
    self.allowEditMenu = YES;
    
    // Register for keyboard notifications.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification object: nil];
}

/*!
 * Set up the cursor timer.
 */

- (void) initCursorTimer {
    if (cursorTimer == nil)
        self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval: 0.333
                                                            target: self
                                                          selector: @selector(blinkCursor:)
                                                          userInfo: nil
                                                           repeats: YES];
}

/*!
 * See if a character can be part of a token as defined for scanning for option left or right arrow.
 *
 * @param ch		The character to check.
 *
 * @return			YES if the character can be part of a token, else NO.
 */

- (BOOL) istoken: (int) ch {
    return isalnum(ch) || ch == '+' || ch == '-' || ch == '_' || ch == '.';
}

/*!
 * See if a character is a numeric digit, including the spin '_' character.
 *
 * @param ch		The character to check.
 *
 * @return			YES if the character is a digit, else NO.
 */

- (BOOL) isspindigit: (int) ch {
    return isnumber(ch) || ch == '_';
}

/*!
 * Called when the keyboard is about to be hidden.
 *
 * We check to see if the hide is because the hardware keyboard has become active. If so, the keyboard
 * will still appear with the accessory view. We turn that off and reshow the keyboard.
 *
 * @param notification			Keyborad notificaiton information.
 */

- (void) keyboardWillHide: (NSNotification *) notification {
    if (self.isFirstResponder) {
    NSDictionary *info = [notification userInfo];
    
    NSValue *keyboardFrameBegin = [info valueForKey: UIKeyboardFrameBeginUserInfoKey];
    CGRect frameBeginRect;
    [keyboardFrameBegin getValue: &frameBeginRect];
    NSValue *keyboardFrameEnd = [info valueForKey: UIKeyboardFrameEndUserInfoKey];
    CGRect frameEndRect;
    [keyboardFrameEnd getValue: &frameEndRect];
    
    float delta = fabs(frameBeginRect.origin.y - frameEndRect.origin.y);
    if (fabs(keyboardWillShowDelta - delta) == PREFERRED_ACCESSORY_HEIGHT && !hardwareKeyboard) {
        hardwareKeyboard = YES;
        [self resignFirstResponder];
        [self becomeFirstResponder];
    }
}
}

/*!
 * Called when the keyboard is about to be shown.
 *
 * The keyboard can show because it is needed or becuase a hardware keyboard is in use, in which case the 
 * O/S still tries to show the accessory view. We check to see which is happening and reshow the keyboard
 * without the accessory view if a hardware keyboard is in use, or with it if we've jsut switched to a
 * software keyboard.
 *
 * @param notification			Keyborad notificaiton information.
 */

- (void) keyboardWillShow: (NSNotification *) notification {
    if (self.isFirstResponder) {
    NSDictionary *info = [notification userInfo];
    
    NSValue *keyboardFrameBegin = [info valueForKey: UIKeyboardFrameBeginUserInfoKey];
    CGRect frameBeginRect;
    [keyboardFrameBegin getValue: &frameBeginRect];
    NSValue *keyboardFrameEnd = [info valueForKey: UIKeyboardFrameEndUserInfoKey];
    CGRect frameEndRect;
    [keyboardFrameEnd getValue: &frameEndRect];
    
    keyboardWillShowDelta = fabs(frameBeginRect.origin.y - frameEndRect.origin.y);
    
    if (keyboardWillShowDelta == PREFERRED_ACCESSORY_HEIGHT) {
        if (!hardwareKeyboard) {
            hardwareKeyboard = YES;
            [self resignFirstResponder];
            [self becomeFirstResponder];
        }
    } else if (hardwareKeyboard) {
        hardwareKeyboard = NO;
        [self resignFirstResponder];
        [self becomeFirstResponder];
    }
}
}

/*!
 * Handle typing a special character from a Bluetooth keyboard.
 *
 * @param command		The keycommand to handle.
 */

- (void) keyCommand: (UIKeyCommand *) command {
    // Start a repeat key timer.
    if (repeatKeyTimer == nil) {
        repeatKeyStartCounter = 5;
        self.repeatKeyCommand = command;
        self.repeatKeyTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                               target: self
                                                             selector: @selector(repeatKey:)
                                                             userInfo: nil
                                                              repeats: YES];
    }
    
//    for (int i = 0; i < command.input.length; ++i) printf("%02X ", [command.input characterAtIndex: i]); putchar('\n');
    BOOL needsDisplay = selectedRange.length > 0;
    
    if ([command.input isEqualToString: UIKeyInputDownArrow]) {
        if (command.modifierFlags & UIKeyModifierCommand) {
            // Move to the end of the file.
            [self cursorOff];
            if (command.modifierFlags & UIKeyModifierShift)
                [self extendSelectionTo: (int) text.length];
            else {
                selectedRange.location = text.length;
                selectedRange.length = 0;
                [self selectionChanged];
            }
            [self cursorVisible];
        } else if (command.modifierFlags & UIKeyModifierAlternate) {
            // Move to the end of the current line, or the next one if we are already at the end of a line.
            [self cursorOff];
            int location = [self extendSelectionTailLocation];
            if (location < text.length) {
                ++location;
                while (location < text.length && [text characterAtIndex: location] != '\n')
                    ++location;
            }
            if (command.modifierFlags & UIKeyModifierShift)
                [self extendSelectionTo: location];
            else {
                selectedRange.location = location;
                selectedRange.length = 0;
                [self selectionChanged];
            }
            [self cursorVisible];
        } else if (selectedRange.location < text.length || selectedRange.length > 0) {
            // Move down one line, maintaining the column from the original up or down move if possible.
            int line, offset;
            [self offsetsFromRange: [self extendSelectionTailRange] line0: &line offset0: &offset line1: nil offset1: nil];
            
            if (cursorColumn == -1)
                cursorColumn = offset;
            
            [self cursorOff];
            if (command.modifierFlags & UIKeyModifierShift)
                [self extendSelectionTo: [self offsetToLine: line + 1 column: cursorColumn]];
            else {
                if (selectedRange.length == 0)
                    selectedRange.location = [self offsetToLine: line + 1 column: cursorColumn];
                else {
                    selectedRange.location += selectedRange.length;
                    selectedRange.length = 0;
                }
                [self selectionChanged];
            }
            [self cursorVisible];
        }
        
        // Scroll to the end of the selected range.
        NSRange range = selectedRange;
        range.location += range.length;
        range.length = 0;
        [self scrollRangeToVisible: range];
        
        // Show the edit menu at the end of the selected range.
        if (selectedRange.length > 0)
	        [self showEditMenu: [self lastRectForRange: selectedRange]];
        else
            [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
        
        // Start a new undo group.
        [undoManager beginNewUndoGroup];
    } else if ([command.input isEqualToString: UIKeyInputLeftArrow]) {
        if (command.modifierFlags & UIKeyModifierCommand) {
            // Move to the start of the current line.
            [self cursorOff];
            int location = [self extendSelectionTailLocation];
            while (location > 0 && [text characterAtIndex: location - 1] != '\n')
            	--location;
            if (command.modifierFlags & UIKeyModifierShift)
                [self extendSelectionTo: location];
            else {
                selectedRange.location = location;
                selectedRange.length = 0;
                [self selectionChanged];
            }
            [self cursorVisible];
            [self scrollRangeToVisible: selectedRange];
        } else if (command.modifierFlags & UIKeyModifierAlternate) {
            // Move to the start of the previous identifier or number.
            [self cursorOff];
            int location = [self extendSelectionTailLocation];
            if (location > 0)
                --location;
            location = [self previousToken: location];
            if (command.modifierFlags & UIKeyModifierShift)
                [self extendSelectionTo: location];
            else {
                selectedRange.location = location;
                selectedRange.length = 0;
                [self selectionChanged];
            }
            [self cursorVisible];
            [self scrollRangeToVisible: selectedRange];
        } else if (selectedRange.location > 0 || selectedRange.length > 0) {
            // Move left one character.
        	[self cursorOff];
            if (command.modifierFlags & UIKeyModifierShift) {
                if ([self extendSelectionTailLocation] > 0)
                    [self extendSelectionTo: [self extendSelectionTailLocation] - 1];
            } else {
                if (selectedRange.length > 0)
                    selectedRange.length = 0;
                else {
                    if (selectedRange.location > 0)
                        --selectedRange.location;
                }
                [self cursorVisible];
            }
            
            cursorColumn = -1;
            
            // Scroll to the start of the selected range.
            [self scrollRangeToVisible: selectedRange];
            
            // Show the edit menu at the start of the selected range.
            if (selectedRange.length > 0)
                [self showEditMenu: [self firstRectForRange: selectedRange]];
            else
                [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
        }
        
        // Start a new undo group.
        [undoManager beginNewUndoGroup];
    } else if ([command.input isEqualToString: UIKeyInputRightArrow]) {
        if (command.modifierFlags & UIKeyModifierCommand) {
            [self cursorOff];
            int location = [self extendSelectionTailLocation];
            while (location < text.length && [text characterAtIndex: location] != '\n')
                ++location;
            if (command.modifierFlags & UIKeyModifierShift)
                [self extendSelectionTo: location];
            else {
                selectedRange.location = location;
                selectedRange.length = 0;
                [self selectionChanged];
            }
            [self cursorVisible];
        } else if (command.modifierFlags & UIKeyModifierAlternate) {
            // Move to the start of the end of the current identifier or number or the end of hte next one if we are not on one.
            [self cursorOff];
            int location = [self extendSelectionTailLocation];
            if (location < text.length)
                ++location;
            location = [self endOfToken: location];
            if (command.modifierFlags & UIKeyModifierShift)
                [self extendSelectionTo: location];
            else {
                selectedRange.location = location;
                selectedRange.length = 0;
                [self selectionChanged];
            }
            [self cursorVisible];
        } else if (selectedRange.location < text.length || selectedRange.length > 0) {
            [self cursorOff];
            if (command.modifierFlags & UIKeyModifierShift) {
                if ([self extendSelectionTailLocation] < text.length)
                    [self extendSelectionTo: [self extendSelectionTailLocation] + 1];
            } else {
                if (selectedRange.length > 0) {
                    selectedRange.location += selectedRange.length;
                    selectedRange.length = 0;
                } else {
                    if (selectedRange.location < text.length)
	                    ++selectedRange.location;
                }
            }
            [self cursorVisible];
            
            cursorColumn = -1;
        }
        
        // Scroll to the end of the selected range.
        NSRange range = selectedRange;
        range.location += range.length;
        range.length = 0;
        [self scrollRangeToVisible: range];
        
        // Show the edit menu at the end of the selected range.
        if (selectedRange.length > 0)
            [self showEditMenu: [self lastRectForRange: selectedRange]];
        else
            [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
        
        // Start a new undo group.
        [undoManager beginNewUndoGroup];
    } else if ([command.input isEqualToString: UIKeyInputUpArrow]) {
        if (command.modifierFlags & UIKeyModifierCommand) {
            [self cursorOff];
            if (command.modifierFlags & UIKeyModifierShift) {
                [self extendSelectionTo: 0];
            } else {
                selectedRange.location = 0;
                selectedRange.length = 0;
                [self selectionChanged];
            }
            [self cursorVisible];
            [self scrollRangeToVisible: selectedRange];
        } else if (command.modifierFlags & UIKeyModifierAlternate) {
            // Move to the start of the current line, or the previous one if we are already at the start of a line.
            [self cursorOff];
            int location = [self extendSelectionTailLocation];
            if (location > 0) {
                --location;
                while (location > 0 && [text characterAtIndex: location - 1] != '\n')
                    --location;
            }
            if (command.modifierFlags & UIKeyModifierShift) {
                [self extendSelectionTo: location];
            } else {
                selectedRange.location = location;
                selectedRange.length = 0;
                [self selectionChanged];
            }
            [self cursorVisible];
            [self scrollRangeToVisible: selectedRange];
        } else if (selectedRange.location > 0 || selectedRange.length > 0) {
            int line, offset;
            [self offsetsFromRange: [self extendSelectionTailRange] line0: &line offset0: &offset line1: nil offset1: nil];
            
            if (line > 0) {
                if (cursorColumn == -1)
                    cursorColumn = offset;
                
                [self cursorOff];
                if (command.modifierFlags & UIKeyModifierShift) {
                    [self extendSelectionTo: [self offsetToLine: line - 1 column: cursorColumn]];
                } else {
                    selectedRange.location = [self offsetToLine: line - 1 column: cursorColumn];
                    selectedRange.length = 0;
                    [self selectionChanged];
                }
                [self cursorVisible];
            }
            
            // Scroll to the start of the selected range.
            [self scrollRangeToVisible: selectedRange];
            
            // Show the edit menu at the start of the selected range.
            if (selectedRange.length > 0)
                [self showEditMenu: [self firstRectForRange: selectedRange]];
            else
                [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
        }
        
        // Start a new undo group.
        [undoManager beginNewUndoGroup];
    } else if ([command.input isEqualToString: @"f"]) {
        if ([codeViewDelegate respondsToSelector: @selector(codeViewFind)])
            [codeViewDelegate codeViewFind];
    } else if ([command.input isEqualToString: @"g"]) {
        if (command.modifierFlags & UIKeyModifierShift) {
            if ([codeViewDelegate respondsToSelector: @selector(codeViewFindPrevious)])
                [codeViewDelegate codeViewFindPrevious];
        } else {
            if ([codeViewDelegate respondsToSelector: @selector(codeViewFindNext)])
                [codeViewDelegate codeViewFindNext];
        }
    } else if ([command.input isEqualToString: @"]"]) {
        [undoManager beginNewUndoGroup];
        [self doIndent];
        [undoManager beginNewUndoGroup];
    } else if ([command.input isEqualToString: @"["]) {
        [undoManager beginNewUndoGroup];
        [self doOutdent];
        [undoManager beginNewUndoGroup];
    }
    
    // Turn off the edit menu.
    [UIMenuController sharedMenuController].menuVisible = NO;
    
    // Update the view.
    if (selectedRange.length > 0 || needsDisplay) {
        [self setNeedsDisplay];
        if (selectedRange.length == 0)
            [self cursorVisible];
    }
}

/*!
 * Starting at a given location in the text, find the start of the previoius token.
 *
 * Tokens are identifiers or numbers. Any character that cannot be in an identifier or token is skipped
 * until the first qualifying character is found.
 *
 * This method implements a reasonable approximation suitable for editing when some tokens may not be 
 * well formed.
 *
 * @param offset	The offset in the text of the first character to check.
 *
 * @return			The offset of the first character in the token, or the start of the file.
 */

- (int) previousToken: (int) offset {
    char ch = [text characterAtIndex: offset];
    while (offset > 0 && ![self istoken: ch]) {
        --offset;
        ch = [text characterAtIndex: offset];
    }
    
    BOOL done = NO;
    BOOL scanningNumber = NO;
    BOOL scanningIdentifier = NO;
    while (!done && offset > 0) {
        if (scanningIdentifier || isalpha(ch)) {
            // We're scanning an identifier. Skip back to the first character that can be a part of
            // an identifier.
            while (offset > 0 && !done) {
                ch = [text characterAtIndex: offset - 1];
                if (isalnum(ch) || ch == '_')
                    --offset;
                else
                    done = YES;
            }
        } else if (ch == '-' || ch == '+' || ch == '.' || scanningNumber) {
            // A sign character or decimal point unabiguously identifies a number.
            if ((ch == '+' || ch == '-') && offset > 1 && tolower([text characterAtIndex: offset - 1]) == 'e') {
                // We found a signt and exponent. Skip both.
                offset -= 2;
                ch = [text characterAtIndex: offset];
            }
            // Skip any run of digits or '_' up to a possible decimal point.
            while (offset > 0 && [self isspindigit: [text characterAtIndex: offset - 1]])
                --offset;
            // Skip any decimal point.
            if (offset > 0 && [text characterAtIndex: offset - 1] == '.')
                --offset;
            // Skip any run of digits or '_' up to a possible leading sign.
            while (offset > 0 && [self isspindigit: [text characterAtIndex: offset - 1]])
                --offset;
            // Skip any leading sign.
            ch = [text characterAtIndex: offset];
            if ((ch == '-' || ch == '+') && offset > 0)
                --offset;
            done = YES;
        } else if ([self isspindigit: ch]) {
            // These characters are ambiguous ('_' due to spin). As long as the previous character can be
            // part of a token, just skip it.
            if ([self istoken: [text characterAtIndex: offset - 1]])
            	--offset;
            else
                done = YES;
            ch = [text characterAtIndex: offset];
        } else if (tolower(ch) == 'e') {
            // This could be the exponent in a number or part of an identifier. Skip left if the
            // previous character can be part of an identifier, then continue scanning.
            --offset;
            ch = [text characterAtIndex: offset];
            while (isnumber(ch) && offset > 0) {
                --offset;
                ch = [text characterAtIndex: offset];
            }
            if (isalpha(ch))
                scanningIdentifier = YES;
            else if (ch == '-' || ch == '+' || ch == '.')
                scanningNumber = YES;
            else {
                ++offset;
                done = YES;
            }
        } else
            done = YES;
    }
    return offset;
}

/*!
 * Remove all actions from the undo buffer.
 */

- (void) purgeUndoBuffer {
    [undoManager removeAllActions];
}

/*!
 * Handle a repeat key.
 *
 * This method periodically repeats the effect of the most recently typed character.
 *
 * @param timer		The timer that fired this action.
 */

- (void) repeatKey: (NSTimer *) timer {
    if (repeatKeyStartCounter == 0)
        [self keyCommand: repeatKeyCommand];
    else
        --repeatKeyStartCounter;
}

/*!
 * Replace text with new text.
 *
 * Upon completion, the selected range will be a zero length selection after the new text.
 *
 * @param range			The range of text to replace. This must be a valid range for the current
 *						text.
 * @param theText		The new text.
 */

- (void) replaceRange: (NSRange) range withText: (NSString *) theText {
    self.selectedRange = range;
    [self insertText: theText];
}

/*!
 * Call when the selection changes to notify delegates and update the code completion buttons.
 */

- (void) selectionChanged {
    if ([codeViewDelegate respondsToSelector: @selector(codeViewDidChangeSelection:)])
        [codeViewDelegate codeViewDidChangeSelection: self];
    [inputAccessoryView setContext: text selection: selectedRange];
}

/*!
 * Set the selection range without starting a new undo group.
 *
 * @param range		The new selection range.
 */

- (void) setSelectedRangeNoUndoGroup: (NSRange) range {
    [self cursorOff];
    selectedRange = range;
    [self cursorOn];
    [self setNeedsDisplay];
    cursorColumn = -1;
    [self selectionChanged];
}

/*!
 * Show the edit menu.
 *
 * @param r				The display rectangle where the menu will be shown.
 */

- (void) showEditMenu: (CGRect) r {
    if (allowEditMenu) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect: r inView: self];
        [menuController setMenuVisible: YES animated: NO];
    }
}

/*!
 * Do the math to start tracking pinches.
 *
 * @param touches		The touches inthe pinch. There must be at least two.
 */

- (void) startTrackingPinch: (NSSet *) touches {
    trackingPinch = YES;
    self.scrollEnabled = NO;
    pinchStartDistance = [self distanceBetweenTouches: touches];
    pinchStartFontSize = [font pointSize];
}

/*!
 * Call this method when the text changes.
 */

- (void) textChanged {
    if ([codeViewDelegate respondsToSelector: @selector(codeViewTextChanged)])
        [codeViewDelegate codeViewTextChanged];
    [inputAccessoryView setContext: text selection: selectedRange];
}

/*!
 * Call this method to determine if a touch event is near enough to the edve fo the view to trigger 
 * a scroll and, if so, to initiaate the scroll. If a scroll starts, a timer is also fired. As long 
 * as the touch is still active, the timer will continue to scroll the screen.
 *
 * @param timer			The timer that triggeredthis call, or nil if the call was not triggered by 
 *						a timer.
 */

- (void) touchScroll: (NSTimer *) timer {
    if (trackingSelection && trackingTouchScroll) {
        trackingTouchScroll = NO;
        float offsetX = self.contentOffset.x, offsetY = self.contentOffset.y;
        
        if (touchScrollLocation.x - self.contentOffset.x < LOLLIPOP_TOUCH_SIZE) {
            offsetX = self.contentOffset.x - LOLLIPOP_TOUCH_SIZE*4;
            if (offsetX < 0)
                offsetX = 0;
            if (offsetX != self.contentOffset.x) {
                touchScrollLocation.x += offsetX - self.contentOffset.x;
                trackingTouchScroll = YES;
            }
        } else if (self.contentOffset.x + self.frame.size.width - touchScrollLocation.x < LOLLIPOP_TOUCH_SIZE) {
            offsetX = self.contentOffset.x + LOLLIPOP_TOUCH_SIZE*4;
            if (offsetX > self.contentSize.width - self.frame.size.width)
                offsetX = self.contentSize.width - self.frame.size.width;
            if (offsetX != self.contentOffset.x) {
                touchScrollLocation.x += offsetX - self.contentOffset.x;
                trackingTouchScroll = YES;
            }
        }
        
        if (touchScrollLocation.y - self.contentOffset.y < LOLLIPOP_TOUCH_SIZE) {
            offsetY = self.contentOffset.y - LOLLIPOP_TOUCH_SIZE*4;
            if (offsetY < 0)
                offsetY = 0;
            if (offsetY != self.contentOffset.y) {
                touchScrollLocation.y += offsetY - self.contentOffset.y;
                trackingTouchScroll = YES;
            }
        } else if (self.contentOffset.y + self.frame.size.height - touchScrollLocation.y < LOLLIPOP_TOUCH_SIZE) {
            offsetY = self.contentOffset.y + LOLLIPOP_TOUCH_SIZE*4;
            if (offsetY > self.contentSize.height - self.frame.size.height)
                offsetY = self.contentSize.height - self.frame.size.height;
            if (offsetY != self.contentOffset.y) {
                touchScrollLocation.y += offsetY - self.contentOffset.y;
                trackingTouchScroll = YES;
            }
        }
        
        if (trackingTouchScroll) {
            // Do the scroll.
            [self setContentOffset: CGPointMake(offsetX, offsetY) animated: YES];
            
            // Update the selection.
            [self updateSelectionForTouch];
            
            // Schedule another scroll.
            if (touchScrollTimer == nil)
                self.touchScrollTimer = [NSTimer scheduledTimerWithTimeInterval: 0.33 target: self selector: @selector(touchScroll:) userInfo: nil repeats: NO];
        }
    }
}

/*!
 * If this timer fires, start tracking the magnifier tool used to precicely track the selection point.
 */

- (void) trackMagnifier: (NSTimer *) timer {
    self.magnifierTimer = nil;
    
    if (!trackingSelection || trackingPinch) {
        trackingMagnifier = YES;
        self.scrollEnabled = NO;
        [self cursorVisible];
        
        UIView *topView = [[UIApplication sharedApplication] keyWindow];
        CGPoint location = [magnifierTouch locationInView: topView];
        CGRect frame = CGRectMake(location.x - MAGNIFIER_SIZE/2, location.y - MAGNIFIER_SIZE, MAGNIFIER_SIZE, MAGNIFIER_SIZE);
        self.magnifierView = [[CodeMagnifierView alloc] initWithFrame: frame];
        ((CodeMagnifierView *) magnifierView).viewToMagnify = topView;
        magnifierView.opaque = NO;
        [topView addSubview: magnifierView];
    }
}

/*!
 * Undo the indicated change.
 *
 * @param undoObject		The change to undo.
 */

- (void) undo: (CodeUndo *) undoObject {
    [undoObject undo: self];
    [undoManager registerUndoWithTarget: self selector: @selector(undo:) object: [undoObject redoObject]];
    [self scrollRangeToVisible: selectedRange];
    
    [self textChanged];
}

/*!
 * This method takes a touch location stored in touchScrollLocation and updates selectedRange. It is 
 * a worker method for touchScroll: and touchesEnded:withEvent:.
 */

- (void) updateSelectionForTouch {
    int offset = [self offsetFromLocation: touchScrollLocation];
    if (firstLollipop) {
        if (offset < initialRange.location + initialRange.length) {
            selectedRange.location = offset;
            selectedRange.length = initialRange.location + initialRange.length - offset;
        } else {
            selectedRange.location = initialRange.location + initialRange.length;
            selectedRange.length = offset - selectedRange.location;
        }
    } else {
        if (offset < initialRange.location) {
            selectedRange.location = offset;
            selectedRange.length = initialRange.location - offset;
        } else {
            selectedRange.location = initialRange.location;
            selectedRange.length = offset - selectedRange.location;
        }
    }
    [self selectionChanged];
    
    if (selectedRange.length > 0 && !trackingSelection)
        [self showEditMenu: [self firstRectForRange: selectedRange]];
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
            maxChars = (int) line.length;
    size.width = maxChars*charWidth;
    self.contentSize = size;
}

#pragma mark - UIView overrides

/*!
 * Set the frame rectangle, which describes the view’s location and size in its superview’s coordinate system.
 *
 * Override forces a repaint so showing or hiding the keyboard does not streatch the text.
 */

- (void) setFrame: (CGRect) frame {
    [super setFrame: frame];
    [self scrollRangeToVisible: selectedRange];
    [self setNeedsDisplay];
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

#pragma mark - Touch events

/*!
 * See if a touch event is in a lollipop.
 *
 * As a side effect, this sets firstLollipop to YES or NO, depending on whether the touch was in the
 * starting or ending selection lollipop. The value is not valid if the touch is not in either lollipop.
 *
 * @param touch			The touch event to check.
 *
 * @return				YES if the touch is in a lollipop, else NO.
 */

- (BOOL) isTouchInLollipop: (UITouch *) touch {
    BOOL result = NO;
    
    if (selectedRange.length > 0 && selectionRects != nil) {
        CGRect r = ((CodeRect *) selectionRects[0]).rect;
        r.origin.x -= LOLLIPOP_TOUCH_SIZE;
        r.size.width = 2*LOLLIPOP_TOUCH_SIZE;
        r.origin.y -= LOLLIPOP_SIZE + LOLLIPOP_TOUCH_SIZE;
        r.size.height = LOLLIPOP_SIZE + 2*LOLLIPOP_TOUCH_SIZE + r.size.height;
        
        result = CGRectContainsPoint(r, [touch locationInView: self]);
        firstLollipop = YES;
        
        if (!result) {
            CGRect r = ((CodeRect *) selectionRects[selectionRects.count - 1]).rect;
            r.origin.x += r.size.width - LOLLIPOP_TOUCH_SIZE;
            r.size.width = 2*LOLLIPOP_TOUCH_SIZE;
            r.origin.y += r.size.height + LOLLIPOP_SIZE - LOLLIPOP_TOUCH_SIZE;
            r.size.height = 2*LOLLIPOP_TOUCH_SIZE;
            
            result = CGRectContainsPoint(r, [touch locationInView: self]);
            firstLollipop = NO;
        }
    }
    
    return result;
}
            
/*!
 * Tells the receiver when one or more fingers touch down in a view or window.
 *
 * @param touches		A set of UITouch instances that represent the touches for the starting phase 
 *						of the event represented by event.
 * @param event			An object representing the event to which the touches belong.
 */

- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
    if (touches.count == 1) {
        if ([self isTouchInLollipop: [touches anyObject]]) {
            trackingSelection = YES;
            self.scrollEnabled = !trackingSelection;
            initialRange = selectedRange;
        }
        
        if (self.scrollEnabled && [self isFirstResponder]) {
            // If scrolling is enabled, we are not tracking a lollipop. Start a timer that will look at the 
            // touch location later to see if the touch moved.
            self.magnifierTouch = [touches anyObject];
            self.magnifierTimer = [NSTimer scheduledTimerWithTimeInterval: MAGNIFIER_TIME 
                                                                   target: self 
                                                                 selector: @selector(trackMagnifier:) 
                                                                 userInfo: nil 
                                                                  repeats: NO];
        }
    } else if (touches.count == 2)
        [self startTrackingPinch: touches];
}

/*!
 * Sent to the receiver when a system event (such as a low-memory warning) cancels a touch event.
 *
 * @param touches		A set of UITouch instances that represent the touches for the ending phase of 
 *						the event represented by event.
 * @param event			An object representing the event to which the touches belong.
 */

- (void) touchesCancelled: (NSSet *) touches withEvent: (UIEvent *) event {
    self.scrollEnabled = YES;
    trackingSelection = NO;
    trackingPinch = NO;
    
    if (magnifierTimer != nil) {
        // Invalidate any magnifier timer.
        [magnifierTimer invalidate];
        self.magnifierTimer = nil;
    } else if (trackingMagnifier) {
        // If we are tracking a selection, erase the magnifier view.
        [magnifierView removeFromSuperview];
        self.magnifierView = nil;
        trackingMagnifier = NO;
    }
}

/*!
 * Tells the receiver when one or more fingers are raised from a view or window.
 *
 * @param touches		A set of UITouch instances that represent the touches for the ending phase 
 *						of the event represented by event.
 * @param event			An object representing the event to which the touches belong.
 */

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event {
    UITouch *touch = [touches anyObject];
    if (touches.count == 1 && touch) {
        if ([touch tapCount] > 0 || magnifierView != nil) {
            if ([self becomeFirstResponder]) {
                int tapCount = ([touch tapCount] - 1)%3 + 1;
                switch (tapCount) {
                    case 1: {
                        if ([self isTouchInLollipop: touch]) {
                            // Single taps in a lollipop display the edit menu.
                            CGPoint location = [touch locationInView: self];
                            [self showEditMenu: CGRectMake(location.x, location.y, 5, 5)];
                        } else {
                            // Single taps place the insertion point at the tap location and cause us to 
                            // becoem first responder.
                            int location = (int) selectedRange.location;
                            
                            selectedRange.location = [self offsetFromLocation: [touch locationInView: self]];
                            if (selectedRange.length > 0) {
                                selectedRange.length = 0;
                                [self setNeedsDisplay];
                                [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
                            } else {
                                if (location == selectedRange.location && magnifierView == nil && !firstTap) {
                                    [self showEditMenu: [self firstRectForRange: selectedRange]];
                                } else {
                                    [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
                                }
                            }
                            
                            cursorColumn = -1;
                            [undoManager beginNewUndoGroup];
                            [self selectionChanged];
                        }
                        break;
                    }
                        
                    case 2: 
                        // Double taps select a word.
                        [self cursorOff];
                        
                        selectedRange.location = [self previousToken: [self offsetFromLocation: [touch locationInView: self]]];
                        selectedRange.length = (int) ([self endOfToken: (int) selectedRange.location] - selectedRange.location);
                        if (selectedRange.length == 0) {
                            if (selectedRange.location < text.length)
                                selectedRange.length = 1;
                            else if (selectedRange.location > 0) {
                                selectedRange.length = 1;
                                --selectedRange.location;
                            }
                        }
                        
                        if (selectedRange.length > 0) {
                            initialRange = selectedRange;
                            [self showEditMenu: [self firstRectForRange: selectedRange]];
                        }
                        
                        [self cursorOn];
                        
                        cursorColumn = -1;
                        [undoManager beginNewUndoGroup];
                        [self selectionChanged];
                        
                        [self setNeedsDisplay];
                        break;
                        
                    case 3: 
                        // Tripple taps select a line.
                        [self cursorOff];
                        
                        selectedRange.location = [self offsetFromLocation: [touch locationInView: self]];
                        while (selectedRange.location > 0 && [text characterAtIndex: selectedRange.location - 1] != '\n') {
                            --selectedRange.location;
                            ++selectedRange.length;
                        }
                        while (selectedRange.location + selectedRange.length < text.length - 1 
                               && [text characterAtIndex: selectedRange.location + selectedRange.length] != '\n') 
                        {
                            ++selectedRange.length;
                        }
                        
                        if (selectedRange.length > 0) {
                            initialRange = selectedRange;
                            [self showEditMenu: [self firstRectForRange: selectedRange]];
                        }
                        
                        [self cursorOn];
                        
                        cursorColumn = -1;
                        [undoManager beginNewUndoGroup];
                        [self selectionChanged];
                        
                        [self setNeedsDisplay];
                        break;
                }
                firstTap = NO;
            }
        }
    }
    
    self.scrollEnabled = YES;
    trackingSelection = NO;
    trackingPinch = NO;
    
    if (magnifierTimer != nil) {
        // Invalidate any magnifier timer.
        [magnifierTimer invalidate];
        self.magnifierTimer = nil;
    } else if (trackingMagnifier) {
        // If we are tracking a selection, erase the magnifier view.
        [magnifierView removeFromSuperview];
        self.magnifierView = nil;
        trackingMagnifier = NO;
    }
}

/*!
 * Tells the receiver when one or more fingers associated with an event move within a view or window.
 *
 * @param touches		A set of UITouch instances that represent the touches that are moving during 
 *						the event represented by event.
 * @param event			An object representing the event to which the touches belong.
 */

- (void) touchesMoved: (NSSet *) touches withEvent: (UIEvent *) event {
    if (touches.count == 1) {
        if (trackingSelection) {
            // Handle dragging lollipops (the ends of selection ranges).
            trackingTouchScroll = NO;
            [touchScrollTimer invalidate];
            touchScrollTimer = nil;
            
            UITouch *touch = [touches anyObject];
            if (touch) {
                // Update the selection.
                touchScrollLocation = [touch locationInView: self];
                [self updateSelectionForTouch];
                
                trackingTouchScroll = YES;
                [self touchScroll: nil];
                
                [self setNeedsDisplay];
            }
        }
        
        if (trackingMagnifier) {
            // If we are tracking a selection, move it to the new location.
            UIView *topView = [[UIApplication sharedApplication] keyWindow];
            UITouch *touch = [touches anyObject];
            CGPoint location = [touch locationInView: topView];
            CGRect frame = CGRectMake(location.x - MAGNIFIER_SIZE/2, location.y - MAGNIFIER_SIZE, MAGNIFIER_SIZE, MAGNIFIER_SIZE);
            magnifierView.frame = frame;
            [magnifierView setNeedsDisplay];
            
            selectedRange.location = [self offsetFromLocation: [touch locationInView: self]];
            if (selectedRange.length > 0)
                selectedRange.length = 0;
            [self cursorVisible];
            [self setNeedsDisplay];
            [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
            [self selectionChanged];
        } else if (magnifierTimer != nil) {
            // See if the touch has moved far enough from the original for it to make sense to cancel the magnifier timer.
            UIView *topView = [[UIApplication sharedApplication] keyWindow];
            UITouch *touch = [touches anyObject];
            CGPoint location1 = [touch locationInView: topView];
            CGPoint location2 = [magnifierTouch locationInView: topView];
            float delta = ((location1.x - location2.x)*(location1.x - location2.x) 
                           + (location1.y - location2.y)*(location1.y - location2.y));
            if (delta > 16.0) {
            	// If we are waiting for the magnifier timer to fire, cancel it.
            	[magnifierTimer invalidate];
            	self.magnifierTimer = nil;
        	}
        }
    } else if (touches.count == 2) {
        if (trackingPinch) {
            float size = pinchStartFontSize*[self distanceBetweenTouches: touches]/pinchStartDistance;
            size = size < MIN_FONT_SIZE ? MIN_FONT_SIZE : size;
            size = size > MAX_FONT_SIZE ? MAX_FONT_SIZE : size;
            self.font = [font fontWithSize: size];
            [self setNeedsDisplay];
        } else
            [self startTrackingPinch: touches];
    }
}

#pragma mark - Getters and setters

/*!
 * Set the allowEditMenu flag. Setting it to NO will hide the edit menu if it is visible.
 *
 * @param theAllowEditMenu	The new flag setting.
 */

- (void) setAllowEditMenu: (BOOL) theAllowEditMenu {
    allowEditMenu = theAllowEditMenu;
    if (!allowEditMenu)
        [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
}

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
#if IS_PARALLAX
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
#endif
    }
}

/*!
 * Set the selection range.
 *
 * @param range		The new selection range.
 */

- (void) setSelectedRange: (NSRange) range {
    [self setSelectedRangeNoUndoGroup: range];
    [undoManager beginNewUndoGroup];
    firstTap = YES;
}

/*!
 * Set the text contents for the view.
 *
 * @param theText		The new text contents.
 */

- (void) setText: (NSString *) theText {
    text = [theText stringByReplacingOccurrencesOfString: @"\r\n" withString: @"\n"];
    text = [text stringByReplacingOccurrencesOfString: @"\r" withString: @"\n"];
    self.lines = [text componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    [self updateViewSize];
    [self setNeedsDisplay];
    self.backgroundHighlights = [highlighter highlightBlocks: text];
    self.multilineHighlights = [highlighter multilineHighlights: text];
    if (selectedRange.location > text.length)
        selectedRange.location = text.length;
    if (selectedRange.location + selectedRange.length > text.length)
        selectedRange.length = text.length - selectedRange.location;
    firstTap = YES;
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
    CGContextSetFillColorWithColor(context, [self.backgroundColor CGColor]);
    CGContextFillRect(context, rect);
    
    // Draw any blocks of background color.
    if (backgroundHighlights && useSyntaxColoring) {
        for (ColoredRange *coloredRange in backgroundHighlights) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [coloredRange.color CGColor]);
            NSArray *rects = [self selectionRectsForRange: coloredRange.range];
            for (CodeRect *rect in rects) {
                CGContextFillRect(context, rect.rect);
            }
        }
    }
    
    // Draw the background for any selection.
    if (selectedRange.length > 0) {
        selectionRects = [self selectionRectsForRange: selectedRange];
        CGContextSetFillColorWithColor(context, [[UIColor colorWithRed: 204.0/255.0 green: 221.0/255.0 blue: 237.0/255.0 alpha: 1.0] CGColor]);
        for (CodeRect *rect in selectionRects)
	        CGContextFillRect(context, rect.rect);
    }

    // Find the range of lines to draw.
    int firstLine = self.contentOffset.y/font.lineHeight;
    if (firstLine < 0)
        firstLine = 0;
    int lastLine = 1 + firstLine + self.frame.size.height/font.lineHeight;
    if (lastLine > lines.count)
        lastLine = (int) lines.count;
        
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
    
    if (useSyntaxColoring) {
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
                int start = coloredRange.range.location < initialOffset 
                ? 0 
                : (int) (coloredRange.range.location - initialOffset);
                int end = coloredRange.range.location + coloredRange.range.length > initialOffset + highlightIndexSize 
                ? highlightIndexSize 
                : (int) (coloredRange.range.location + coloredRange.range.length - initialOffset);
                for (int i = start; i < end; ++i)
                    highlightIndexes[i] = colorIndex;
            }
        
        // Track multiline highlights through the visible text.
        for (ColoredRange *coloredRange in multilineHighlights)
            if (coloredRange.range.location < initialOffset + highlightIndexSize 
                && coloredRange.range.location + coloredRange.range.length > initialOffset)
            {
                int colorIndex = [self colorIndexForColor: coloredRange.color];
                int start = coloredRange.range.location < initialOffset 
                ? 0 
                : (int)  (coloredRange.range.location - initialOffset);
                int end = coloredRange.range.location + coloredRange.range.length > initialOffset + highlightIndexSize 
                ? highlightIndexSize 
                : (int) (coloredRange.range.location + coloredRange.range.length - initialOffset);
                for (int i = start; i < end; ++i)
                    highlightIndexes[i] = colorIndex;
            }
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
    if (cursorState && selectedRange.length == 0) {
        CGRect r = [self firstRectForRange: selectedRange];
        CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
        CGContextFillRect(context, r);
    }
    
    // Draw the lollipops for any selection.
    if (selectedRange.length > 0) {
        CGRect r = ((CodeRect *) selectionRects[0]).rect;
        r.size.width = 1.0;
        [self drawLollipopWithContext: context at: r rightSideUp: YES];
        
        r = ((CodeRect *) selectionRects[selectionRects.count - 1]).rect;
        r.origin.x += r.size.width - 1.0;
        r.size.width = 1.0;
        [self drawLollipopWithContext: context at: r rightSideUp: NO];
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
 * Return the last rectangle that encloses a range of text in a document.
 *
 * @param range			The range of text for which to return a rectangle.
 */

- (CGRect) lastRectForRange: (NSRange) range {
    NSArray *rects = [self selectionRectsForRange: range];
    return ((CodeRect *) rects[rects.count - 1]).rect;
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
    
    int textLine = 0;
    int i = 0;
    while (textLine < line)
        if (buffer[i++] == '\n')
            ++textLine;
    
    free(buffer);

    return i + offset;
}

/*!
 * Get the offset in the text from a touch location in the view.
 *
 * @param location		The location in the view.
 *
 * @return				The offset in the text.
 */

- (int) offsetFromLocation: (CGPoint) location {
    int offset = 0;
    
    UInt16 *buffer = (UInt16 *) malloc(2*text.length);
    NSRange substringRange;
    substringRange.location = 0;
    substringRange.length = text.length;
    if (substringRange.length > 0) {
        [text getBytes: buffer maxLength: 2*text.length usedLength: nil encoding: NSUnicodeStringEncoding options: 0 range: substringRange remainingRange: nil];
        
        int line = (int) (location.y/font.lineHeight);
        if (line < 0)
            line = 0;
        
        while (line && offset < substringRange.length - 1)
            if (buffer[offset++] == '\n')
                --line;
        
        [self cursorOff];
        int lineOffset = (int) (location.x/charWidth);
        while (lineOffset && offset < substringRange.length)
            if (offset < substringRange.length && buffer[offset] == '\n')
                break;
            else {
                ++offset;
                --lineOffset;
            }
        [self cursorOn];
        
        free(buffer);
    }
    
    return offset;
}

/*!
 * Given a screen line index and column offset, find the character offset in the text.
 *
 * @param line			The index of the line on the screen. This may be larger than the number of lines in 
 *						the text, in which case the last line is used.
 * @param column		The index of the character in the line. This may be past the actual number of characters 
 *						in the line, in shich case the position of the end of line is returned.
 *
 * @return				he offset in the text.
 */

- (int) offsetToLine: (int) line column: (int) column {
    UInt16 *buffer = (UInt16 *) malloc(2*text.length);
    NSRange substringRange;
    substringRange.location = 0;
    substringRange.length = text.length;
    [text getBytes: buffer maxLength: 2*text.length usedLength: nil encoding: NSUnicodeStringEncoding options: 0 range: substringRange remainingRange: nil];
    
    int offset = 0;
    while (line && offset < substringRange.length - 1)
        if (buffer[offset++] == '\n')
            --line;
    
    while (column && offset < substringRange.length - 1)
        if (buffer[offset] == '\n')
            break;
        else {
            ++offset;
            --column;
        }
    
    free(buffer);
    
    return offset;
}

/*!
 * Get the line and character positions corresponding to a text range.
 *
 * @param range			The text range.
 * @param line0			(output) The initial line index.
 * @param offset0		(output) The initial character index in the intial line.
 * @param line1			(output) The final line index. Pass nil if you do not need this value.
 * @param offset1		(output) The final character index in the final line. Pass nil if you do not need this value.
 */

- (void) offsetsFromRange: (NSRange) range line0: (int *) line0 offset0: (int *) offset0 line1: (int *) line1 offset1: (int *) offset1 {
    int offset = 0;
    int line = 0;
    int length = (int) (2*(range.location + range.length));
    
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
    
    if (line1 != nil || offset1 != nil) {
        for (int i = (int) range.location; i < range.location + range.length; ++i) {
            if (buffer[i] == '\n') {
                ++line;
                offset = 0;
            } else
                ++offset;
        }
        
        free(buffer);
        if (line1 != nil)
	        *line1 = line;
        if (offset1 != nil)
	        *offset1 = offset;
    }
}

/*!
 * Scrolls the receiver until the text in the specified range is visible. Does nothing if the range is already visible.
 *
 * @param range			The range of text to scroll into view.
 */

- (void) scrollRangeToVisible: (NSRange) range {
    // Get the line/column for the range.
    int line0, column0, line1, column1;
    [self offsetsFromRange: range line0: &line0 offset0: &column0 line1: &line1 offset1: &column1];
    
    // Find the pixel offsets for the range.
    float x0 = charWidth*column0;
    float x1 = charWidth*column1;
    float y0 = font.lineHeight*line0;
    float y1 = font.lineHeight*line1;
    
    // Get the size for the display.
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    
    // Find the offset for the end of the selction first. Finding the offset for the first part last
    // gives visual preference to the selection start.
    float offsetX = self.contentOffset.x;
    if (x1 > offsetX + width - charWidth)
        offsetX = x1 - width + charWidth;
    else if (x1 < offsetX)
        offsetX = x1 < charWidth ? x1 : x1 - charWidth;
    if (x0 > offsetX + width - charWidth)
        offsetX = x0 - width + charWidth;
    else if (x0 < offsetX)
        offsetX = x0 < charWidth ? x0 : x0 - charWidth;

    float offsetY = self.contentOffset.y;
    if (y1 > offsetY + height - font.lineHeight)
        offsetY = y1 - height + font.lineHeight*2;
    else if (y1 < offsetY)
        offsetY = y1;
    if (y0 > offsetY + height - font.lineHeight)
        offsetY = y0 - height + font.lineHeight*2;
    else if (y0 < offsetY)
        offsetY = y0;
    
    // Update the screen location.
    if (offsetX != self.contentOffset.x || offsetY != self.contentOffset.y)
        [self setContentOffset: CGPointMake(offsetX, offsetY) animated: YES];
}

/*!
 * Get the rectangles that enclose a range.
 *
 * The returned array will contain one to three rectangles, depending on the number of lines the selection encompasses. If
 * the range has zero length, the rectangle will have a width of 1 and a location to the left of the indicated character.
 *
 * @param range			The range of text for which to find the selection rectangles.
 *
 * @return				An array of one to three CodeRect objects.
 */

- (NSArray *) selectionRectsForRange: (NSRange) range {
    NSMutableArray *localSelectionRects = [[NSMutableArray alloc] init];
    
    int line0, line1, offset0, offset1;
    [self offsetsFromRange: range line0: &line0 offset0: &offset0 line1: &line1 offset1: &offset1];
    CGFloat x0 = offset0*charWidth;
    CGFloat y0 = line0*font.lineHeight;
    CGFloat x1 = offset1*charWidth;
    if (line0 == line1) {
        if (offset0 == offset1)
            x1 += 1;
        CodeRect *rect = [[CodeRect alloc] initWithX: x0 y: y0 width: x1 - x0 height: font.lineHeight];
        [localSelectionRects addObject: rect];
    } else if (line0 + 1 == line1) {
        CodeRect *rect = [[CodeRect alloc] initWithX: x0 y: y0 width: self.self.contentSize.width - x0 height: font.lineHeight];
        [localSelectionRects addObject: rect];
        if (offset1 > 0) {
            rect = [[CodeRect alloc] initWithX: 0 y: y0 + font.lineHeight width: x1 height: font.lineHeight];
            [localSelectionRects addObject: rect];
        }
    } else {
        CodeRect *rect = [[CodeRect alloc] initWithX: x0 y: y0 width: self.self.contentSize.width - x0 height: font.lineHeight];
        [localSelectionRects addObject: rect];
        CGFloat centerHeight = font.lineHeight*(line1 - line0 - 1);
        rect = [[CodeRect alloc] initWithX: 0 y: y0 + font.lineHeight width: self.self.contentSize.width height: centerHeight];
        [localSelectionRects addObject: rect];
        if (offset1 > 0) {
            rect = [[CodeRect alloc] initWithX: 0 y: y0 + font.lineHeight + centerHeight width: x1 height: font.lineHeight];
            [localSelectionRects addObject: rect];
        }
    }
    
    return localSelectionRects;
}

#pragma mark - UIResponder overrides

/*!
 * Notifies the receiver that it is about to become first responder in its window.
 *
 * @return				YES if the receiver accepts first-responder status or NO if it refuses this status. 
 *						The default implementation returns YES, accepting first responder status.
 */

- (BOOL) becomeFirstResponder {
    if (self.isFirstResponder)
        return YES;
    
    if (!editable)
        return NO;
    
    if ([super becomeFirstResponder]) {
        BOOL allowEditing = YES;
        if ([codeViewDelegate respondsToSelector: @selector(codeViewShouldBeginEditing:)])
            allowEditing = [codeViewDelegate codeViewShouldBeginEditing: self];
        if (allowEditing) {
            if ([codeViewDelegate respondsToSelector: @selector(codeViewDidBeginEditing:)])
                [codeViewDelegate codeViewDidBeginEditing: self];
            return YES;
        }
    }
    
    return NO;
}

/*!
 * Returns a Boolean value indicating whether the receiver can become first responder.
 *
 * @return			Returns YES.
 */

- (BOOL) canBecomeFirstResponder {
    return editable;
}

/*!
 * Requests the receiving responder to enable or disable the specified command in the user interface.
 *
 * @param action		A selector that identifies a method associated with a command. For the editing menu, this 
 *						is one of the editing methods declared by the UIResponderStandardEditActions informal 
 *						protocol (for example, copy:).
 * @param sender		The object calling this method. For the editing menu commands, this is the shared 
 *						UIApplication object. Depending on the context, you can query the sender for information 
 *						to help you determine whether a command should be enabled.
 *
 * @return				YES if the the command identified by action should be enabled or NO if it should be 
 *						disabled. Returning YES means that your class can handle the command in the current 
 *						context.
 */

- (BOOL) canPerformAction: (SEL) action withSender: (id) sender {
    BOOL result = NO;
    if (action == @selector(cut:) 
        || action == @selector(copy:) 
        || action == @selector(delete:)) 
    {
        result = selectedRange.length > 0;
    } else if (action == @selector(paste:)) {
        NSString *scrap = [UIPasteboard generalPasteboard].string;
        result = scrap && scrap.length > 0;
    } else if (action == @selector(selectAll:)) {
        result = text && text.length > 0;
    } else if (action == @selector(keyCommand:)) {
        result = YES;
    }
    return result;
}

/*!
 * The custom input accessory view to display when the receiver becomes the first responder.
 *
 * This property is typically used to attach an accessory view to the system-supplied keyboard that is presented 
 * for UITextField and UITextView objects.
 *
 * @return				The input accessory view.
 */

- (UIView *) inputAccessoryView {
#if IS_PARALLAX
    return nil;
#else
    if (hardwareKeyboard || SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        self.inputAccessoryView = nil;
        return nil;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *completion = [defaults stringForKey: @"code_completion_preference"];
    if (completion != nil)
        if (![defaults boolForKey: @"code_completion_preference"])
            return nil;

    
    if (!inputAccessoryView) {
        CGRect accessFrame = CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width, PREFERRED_ACCESSORY_HEIGHT);
        inputAccessoryView = [[BASICInputAccessoryView alloc] initWithFrame: accessFrame];
        inputAccessoryView.codeInputAccessoryViewDelegate = self;
    }
    return inputAccessoryView;
#endif
}

/*!
 * The key commands that trigger actions on this responder.
 *
 * A responder object that supports hardware keyboard commands can redefine this property and use it to return an array 
 * of UIKeyCommand objects that it supports. Each key command object represents the keyboard sequence to recognize and 
 * the action method of the responder to call in response.
 */

- (NSArray *) keyCommands {
    if (theKeyCommands == nil) {
        UIKeyCommand *upArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputUpArrow modifierFlags: 0 action: @selector(keyCommand:)];
        UIKeyCommand *downArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputDownArrow modifierFlags: 0 action: @selector(keyCommand:)];
        UIKeyCommand *leftArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputLeftArrow modifierFlags: 0 action: @selector(keyCommand:)];
        UIKeyCommand *rightArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputRightArrow modifierFlags: 0 action: @selector(keyCommand:)];
        
        UIKeyCommand *commandUpArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputUpArrow modifierFlags: UIKeyModifierCommand action: @selector(keyCommand:)];
        UIKeyCommand *commandDownArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputDownArrow modifierFlags: UIKeyModifierCommand action: @selector(keyCommand:)];
        UIKeyCommand *commandLeftArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputLeftArrow modifierFlags: UIKeyModifierCommand action: @selector(keyCommand:)];
        UIKeyCommand *commandRightArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputRightArrow modifierFlags: UIKeyModifierCommand action: @selector(keyCommand:)];
        
        UIKeyCommand *optionUpArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputUpArrow modifierFlags: UIKeyModifierAlternate action: @selector(keyCommand:)];
        UIKeyCommand *optionDownArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputDownArrow modifierFlags: UIKeyModifierAlternate action: @selector(keyCommand:)];
        UIKeyCommand *optionLeftArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputLeftArrow modifierFlags: UIKeyModifierAlternate action: @selector(keyCommand:)];
        UIKeyCommand *optionRightArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputRightArrow modifierFlags: UIKeyModifierAlternate action: @selector(keyCommand:)];
        
        UIKeyCommand *shiftUpArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputUpArrow modifierFlags: UIKeyModifierShift action: @selector(keyCommand:)];
        UIKeyCommand *shiftDownArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputDownArrow modifierFlags: UIKeyModifierShift action: @selector(keyCommand:)];
        UIKeyCommand *shiftLeftArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputLeftArrow modifierFlags: UIKeyModifierShift action: @selector(keyCommand:)];
        UIKeyCommand *shiftRightArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputRightArrow modifierFlags: UIKeyModifierShift action: @selector(keyCommand:)];
        
        UIKeyCommand *shiftCommandUpArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputUpArrow modifierFlags: UIKeyModifierCommand | UIKeyModifierShift action: @selector(keyCommand:)];
        UIKeyCommand *shiftCommandDownArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputDownArrow modifierFlags: UIKeyModifierCommand | UIKeyModifierShift action: @selector(keyCommand:)];
        UIKeyCommand *shiftCommandLeftArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputLeftArrow modifierFlags: UIKeyModifierCommand | UIKeyModifierShift action: @selector(keyCommand:)];
        UIKeyCommand *shiftCommandRightArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputRightArrow modifierFlags: UIKeyModifierCommand | UIKeyModifierShift action: @selector(keyCommand:)];
        
        UIKeyCommand *shiftOptionUpArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputUpArrow modifierFlags: UIKeyModifierAlternate | UIKeyModifierShift action: @selector(keyCommand:)];
        UIKeyCommand *shiftOptionDownArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputDownArrow modifierFlags: UIKeyModifierAlternate | UIKeyModifierShift action: @selector(keyCommand:)];
        UIKeyCommand *shiftOptionLeftArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputLeftArrow modifierFlags: UIKeyModifierAlternate | UIKeyModifierShift action: @selector(keyCommand:)];
        UIKeyCommand *shiftOptionRightArrow = [UIKeyCommand keyCommandWithInput: UIKeyInputRightArrow modifierFlags: UIKeyModifierAlternate | UIKeyModifierShift action: @selector(keyCommand:)];
        
        UIKeyCommand *command_f = [UIKeyCommand keyCommandWithInput: @"f" modifierFlags: UIKeyModifierCommand action: @selector(keyCommand:)];
        UIKeyCommand *command_g = [UIKeyCommand keyCommandWithInput: @"g" modifierFlags: UIKeyModifierCommand action: @selector(keyCommand:)];
        UIKeyCommand *command_G = [UIKeyCommand keyCommandWithInput: @"g" modifierFlags: UIKeyModifierCommand | UIKeyModifierShift action: @selector(keyCommand:)];

        UIKeyCommand *command_lbracket = [UIKeyCommand keyCommandWithInput: @"[" modifierFlags: UIKeyModifierCommand action: @selector(keyCommand:)];
        UIKeyCommand *command_rbracket = [UIKeyCommand keyCommandWithInput: @"]" modifierFlags: UIKeyModifierCommand action: @selector(keyCommand:)];
        
        self.theKeyCommands = [[NSArray alloc] initWithObjects: upArrow, downArrow, leftArrow, rightArrow, 
                               commandUpArrow, commandDownArrow, commandLeftArrow, commandRightArrow, 
                               optionUpArrow, optionDownArrow, optionLeftArrow, optionRightArrow, 
                               shiftUpArrow, shiftDownArrow, shiftLeftArrow, shiftRightArrow,
                               shiftCommandUpArrow, shiftCommandDownArrow, shiftCommandLeftArrow, shiftCommandRightArrow,
                               shiftOptionUpArrow, shiftOptionDownArrow, shiftOptionLeftArrow, shiftOptionRightArrow, 
                               command_f, command_g, command_G, command_lbracket, command_rbracket, nil];
    }
    
    if (repeatKeyTimer != nil) {
        [repeatKeyTimer invalidate];
        self.repeatKeyTimer = nil;
    }
    
    return theKeyCommands;
}

/*!
 * Notifies the receiver that it has been asked to relinquish its status as first responder in its window.
 *
 * The default implementation returns YES, resigning first responder status. Subclasses can override this 
 * method to update state or perform some action such as unhighlighting the selection, or to return NO, 
 * refusing to relinquish first responder status. If you override this method, you must call super (the 
 * superclass implementation) at some point in your code.
 *
 * @return				YES if first responder status was resigned, else NO.
 */

- (BOOL) resignFirstResponder {
    if ([super resignFirstResponder]) {
        if ([codeViewDelegate respondsToSelector: @selector(codeViewDidEndEditing:)])
            [codeViewDelegate codeViewDidEndEditing: self];
        return YES;
    }
    return NO;
}

#pragma mark - UIKeyInput

/*!
 * Delete a character from the displayed text. (required)
 *
 * Remove the character just before the cursor from your class’s backing store and redisplay the text.
 */

- (void) deleteBackward {
    [self cursorOff];
    NSRange undoRange = selectedRange;
    if (selectedRange.length == 0 && selectedRange.location > 0) {
        --selectedRange.location;
        selectedRange.length = 1;
    }
    if (selectedRange.length > 0) {
        CodeUndo *undoObject = [CodeUndo undoBackDeletion: undoRange removedText: [text substringWithRange: selectedRange]];
        [undoManager registerUndoWithTarget: self selector: @selector(undo:) object: undoObject];

        self.text = [text stringByReplacingCharactersInRange: selectedRange withString: @""];
        selectedRange.length = 0;
    }
    [self cursorOn];
    
    [self scrollRangeToVisible: selectedRange];

    cursorColumn = -1;

    [UIMenuController sharedMenuController].menuVisible = NO;
    
    [self textChanged];
}

/*!
 * A Boolean value that indicates whether the text-entry objects has any text. (required)
 */

- (BOOL) hasText {
    return text && text.length > 0;
}

/*!
 * Insert a character into the displayed text. (required)
 *
 * @param theText	A string object representing the character typed on the system keyboard.
 */

- (void) insertText: (NSString *) theText {
    // Make sure we should do the edit.
    BOOL allowChange = YES;
    if ([codeViewDelegate respondsToSelector: @selector(codeView:shouldChangeTextInRange:replacementText:)])
        allowChange = [codeViewDelegate codeView: self shouldChangeTextInRange: selectedRange replacementText: theText];
    
    if (allowChange) {
        // Regsiter the action for undo.
        NSString *removedText = nil;
        if (selectedRange.length > 0)
            removedText = [self.text substringWithRange: selectedRange];
        CodeUndo *undoObject = [CodeUndo undoInsertion: selectedRange insertedText: theText removedText: removedText];
        [undoManager registerUndoWithTarget: self selector: @selector(undo:) object: undoObject];
        if ([codeViewDelegate respondsToSelector: @selector(codeViewTextChanged)])
            [codeViewDelegate codeViewTextChanged];
        
        // Insert the text.
        [self cursorOff];
        self.text = [text stringByReplacingCharactersInRange: selectedRange withString: theText];
        selectedRange.length = 0;
        selectedRange.location += theText.length;

        // Follow indents on returns.
        if (followIndentation && [[theText substringFromIndex: theText.length - 1] compare: @"\n"] == NSOrderedSame) {
            // Find the most recent non-blank line.
            NSArray *previousLines = [[text substringToIndex: selectedRange.location] componentsSeparatedByString: @"\n"];
            int index = (int) previousLines.count - 1;
            while (index > 0 && [[previousLines objectAtIndex: index] length] == 0)
                --index;
            if (index >= 0) {
                // Figure out how much whitespace is on it.
                int whiteSpaceIndex = 0;
                NSString *line = [previousLines objectAtIndex: index];
                while (whiteSpaceIndex < [line length] &&  isspace([line characterAtIndex: whiteSpaceIndex]))
                    ++whiteSpaceIndex;
                
                // If there is any whitespace at the start of the line, insert the same in the new line.
                if (whiteSpaceIndex > 0)
                    [self performSelector: @selector(insertText:) withObject: [line substringToIndex: whiteSpaceIndex] afterDelay: 0.02];
            }
        }

        [self cursorOn];
        
        // Scroll to show the change.
        [self scrollRangeToVisible: selectedRange];
        
        // Reset the up/down arrow column.
        cursorColumn = -1;
        
        // Hide the edit menu.
        [UIMenuController sharedMenuController].menuVisible = NO;
        
        [self textChanged];
    }
}

#pragma mark - CodeInputAccessoryViewDelegate

/*!
 * Tells the delegate the user has selected code completion text.
 *
 * @param range			The range of text to replace.
 * @param theText		The text to replace.
 */

- (void) codeInputAccessoryViewExtendingRange: (NSRange) range withText: (NSString *) theText {
    [self replaceRange: range withText: theText];
}

#pragma mark - UIScrollViewDelegate

/*!
 * Tells the delegate when the user scrolls the content view within the receiver.
 *
 * @param scrollView	The scroll-view object in which the scrolling occurred.
 */

- (void) scrollViewDidScroll: (UIScrollView *) scrollView {
    [self setNeedsDisplay];
    [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
    if ([codeViewDelegate respondsToSelector: @selector(codeViewDidScroll:)])
        [codeViewDelegate codeViewDidScroll: self];
}

#pragma mark - UIResponderStandardEditActions

/*!
 * Copy the selection to the pasteboard.
 *
 * @param sender		The object calling this method.
 */

- (void) copy: (id) sender {
    if (selectedRange.length > 0) {
        NSString *scrap = [text substringWithRange: selectedRange];
        [[UIPasteboard generalPasteboard] setValue: scrap forPasteboardType: (NSString *) kUTTypeSourceCode];
        [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
    }
}

/*!
 * Remove the selection from the user interface and write it to the pasteboard.
 *
 * @param sender		The object calling this method.
 */

- (void) cut: (id) sender {
    if (selectedRange.length > 0) {
        NSString *scrap = [text substringWithRange: selectedRange];
        [[UIPasteboard generalPasteboard] setValue: scrap forPasteboardType: (NSString *) kUTTypeSourceCode];
        [self insertText: @""];
        [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
    }
}

/*!
 * Remove the selection from the user interface.
 *
 * @param sender		The object calling this method.
 */

- (void) delete: (id) sender {
    if (selectedRange.length > 0) {
        [self insertText: @""];
        [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
    }
}

/*!
 * Read data from the pasteboard and display it in the user interface.
 *
 * @param sender		The object calling this method.
 */

- (void) paste: (id) sender {
    NSString *scrap = [UIPasteboard generalPasteboard].string;
    if (scrap && scrap.length > 0) {
        [self insertText: scrap];
        [[UIMenuController sharedMenuController] setMenuVisible: NO animated: YES];
    }
}

/*!
 * Select all objects in the current view.
 *
 * @param sender		The object calling this method.
 */

- (void) selectAll: (id) sender {
    selectedRange.location = 0;
    selectedRange.length = text.length;
    [self selectionChanged];
    [self setNeedsDisplay];
    
    CGRect rect = CGRectMake(self.contentOffset.x + self.frame.size.width/2.0, self.contentOffset.y + self.frame.size.height/2.0, 10, 10);
    [self showEditMenu: rect];
}

@end
