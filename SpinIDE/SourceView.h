//
//  SourceView.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/30/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CodeView.h"
#import "Common.h"

@protocol SourceViewDelegate <NSObject>

@optional

/*!
 * Tells the delegate that user has requested a Find command via a keyboard shortcut.
 */

- (void) sourceViewFind;

/*!
 * Tells the delegate that user has requested a Find Next command via a keyboard shortcut.
 */

- (void) sourceViewFindNext;

/*!
 * Tells the delegate that user has requested a Find Previous command via a keyboard shortcut.
 */

- (void) sourceViewFindPrevious;

/*!
 * Notify the delegate that the text has changed in some way.
 */

- (void) sourceViewTextChanged;

@end


@interface SourceView : CodeView <CodeViewDelegate>

@property (weak, nonatomic) id<SourceViewDelegate> sourceViewDelegate;
@property (nonatomic, retain) NSString *path;				// The full path of the file being edited.

- (void) save;
- (void) setSource: (NSString *) text forPath: (NSString *) thePath;

@end
