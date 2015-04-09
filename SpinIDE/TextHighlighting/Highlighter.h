//
//  Highlighter.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/30/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HighlighterRule.h"

@interface Highlighter : NSObject

@property (nonatomic, retain) UIColor *multiLineCommentColor;	// The text color for multiline comments.
@property (nonatomic, retain) NSRegularExpression *multilineCommentEndExpression; // The regular expression for the end of a multiline comment.
@property (nonatomic, retain) NSRegularExpression *multilineCommentStartExpression; // The regular expression for the start of a multiline comment.
@property (nonatomic, retain) NSMutableArray *rules;

- (NSArray *) highlightBlocks: (NSString *) theText;
- (NSArray *) multilineHighlights: (NSString *) theText;
- (NSArray *) wordHighlights: (NSString *) theText forRange: (NSRange) range;

@end
