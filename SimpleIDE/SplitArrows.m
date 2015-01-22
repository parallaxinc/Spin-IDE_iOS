//
//  SplitArrows.m
//  iosBASIC
//
//	This view shows the arrows that appear on SplitViewControls.
//
//  Created by Mike Westerfield on 9/26/11 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2011 Byte Works, Inc. All rights reserved.
//

#import "SplitArrows.h"

@implementation SplitArrows

@synthesize horizontal;

/*!
 * Returns an initialized object.
 *
 * @param frame			A rectangle defining the frame of the UISwitch object.
 *
 * @return				An initialized AccessorizedTextView object or nil if the object could not be initialized.
 */

- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

/*!
 * Draws the receiver’s image within the passed-in rectangle.
 *
 * @param rect			The portion of the view’s bounds that needs to be updated.
 */

- (void) drawRect: (CGRect) rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGSize size = self.frame.size;
	int height = size.height;
	int width = size.width;
    if (horizontal) {
        CGContextMoveToPoint(context, 1, height/2 + 1);
        CGContextAddLineToPoint(context, width/2, height - 1);
        CGContextAddLineToPoint(context, width - 1, height/2 + 1);
        CGContextFillPath(context);
        
        CGContextMoveToPoint(context, 1, height/2 - 1);
        CGContextAddLineToPoint(context, width/2, 1);
        CGContextAddLineToPoint(context, width - 1, height/2 - 1);
        CGContextFillPath(context);
    } else {
        CGContextMoveToPoint(context, width/2 + 1, 1);
        CGContextAddLineToPoint(context, width - 1, height/2);
        CGContextAddLineToPoint(context, width/2 + 1, height - 1);
        CGContextFillPath(context);
        
        CGContextMoveToPoint(context, width/2 - 1, 1);
        CGContextAddLineToPoint(context, 1, height/2);
        CGContextAddLineToPoint(context, width/2 - 1, height - 1);
        CGContextFillPath(context);
    }
}

@end
