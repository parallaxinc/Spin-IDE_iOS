//
//  CodeUndo.m
//  Spin IDE
//
//	Encapsulates an undo object for CodeView. These objects are managed by NSUndoManager.
//
//  Created by Mike Westerfield on 3/31/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "CodeUndo.h"


typedef enum {insertionOperation, backDeletionOperation, selectionOperation} operationType;


@interface CodeUndo () {
    BOOL redo;											// YES if this is a redo object (it has been undone, and hte next 
    													// action is to redo it) else NO if this is a undo object (the 
    													// action was taked, and needs to be redone.
    operationType operation;							// The kind of undo operation.
    NSRange selectionRange;								// The selection range at the start of the operation.
}

@property (nonatomic, retain) NSString *insertedString;	// The string containing inserted text, or nil if there is none.
@property (nonatomic, retain) NSString *removedString;	// The string containing removed text, or nil if there is none.

@end


@implementation CodeUndo

@synthesize insertedString;
@synthesize removedString;

/*!
 * Get a redo object that can redo this undo.
 *
 * @return				The redo object.
 */

- (CodeUndo *) redoObject {
    CodeUndo *undoObject = [[CodeUndo alloc] init];
    
    switch (operation) {
        case insertionOperation: {
            undoObject->selectionRange = selectionRange;
            undoObject.insertedString = insertedString;
            undoObject.removedString = removedString;
            undoObject->redo = !redo;
            undoObject->operation = insertionOperation;
            break;
        }
            
        case backDeletionOperation: {
            undoObject->selectionRange = selectionRange;
            undoObject.insertedString = insertedString;
            undoObject.removedString = removedString;
            undoObject->redo = !redo;
            undoObject->operation = backDeletionOperation;
            break;
        }
            
        case selectionOperation: {
            undoObject->selectionRange = selectionRange;
            undoObject->redo = !redo;
            undoObject->operation = selectionOperation;
        }
    }
    
    return undoObject;
}

/*!
 * Create and return a new undo object that encapsulates deletion of text by hitting the back delte key, possibly deleting 
 * an existing selection as well.
 *
 * @param theRange		The selection range at the start of the operation. Pass a zero length for back deletion with no selection.
 * @param removedText	The deleted text. This must not be nil.
 *
 * @return				An undo object which can be passed to NSUndoManager registerUndoWithTarget:selector:object:.
 */

+ (CodeUndo *) undoBackDeletion: (NSRange) theRange removedText: (NSString *) removedText {
    CodeUndo *undoObject = [[CodeUndo alloc] init];
    
    undoObject->selectionRange = theRange;
    undoObject.removedString = removedText;
    undoObject->redo = NO;
    undoObject->operation = backDeletionOperation;
    
    return undoObject;
}

/*!
 * Create and return a new undo object that encapsulates insertion of text by typing, possibly deleting an existing selection.
 *
 * @param theRange		The selection range at the start of the operation.
 * @param insertedText	The text inserted in the text string.
 * @param removedText	If there was a selection, this is the selected text that the inserted text replaced. Pass nil if there
 *						is no removed text.
 *
 * @return				An undo object which can be passed to NSUndoManager registerUndoWithTarget:selector:object:.
 */

+ (CodeUndo *) undoInsertion: (NSRange) theRange insertedText: (NSString *) insertedText removedText: (NSString *) removedText {
    CodeUndo *undoObject = [[CodeUndo alloc] init];
    
    undoObject->selectionRange = theRange;
    undoObject.insertedString = insertedText;
    undoObject.removedString = removedText;
    undoObject->redo = NO;
    undoObject->operation = insertionOperation;
    
    return undoObject;
}

/*!
 * Create and return a new undo object that records a selection for later redo.
 *
 * @param theRange		The selection range at the start of the operation.
 *
 * @return				An undo object which can be passed to NSUndoManager registerUndoWithTarget:selector:object:.
 */

+ (CodeUndo *) undoSelection: (NSRange) theRange {
    CodeUndo *undoObject = [[CodeUndo alloc] init];
    
    undoObject->selectionRange = theRange;
    undoObject->redo = NO;
    undoObject->operation = selectionOperation;
    
    return undoObject;
}

/*!
 * Perform the undo operation indicated by this object on the passed text.
 *
 * @param codeView		The CodeView object on which to undo the action.
 *
 * @return				The modified text.
 */

- (void) undo: (CodeView *) codeView {
    switch (operation) {
        case insertionOperation: {
            if (redo) {
                NSRange range;
                range.location = selectionRange.location;
                range.length = removedString ? removedString.length : 0;
                codeView.text = [codeView.text stringByReplacingCharactersInRange: range withString: insertedString ? insertedString : @""];
                
                range.location = selectionRange.location + (insertedString ? insertedString.length : 0);
                range.length = 0;
                [codeView setSelectedRangeNoUndoGroup: range];
            } else {
                NSRange range;
                range.location = selectionRange.location;
                range.length = insertedString ? insertedString.length : 0;
                
                codeView.text = [codeView.text stringByReplacingCharactersInRange: range withString: removedString ? removedString : @""];
                [codeView setSelectedRangeNoUndoGroup: selectionRange];
            }
            break;
        }

        case backDeletionOperation: {
            if (redo) {
                NSRange range;
                if (selectionRange.length == 0) {
                    // The deletion deleted that character behind the cursor.
                    range.location = selectionRange.location - 1;
                    range.length = 0;
                    [codeView setSelectedRangeNoUndoGroup: range];
                    range.length = 1;
                } else {
                    // The deletion deleted selected text.
                    range.location = selectionRange.location;
                    range.length = 0;
                    [codeView setSelectedRangeNoUndoGroup: range];
                    range.length = selectionRange.length;
                }
                codeView.text = [codeView.text stringByReplacingCharactersInRange: range withString: @""];
            } else {
                NSRange range;
                if (selectionRange.length == 0) {
                    // The deletion deleted that character behind the cursor.
                    range.location = selectionRange.location - 1;
                } else {
                    // The deletion deleted selected text.
                    range.location = selectionRange.location;
                }
                range.length = 0;
                
                codeView.text = [codeView.text stringByReplacingCharactersInRange: range withString: removedString];
                [codeView setSelectedRangeNoUndoGroup: selectionRange];
            }
            break;
        }
            
        case selectionOperation:
            if (!redo) {
                [codeView setSelectedRangeNoUndoGroup: selectionRange];
            }
            break;
	}
}

@end
