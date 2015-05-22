//
//  CodeView.h
//  Spin IDE
//
//  Created by Mike Westerfield on 3/4/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_PARALLAX 1

#if IS_PARALLAX
#import "CodeInputAccessoryView.h"
#else
#import "BASICInputAccessoryView.h"
#endif
#import "CodeUndoManager.h"
#import "Common.h"


@class CodeView;


@protocol CodeViewDelegate <NSObject>

@optional

/*!
 * Tells the delegate that editing of the specified text view has begun.
 *
 * Implementation of this method is optional. A text view sends this message to its delegate immediately after 
 * the user initiates editing in a text view and before any changes are actually made. You can use this method 
 * to set up any editing-related data structures and generally prepare your delegate to receive future editing 
 * messages.
 *
 * @param tView			The text view in which editing began.
 */

- (void) codeViewDidBeginEditing: (CodeView *) tView;

/*!
 * Tells the delegate that the text selection changed in the specified text view.
 *
 * @param tView			The text view whose selection changed.
 */

- (void) codeViewDidChangeSelection: (CodeView *) tView;

/*!
 * Tells the delegate that editing of the specified text view has ended.
 *
 * Implementation of this method is optional. A text view sends this message to its delegate after it closes 
 * out any pending edits and resigns its first responder status. You can use this method to tear down any 
 * data structures or change any state information that you set when editing began.
 *
 * @param tView			The text view containing the changes.
 */

- (void) codeViewDidEndEditing: (CodeView *) tView;

/*!
 * Tells the delegate when the user scrolls the content view within the receiver.
 *
 * @param scrollView	The scroll-view object in which the scrolling occurred.
 */

- (void) codeViewDidScroll: (CodeView *) scrollView;

/*
 * Asks the delegate if editing should begin in the specified text view.
 *
 * When the user performs an action that would normally initiate an editing session, the text view calls this method first
 * to see if editing should actually proceed.
 *
 * Parameters:
 *	tView - The text view.
 *
 * Returns: YES if editing is allowed, else NO.
 */

- (BOOL) codeViewShouldBeginEditing: (CodeView *) tView;

/*
 * Asks the delegate whether the specified text should be replaced in the text view.
 *
 * Parameters:
 *  tView -  The text view containing the changes.
 *	range - The current selection range.
 *	text - The text to insert.
 *
 * Returns: YES if the old text should be replaced by the new text; NO if the replacement operation should be aborted.
 */

- (BOOL) codeView: (CodeView *) tView shouldChangeTextInRange: (NSRange) range replacementText: (NSString *) text;

/*!
 * Tells the delegate that user has requested a Find command via a keyboard shortcut.
 */

- (void) codeViewFind;

/*!
 * Tells the delegate that user has requested a Find Next command via a keyboard shortcut.
 */

- (void) codeViewFindNext;

/*!
 * Tells the delegate that user has requested a Find Previous command via a keyboard shortcut.
 */

- (void) codeViewFindPrevious;

/*!
 * Tells the delegate that the text has changed. This is typically used to update the status of the undo/redo menus.
 */

- (void) codeViewTextChanged;

@end


@interface CodeView : UIScrollView <UIScrollViewDelegate, UIKeyInput, UITextInputTraits, CodeInputAccessoryViewDelegate>

@property (nonatomic) BOOL allowEditMenu;				// If YES, the edit menu is shown four double-taps, etc. If NO, it is hidden.
@property (nonatomic, assign) id<CodeViewDelegate> codeViewDelegate;
@property (nonatomic, getter=isEditable) BOOL editable;	// Is the view currently editable?
@property (nonatomic) BOOL followIndentation;			// If YES, hitting return will add whitespace to match the start of the line above.
@property (nonatomic, retain) UIFont *font;				// The font for the view. This must be a monospaced font.
@property (nonatomic) int indentCharacters;				// The number of characters to indent when indenting code.
@property (nonatomic, retain) CodeInputAccessoryView *inputAccessoryView; // The keyboard input accessory view.
@property (nonatomic) languageType language;			// The language for the text in this view.
@property (nonatomic) NSRange selectedRange;			// The current selection.
@property (nonatomic, retain) NSString *text;			// The current contents of the view.
@property (nonatomic, retain) CodeUndoManager *undoManager;	// The undo manager for this document.
@property (nonatomic) BOOL useSyntaxColoring;			// Perform syntax coloring on the text?

@property(nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property(nonatomic) UITextAutocorrectionType autocorrectionType;
@property(nonatomic) UITextSpellCheckingType spellCheckingType;
@property(nonatomic) BOOL enablesReturnKeyAutomatically;
@property(nonatomic) UIKeyboardAppearance keyboardAppearance;
@property(nonatomic) UIKeyboardType keyboardType;
@property(nonatomic) UIReturnKeyType returnKeyType;
@property(nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;

- (void) didReceiveMemoryWarning;
- (void) deleteBackward;
- (CGRect) firstRectForRange: (NSRange) range;
- (void) purgeUndoBuffer;
- (void) replaceRange: (NSRange) range withText: (NSString *) text;
- (void) scrollRangeToVisible: (NSRange) range;
- (NSArray *) selectionRectsForRange: (NSRange) range;
- (void) setSelectedRangeNoUndoGroup: (NSRange) range;

@end
