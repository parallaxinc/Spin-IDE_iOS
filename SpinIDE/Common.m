//
//  Common.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/30/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "Common.h"

@implementation Common

/*!
 * Get the path name of the sandbox as a c string.
 *
 * The path name is terminated with a / character.
 *
 * @return			The full path of the sandbox directory.
 */

+ (const char *) csandbox {
    NSString *path = [Common sandbox];
    if ([path characterAtIndex: path.length - 1] != '/')
        path = [path stringByAppendingString: @"/"];
    return [path UTF8String];
}

/*!
 * Universal entry point for reporting NSError errors tot he user.
 *
 * @param error		The error to report.
 */

+ (void) reportError: (NSError *) error {
    NSString *message = error.localizedDescription;
    if (error.localizedFailureReason)
        message = [NSString stringWithFormat: @"%@\n\n%@", message, error.localizedFailureReason];
    if (error.localizedRecoverySuggestion)
        message = [NSString stringWithFormat: @"%@\n\n%@", message, error.localizedRecoverySuggestion];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error"
                                                    message: message
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

/*!
 * Get the path name of the sandbox.
 *
 * @return			The full path of the sandbox directory.
 */

+ (NSString *) sandbox {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex: 0];
}

/*!
 * Get the prefered font for text in the console and source views.
 *
 * @return			The font.
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

/*!
 * Return a list of the file extensions that are valid in projects and the editor.
 *
 * @return			An array of NSString objects with the valid file extensions.
 */

+ (NSArray *) validExtensions {
    NSMutableArray *extensions = [[NSMutableArray alloc] init];
    
    NSString *sandbox = [Common sandbox];
    NSString *path = [sandbox stringByAppendingPathComponent: @"extensions.txt"];
    NSError *error = nil;
    NSString *extensionsString = [NSString stringWithContentsOfFile: path encoding: NSUTF8StringEncoding error: &error];
    
    if (!error && extensionsString != nil) {
        NSArray *extensionPrototypes = [extensionsString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
        for (NSString *extension in extensionPrototypes) {
            NSString *trimmed = [extension stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (trimmed && trimmed.length > 0)
                [extensions addObject: trimmed];
        }
    }
    
    if (extensions.count == 0)
        [extensions addObjectsFromArray: [NSArray arrayWithObjects: @"spin", @"c", @"cpp", @"h", nil]];
    
    return extensions;
}

@end
