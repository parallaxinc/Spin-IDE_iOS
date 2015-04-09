//
//  CodeUndoManager.m
//  Spin IDE
//
//	A wrapper for NSUndoManager that handles undo groups. The editor should call beginNewUndoGroup whenever an editing
//	change (such as a cursor move) warrants grouping subsequent changes into a new group. No other calls regarding
//	grouping are needed.
//
//  Created by Mike Westerfield on 3/31/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "CodeUndoManager.h"

@implementation CodeUndoManager

/*!
 * Call this method when an editing operation causes subsequent canges to be part of a new undo group, e.g. when the
 * cursor moves between typing characters.
 */

- (void) beginNewUndoGroup {
    while (self.groupingLevel > 0)
        [self endUndoGrouping];
}

/*!
 * Handle grouping of redo commands by starting and stopping a group as the undo operation progresses. This groups the
 * redo objects in the same way they were grouped for undo.
 *
 * @param notification		This kind of undo notification to handle.
 */

- (void) doGroupForNotification: (NSNotification *) notification {
    if ([notification.name isEqualToString: NSUndoManagerWillUndoChangeNotification])
        [self beginUndoGrouping];
    else if ([notification.name isEqualToString: NSUndoManagerDidUndoChangeNotification])
        [self endUndoGrouping];
    else if ([notification.name isEqualToString: NSUndoManagerWillRedoChangeNotification])
        [self beginUndoGrouping];
    else if ([notification.name isEqualToString: NSUndoManagerDidRedoChangeNotification])
        [self endUndoGrouping];
}

/*!
 * Returns an initialized highlighter object for C.
 *
 * @return			The initialized object.
 */

- (id) init {
    self = [super init];
    
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver: self 
//                                                 selector: @selector(doGroupForNotification:) 
//                                                     name: NSUndoManagerCheckpointNotification 
//                                                   object: self];
//        [[NSNotificationCenter defaultCenter] addObserver: self 
//                                                 selector: @selector(doGroupForNotification:) 
//                                                     name: NSUndoManagerDidOpenUndoGroupNotification 
//                                                   object: self];
        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector(doGroupForNotification:) 
                                                     name: NSUndoManagerDidRedoChangeNotification 
                                                   object: self];
        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector(doGroupForNotification:) 
                                                     name: NSUndoManagerDidUndoChangeNotification 
                                                   object: self];
//        [[NSNotificationCenter defaultCenter] addObserver: self 
//                                                 selector: @selector(doGroupForNotification:) 
//                                                     name: NSUndoManagerWillCloseUndoGroupNotification 
//                                                   object: self];
//        [[NSNotificationCenter defaultCenter] addObserver: self 
//                                                 selector: @selector(doGroupForNotification:) 
//                                                     name: NSUndoManagerDidCloseUndoGroupNotification 
//                                                   object: self];
        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector(doGroupForNotification:) 
                                                     name: NSUndoManagerWillRedoChangeNotification
                                                   object: self];
        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector(doGroupForNotification:) 
                                                     name: NSUndoManagerWillUndoChangeNotification
                                                   object: self];
    }
    
    return self;
}

/*!
 * Records a single undo operation for a given target, so that when an undo is performed it is sent a specified 
 * selector with a given object as the sole argument.
 *
 * @param target		The target of the undo operation.
 * @param aSelector		The selector for the undo operation.
 * @param anObject		The argument sent with the selector.
 */

- (void) registerUndoWithTarget: (id) target selector: (SEL) aSelector object: (id) anObject {
    if (self.groupingLevel == 0)
        [self beginUndoGrouping];
    [super registerUndoWithTarget: target selector: aSelector object: anObject];
}

/*!
 * Closes the top-level undo group if necessary and invokes undoNestedGroup.
 *
 * This method also invokes endUndoGrouping if the nesting level is 1. Raises an NSInternalInconsistencyException 
 * if more than one undo group is open (that is, if the last group isn’t at the top level).
 *
 * This method posts an NSUndoManagerCheckpointNotification.
 *
 * This override also makes sure any open group is closed, which is necessary to prevent an exception from the
 * undo manager.
 */

- (void) undo {
    while (self.groupingLevel > 0)
        [self endUndoGrouping];
    [super undo];
}

@end
