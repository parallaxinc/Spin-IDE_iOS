//
//  Project.m
//  SimpleIDE
//
//	Contains information about a project at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//
//  Created by Mike Westerfield on 1/9/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "Project.h"

@implementation Project

@synthesize language;
@synthesize files;
@synthesize name;
@synthesize path;
@synthesize sidePath;
@synthesize spinCompilerOptions;

/*!
 * Read a project, initializing this object for that project's contents. Any values i this object refering to an old project will be lost.
 */

- (void) readSideFile: (NSString *) projectName error: (NSError **) error {
    // Get the various paths.
    self.name = projectName;
    self.path = [[Common sandbox] stringByAppendingPathComponent: name];
    self.sidePath = [path stringByAppendingPathComponent: [name stringByAppendingPathExtension: @"side"]];
    
    // Scan the .side file for files and the language.
    self.files = [[NSMutableArray alloc] init];
    NSArray *lines = [[NSString stringWithContentsOfFile: sidePath 
                                                encoding: NSUTF8StringEncoding 
                                                   error: nil] componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        if ([line stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
            if ([line characterAtIndex: 0] == '>') {
                NSString *command = [line substringFromIndex: 1];
                if ([[command lowercaseString] hasPrefix: @"compiler="]) {
                    command = [[command substringFromIndex: 9] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if ([command caseInsensitiveCompare: @"C"] == NSOrderedSame)
                        self.language = languageC;
                    else if ([command caseInsensitiveCompare: @"CPP"] == NSOrderedSame)
                        self.language = languageCPP;
                    else
                        self.language = languageSpin;
                } else if ([[command lowercaseString] hasPrefix: @"defs::"]) {
                    command = [[command substringFromIndex: 6] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    self.spinCompilerOptions = command;
                }
            } else {
                NSString *filePath = [path stringByAppendingPathComponent: line];
                if ([[NSFileManager defaultManager] fileExistsAtPath: filePath])
                    [files addObject: line];
            }
        }
    }
}

/*!
 * Write or replace the .side file that contains project options and file names.
 *
 * @param error		Location to store the error message. This is unchanged if there is no error.
 */

- (void) writeSideFile: (NSError **) error {
    self.sidePath = [path stringByAppendingPathComponent: [name stringByAppendingPathExtension: @"side"]];
    
    NSString *sideFile = @"";
    for (NSString *file in files)
        sideFile = [NSString stringWithFormat: @"%@%@\n", sideFile, [file lastPathComponent]];
    NSString *compiler = @"Unknown";
    switch (language) {
        case languageC: compiler = @"C"; break;
        case languageCPP: compiler = @"CPP"; break;
        case languageSpin: compiler = @"SPIN"; break;
    }
    
    sideFile = [NSString stringWithFormat: @"%@>compiler=%@\n", sideFile, compiler];
    
    if (spinCompilerOptions && spinCompilerOptions.length > 0)
	    sideFile = [NSString stringWithFormat: @"%@>defs::%@\n", sideFile, spinCompilerOptions];
    
    [sideFile writeToFile: sidePath atomically: YES encoding: NSUTF8StringEncoding error: error];
    // TODO: Update once C projects are supported.
}

@end
