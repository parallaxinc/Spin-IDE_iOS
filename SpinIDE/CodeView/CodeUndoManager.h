//
//  CodeUndoManager.h
//  Spin IDE
//
//  Created by Mike Westerfield on 3/31/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeUndoManager : NSUndoManager

- (void) beginNewUndoGroup;

@end
