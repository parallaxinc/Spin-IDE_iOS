//
//  SourceConsoleSplitView.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/12/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "SourceConsoleSplitView.h"


@interface SourceConsoleSplitView ()

@property (nonatomic, retain) SplitView *terminalConsoleSplitView;

@end


@implementation SourceConsoleSplitView

@synthesize consoleView;
@synthesize sourceView;
@synthesize terminalConsoleSplitView;
@synthesize terminalView;

/*
 * Do initializetion common to all initialization methods.
 */

- (void) initDebugViewCommon {
    // Create a horizontally split view with the terminal on the left and the console on the right.
    self.terminalConsoleSplitView = [[SplitView alloc] initWithFrame: bottomView.frame];
    
    self.terminalView = [[TerminalView alloc] initWithFrame: terminalConsoleSplitView.topView.frame];
    terminalView.backgroundColor = [UIColor greenColor];
    terminalConsoleSplitView.topView = terminalView;
    
    self.consoleView = [[UITextView alloc] initWithFrame: terminalConsoleSplitView.bottomView.frame];
    consoleView.editable = NO;
    terminalConsoleSplitView.bottomView = consoleView;
    
    terminalConsoleSplitView.location = 0.5;
    terminalConsoleSplitView.minimum = 0.0;
    terminalConsoleSplitView.maximum = 1.0;
    terminalConsoleSplitView.horizontalSplit = YES;
    
    // Set up the lain split view, with the source on top and the information views on the bottom.
    self.sourceView = [[SourceView alloc] initWithFrame: [topView frame]];
    sourceView.backgroundColor = [UIColor whiteColor];
    self.topView = sourceView;
    
    self.bottomView = terminalConsoleSplitView;

    self.location = 0.8;
    self.minimum = 0.1;
    self.maximum = 0.9;
}

/*
 * Returns an object initialized from data in a given unarchiver.
 *
 * Parameters:
 *  encoder - An archiver object.
 *
 * Returns: self, initialized using the data in decoder.
 */

- (id) initWithCoder: (NSCoder *) decoder {
    self = [super initWithCoder: decoder];
    if (self) {
        [self initDebugViewCommon];
    }
    return self;
}

/*
 * Returns an initialized object.
 *
 * Parameters:
 *  frame - A rectangle defining the frame of the UISwitch object.
 *
 * Returns: An initialized AccessorizedTextView object or nil if the object could not be initialized.
 */

- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame: frame];
    if (self) {
        [self initDebugViewCommon];
    }
    return self;
}

@end
