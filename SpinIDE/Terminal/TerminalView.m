//
//  TerminalView.m
//  SpinIDE
//
//	Implements the top level view for the terminal pane. This includes the button bar, terminal input pane and 
//	terminal output pane.
//
//  Created by Mike Westerfield on 4/10/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax, Inc. All rights reserved.
//

#import "TerminalView.h"

#import "CodeView.h"
#import "SplitView.h"


@interface TerminalView ()

@property (nonatomic, retain) CodeView *terminalInputView;	// The view that shows terminal input.
@property (nonatomic, retain) CodeView *terminalOutputView;	// The view that shows terminal output.
@property (nonatomic, retain) SplitView *splitView;			// The split view that holds the terminal input and output views.

@end



@implementation TerminalView

@synthesize terminalInputView;
@synthesize terminalOutputView;
@synthesize splitView;

/*!
 * Do initializetion common to all initialization methods.
 */

- (void) initTermialCommon {
    self.splitView = [[SplitView alloc] initWithFrame: self.bounds];
    
    self.terminalInputView = [[CodeView alloc] initWithFrame: [splitView.topView frame]];
    terminalInputView.backgroundColor = [UIColor yellowColor];
    splitView.topView = terminalInputView;
    
    self.terminalOutputView = [[CodeView alloc] initWithFrame: [splitView.bottomView frame]];
    terminalOutputView.backgroundColor = [UIColor blueColor];
    terminalOutputView.editable = NO;
    splitView.bottomView = terminalOutputView;
    
    splitView.location = 0.2;
    splitView.minimum = 0.1;
    splitView.maximum = 0.9;
    
    [self addSubview: splitView];
}

/*!
 * Returns an object initialized from data in a given unarchiver.
 *
 * @param encoder		An archiver object.
 *
 * @return				self, initialized using the data in decoder.
 */

- (id) initWithCoder: (NSCoder *) decoder {
    self = [super initWithCoder: decoder];
    if (self) {
        [self initTermialCommon];
    }
    return self;
}

/*!
 * Returns an initialized object.
 *
 * @param frame			A rectangle defining the frame of the UISwitch object.
 *
 * @return				An initialized AccessorizedTextView object or nil if the object could not be initialized.
 */

- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame: frame];
    if (self) {
        [self initTermialCommon];
    }
    return self;
}

/*!
 * Specifies receiver’s bounds rectangle.
 *
 * @param frame			The new bounds.
 */

- (void) setBounds: (CGRect) bounds {
    splitView.bounds = bounds;
    [super setBounds: bounds];
}

/*!
 * Specifies receiver’s frame rectangle in the super-layer’s coordinate space.
 *
 * @param frame			The new frame.
 */

- (void) setFrame: (CGRect) frame {
    splitView.frame = frame;
    [super setFrame: frame];
}

@end
