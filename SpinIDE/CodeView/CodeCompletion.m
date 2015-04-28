//
//  CodeCompletion.m
//  iosBASIC
//
//  Created by Mike Westerfield on 4/24/15.
//  Copyright (c) 2015 Byte Works, Inc. All rights reserved.
//

#import "CodeCompletion.h"

@implementation CodeCompletion

@synthesize color;
@synthesize count;
@synthesize name;
@synthesize selection;
@synthesize tag;
@synthesize text;

#pragma mark - Misc

/*!
 * Returns an initialized object.
 *
 * @param theName			The display name for this object.
 */

- (id) initWithName: (NSString *) theName {
    self = [super init];
    
    if (self) {
        self.name = theName;
    }
    
    return self;
}

#pragma mark - Getters and setters

/*!
 * Returns the replacement text for this code completion. If there is no explicit text set, the display text with a 
 * trailing space is returned.
 *
 * @return					The replacement text.
 */

- (NSString *) text {
    if (text)
        return text;
    return [name stringByAppendingString: @" "];
}

@end
