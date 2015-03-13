//
//  CodeRect.h
//  Spin IDE
//
//  Created by Mike Westerfield on 3/4/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeRect : NSObject

@property (nonatomic) CGRect rect;

- (id) initWithX: (CGFloat) x y: (CGFloat) y width: (CGFloat) width height: (CGFloat) height;

@end
