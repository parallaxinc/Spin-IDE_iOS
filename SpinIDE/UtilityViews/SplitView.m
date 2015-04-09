//
//  SplitView.m
//  iosBASIC
//
//  This view is used as a controller and divider for split views. It can be dragged up an down,
//  reporting the movements to a delegate that implements SplitViewDelegate.
//
//  Created by Mike Westerfield on 6/16/11 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright 2011 Byte Works, Inc. All rights reserved.
//

#import "SplitView.h"

@interface SplitView ()

@property (nonatomic) double locationWhenHidden;
@property (nonatomic) BOOL showingBottom;
@property (nonatomic) BOOL splitHidden;

- (void) initCommon;

@end

@implementation SplitView

@synthesize bottomView;
@synthesize horizontalSplit;
@synthesize locationWhenHidden;
@synthesize showingBottom;
@synthesize splitControl;
@synthesize splitHidden;
@synthesize topView;

/*!
 * Hide or show the split screen and it's control.
 *
 * @param hide					YES to hide the split, or NO to show it.
 * @param showingBottomFlag		If the split is showing, this is ignored. If it is hidden, YES shows the
 *								bottom/right view, while NO shows the top/left view.
 */

- (void) hideSplit: (BOOL) hide showingBottom: (BOOL) showingBottomFlag {
	[self setSplitHidden: hide];
	[self setShowingBottom: showingBottomFlag];
	
	if (hide) {
		[self setLocationWhenHidden: [self location]];
		if (showingBottomFlag) {
			[topView setHidden: YES];
			[splitControl setHidden: YES];
			[bottomView setFrame: [self bounds]];
		} else {
			[bottomView setHidden: YES];
			[splitControl setHidden: YES];
			[topView setFrame: [self bounds]];
		}
	} else {
		[topView setHidden: NO];
		[splitControl setHidden: NO];
		[topView setHidden: NO];
		[self setLocation: [self locationWhenHidden]];
	}
}

/*!
 * Do initializetion common to all initialization methods.
 */

- (void) initCommon {
	self.splitControl = [[SplitViewControl alloc] init];
	[splitControl setDelegate: self];
	CGRect splitFrame;
	CGRect selfFrame = [self frame];
	splitFrame.origin.x = 0;
	splitFrame.origin.y = (selfFrame.size.height - [splitControl splitSize])/2;
	splitFrame.size.width = selfFrame.size.width;
	splitFrame.size.height = [splitControl splitSize];
	[splitControl setFrame: splitFrame];
	[self addSubview: splitControl];
	
	self.topView = [[UIView alloc] init];
	CGRect frame;
	frame.origin.x = 0;
	frame.origin.y = 0;
	frame.size.width = selfFrame.size.width;
	frame.size.height = splitFrame.origin.y;
	[topView setFrame: frame];
	[topView setBackgroundColor: [UIColor redColor]];
	[self addSubview: topView];
	
	self.bottomView = [[UIView alloc] init];
	frame.origin.x = 0;
	frame.origin.y = splitFrame.size.height + splitFrame.origin.y;
	frame.size.width = selfFrame.size.width;
	frame.size.height = selfFrame.size.height - (splitFrame.size.height + splitFrame.origin.y);
	[bottomView setFrame: frame];
	[bottomView setBackgroundColor: [UIColor blueColor]];
	[self addSubview: bottomView];
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
 * Lay out the subviews for this split view.
 *
 * Call this method when the frame or bounds change.
 *
 * @param frame			The new frame for this view. Only the size is used, so the bounds may be passed, too.
 */

- (void) layoutSplitViews: (CGRect) frame {
    if ([self splitHidden]) {
        if ([self showingBottom])
            [bottomView setFrame: [self bounds]];
        else
            [topView setFrame: [self bounds]];
    } else {
        CGRect oldFrame = [self frame];
        CGRect splitFrame = [splitControl frame];
        double splitRatio;
        if (horizontalSplit)
            splitRatio = splitFrame.origin.x/oldFrame.size.width;
        else
            splitRatio = splitFrame.origin.y/oldFrame.size.height;
        
        if (horizontalSplit) {
            splitFrame.origin.x = splitRatio*frame.size.width;
            splitFrame.size.height = frame.size.height;
            [splitControl setFrame: splitFrame];
            
            CGRect subFrame;
            subFrame.origin.x = 0;
            subFrame.origin.y = 0;
            subFrame.size.width = splitFrame.origin.x;
            subFrame.size.height = frame.size.height;
            [topView setFrame: subFrame];
            
            subFrame.origin.x = splitFrame.origin.x + splitFrame.size.width;
            subFrame.size.width = frame.size.width - subFrame.origin.x;
            [bottomView setFrame: subFrame];
        } else {
            splitFrame.origin.y = splitRatio*frame.size.height;
            splitFrame.size.width = frame.size.width;
            [splitControl setFrame: splitFrame];
            
            CGRect subFrame;
            subFrame.origin.x = 0;
            subFrame.origin.y = 0;
            subFrame.size.width = frame.size.width;
            subFrame.size.height = splitFrame.origin.y;
            [topView setFrame: subFrame];
            
            subFrame.origin.y = splitFrame.origin.y + splitFrame.size.height;
            subFrame.size.height = frame.size.height - subFrame.origin.y;
            [bottomView setFrame: subFrame];
        }
    }
}

/*!
 * Get the location of the split view controller. This is a vlaue from 0.0 to 1.0, indicating the
 * ratio of the distance from the top/left of the view to the edge of the control divided by the
 * hiehg/width of the view the control is in.
 *
 * @return				The location of the control.
 */

- (double) location {
	CGRect bounds = [self bounds];
	CGRect frame = [splitControl frame];
	if (horizontalSplit)
		return frame.origin.x/bounds.size.width;
	return frame.origin.y/bounds.size.height;
}

/*!
 * Set the bottom view.
 *
 * @param view			The new bottom view.
 */

- (void) setBottomView: (UIView *) view {
	CGRect frame = [bottomView frame];
	[view setFrame: frame];
	
	[bottomView removeFromSuperview];
	[self addSubview: view];
	
	bottomView = view;
}

/*!
 * Specifies receiver’s bounds rectangle.
 *
 * @param frame			The new bounds.
 */

- (void) setBounds: (CGRect) bounds {
    [self layoutSplitViews: bounds];
    [super setBounds: bounds];
}

/*!
 * Specifies receiver’s frame rectangle in the super-layer’s coordinate space.
 *
 * @param frame			The new frame.
 */

- (void) setFrame: (CGRect) frame {
    [self layoutSplitViews: frame];
	[super setFrame: frame];
}

/*!
 * Set whether the split is horizaontal or vertical.
 *
 * @param flag			YES for a horizontal (side-by-side) split; NO for a vertical (top-bottom) split.
 */

- (void) setHorizontalSplit: (BOOL) flag {
	if (flag != horizontalSplit) {
		horizontalSplit = flag;
		if (![self splitHidden]) {
			[splitControl setHorizontalSplit: flag];
			CGRect splitFrame = [splitControl frame];
			CGRect viewFrame = [self frame];
			
			if (horizontalSplit) {
				CGRect frame = [topView frame];
				frame.size.width = splitFrame.origin.x;
				frame.size.height = viewFrame.size.height;
				frame.origin.x = 0;
				frame.origin.y = 0;
				[topView setFrame: frame];
				
				frame = [bottomView frame];
				frame.size.width = viewFrame.size.width - (splitFrame.origin.x + splitFrame.size.width);
				frame.size.height = viewFrame.size.height;
				frame.origin.x = splitFrame.origin.x + splitFrame.size.width;
				frame.origin.y = 0;
				[bottomView setFrame: frame];
			} else {
				CGRect frame = [topView frame];
				frame.size.width = viewFrame.size.width;
				frame.size.height = viewFrame.origin.y;
				frame.origin.x = 0;
				frame.origin.y = 0;
				[topView setFrame: frame];
				
				frame = [bottomView frame];
				frame.size.width = viewFrame.size.width;
				frame.size.height = viewFrame.size.height - (splitFrame.origin.y + splitFrame.size.height);
				frame.origin.x = 0;
				frame.origin.y = splitFrame.origin.y + splitFrame.size.height;
				[bottomView setFrame: frame];
			}
		}
	}
}

/*!
 * Set the location of the split view controller. This is a vlaue from 0.0 to 1.0, indicating the
 * ratio of the distance from the top/left of the view to the edge of the control divided by the
 * height/width of the view the control is in.
 *
 * @param location		The location of the control.
 */

- (void) setLocation: (double) location {
	CGRect myBounds = [self bounds];
	if (horizontalSplit) {
		CGRect splitFrame;
		splitFrame.origin.x = location*myBounds.size.width;
		splitFrame.origin.y = 0;
		splitFrame.size.width = [splitControl splitSize];
		splitFrame.size.height = myBounds.size.height;
		[splitControl setFrame: splitFrame];
		
		CGRect frame = myBounds;
		frame.size.width = splitFrame.origin.x;
		[topView setFrame: frame];
		
		frame.origin.x = splitFrame.origin.x + splitFrame.size.width;
		frame.size.width = myBounds.size.width - frame.origin.x;
		[bottomView setFrame: frame];
	} else {
		CGRect splitFrame;
		splitFrame.origin.x = 0;
		splitFrame.origin.y = location*myBounds.size.height;
		splitFrame.size.width = myBounds.size.width;
		splitFrame.size.height =[splitControl splitSize];
		[splitControl setFrame: splitFrame];
		
		CGRect frame = myBounds;
		frame.size.height = splitFrame.origin.y;
		[topView setFrame: frame];
		
		frame.origin.y = splitFrame.origin.y + splitFrame.size.height;
		frame.size.height = myBounds.size.height - frame.origin.y;
		[bottomView setFrame: frame];
	}
}

/*!
 * Set the maximum allowed value for the slider. (This only controls user interaction.)
 *
 * The value is the ratio of the location of the top/left of the slider to the size of the view.
 *
 * @param value			The maximum slider value.
 */

- (void) setMaximum: (double) value {
	[splitControl setMaximum: value];
}

/*!
 * Set the minimum allowed value for the slider. (This only controls user interaction.)
 *
 * The value is the ratio of the location of the top/left of the slider to the size of the view.
 *
 * @param value			The minimum slider value.
 */

- (void) setMinimum: (double) value {
	[splitControl setMinimum: value];
}

/*!
 * Set the top view.
 *
 * @param view			The new top view.
 */

- (void) setTopView: (UIView *) view {
	CGRect frame = [topView frame];
	[view setFrame: frame];
	
	[topView removeFromSuperview];
	[self addSubview: view];
	
	topView = view;
}

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
 * @param from			The original position of the control. This is the top or left of the control.
 * @param to			The new posiiton of the control.
 */

- (void) splitViewProtocolMovedFrom: (double) from to: (double) to {
	CGRect frame = [topView frame];
	if (horizontalSplit) {
		frame.size.width += to - from;
		[topView setFrame: frame];
		
		frame = [bottomView frame];
		frame.size.width -= to - from;
		frame.origin.x += to - from;
	} else {
		frame.size.height += to - from;
		[topView setFrame: frame];
		
		frame = [bottomView frame];
		frame.size.height -= to - from;
		frame.origin.y += to - from;
	}
	[bottomView setFrame: frame];
}

@end
