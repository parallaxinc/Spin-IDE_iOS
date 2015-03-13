//
//  CHighlighter.m
//  SimpleIDE
//
//	This subclass of Highlighter provides text highlighting for the C language.
//
//  Created by Mike Westerfield on 4/30/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html ).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "CHighlighter.h"

@implementation CHighlighter

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
        rule.color = [UIColor colorWithRed: 0.0 green: 0.4 blue: 0.8 alpha: 1.0];
        [self.rules addObject: rule];
        
        // Create the rule for function name patterns.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\b[A-Za-z0-9_]+[\\s]*(?=\\()" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 0.0 green: 0.0 blue: 1.0 alpha: 1.0];
        [self.rules addObject: rule];
        
        // Create the rule for number patterns.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\b\\d+" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 1.0 green: 0.0 blue: 1.0 alpha: 1.0];
        [self.rules addObject: rule];
        
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\b0x[0-9,a-f,A-F]*" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 1.0 green: 0.0 blue: 1.0 alpha: 1.0];
        [self.rules addObject: rule];
        
        // Create the rule for reserved word patterns.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\b(bauto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|struct|switch|register|return|short|signed|sizeof|static|typedef|union|unsigned|void|volatile|while)\\b" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 0.2 green: 0.0 blue: 0.6 alpha: 1.0];
        [self.rules addObject: rule];
        
        // Create the rule for preprocessor patterns.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\b(assert|class|define|defined|error|ident|import|include|include_next|line|pragma|public|private|unassert|undef|warning|int\\d+_t|uint\\d+_t|elif|ifdef|ifndef|endif)\\b" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 0.5 green: 0.5 blue: 0.0 alpha: 1.0];
        [self.rules addObject: rule];
        
        // Create the rule for quoted strings.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"[\"].*[\"]" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 1.0 green: 0.0 blue: 0.0 alpha: 1.0];
        [self.rules addObject: rule];
        
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"[<][a-z,A-Z].*[^-][>]" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 1.0 green: 0.0 blue: 0.0 alpha: 1.0];
        [self.rules addObject: rule];
        
        // Create the rule for single line comments.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"//[^\n]*" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 0.0 green: 0.5 blue: 0.0 alpha: 1.0];
        [self.rules addObject: rule];
        
        // Create the rule for multiline comments.
        self.multilineCommentStartExpression = [[NSRegularExpression alloc] initWithPattern: @"/\\*" options: 0 error: nil];
        self.multilineCommentEndExpression = [[NSRegularExpression alloc] initWithPattern: @"\\*/" options: 0 error: nil];
        self.multiLineCommentColor = [UIColor colorWithRed: 0.0 green: 0.5 blue: 0.0 alpha: 1.0];
    }
    
    return self;
}

@end
