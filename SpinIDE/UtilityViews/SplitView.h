//
//  SplitView.h
//  iosBASIC
//
//  Created by Mike Westerfield on 6/16/11 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright 2011 Byte Works, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SplitViewControl.h"

@interface SplitView : UIView <SplitViewProtocol> {
	IBOutlet UIView *bottomView;				// The view at the bottom or right of the split.
	BOOL horizontalSplit;						// Is the split horizontal (side-by-side panes) or vertical?
	IBOutlet SplitViewControl *splitControl;	// The view that acts as the split slider.
	IBOutlet UIView *topView;					// The view at the top or left of the split.
}

@property (nonatomic, retain) UIView *bottomView;
@property (nonatomic) double location;
@property (nonatomic) BOOL horizontalSplit;
@property (nonatomic, retain) SplitViewControl *splitControl;
@property (nonatomic, retain) UIView *topView;

- (void) hideSplit: (BOOL) hide showingBottom: (BOOL) showingBottom;
- (void) setMaximum: (double) value;
- (void) setMinimum: (double) value;
- (void) splitViewProtocolMovedFrom: (double) from to: (double) to;

@end
