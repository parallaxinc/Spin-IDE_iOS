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

@property (nonatomic, retain) NSDictionary *multiLineCommentAttributes;	// Character attributes for multiline comments.
@property (nonatomic, retain) NSRegularExpression *multilineCommentEndExpression; // The regular expression for the end of a multiline comment.
@property (nonatomic, retain) NSRegularExpression *multilineCommentStartExpression; // The regular expression for the start of a multiline comment.
@property (nonatomic, retain) NSMutableArray *rules;

- (void) format: (NSString *) text completionHandler: (void (^)(NSAttributedString *)) callbackBlock;
- (NSAttributedString *) setFont: (NSString *) text;

@end
