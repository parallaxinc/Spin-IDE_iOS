//
//  Loader.h
//  XBee Loader
//
//  Created by Mike Westerfield on 7/15/14 at the Byte Works, Inc.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "GCDAsyncUdpSocket.h"
#import "TXBee.h"


@protocol LoaderDelegate <NSObject>

@optional

/*!
 * Called when the Propeller board reported a checksum failure. This may or may not result in an unsuccessful
 * load, depending on whether there are load retries left.
 *
 * This method is always called from the main thread.
 */

- (void) checksumFailure;

/*!
 * Called when the laoder has completed loading the binary.
 *
 * The loader is now in a dormant state, waiting for a new load.
 *
 * This method is not called if loaderFatalError is called to report an unsuccessful load.
 *
 * This method is always called from the main thread.
 */

- (void) loaderComplete;

/*!
 * When the delegate calls scan:port:, this class begins a process of collecting a list of available XBee WiFi
 * devices. Once the process is complete, this method is called on the delegate.
 *
 * @param devices		An array of devices found. This may be empty, but will not be null. Each element in the
 *						array (if any) is a TXBee object with all relevant information about the device filled in.
 */

- (void) loaderDevices: (NSArray *) devices;

/*!
 * Called when the binary failed to load. This may or may not result in an unsuccessful load, depending on
 * whether there are load retries left. This count includes any checksum failures.
 *
 * This method is always called from the main thread.
 */

- (void) loadFailure;

/*!
 * Called when the loader is sending bytes from the binary image to the XBee, this allows the UI to report
 * progress to the user.
 *
 * This method is always called from the main thread.
 *
 * @param progress		The progress. The range is 0.0 (starting) to 1.0 (complete).
 */

- (void) loaderProgress: (float) progress;

/*!
 * Called when an error occurs. These errors stop the laod.
 *
 * This method is always called from the main thread.
 *
 * @param status		The test message indicating the status.
 */

- (void) loaderState: (NSString *) message;

/*!
 * Called when the internal status of the loader changes, this method supplies a status string suitable for
 * display in a UI to provide textual progress information.
 *
 * Errors whose domain is [[Loader defaultLoader] loaderDomain] indicate internal errors in the loader, as follows:
 *
 *		id		error
 *		--		-----
 *		1		The Propeller did not respond to a reset/handshake attempt, even after the maximum allowed number
 *				of tries, as specified when starting the laod.
 *		2		The handshake was successfu, but the Propeller did not respond. This is only reported if the
 *				load has failed the maximum number of allowed times, as specified when starting the laod.
 *		3		The Propeller reaponded to a load, but the checksum was invalid. This is only reported if the
 *				load has failed the maximum number of allowed times, as specified when starting the load.
 *
 * Any other error is passed up from iOS, and generally indicates an error that inticates a fundamental problem
 * that makes trying again pointless.
 *
 * The loader is now in a dormant state, waiting for a new load.
 *
 * This method is always called from the main thread.
 *
 * @param error			The error.
 */

- (void) loaderFatalError: (NSError *) error;

@end


@interface Loader : NSObject <NSStreamDelegate, GCDAsyncUdpSocketDelegate>

@property (nonatomic, retain) id<LoaderDelegate> delegate;
@property (nonatomic, retain) NSString *loaderDomain;

- (void) cancel;
+ (Loader *) defaultLoader;
- (NSString *) getDeviceName: (TXBee *) xBee;
- (void) load: (NSString *) binary
        eprom: (BOOL) eprom
         xBee: (TXBee *) xBee
 loadAttempts: (int) loadAttempts
        error: (NSError **) error;
- (void) scan: (NSString *) subnet commandPort: (int) commandPort serialPort: (int) serialPort;

@end
