//
//  CodeCompletion.h
//  iosBASIC
//
//  Created by Mike Westerfield on 4/24/15.
//  Copyright (c) 2015 Byte Works, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CodeCompletion : NSObject

@property (nonatomic, retain) UIColor *color;					// The color for the text.
@property (nonatomic) int count;								// The number of times this appears in the code.
@property (nonatomic, retain) NSString *name;					// The display name for code completion.
@property (nonatomic) NSRange selection;						// The selection this would replace.
@property (nonatomic) int tag;									// An identifier used to distinguise between some kinds of completions.
@property (nonatomic, retain) NSString *text;					// The text to insert for code completion.

- (id) initWithName: (NSString *) name;

@end
