//
//  CodeMagnifierView.h
//  Spin IDE
//
//  Created by Mike Westerfield on 4/3/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CodeMagnifierView : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic, retain) UIView *viewToMagnify;

@end
