//
//  CodeRect.m
//  Spin IDE
//
//	This is a thin wrapper class for CGRect that allows it to be treated as an object.
//
//  Created by Mike Westerfield on 3/4/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "CodeRect.h"

@implementation CodeRect

@synthesize rect;

/*!
 * Returns an initialized rect object.
 *
 * @param x			The horizontal location of the rect.
 * @param y			The vertical location of the rect.
 * @param width		The width of the rect.
 * @param height	The height of the rect.
 *
 * @return			The initialized object.
 */

- (id) initWithX: (CGFloat) x y: (CGFloat) y width: (CGFloat) width height: (CGFloat) height {
    self = [super init];
    
    if (self) {
        rect = CGRectMake(x, y, width, height);
    }
    
    return self;
}

@end
