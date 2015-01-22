//
//  Common.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/30/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

// System version
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_4_INCH_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0)

// Supported languages
#define SUPPORT_SPIN YES
#define SUPPORT_C YES
#define SUPPORT_CPP YES

// The domain for locally generated NSError objects.
#define simpleIDEDomain @"SimpleIDE"

typedef enum {languageC, languageCPP, languageSpin} languageType;

@interface Common : NSObject

+ (const char *) csandbox;
+ (void) reportError: (NSError *) error;
+ (NSString *) sandbox;
+ (UIFont *) textFont;

@end
