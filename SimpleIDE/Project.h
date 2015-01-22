//
//  Project.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/9/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Common.h"

@interface Project : NSObject

@property (nonatomic, retain) NSMutableArray *files;	// The list of files in the project. Includes extension, but not path. Array of NSString.
@property (nonatomic) languageType language;			// The language for the project.
@property (nonatomic, retain) NSString *name;			// The display name of the project.
@property (nonatomic, retain) NSString *path;			// The path of the folder containing the project.
@property (nonatomic, retain) NSString *sidePath;		// The full path of the .side (project) file.

@end
