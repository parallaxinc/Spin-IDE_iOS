//
//  SplitViewControl.h
//  iosBASIC
//
//  Created by Mike Westerfield on 6/16/11 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright 2011 Byte Works, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SplitArrows.h"
#import <QuartzCore/QuartzCore.h>

@protocol SplitViewProtocol <NSObject>

/*!
 * The split view control has moved from one location to another. This message gives the start
 * and end locations for the move. 
 *
 * Is is up to the receiver to keep track of whether the split is horizontal or vertical, and 
 * the size of the split control, if needed.
 *
 * The receiver typically responds by adjusting the views that represent the two parts of the 
 * split view.
 *
 * @param from		The original position of hte control. This is the top or left of the control.
 * @param to		The new posiiton of the control.
 */

- (void) splitViewProtocolMovedFrom: (double) from to: (double) to;

@end


@interface SplitViewControl: UIView {
    SplitArrows *arrows;						// The arrow lisde indicator.
	CAGradientLayer *gradient;					// The gradient layer.
    double maximum;								// The largest allowed position for the slider. A value from 0.0..1.0
    											// indicating the distance from the top/left.
	double minimum;								// The smallest allowed position for the slider. A value from 0.0..1.0
                                                // indicating the distance from the top/left.
	
	double splitSize;							// The thickness of the split control.
	
	id delegate;								// The SplitViewProtocol delegate.
	
	BOOL horizontalSplit;						// Is the split horizontal (side-by-side panes) or vertical?
	
@private
	CGPoint startPoint;
}


@property (nonatomic, retain) SplitArrows *arrows;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) CAGradientLayer *gradient;
@property (nonatomic) BOOL horizontalSplit;
@property (nonatomic) double maximum;
@property (nonatomic) double minimum;
@property (nonatomic) double splitSize;

- (void) initCommon;

@end
