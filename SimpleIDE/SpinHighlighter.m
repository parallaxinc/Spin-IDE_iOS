//
//  SpinHighlighter.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 5/5/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html ).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "SpinHighlighter.h"

@implementation SpinHighlighter

/*!
 * Returns an initialized highlighter object for C.
 *
 * @return			The initialized object.
 */

- (id) init {
    self = [super init];
    
    if (self) {
        // Create the rule for identifier patterns.
        HighlighterRule *rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\b[A-Za-z0-9_]+" options: 0 error: nil];
        rule.attributes = [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 0.0 green: 0.4 blue: 0.8 alpha: 1.0], NSForegroundColorAttributeName, nil];
        [self.rules addObject: rule];
        
        // Create the rule for function name patterns.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\b[A-Za-z0-9_]+[\\s]*(?=\\()" options: 0 error: nil];
        rule.attributes = [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 0.0 green: 0.0 blue: 1.0 alpha: 1.0], NSForegroundColorAttributeName, nil];
        [self.rules addObject: rule];
        
        // Create the rule for number patterns.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\b\\d+" options: 0 error: nil];
        rule.attributes = [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 1.0 green: 0.0 blue: 1.0 alpha: 1.0], NSForegroundColorAttributeName, nil];
        [self.rules addObject: rule];
        
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\b0x[0-9,a-f,A-F]*" options: 0 error: nil];
        rule.attributes = [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 1.0 green: 0.0 blue: 1.0 alpha: 1.0], NSForegroundColorAttributeName, nil];
        [self.rules addObject: rule];
        
        // Create the rule for reserved word patterns.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\babort\\b|={2,}|\\+{2,}|-{2,}|_{2,}|\\\\{2,}|\\belif\\b|\\bifdef\\b|\\bendif\\b" options: 0 error: nil];
        rule.attributes = [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 0.2 green: 0.0 blue: 0.6 alpha: 1.0], NSForegroundColorAttributeName, nil];
        [self.rules addObject: rule];
        
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\b(con|dat|obj|pub|pri|var|define|defined|error|include|undef|warning)\\b" options: 0 error: nil];
        rule.attributes = [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 0.4 green: 0.4 blue: 0.0 alpha: 1.0], NSForegroundColorAttributeName, nil];
        [self.rules addObject: rule];

        // Create the rule for quoted strings.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"[\"].*[\"]" options: 0 error: nil];
        rule.attributes = [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 1.0 green: 0.0 blue: 0.0 alpha: 1.0], NSForegroundColorAttributeName, nil];
        [self.rules addObject: rule];
        
        // Create the rule for single line comments.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"//[^\n]*" options: 0 error: nil];
        rule.attributes = [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 0.0 green: 0.5 blue: 0.0 alpha: 1.0], NSForegroundColorAttributeName, nil];
        [self.rules addObject: rule];
        
        // Create the rule for multiline comments.
        self.multilineCommentStartExpression = [[NSRegularExpression alloc] initWithPattern: @"/\\*" options: 0 error: nil];
        self.multilineCommentEndExpression = [[NSRegularExpression alloc] initWithPattern: @"\\*/" options: 0 error: nil];
        self.multiLineCommentAttributes = [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 0.0 green: 0.5 blue: 0.0 alpha: 1.0], NSForegroundColorAttributeName, nil];
    }
    
    return self;
}

@end
