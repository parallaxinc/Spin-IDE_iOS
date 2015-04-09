//
//  SplitViewControl.m
//  iosBASIC
//
//  Created by Mike Westerfield on 6/16/11 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright 2011 Byte Works, Inc. All rights reserved.
//

#import "SplitViewControl.h"

@implementation SplitViewControl

@synthesize arrows;
@synthesize delegate;
@synthesize gradient;
@synthesize horizontalSplit;
@synthesize maximum;
@synthesize minimum;
@synthesize splitSize;

/*!
 * Do initialization common to all init calls.
 */

- (void) initCommon {
    UIColor *left = [UIColor colorWithRed: 0.652 green: 0.672 blue: 0.723 alpha: 1.0];
    UIColor *right = [UIColor colorWithRed: 0.953 green: 0.957 blue: 0.965 alpha: 1.0];
    gradient = [CAGradientLayer layer];
    gradient.frame = [self bounds];
    gradient.colors = [NSArray arrayWithObjects: (id) [left CGColor], (id) [right CGColor], nil];
    gradient.startPoint = CGPointMake(0.5, 1.0);
    gradient.endPoint = CGPointMake(0.5, 0.0);
    [self.layer insertSublayer: gradient atIndex: 0];
    
    minimum = 0;
    maximum = 1;
    splitSize = 20;
    
    self.arrows = [[SplitArrows alloc] initWithFrame: CGRectMake(0, 0, splitSize, splitSize)];
    [self addSubview: arrows];
    [arrows setHorizontal: YES];
}

/*!
 * Returns an object initialized from data in a given unarchiver.
 *
 * @param encoder		An archiver object.
 *
 * @return				self, initialized using the data in decoder.
 */

- (id) initWithCoder: (NSCoder *) decoder {
    self = [super initWithCoder: decoder];
    if (self) {
        [self initCommon];
    }
    return self;
}

/*!
 * Returns an initialized object.
 *
 * @param frame			A rectangle defining the frame of the UISwitch object.
 *
 * @return				An initialized AccessorizedTextView object or nil if the object could not be initialized.
 */

- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame: frame];
    if (self) {
        [self initCommon];
    }
    return self;
}

/*!
 * The frame rectangle, which describes the view’s location and size in its superview’s coordinate system.
 *
 * @param frame			The new frame.
 */

- (void) setFrame: (CGRect) frame {
    [gradient setFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [super setFrame: frame];
    [self setNeedsDisplay];
}

/*!
 * Set whether the split is horizaontal or vertical.
 *
 * The expectation is that this method is called by the controler, which takes care of setting
 * up the split panes after this call is complete.
 *
 * @param flag			YES for a horizontal (side-by-side) split; NO for a vertical (top-bottom) split.
 */

- (void) setHorizontalSplit: (BOOL) flag {
	if (flag != horizontalSplit) {
		horizontalSplit = flag;
		
		CGRect superFrame = [self.superview frame];
		CGRect frame = [self frame];
		if (horizontalSplit) {
			frame.size.width = splitSize;
			frame.size.height = superFrame.size.height;
			frame.origin.x = (superFrame.size.width - frame.size.width)/2;
			frame.origin.y = 0;
            gradient.startPoint = CGPointMake(0.0, 0.5);
            gradient.endPoint = CGPointMake(1.0, 0.5);
            
            [arrows setHorizontal: NO];
		} else {
			frame.size.width = splitSize;
			frame.size.height = frame.size.width;
			frame.origin.x = 0;
			frame.origin.y = (superFrame.size.height - frame.size.height)/2;
            gradient.startPoint = CGPointMake(0.5, 1.0);
            gradient.endPoint = CGPointMake(0.5, 0.0);
            
            [arrows setHorizontal: YES];
		}
		[self setFrame: frame];
	}
}

/*!
 * Sent to the receiver when one or more fingers touch down in the associated view.
 *
 * This implementation handles the start of a view-adjusting slide operation.
 *
 * @param touches		A set of UITouchinstances in the event represented by event that 
 *						represent the touches in the UITouchPhaseBeganphase.
 * @param event			A UIEventobject representing the event to which the touches belong.
 */

- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
	UITouch *touch = [touches anyObject];
	startPoint = [touch locationInView: self];
}

/*!
 * Sent to the receiver when one or more fingers move in the associated view.
 *
 * This implementation tracks movements, moving this view and sending a 
 * splitViewProtocolMovedFrom:to: message to the delegate.
 *
 * @param touches		A set of UITouchinstances in the event represented by event that 
 *						represent touches in the UITouchPhaseMovedphase.
 * @param event			A UIEventobject representing the event to which the touches belong.
 */

- (void) touchesMoved: (NSSet *) touches withEvent: (UIEvent *) event {
	UITouch *touch = [touches anyObject];
	CGPoint currentPoint = [touch locationInView: self];
	
	CGRect superFrame = [self.superview frame];
	
	CGRect frame = [self frame];
	if (horizontalSplit) {
		double from = frame.origin.x;
		frame.origin.x += currentPoint.x - startPoint.x;
		if (frame.origin.x < minimum*superFrame.size.width)
			frame.origin.x = minimum*superFrame.size.width;
		if (frame.origin.x < 0)
			frame.origin.x = 0;
		if (frame.origin.x + frame.size.width > superFrame.size.width)
			frame.origin.x = superFrame.size.width - frame.size.width;
		if (frame.origin.x > maximum*superFrame.size.width)
			frame.origin.x = maximum*superFrame.size.width;
		[self setFrame: frame];
		
		if (from != frame.origin.x && [delegate respondsToSelector: @selector(splitViewProtocolMovedFrom:to:)])
			[delegate splitViewProtocolMovedFrom: from to: frame.origin.x];
	} else {
		double from = frame.origin.y;
		frame.origin.y += currentPoint.y - startPoint.y;
		if (frame.origin.y < minimum*superFrame.size.height)
			frame.origin.y = minimum*superFrame.size.height;
		if (frame.origin.y < 0)
			frame.origin.y = 0;
		if (frame.origin.y + frame.size.height > superFrame.size.height)
			frame.origin.y = superFrame.size.height - frame.size.height;
		if (frame.origin.y > maximum*superFrame.size.height)
			frame.origin.y = maximum*superFrame.size.height;
		[self setFrame: frame];
		
		if (from != frame.origin.y && [delegate respondsToSelector: @selector(splitViewProtocolMovedFrom:to:)])
			[delegate splitViewProtocolMovedFrom: from to: frame.origin.y];
	}
}

@end
