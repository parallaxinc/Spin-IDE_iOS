//
//  Common.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/30/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html ).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "Common.h"

@implementation Common

/*!
 * Get the path name of the sandbox as a c string.
 *
 * The path name is terminated with a / character.
 *
 * @return		The full path of the sandbox directory.
 */

+ (const char *) csandbox {
    NSString *path = [Common sandbox];
    if ([path characterAtIndex: path.length - 1] != '/')
        path = [path stringByAppendingString: @"/"];
    return [path UTF8String];
}

/*!
 * Get the path name of the sandbox.
 *
 * @return		The full path of the sandbox directory.
 */

+ (NSString *) sandbox {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex: 0];
}

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
