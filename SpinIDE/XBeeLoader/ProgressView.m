//
//  ProgressView.m
//  Prop Loader
//
//	Implements a special view with a progress bar. The prefered size is 280x88, positioned 20 pixels from the left of the superview.
//
//  Created by Mike Westerfield on 4/16/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "ProgressView.h"

static ProgressView *this;

@interface ProgressView ()

@property (nonatomic, retain) UILabel *caption;
@property (nonatomic, retain) UIProgressView *progressView;

@end

@implementation ProgressView

@synthesize caption;
@synthesize progressView;
@synthesize title;

/*!
 * Initializes and returns a newly allocated view object with the specified frame rectangle.
 *
 * @param frame		The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which 
 *					you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
 */

- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame: frame];
    if (self) {
        // Record the object for the singleton calls.
        this = self;
        
        // Make this view lght gray. This view appears as the border to the progress view.
        self.backgroundColor = [UIColor lightGrayColor];
        
        // Set up the other compnents in the view.
        UIView *whiteView = [[UIView alloc] initWithFrame: CGRectMake(4, 4, 272, 80)];
        whiteView.backgroundColor = [UIColor whiteColor];
        [self addSubview: whiteView];
        
        self.caption = [[UILabel alloc] initWithFrame: CGRectMake(20, 20, 232, 21)];
        caption.text = title;
        [whiteView addSubview: caption];
        
        progressView = [[UIProgressView alloc] initWithFrame: CGRectMake(20, 58, 232, 2)];
        [whiteView addSubview: progressView];
    }
    return self;
}

/*!
 * Worker routine to update the progress bar using an NSNumber object so the method can be called from performSelectorOnMainThread.
 *
 * @param prog		The progress as a value in [0.0..1.0];
 */

- (void) update: (NSNumber *) prog {
    this.progressView.progress = [prog floatValue];
}

/*!
 * Set the progress.
 *
 * As a convienience to the called, this method may be called from off of the main thread, event though it does UI updates.
 *
 * @param prog		The progress as a value in [0.0..1.0];
 */

- (void) setProgress: (float) prog {
    [this performSelectorOnMainThread: @selector(update:) withObject: [NSNumber numberWithFloat: prog] waitUntilDone: NO];
}

/*!
 * Set the title (captoin) for the progress view.
 *
 * @param theTitle	The new title.
 */

- (void) setTitle: (NSString *) theTitle {
	title = theTitle;
    caption.text = theTitle;
}

@end
