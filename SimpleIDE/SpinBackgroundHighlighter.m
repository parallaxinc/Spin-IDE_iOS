//
//  SpinBackgroundHighlighter.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/16/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "SpinBackgroundHighlighter.h"


typedef enum {blockNone, blockCON, blockVAR, blockOBJ, blockPUB, blockPRI, blockDAT} blockType;
typedef enum {tCON, tVAR, tOBJ, tPUB, tPRI, tDAT, tEOF, tNone} tokenType;

#define EOF (-1)									/* The character code indicating the end of file. */


@interface SpinBackgroundHighlighter () {
    int ch;											// The next character to process. Also returned by nextCh.
    BOOL lastWasWordStart;							// Was the last character scanned one that indicates the start of a new token? (e.e.g, not alphanum.)
    int lineStart;									// The offset of the start of the line containing the current token.
    int offset;										// The offset of the next character in the text. (Offset for the character past ch.)
}

@property (nonatomic, retain) NSArray *blockColors;	// Array of NSDictionary text attributes for the normally shaded blocks, indexed by 
													// tokenType. Index is [tCON..tDAT].
@property (nonatomic, retain) NSArray *darkBlockColors;	// Array of NSDictionary text attributes for the darkly shaded blocks, indexed 
													// by tokenType. Index is [tCON..tDAT].
@property (nonatomic, retain) NSString *text;		// The text to scan.

@end


@implementation SpinBackgroundHighlighter

@synthesize blockColors;
@synthesize darkBlockColors;
@synthesize text;

/*!
 * Apply spin background highlighting to the blocks in the spin file.
 *
 * @param attributedText	The text to highlight. Attributes for the highlighting are added to this attributed text string.
 */

- (void) highlightBlocks: (NSMutableAttributedString *) attributedText {
    int lastLineStart = 0;							// Offset of the start of the line containing lastToken.
    tokenType lastToken = tNone;					// This is the last block type processed, or tNone for the first block.
    tokenType lastLastToken = tNone;				// This is the block type processed before lastToken, or tNone for the first block.
    BOOL lastWasDark = YES;							// Was the last block darkened due to it being the second similar block in a row?
    
    offset = 0;
    ch = ' ';
    lineStart = 0;
    self.text = attributedText.string;

    tokenType token = [self nextToken];
    while (lastToken != tEOF) {
        // Determine the color for the block ending with the current token.
        if (lastToken <= tDAT) {
            NSDictionary *blockColor = blockColors[lastToken];
            if (lastLastToken == lastToken && !lastWasDark) {
                lastWasDark = YES;
                blockColor = darkBlockColors[lastToken];
            } else
                lastWasDark = NO;
            
            // Color the block completed by the current token.
            if (token == tEOF)
                // This handles files that don't end in a line feed, making sure the last line is highlighted.
                lineStart = attributedText.length;
            NSRange textRange = {lastLineStart, lineStart - lastLineStart};
            [attributedText addAttributes: blockColor range: textRange];
        }
        
        // Update the state.
        if (lastToken != tNone)
	        lastLineStart = lineStart;
        lastLastToken = lastToken;
        lastToken = token;
        
        token = [self nextToken];
    }
}

/*!
 * Returns an initialized object.
 *
 * @return			The initialized object.
 */

- (id) init {
    self = [super init];
    
    if (self) {
        self.blockColors = [NSArray arrayWithObjects:
                            [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 255.0/255.0 green: 248.0/255.0 blue: 192.0/255.0 alpha: 1.0],
                             NSBackgroundColorAttributeName, nil], // CON
                            [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 255.0/255.0 green: 223.0/255.0 blue: 191.0/255.0 alpha: 1.0],
                             NSBackgroundColorAttributeName, nil], // VAR
                            [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 255.0/255.0 green: 191.0/255.0 blue: 191.0/255.0 alpha: 1.0],
                             NSBackgroundColorAttributeName, nil], // OBJ
                            [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 191.0/255.0 green: 223.0/255.0 blue: 255.0/255.0 alpha: 1.0],
                             NSBackgroundColorAttributeName, nil], // PUB
                            [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 191.0/255.0 green: 248.0/255.0 blue: 255.0/255.0 alpha: 1.0],
                             NSBackgroundColorAttributeName, nil], // PRI
                            [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 191.0/255.0 green: 255.0/255.0 blue: 200.0/255.0 alpha: 1.0],
                             NSBackgroundColorAttributeName, nil], // DAT
                            nil];
        self.darkBlockColors = [NSArray arrayWithObjects:
                            [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 0.9*255.0/255.0 green: 0.9*248.0/255.0 blue: 0.9*192.0/255.0 alpha: 1.0],
                             NSBackgroundColorAttributeName, nil], // CON
                            [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 0.9*255.0/255.0 green: 0.9*223.0/255.0 blue: 0.9*191.0/255.0 alpha: 1.0],
                             NSBackgroundColorAttributeName, nil], // VAR
                            [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 0.9*255.0/255.0 green: 0.9*191.0/255.0 blue: 0.9*191.0/255.0 alpha: 1.0],
                             NSBackgroundColorAttributeName, nil], // OBJ
                            [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 0.9*191.0/255.0 green: 0.9*223.0/255.0 blue: 0.9*255.0/255.0 alpha: 1.0],
                             NSBackgroundColorAttributeName, nil], // PUB
                            [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 0.9*191.0/255.0 green: 0.9*248.0/255.0 blue: 0.9*255.0/255.0 alpha: 1.0],
                             NSBackgroundColorAttributeName, nil], // PRI
                            [[NSDictionary alloc] initWithObjectsAndKeys: [UIColor colorWithRed: 0.9*191.0/255.0 green: 0.9*255.0/255.0 blue: 0.9*200.0/255.0 alpha: 1.0],
                             NSBackgroundColorAttributeName, nil], // DAT
                            nil];
    }
    
    return self;
}

/*!
 * Get the next character in the file.
 *
 * @return			The next character in the file.
 */

- (int) nextCh {
    if (offset >= text.length)
        ch = EOF;
    else 
        ch = [text characterAtIndex: offset++];
    return ch;
}

/*!
 * Finds and returns the next token in the file.
 *
 * The file is the characters contained in the string text. Only some tokns are really scanned; others are skipped
 * as if they were comments.
 */

- (tokenType) nextToken {
    // Scan the file, looking for the tokens we care about. Ignore all others.
    tokenType token = tNone;
    while (token == tNone) {
        switch (ch) {
            case '\n': // End of line
                lineStart = offset;
                lastWasWordStart = YES;
                [self nextCh];
                break;
                
            case EOF: // End of file
                token = tEOF;
                break;
                
            case '\'': // Comment to end of line
                while (ch != '\n' && ch != EOF)
                    ch = [self nextCh];
                lastWasWordStart = YES;
                break;
                
            case '{': { // Block comment.
                ch = [self nextCh];
                if (ch == '\n')
                    lineStart = offset;
                BOOL docComment = ch == '{';
                BOOL done = NO;
                while (!done) {
                    if (ch == EOF)
                        done = YES;
                    else if (ch == '\n') {
                        lineStart = offset;
                        [self nextCh];
                    } else if (ch == '}') {
                        if (docComment) {
                            [self nextCh];
                            if (ch == '}')
                                done = YES;
                        } else
                            done = YES;
                        [self nextCh];
                    } else
                        [self nextCh];
                }
                lastWasWordStart = YES;
                break;
            }
                
            case '"':
                [self nextCh];
                while (ch != '\n' && ch != EOF && ch != '"')
                    ch = [self nextCh];
                lastWasWordStart = YES;
                break;
                
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                while ((ch >= '0' && ch <= '9') || ch == '_')
                    [self nextCh];
                lastWasWordStart = YES;
                break;
                
            case 'c':
            case 'C':
                if (lastWasWordStart) {
                    [self nextCh];
                    if (toupper(ch) == 'O') {
                        [self nextCh];
                        if (toupper(ch) == 'N') {
                            [self nextCh];
                            if (isalnum(ch))
                                lastWasWordStart = NO;
                            else
                                token = tCON;
                        }
                    }
                } else
                    [self nextCh];
                
            case 'd':
            case 'D':
                if (lastWasWordStart) {
                    [self nextCh];
                    if (toupper(ch) == 'A') {
                        [self nextCh];
                        if (toupper(ch) == 'T') {
                            [self nextCh];
                            if (isalnum(ch))
                                lastWasWordStart = NO;
                            else
                                token = tDAT;
                        }
                    }
                } else
                    [self nextCh];
                
            case 'o':
            case 'O':
                if (lastWasWordStart) {
                    [self nextCh];
                    if (toupper(ch) == 'B') {
                        [self nextCh];
                        if (toupper(ch) == 'J') {
                            [self nextCh];
                            if (isalnum(ch))
                                lastWasWordStart = NO;
                            else
                                token = tOBJ;
                        }
                    }
                } else
                    [self nextCh];
                
            case 'p':
            case 'P':
                if (lastWasWordStart) {
                    [self nextCh];
                    int ch2 = toupper(ch);
                    if (ch2 == 'R') {
                        [self nextCh];
                        if (toupper(ch) == 'I') {
                            [self nextCh];
                            if (isalnum(ch))
                                lastWasWordStart = NO;
                            else
                                token = tPRI;
                        }
                    } else if (ch2 == 'U') {
                        [self nextCh];
                        if (toupper(ch) == 'B') {
                            [self nextCh];
                            if (isalnum(ch))
                                lastWasWordStart = NO;
                            else
                                token = tPUB;
                        }
                    }
                } else
                    [self nextCh];
                
            case 'v':
            case 'V':
                if (lastWasWordStart) {
                    [self nextCh];
                    if (toupper(ch) == 'A') {
                        [self nextCh];
                        if (toupper(ch) == 'R') {
                            [self nextCh];
                            if (isalnum(ch))
                                lastWasWordStart = NO;
                            else
                                token = tVAR;
                        }
                    }
                } else
                    [self nextCh];

            default:
                lastWasWordStart = !isalnum(ch);
                [self nextCh];
                break;
        }
    }
    return token;
}

@end
