//
//  CodeInputAccessoryView.h
//  Spin IDE
//
//  Created by Mike Westerfield on 4/7/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PREFERRED_ACCESSORY_HEIGHT (40)						/* The preferred height for the accessory view. */

@protocol CodeInputAccessoryViewDelegate <NSObject>

@optional

/*!
 * Tells the delegate the user has selected code completion text.
 *
 * @param range			The range of text to replace.
 * @param text			The text to replace.
 */

- (void) codeInputAccessoryViewExtendingRange: (NSRange) range withText: (NSString *) text;

@end


@interface CodeInputAccessoryView : UIView

@property (nonatomic, assign) id<CodeInputAccessoryViewDelegate> codeInputAccessoryViewDelegate;
@property (nonatomic) NSRange selection;					// The current selection.
@property (nonatomic, retain) NSString *text;				// The current text.

- (void) setContext: (NSString *) text selection: (NSRange) selection;

@end
