//
//  LoadImageViewController.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/20/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "Loader.h"
#import "TXBee.h"


@protocol LoadImageViewControllerDelegate <NSObject>

@optional

/*!
 * Called when the laoder has completed loading the binary.
 *
 * The loader is now in a dormant state, waiting for a new load.
 *
 * This method is not called if loaderFatalError is called to report an unsuccessful load.
 *
 * This method is always called from the main thread.
 */

- (void) loadImageViewControllerLoadComplete;

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

- (void) loadImageViewControllerFatalError: (NSError *) error;

@end


@interface LoadImageViewController : UIViewController <LoaderDelegate>

@property (nonatomic, retain) id<LoadImageViewControllerDelegate> delegate;
@property (nonatomic) BOOL eeprom;									// Set to YES to load the file to EPROM, or leave as NO for RAM.
@property (nonatomic, retain) IBOutlet UILabel *ipAddressLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic) TXBee *xBee;									// Information about the current device.

- (IBAction) cancelButton: (id) sender;
- (void) load: (NSString *) binary;

@end
