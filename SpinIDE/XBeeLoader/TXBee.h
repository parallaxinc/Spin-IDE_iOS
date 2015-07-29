//
//  TXBee.h
//  XBee Loader
//
//  Created by Mike Westerfield on 7/21/14 at the Byte Works, Inc.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXBee : NSObject

#define VALUE_UNKNOWN (-1)				/* Unknown value; for checksum and firmware. */

@property (nonatomic) int cfgChecksum;					// Configuration checksum
@property (nonatomic) int firmwareVersion;				// The firmware version
@property (nonatomic, retain) NSString *ipAddr;			// IP Address
@property (nonatomic) int ipPort;						// IP Port. This is the port for general serial communication.
@property (nonatomic, retain) NSString *name;			// The name of the device as returned by the XBee NI command.

@end
