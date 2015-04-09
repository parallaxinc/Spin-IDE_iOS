//
//  CodeMagnifierView.m
//  Spin IDE
//
//  Created by Mike Westerfield on 4/3/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "CodeMagnifierView.h"


#define DEFAULT_SCALE (1.2)

@implementation CodeMagnifierView

@synthesize scale;
@synthesize viewToMagnify;

/*!
 * Draws the receiver’s image within the passed-in rectangle.
 *
 * @param rect			The portion of the view’s bounds that needs to be updated.
 */

- (void) drawRect: (CGRect) rect {
    // Draw the magnified view.
    self.hidden = YES;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, self.frame.size.width/2, self.frame.size.height/2);
    CGContextScaleCTM(context, scale, scale);
    CGContextTranslateCTM(context, -(self.frame.origin.x + self.bounds.size.width/2), -self.frame.origin.y - self.bounds.size.height*0.95);
    [self.viewToMagnify.layer renderInContext: context];
    self.hidden = NO;
    
    // Draw the magnifier gradient.
    CGRect frame = self.frame;
    frame.origin.x += (frame.size.width - frame.size.width/scale)/2;
    frame.origin.y += frame.size.height/2;
    frame.size.width /= scale;
    frame.size.height /= scale;
	[[UIImage imageNamed: @"magnifier.png"] drawInRect: frame blendMode: kCGBlendModeNormal alpha: 1.0];
}

/*!
 * Do initializetion common to all initialization methods.
 */

- (void) initCodeMagnifierViewCommon {
    // Set up the magnifier shape and border.
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 2;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.masksToBounds = YES;
    self.scale = DEFAULT_SCALE;
}

/*!
 * Implemented by subclasses to initialize a new object (the receiver) immediately
 * after memory for it has been allocated.
 *
 * @param aDecoder		The decoder.
 *
 * @return				An initialized object or nil if the object could not be initialized.
 */

- (id) initWithCoder: (NSCoder *) aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self initCodeMagnifierViewCommon];
    }
    return self;
}

/*!
 * Returns an initialized object.
 *
 * @param frame			A rectangle defining the frame of the UISwitch object.
 *
 * @return				An initialized object or nil if the object could not be initialized.
 */

- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame: frame];
    if (self) {
        [self initCodeMagnifierViewCommon];
    }
    return self;
}

@end
