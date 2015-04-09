//
//  CodeUndo.h
//  Spin IDE
//
//  Created by Mike Westerfield on 3/31/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CodeView.h"

@interface CodeUndo : NSObject

- (CodeUndo *) redoObject;
+ (CodeUndo *) undoBackDeletion: (NSRange) theRange removedText: (NSString *) removedText;
+ (CodeUndo *) undoInsertion: (NSRange) range insertedText: (NSString *) theText removedText: (NSString *) removedText;
+ (CodeUndo *) undoSelection: (NSRange) theRange;
- (void) undo: (CodeView *) codeView;

@end
