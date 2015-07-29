//
//  LoadImageViewController.m
//  SimpleIDE
//
//	This is the main view controller for the XBee/Propeller file loader. You can use this
//	view directly as the main view of a popover view controller, subclass it with your own
//	view controller to use it as part of your interface, or copy the contents into your
//	own class.
//
//	If you decide to subclass or adapt this view, include the componenets found in
//	LoadImageViewController.xib in your own nib file or storyboard.
//
//	This class also brings up the ConfigurationViewController in response to a user tap on
//	the Configure button. As designed, this brings up another popover. It is easy enough
//	rework the transition for iPhone navigation views or segues. See the configureButton
//	method.
//
//  Created by Mike Westerfield on 1/20/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "LoadImageViewController.h"

#import "ConfigurationViewController.h"

@interface LoadImageViewController () {
    BOOL doingLoad;							// YES if we are currently doing a load, else NO.
    int maxLoads;							// The maximum number of load attempts before giving up.
    int serialPort;							// The serial port.
}

@property (nonatomic, retain) NSString *ipAddress;					// The IP address of the XBee radio.
@property (nonatomic) BOOL viewingAlert;							// True when the user is viewing an alert.

@end

@implementation LoadImageViewController

@synthesize delegate;
@synthesize eeprom;
@synthesize ipAddress;
@synthesize ipAddressLabel;
@synthesize nameLabel;
@synthesize progressView;
@synthesize statusLabel;
@synthesize viewingAlert;
@synthesize xBee;

#pragma mark - Misc.

/*!
 * Load the binary file.
 *
 * Do not call this method from the main thread.
 *
 * @param binary			The name of the file to send to the propeller.
 */

- (void) load: (NSString *) binary {
    Loader *loader = [Loader defaultLoader];
    loader.delegate = self;
    
    NSError *error = nil;
    [loader load: binary
          eeprom: eeprom
            xBee: xBee
    loadAttempts: maxLoads
           error: &error];
    if (error)
        [self performSelectorOnMainThread: @selector(reportError:) withObject: error waitUntilDone: NO];
}

/*!
 * Load the preferences.
 */

- (void) loadPreferences {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *preferenceIPAddress = [defaults stringForKey: @"ip_address_preference"];
    if (preferenceIPAddress != nil)
        ipAddress = preferenceIPAddress;
    
    serialPort = 9750;
    NSString *serialPortPreference = [defaults stringForKey: @"serial_port_preference"];
    if (serialPortPreference != nil)
        serialPort = (int) [serialPortPreference integerValue];
    
    NSString *loadsPreference = [defaults stringForKey: @"load_retry_preference"];
    if (loadsPreference == nil)
        maxLoads = 2;
    else
        maxLoads = (int) [loadsPreference integerValue];
}

/*!
 * Report an error.
 *
 * If the app is in test mode, this just records the kind of error for statistics. If the user is loading a single
 * program, this reports the error in an error dialog.
 *
 * The caller is responsible for clean up and placing the machine back into a stable state.
 *
 * @param error		The system error to report.
 */

- (void) reportError: (NSError *) error {
    // Make sure the user isn't already seeing an error. (This prevents the stream methods from
    // reporting a cascade of errors, forcing the user to dismiss each one.)
    if (!viewingAlert) {
        // Display the error in an alert.
        self.viewingAlert = YES;
        NSString *title = @"Load Failed";
        if (error.code >= 10)
            title = @"Device Not Found";
        NSString *message = [error localizedDescription];
        if (error.localizedFailureReason != nil)
            message = [NSString stringWithFormat: @"%@\n\n%@", message, error.localizedFailureReason];
        if (error.localizedRecoverySuggestion != nil)
            message = [NSString stringWithFormat: @"%@\n\n%@", message, error.localizedRecoverySuggestion];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: message
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    doingLoad = NO;
}

/*!
 * Update the name of the current device.
 *
 * Do not call this method from the main thread.
 */

- (void) updateDeviceName {
    NSString *deviceName = [[Loader defaultLoader] getDeviceName: xBee];
    if (deviceName != nil)
        deviceName =[NSString stringWithFormat: @"Name: %@", deviceName];
    else {
        NSError *error = [NSError errorWithDomain: [[Loader defaultLoader] loaderDomain]
                                             code: 20
                                         userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                    @"An XBee device with the given IP address was not found.",
                                                    NSLocalizedDescriptionKey,
                                                    @"Make sure the device is turned on and in range. Use Settings to scan for available devices; this will also confirm the device is turned on.",
                                                    NSLocalizedRecoverySuggestionErrorKey,
                                                    nil]];
        [self performSelectorOnMainThread: @selector(reportError:) withObject: error waitUntilDone: NO];
    }
    
    [nameLabel performSelectorOnMainThread: @selector(setText:) withObject: deviceName waitUntilDone: NO];
}

#pragma mark - View maintenance

/*!
 * Called after the controller’s view is loaded into memory.
 */

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Set our initial state.
    Loader *loader = [Loader defaultLoader];
    loader.delegate = self;
    
    // Load the preferences once. This makes sure they are set on a new install, enabling test mode to fetch
    // an IP address and TCP port.
    [self loadPreferences];
    
    // Set up an XBee device record.
    if (xBee == nil) {
        self.xBee = [[TXBee alloc] init];
        xBee.ipAddr = ipAddress;
        xBee.ipPort = serialPort;
        xBee.cfgChecksum = VALUE_UNKNOWN;
        xBee.name = @"";
    }
}

/*!
 * Notifies the view controller that its view was added to a view hierarchy.
 *
 * You can override this method to perform additional tasks associated with presenting the view. If you override 
 * this method, you must call super at some point in your implementation.
 *
 * @param animated	If YES, the view was added to the window using an animation.
 */

- (void) viewDidAppear: (BOOL) animated {
    // Update the IP address.
    [self loadPreferences];
    ipAddressLabel.text = [NSString stringWithFormat: @"IP: %@", ipAddress];
    
    // Get the XBee object for this iP address (if any).
    NSArray *devices = [ConfigurationViewController xBeeDevices];
    TXBee *device = nil;
    for (TXBee *aDevice in devices)
        if ([aDevice.ipAddr isEqualToString: ipAddress]) {
            device = aDevice;
            break;
        }
    
    if (device) {
        nameLabel.text = device.name;
        ipAddress = device.ipAddr;
        self.xBee = device;
    } else {
        // Update the device name, but since it uses the Loader, which must listen to the UDP port on the main
        // thread, do this on another thread.
        [self performSelectorInBackground: @selector(updateDeviceName) withObject: nil];
    }
    
    [super viewDidAppear: animated];
}

#pragma mark - Actions

/*!
 * Handle a hit on the cancel button.
 *
 * @param sender			The button that triggered this call.
 */

- (IBAction) cancelButton: (id) sender {
    [[Loader defaultLoader] cancel];
}

#pragma mark - LoaderDelegate

/*!
 * Called when the loader has completed loading the binary.
 *
 * The loader is now in a dormant state, waiting for a new load.
 *
 * This method is always called from the main thread.
 */

- (void) loaderComplete {
    doingLoad = NO;
    if ([delegate respondsToSelector: @selector(loadImageViewControllerLoadComplete)])
        [delegate loadImageViewControllerLoadComplete];
}

/*!
 * Called when the loader is sending bytes from the binary image to the XBee, this allows the UI to report
 * progress to the user.
 *
 * @param progress		The progress. The range is 0.0 (starting) to 1.0 (complete).
 */

- (void) loaderProgress: (float) progress {
    if (progressView.isHidden)
        [progressView setHidden: NO];
    progressView.progress = progress;
}

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
 * This method is always called from the main thread.
 *
 * @param error			The error.
 */

- (void) loaderFatalError: (NSError *) error {
    [progressView setHidden: YES];
    [self reportError: error];
    if ([delegate respondsToSelector: @selector(loadImageViewControllerFatalError:)])
        [delegate loadImageViewControllerFatalError: error];
}

/*!
 * Called when the internal status of the loader changes, this method supplies a status string suitable for
 * display in a UI to provide textual progress information.
 *
 * This method is always called from the main thread.
 *
 * @param status		The test message indicating the status.
 */

- (void) loaderState: (NSString *) message {
    [statusLabel performSelectorOnMainThread: @selector(setText:) withObject: message waitUntilDone: YES];
}

@end
