//
//  CodeCompletionButton.m
//  iosBASIC
//
//  Created by Mike Westerfield on 4/24/15.
//  Copyright (c) 2015 Byte Works, Inc. All rights reserved.
//

#import "CodeCompletionButton.h"

@implementation CodeCompletionButton

@synthesize codeCompletion;

/*!
 * Create a path for a rounded rectangle.
 *
 * @param rect			The enclosing rectangle.
 * @param radius		The radius of the corners.
 *
 * @return				The path.
 */

CGMutablePathRef createRoundedRectForRect(CGRect rect, CGFloat radius) { 
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
    CGPathCloseSubpath(path);
    
    return path;        
}

/*!
 * Draws the receiver’s image within the passed-in rectangle.
 *
 * @param rect			The portion of the view’s bounds that needs to be updated.
 */

- (void) drawRect: (CGRect) rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGMutablePathRef outerPath = createRoundedRectForRect(rect, 6.0);
    CGContextSetFillColorWithColor(context, [[UIColor alloc] initWithRed: 133.0/255.0 
                                                                   green: 137.0/255.0 
                                                                    blue: 140.0/255.0 
                                                                   alpha: 1.0].CGColor);
    CGContextAddPath(context, outerPath);
    CGContextFillPath(context);
    
    CGRect buttonRect = rect;
    buttonRect.size.height -= 1;
    outerPath = createRoundedRectForRect(buttonRect, 6.0);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddPath(context, outerPath);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}

@end
