//
//  HighlighterRule.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 5/1/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HighlighterRule : NSObject

@property (nonatomic, retain) NSRegularExpression *rule;		// The regular expression for the pattern search.
@property (nonatomic, retain) UIColor *color;					// The color used to paint the selected text.

@end
