//
//  Highlighter.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/30/14.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HighlighterRule.h"

@interface Highlighter : NSObject

@property (nonatomic, retain) NSDictionary *multiLineCommentAttributes;	// Character attributes for multiline comments.
@property (nonatomic, retain) NSRegularExpression *multilineCommentEndExpression; // The regular expression for the end of a multiline comment.
@property (nonatomic, retain) NSRegularExpression *multilineCommentStartExpression; // The regular expression for the start of a multiline comment.
@property (nonatomic, retain) NSMutableArray *rules;

- (NSAttributedString *) format: (NSString *) text;

@end
