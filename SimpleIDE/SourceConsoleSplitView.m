//
//  SourceConsoleSplitView.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/12/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "SourceConsoleSplitView.h"

@implementation SourceConsoleSplitView

@synthesize consoleView;
@synthesize sourceView;

/*
 * Do initializetion common to all initialization methods.
 */

- (void) initDebugViewCommon {
    sourceView = [[SourceView alloc] initWithFrame: [topView frame]];
    [self setTopView: sourceView];
    
    consoleView = [[UITextView alloc] initWithFrame: [bottomView frame]];
    consoleView.editable = NO;
    [self setBottomView: consoleView];
    
    [self setLocation: 0.8];
    [self setMinimum: 0.1];
    [self setMaximum: 0.9];
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
