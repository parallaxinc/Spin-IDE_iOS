//
//  CodeInputAccessoryView.m
//  Spin IDE
//
//  Created by Mike Westerfield on 4/7/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "CodeInputAccessoryView.h"

#import "CodeCompletion.h"
#import "CodeCompletionButton.h"

#define SPACE (14.0)										/* Space between keys. */

// TODO: Add selection point location after insert.
// TODO: Add the various multi-line selections, like FOR-NEXT, SUB-END SUB
// TODO: Cull the reserved words
// TODO: Add methods
// TODO: Add event subrtoutines
// TODO: createCompletionButtons is called twice when a letter is typed or deleted

@interface CodeInputAccessoryView ()

@property (nonatomic, retain) NSMutableArray *buttons;		// The current completion buttons.
@property (nonatomic, retain) CAGradientLayer *gradient;	// The gradient.

@end


@implementation CodeInputAccessoryView

@synthesize buttons;
@synthesize codeInputAccessoryViewDelegate;
@synthesize gradient;
@synthesize selection;
@synthesize text;

#pragma mark - Misc

/*!
 * Add a gradient background, replaceing the old one it it exists.
 */

- (void) addGradient {
    // TODO: Gradient is set for iPad portrait. iPad landscape and iPhone use different gradients. Other O/S versions may, too.
    if (gradient != nil) {
        [gradient removeFromSuperlayer];
    }
    
    self.gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects: 
                       (id) [[UIColor colorWithRed: 209.0/255.0 green: 213.0/255.0 blue: 219.0/255.0 alpha: 1.0] CGColor], 
                       (id) [[UIColor colorWithRed: 203.0/255.0 green: 209.0/255.0 blue: 215.0/255.0 alpha: 1.0] CGColor], 
                       nil];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    [self.layer insertSublayer: gradient atIndex: 0];
}

/*!
 * Return the current list of completion words. These should be sorted by priority, from most likely to be 
 * used to least likely.
 *
 * The result is an array of CodeCompletion objects.
 *
 * Subclasses should override this method to provide an appropriate set of code completions for the current 
 * language.
 *
 * @return				An array of CodeCompletion objects. This may be empty, but not nil.
 */

- (NSArray *) codeCompletions {
    return [[NSArray alloc] init];
}

/*!
 * Handle code completion for the given button.
 *
 * @param button		The code completion button.
 */

- (void) completeCurrentWord: (CodeCompletionButton *) button {
    if ([codeInputAccessoryViewDelegate respondsToSelector: @selector(codeInputAccessoryViewExtendingRange:withText:)])
        [codeInputAccessoryViewDelegate codeInputAccessoryViewExtendingRange: button.codeCompletion.selection 
                                                                    withText: button.codeCompletion.text];
}

/*!
 * Create the completion buttons for the current state.
 */

- (void) createCompletionButtons {
	// Remove any old completion buttons.
    while (buttons.count > 0) {
        CodeCompletionButton *button = [buttons objectAtIndex: 0];
        [buttons removeObjectAtIndex: 0];
        [button removeFromSuperview];
    }
    
    // Create the new completion buttons.
    float left = self.frame.size.width/2.0;
    float right = left;
    BOOL doRight = YES;
    int index = 0;
    NSArray *codeCompletions = [self codeCompletions];
    BOOL done = codeCompletions.count == 0;
    
    while (!done) {
        CodeCompletionButton *compButton = [CodeCompletionButton buttonWithType: UIButtonTypeCustom];
        CodeCompletion *codeCompletion = codeCompletions[index++];
        compButton.codeCompletion = codeCompletion;
        [compButton setTitleColor: codeCompletion.color forState: UIControlStateNormal];
        [compButton addTarget: self action: @selector(completeCurrentWord:) forControlEvents: UIControlEventTouchUpInside];
        [compButton setTitle: codeCompletion.name forState: UIControlStateNormal];
        [compButton sizeToFit];

        CGRect frame = compButton.frame;
        frame.size.width += 16;
        if (frame.size.width < 30)
            frame.size.width = 30;
        frame.size.height = 30.0;
        frame.origin.y = 10.0;
        if (right == left) {
            frame.origin.x = left - frame.size.width/2.0;
            left = frame.origin.x;
            right = left + frame.size.width;
        } else if (doRight) {
            if (right + 2*SPACE + frame.size.width < self.frame.size.width) {
                frame.origin.x = right + SPACE;
                right = right + frame.size.width + SPACE;
                doRight = NO;
            } else if (left - 2*SPACE - frame.size.width > 0) {
                frame.origin.x = left - SPACE - frame.size.width;
                left = left - frame.size.width - SPACE;
                doRight = YES;
            } else
                done = YES;
        } else {
            if (left - 2*SPACE - frame.size.width > 0) {
                frame.origin.x = left - SPACE - frame.size.width;
                left = left - frame.size.width - SPACE;
                doRight = YES;
            } else if (right + 2*SPACE + frame.size.width < self.frame.size.width) {
                frame.origin.x = right + SPACE;
                right = right + frame.size.width + SPACE;
                doRight = NO;
            } else
                done = YES;
        }
        compButton.frame = frame;
        
        if (!done) {
            [self addSubview: compButton];
            [buttons addObject: compButton];
            
            done = index >= codeCompletions.count;
        }
    }
}

/*!
 * Do initializetion common to all initialization methods.
 */

- (void) initCodeInputAccessoryViewCommon {
    [self addGradient];
    self.buttons = [[NSMutableArray alloc] init];
    [self createCompletionButtons];
}

/*!
 * Sets the context used to determine code completions. This also resets the buttons in the accessory view.
 *
 * @param text			The text inthe editor.
 * @param selection		The current selection.
 */

- (void) setContext: (NSString *) theText selection: (NSRange) theSelection {
    self.text = theText;
    self.selection = theSelection;
    [self createCompletionButtons];
}

#pragma mark - UIView overrides

/*
 * Specifies receiver’s frame rectangle in the super-layer’s coordinate space.
 *
 * @param frame			The new frame.
 */

- (void) setBounds: (CGRect) bounds {
    [super setBounds: bounds];
    [self createCompletionButtons];
    [self addGradient];
}

/*!
 * Set the frame rectangle, which describes the view’s location and size in its superview’s coordinate system.
 *
 * Override forces a repaint so showing or hiding the keyboard does not streatch the text.
 */

- (void) setFrame: (CGRect) frame {
    [super setFrame: frame];
    [self createCompletionButtons];
    [self addGradient];
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
        [self initCodeInputAccessoryViewCommon];
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
        [self initCodeInputAccessoryViewCommon];
    }
    return self;
}

@end
