//
//  XBeeCommon.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/20/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

// System and hardware detection.
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_4_INCH_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0)

@interface XBeeCommon : NSObject

+ (int) udpPort;

@end
