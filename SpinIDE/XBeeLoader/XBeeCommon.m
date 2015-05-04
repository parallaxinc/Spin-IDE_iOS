//
//  XBeeCommon.m
//  SimpleIDE
//
//	This class contains macros and methods for reporting hardware specific values and system wide constants.
//
//  Created by Mike Westerfield on 1/20/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "XBeeCommon.h"

static int port;				// The UDP Port.
static BOOL udpPortSet;			// True if the UDP port has been set, else false.

@implementation XBeeCommon

/*!
 * Get the UDP port.
 *
 * The UDP port cannot be changed once set, and generally should not be changed. This method returns the XBee UDP port for all classes in the program.
 *
 * The defult port is 0x0BEE.
 *
 * @return		The UDP port number.
 */

+ (int) udpPort {
    if (!udpPortSet) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *udpPortPreference = [defaults stringForKey: @"ap_port_preference"];
        if (udpPortPreference == nil)
            port = 0xBEE;
        else
            port = (int) [udpPortPreference integerValue];
        udpPortSet = YES;
    }
    return port;
}

@end
