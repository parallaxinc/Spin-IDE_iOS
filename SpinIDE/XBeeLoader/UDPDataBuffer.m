//
//  UDPDataBuffer.m
//  XBee Loader
//
//	This class implements a sinple thread-safe FIFO buffer for storing UDP packest as they arrive from the XBee WiFi.
//
//  Created by Mike Westerfield on 7/23/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "UDPDataBuffer.h"

#include <pthread.h>


static BOOL mutexInitialized = FALSE;		// Has the mutex been initialized?


@interface UDPPacket : NSObject
@property (nonatomic, retain) NSData *udpAddress;				// The address from the most recently received UDP packet.
@property (nonatomic, retain) NSData *udpPacket;				// The data from the most recently received UDP packet.
@property (nonatomic) double udpTime;							// The time stamp for the most recent call to udpSocket:didReceiveData:fromAddress:withFilterContext:.
@end


@implementation UDPPacket
@synthesize udpAddress;
@synthesize udpPacket;
@synthesize udpTime;
@end



@interface UDPDataBuffer () {
    pthread_mutex_t mutex;										// Semaphore used for thread safety.
}

@property (nonatomic, retain) NSMutableArray *stack;			// The FIFO stack of packets.

@end


@implementation UDPDataBuffer

@synthesize stack;

/*!
 * Set up this object.
 *
 * @return The new object.
 */

- (id) init {
    self = [super init];
    
    if (self) {
        // Initialize a semiphore.
        [self initMutex];
    }
    
    return self;
}

- (void) initMutex {
    if (!mutexInitialized) {
        mutexInitialized = TRUE;
        pthread_mutex_init(&mutex, NULL);
    }
}

- (BOOL) peek: (NSData **) udpPacket udpAddress: (NSData **) udpAddress udpTime: (double *) udpTime {
    pthread_mutex_lock(&mutex);
    
    UDPPacket *packet = nil;
    if (stack != nil && stack.count > 0)
        packet = [stack objectAtIndex: 0];
    
    if (packet != nil) {
        if (udpPacket)
            *udpPacket = packet.udpPacket;
        if (udpAddress)
            *udpAddress = packet.udpAddress;
        if (udpTime)
            *udpTime = packet.udpTime;
    }
    
    pthread_mutex_unlock(&mutex);

    return packet != nil;
}

- (BOOL) pull: (NSData **) udpPacket udpAddress: (NSData **) udpAddress udpTime: (double *) udpTime {
    pthread_mutex_lock(&mutex);
    
    UDPPacket *packet = nil;
    if (stack != nil && stack.count > 0) {
        packet = [stack objectAtIndex: 0];
        [stack removeObjectAtIndex: 0];
    }
    
    if (packet != nil) {
        if (udpPacket)
            *udpPacket = packet.udpPacket;
        if (udpAddress)
            *udpAddress = packet.udpAddress;
        if (udpTime)
            *udpTime = packet.udpTime;
    }
    
    pthread_mutex_unlock(&mutex);

    return packet != nil;
}

- (void) push: (NSData *) udpPacket udpAddress: (NSData *) udpAddress udpTime: (double) udpTime {
    UDPPacket *packet = [[UDPPacket alloc] init];
    packet.udpAddress = udpAddress;
    packet.udpPacket = udpPacket;
    packet.udpTime = udpTime;
    
    pthread_mutex_lock(&mutex);
    
    if (stack == nil)
        stack = [[NSMutableArray alloc] init];
    [stack addObject: packet];
    
    pthread_mutex_unlock(&mutex);
}

@end
