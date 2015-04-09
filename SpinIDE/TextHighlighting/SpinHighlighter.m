//
//  SpinHighlighter.m
//  SimpleIDE
//
//	This subclass of Highlighter provides text highlighting for the Spin language.
//
//  Created by Mike Westerfield on 5/5/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "SpinHighlighter.h"

#import "SpinBackgroundHighlighter.h"


@interface SpinHighlighter ()

@property (nonatomic, retain) SpinBackgroundHighlighter *spinBackgroundHighlighter;

@end


@implementation SpinHighlighter

@synthesize spinBackgroundHighlighter;

/*!
 * Apply background highlighting.
 *
 * @param theText		The text to highlight.
 *
 * @return				An array of ColoredRange objects that describe how to color the background, or nil.
 */

- (NSArray *) highlightBlocks: (NSString *) theText {
    return [spinBackgroundHighlighter highlightBlocks: theText];
}

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
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\b\\d[\\d_]*" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 1.0 green: 0.0 blue: 1.0 alpha: 1.0];
        [self.rules addObject: rule];
        
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"[$][A-Za-z0-9_]*" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 1.0 green: 0.0 blue: 1.0 alpha: 1.0];
        [self.rules addObject: rule];
        
        // Create the rule for reserved word patterns.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\babort\\b|={2,}|\\+{2,}|-{2,}|_{2,}|\\\\{2,}|\\belif\\b|\\bifdef\\b|\\bendif\\b" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 0.2 green: 0.0 blue: 0.6 alpha: 1.0];
        [self.rules addObject: rule];
        
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"\\b(?i)(not|float|round|trunc|constant|string|con|dat|obj|pub|pri|var|dev|byte|word|long|precompile|archive|file|if|ifnot|elseif|elseifnot|else|case|other|repeat|while|until|from|to|step|next|quit|abort|return|lookup|lookupz|lookdown|lookdownz|clkmode|clkfreq|chipver|reboot|cognew|strsize|strcmp|bytefill|wordfill|longfill|bytemove|wordmove|longmove|waitpeq|waitpne|waitcnt|waitvid|clkset|cogid|coginit|cogstop|lokcnew|lockret|lockset|lockclr|orgx|org|fit|nop|IF_NC_AND_NZ|IF_NZ_AND_NC|IF_A|IF_NC_AND_Z|IF_Z_AND_NC|IF_NC|IF_AE|IF_C_AND_NZ|IF_NZ_AND_C|IF_NZ|IF_NE|IF_C_NE_Z|IF_Z_NE_C|IF_NC_OR_NZ|IF_NZ_OR_NC|IF_C_AND_Z|IF_Z_AND_C|IF_C_EQ_Z|IF_Z_EQ_C|IF_Z|IF_E|IF_NC_OR_Z|IF_Z_OR_NC|IF_C|IF_B|IF_C_OR_NZ|IF_NZ_OR_C|IF_C_OR_Z|IF_Z_OR_C|IF_BE|IF_ALWAYS|IF_NEVER|WRBYTE|RDBYTE|WRWORD|RDWORD|WRLONG|RDLONG|HUBOP|MUL|MULS|ENC|ONES|ROR|ROL|SHR|SHL|RCR|RCL|SAR|REV|MINS|MAXS|MIN|MAX|MOVS|MOVD|MOVI|JMPRET|ANDN|XOR|MUXC|MUXNC|MUXZ|MUXNZ|ADD|SUB|ADDABS|SUBABS|SUMC|SUMNC|SUMZ|SUMNZ|MOV|NEG|ABS|ABSNEG|NEGC|NEGNC|NEGZ|NEGNZ|CMPS|CMPSX|ADDX|SUBX|ADDS|SUBS|ADDSX|SUBSX|CMPSUB|DJNZ|TJNZ|TJZ|CALL|RET|JMP|TEST|TESTN|CMP|CMPX|WZ|WC|WR|NR|PAR|CNT|INA|INB|OUTA|OUTB|DIRA|DIRB|CTRA|CTRB|FRQA|FRQB|PHSA|PHSB|VCFG|VSCL|RESULT|FALSE|TRUE|NEGX|POSX|PI|RCFAST|RCSLOW|XINPUT|XTAL1|XTAL2|XTAL3|PLL1X|PLL2X|PLL4X|PLL8X|PLL16X)(?-i)\\b" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 0.4 green: 0.4 blue: 0.0 alpha: 1.0];
        [self.rules addObject: rule];

        // Create the rule for quoted strings.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"[\"].*[\"]" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 1.0 green: 0.0 blue: 0.0 alpha: 1.0];
        [self.rules addObject: rule];
        
        // Create the rule for single line comments.
        rule = [[HighlighterRule alloc] init];
        rule.rule = [[NSRegularExpression alloc] initWithPattern: @"'[^\n]*" options: 0 error: nil];
        rule.color = [UIColor colorWithRed: 0.0 green: 0.5 blue: 0.0 alpha: 1.0];
        [self.rules addObject: rule];
        
        // Create the rule for multiline comments.
        self.multilineCommentStartExpression = [[NSRegularExpression alloc] initWithPattern: @"[{]" options: 0 error: nil];
        self.multilineCommentEndExpression = [[NSRegularExpression alloc] initWithPattern: @"[}]+" options: 0 error: nil];
        self.multiLineCommentColor = [UIColor colorWithRed: 0.0 green: 0.5 blue: 0.0 alpha: 1.0];
        
        // Allocate a background highlighter.
        spinBackgroundHighlighter = [[SpinBackgroundHighlighter alloc] init];
    }
    
    return self;
}

/*!
 * Returns YES for spin syntax highlighting, or NO for other languages. Overridden in the SpinHighlighter subclass.
 *
 * @return			YES for spin highlighting, else NO.
 */

- (BOOL) isSpin {
    return YES;
}

@end
