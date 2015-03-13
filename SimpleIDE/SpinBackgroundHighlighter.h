//
//  SpinBackgroundHighlighter.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/16/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpinBackgroundHighlighter : NSObject

- (NSArray *) highlightBlocks: (NSString *) theText;

@end
