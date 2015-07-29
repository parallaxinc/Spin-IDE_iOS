//
//  TXBee.m
//  XBee Loader
//
//  Created by Mike Westerfield on 7/21/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "TXBee.h"

@implementation TXBee

@synthesize cfgChecksum;
@synthesize firmwareVersion;
@synthesize ipAddr;
@synthesize ipPort;
@synthesize name;

/*!
 * Returns an initialized highlighter object for C.
 *
 * @return			The initialized object.
 */

- (id) init {
    self = [super init];
    
    if (self) {
        cfgChecksum = VALUE_UNKNOWN;
        firmwareVersion = VALUE_UNKNOWN;
    }
    
    return self;
}

@end
