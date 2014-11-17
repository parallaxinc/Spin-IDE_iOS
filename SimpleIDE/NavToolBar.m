//
//  NavToolBar.m
//  iosBASIC
//
//  Created by Mike Westerfield on 9/13/13 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html ).
//  Copyright (c) 2013 Byte Works, Inc. All rights reserved.
//

#import "NavToolBar.h"

@implementation NavToolBar
- (void) layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
}
- (void) drawRect:(CGRect)rect
{
}
@end
