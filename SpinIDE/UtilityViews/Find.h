//
//  Find.h
//  iosBASIC
//
//  Created by Mike Westerfield on 6/8/11 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CodeView.h"

@interface Find : NSObject

@property (nonatomic, retain) NSString *findString;			// The string to find.
@property (nonatomic, retain) NSString *replaceString;		// The replace string.
@property (nonatomic) BOOL backwardSearch;					// Search backwards?
@property (nonatomic) BOOL caseSensitive;					// Is the search case sensitive?
@property (nonatomic) BOOL wholeWord;						// Search for whole words?
@property (nonatomic) BOOL wrap;							// Wrap around if the end of file is reached?

+ (Find *) defaultFind;
- (int) find: (CodeView *) text;
- (int) replace: (CodeView *) text;
- (int) replaceAll: (CodeView *) text;
- (int) replaceAndFind: (CodeView *) text;
- (BOOL) wholeWordOK: (CodeView *) text atSelection: (NSRange) selection;

@end
