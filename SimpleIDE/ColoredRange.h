//
//  ColoredRange.h
//  Spin IDE
//
//  Created by Mike Westerfield on 3/4/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColoredRange : NSObject

@property (nonatomic, retain) UIColor *color;		// The color to apply.
@property (nonatomic) NSRange range;				// The text range to which the color applies.

@end
