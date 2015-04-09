//
//  ProgressView.h
//  Prop Loader
//
//  Created by Mike Westerfield on 4/16/14 at the Byte Works, Inc.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView

@property (nonatomic, retain) NSString *title;	// The title (caption) displayed onthe progress view.

- (void) setProgress: (float) progress;			// Set the progress; pass a value in [0.0..1.0].

@end
