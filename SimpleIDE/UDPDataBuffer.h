//
//  UDPDataBuffer.h
//  XBee Loader
//
//  Created by Mike Westerfield on 7/23/14 at the Byte Works, Inc.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDPDataBuffer : NSObject

- (BOOL) peek: (NSData **) udpPacket udpAddress: (NSData **) udpAddress udpTime: (double *) udpTime;
- (BOOL) pull: (NSData **) udpPacket udpAddress: (NSData **) udpAddress udpTime: (double *) udpTime;
- (void) push: (NSData *) udpPacket udpAddress: (NSData *) udpAddress udpTime: (double) udpTime;

@end
