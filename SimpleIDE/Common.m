//
//  Common.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/30/14.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "Common.h"

@implementation Common

/*!
 * Get the prefered font for text in the console and source views.
 *
 * Returns: The font.
 */

+ (UIFont *) textFont {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sizeString = [defaults stringForKey: @"font_size"];
	int size = 14;
    if (sizeString != nil) {
        size = [sizeString intValue];
        if (size < 9)
            size = 9;
        if (size > 24)
            size = 24;
    }
    return [UIFont fontWithName: @"Courier" size: size];
}

@end
