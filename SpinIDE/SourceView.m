//
//  SourceView.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/30/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "SourceView.h"

#import "Common.h"


//
//	This class is used to record the selection range in files that have been opened, so the selection can be restored if the file is reopened.
//

@interface TextLocation : NSObject

@property (nonatomic, retain) NSString *path;
@property (nonatomic) NSRange range;

@end

@implementation TextLocation

@synthesize path;
@synthesize range;

@end

//
//	The implementation of SourceView begins here.
//

@interface SourceView () {
    BOOL dirty;												// YES if the file has changed since the last save or open.
}

@property (nonatomic, retain) NSMutableArray *textLocations;// An array of TextLocation objects; locations for previously opened files.

@end


@implementation SourceView

@synthesize language;
@synthesize path;
@synthesize sourceViewDelegate;
@synthesize textLocations;

#pragma mark - Misc

/*!
 * Do initializetion common to all initialization methods.
 */

- (void) initCommon {
    self.language = languageC;
    self.textLocations = [[NSMutableArray alloc] init];
    self.delegate = self;
    self.codeViewDelegate = self;
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
        [self initCommon];
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
        [self initCommon];
    }
    return self;
}

/*!
 * Save the current source file.
 *
 * This call does nothing, and flags no error, if self.path == nil.
 */

- (void) save {
    if (path) {
        // Save the current file.
        if (dirty) {
            NSError *error;
            [self.text writeToFile: path atomically: YES encoding: NSUTF8StringEncoding error: &error];
            if (error)
                [Common reportError: error];
            else
                dirty = NO;
        }
        
        // Remove the location of the last insertion point for this file (if there is one).
        for (int i = 0; i < textLocations.count; ++i) {
            TextLocation *textLocation = textLocations[i];
            if ([textLocation.path caseInsensitiveCompare: path] == NSOrderedSame) {
                [textLocations removeObjectAtIndex: i];
                break;
            }
        }
        
        // Record the location of the insertion point.
        TextLocation *textLocation = [[TextLocation alloc] init];
        textLocation.path = path;
        textLocation.range = self.selectedRange;
        [textLocations addObject: textLocation];
    }
}

/*!
 * Sets the source displayed in the view and highlights it. This is treated as opening a new file.
 *
 * @param text			The new text.
 * @param path			The full path of the file the text belongs to. Pass nil if there is no
 *						file, in which case an error is flagged if the user tried to edit.
 */

- (void) setSource: (NSString *) text forPath: (NSString *) thePath {
    // Save the current text.
    [self save];
    
    // Use the new file.
    [self setText: text];
    dirty = NO;
    self.path = thePath;
    
    // If the file has already been opened, use the last known insertion point.
    for (TextLocation *textLocation in textLocations)
        if ([textLocation.path caseInsensitiveCompare: path] == NSOrderedSame) {
            self.selectedRange = textLocation.range;
            CGRect rect = [self firstRectForRange: textLocation.range];
//            <<<this is not scrolling properly, and netiehr is the down arrow key. See http://stackoverflow.com/questions/22315755/ios-7-1-uitextview-still-not-scrolling-to-cursor-caret-after-new-line
            [self scrollRectToVisible: rect animated: NO];
        }
}

/*!
 * Update the source with a formatted attributed string.
 *
 * @param attributedText	The newly formatted attributed string.
 */

- (void) updateText: (NSAttributedString *) attributedText {
    NSRange selectedRange = self.selectedRange;
    [self setText: [attributedText string]]; // Rework when text is formatted. 
    self.selectedRange = selectedRange;
}

#pragma mark - UIResponder overrides

/*!
 * Notifies the receiver that it is about to become first responder in its window.
 *
 * Subclasses can override this method to update state or perform some action such as highlighting the selection.
 *
 * A responder object only becomes the first responder if the current responder can resign first-responder status 
 * (canResignFirstResponder) and the new responder can become first responder.
 *
 * You may call this method to make a responder object such as a view the first responder. However, you should 
 * only call it on that view if it is part of a view hierarchy. If the view’s window property holds a UIWindow 
 * object, it has been installed in a view hierarchy; if it returns nil, the view is detached from any hierarchy.
 *
 * @return				YES if the receiver accepts first-responder status or NO if it refuses this status. The 
 *						default implementation returns YES, accepting first responder status.
 */

- (BOOL) becomeFirstResponder {
    if (path)
        return [super becomeFirstResponder];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Open a File"
                                                    message: @"You must open a file or create a new one before editing it."
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];
    
    return NO;
}

#pragma mark - UICodeViewDelegate

/*!
 * Tells the delegate that the text has changed. This is typically used to update the status of the undo/redo menus.
 */

- (void) codeViewTextChanged {
    // Notify the delegate.
    if ([sourceViewDelegate respondsToSelector: @selector(sourceViewTextChanged)])
        [sourceViewDelegate sourceViewTextChanged];
    
    // Mark the file as dirty.
    dirty = YES;
}

/*!
 * Tells the delegate that user has requested a Find command via a keyboard shortcut.
 */

- (void) codeViewFind {
    if ([sourceViewDelegate respondsToSelector: @selector(sourceViewFind)])
        [sourceViewDelegate sourceViewFind];
}

/*!
 * Tells the delegate that user has requested a Find Next command via a keyboard shortcut.
 */

- (void) codeViewFindNext {
    if ([sourceViewDelegate respondsToSelector: @selector(sourceViewFindNext)])
        [sourceViewDelegate sourceViewFindNext];
}

/*!
 * Tells the delegate that user has requested a Find Previous command via a keyboard shortcut.
 */

- (void) codeViewFindPrevious {
    if ([sourceViewDelegate respondsToSelector: @selector(sourceViewFindPrevious)])
        [sourceViewDelegate sourceViewFindPrevious];
}

@end
