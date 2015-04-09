//
//  CodeView.h
//  Spin IDE
//
//  Created by Mike Westerfield on 3/4/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CodeInputAccessoryView.h"
#import "CodeUndoManager.h"
#import "Common.h"

@protocol CodeViewDelegate <NSObject>

@optional

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


@interface CodeView : UIScrollView <UIScrollViewDelegate, UIKeyInput, UITextInputTraits>

@property (weak, nonatomic) id<CodeViewDelegate> codeViewDelegate;
@property (nonatomic) UIFont *font;						// The font for the view. This must be a monospaced font.
@property (nonatomic) int indentCharacters;				// The number of characters to indent when indenting code.
@property (nonatomic, retain) CodeInputAccessoryView *inputAccessoryView; // The keyboard input accessory view.
@property (nonatomic) languageType language;			// The language for the text in this view.
@property (nonatomic) NSRange selectedRange;			// The current selection.
@property (nonatomic, retain) NSString *text;			// The current contents of the view.
@property (nonatomic, retain) CodeUndoManager *undoManager;	// The undo manager for this document.

@property(nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property(nonatomic) UITextAutocorrectionType autocorrectionType;
@property(nonatomic) UITextSpellCheckingType spellCheckingType;

- (void) didReceiveMemoryWarning;
- (CGRect) firstRectForRange: (NSRange) range;
- (void) scrollRangeToVisible: (NSRange) range;
- (void) setSelectedRangeNoUndoGroup: (NSRange) range;

@end
