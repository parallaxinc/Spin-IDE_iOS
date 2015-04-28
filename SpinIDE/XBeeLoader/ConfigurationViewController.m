//
//  ConfigurationViewController.m
//  XBee Loader
//
//  Created by Mike Westerfield on 4/15/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "ConfigurationViewController.h"

#include "Common.h"
#include "XBeeCommon.h"
#include "ProgressView.h"

@interface ConfigurationViewController () {
    int serialPort;											// The general serial communication port.
    double startScanTime;									// The time when scanning for devices began.
    double totalScanTime;									// The time required to scan for devices.
}

@property (nonatomic, retain) id<LoaderDelegate> delegate;	// The loader delegate when this view was displayed.
@property (nonatomic, retain) UIPickerView *devicePicker;	// The XBee device picker.
@property (nonatomic, retain) UIView *glassView;			// Used to animate addition/removal of the progress bar.
@property (nonatomic, retain) NSString *ipAddress;			// The IP address of the XBee radio.
@property (nonatomic) ProgressView *progress;				// The current progress dialog, or nil if there isn't one.

@end


static NSArray *xBeeDevices;	// The currently known XBee devices.


@implementation ConfigurationViewController

@synthesize delegate;
@synthesize devicePicker;
@synthesize glassView;
@synthesize ipAddress;
@synthesize ipAddressTextField;
@synthesize knownDevicesLabel;
@synthesize portTextField;
@synthesize progress;
@synthesize subnetTextField;


/*!
 * Load the preferences.
 */

- (void) loadPreferences {
    // Get the ipAddress preference.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *preferenceIPAddress = [defaults stringForKey: @"ip_address_preference"];
    if (preferenceIPAddress != nil)
        ipAddress = preferenceIPAddress;
    
    // Load the text fields with the prefered values.
    ipAddressTextField.text = ipAddress;
    
    serialPort = 9750;
    NSString *serialPortString = [defaults stringForKey: @"serial_port_preference"];
    if (serialPortString != nil)
        serialPort = (int) [serialPortString integerValue];

    NSString *subnetString = [defaults stringForKey: @"subnet_preference"];
    if (subnetString == nil)
        subnetString = @"255.255.255.0";
    subnetTextField.text = subnetString;
}

/*!
 * Handle a hit on the button requesting scanning for devices.
 */

- (IBAction) scanButtonPressed: (id) sender {
    // Start the scan.
    [glassView setHidden: NO];
    self.progress = [[ProgressView alloc] initWithFrame: CGRectMake(20, 100, 280, 88)];
    progress.title = @"Scan for devices...";
    [UIView transitionWithView: glassView
                      duration: 0.5
                       options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionFlipFromRight
                    animations: ^(void){[glassView addSubview: self.progress];}
                    completion: ^(BOOL finished) {[self performSelectorInBackground: @selector(scanForDevices) withObject: nil];}];
    
    // Set up the timers for progress. We assume a scan will take about 1.5 seconds, but will adjust it based
    // on actual scan times.
    if (totalScanTime <= 0)
        totalScanTime = 1.5;
    startScanTime = CFAbsoluteTimeGetCurrent();
    [NSTimer scheduledTimerWithTimeInterval: 0.1
                                     target: self
                                   selector: @selector(updateProgress:)
                                   userInfo: nil
                                    repeats: NO];
}

/*!
 * Scan for avialable XBee WiFi devices.
 */

- (void) scanForDevices {
    NSString *subnet = [[[Common getIPAddress] stringByDeletingPathExtension] stringByAppendingPathExtension: @"255"];
    Loader *loader = [Loader defaultLoader];
    self.delegate = loader.delegate;
    loader.delegate = self;
    [loader scan: subnet commandPort: [XBeeCommon udpPort] serialPort: serialPort];
}

/*!
 * Select the current device form the device list.
 */

- (void) selectCurrentDevice {
    if (xBeeDevices.count > 0) {
        BOOL foundDefault = NO;
        for (int i = 0; i < xBeeDevices.count; ++i) {
            TXBee *xBee = xBeeDevices[i];
            if ([xBee.ipAddr isEqualToString: ipAddress]) {
                [devicePicker selectRow: i inComponent: 0 animated: YES];
                foundDefault = YES;
                break;
            }
        }
        if (!foundDefault) {
            [devicePicker selectRow: 0 inComponent: 0 animated: YES];
            [self pickerView: nil didSelectRow: 0 inComponent: 0];
        }
    }
}

/*!
 * Sets the progress indicator.
 *
 * This is a convenience method used to update the progress indicator. It must be called from the main thread.
 */

- (void) setProgress {
    [progress setProgress: (CFAbsoluteTimeGetCurrent() - startScanTime)/totalScanTime];
}

/*!
 * Update the progress indicator.
 *
 * We don't have a reliable way of knowing how long a scan will take. We use an estimate for the total time, then
 * update the progress based on the elapsed time. This method is called periodically to update the progress
 * indicator.
 *
 * @param timer		The timer that fired this action.
 */

- (void) updateProgress: (NSTimer *) tiemr {
    if (progress != nil) {
        [self performSelectorOnMainThread: @selector(setProgress) withObject: nil waitUntilDone: NO];
        [NSTimer scheduledTimerWithTimeInterval: 0.1
                                         target: self
                                       selector: @selector(updateProgress:)
                                       userInfo: nil
                                        repeats: NO];
    }
}

#pragma mark - View maintenance

/*!
 * Called after the controller’s view is loaded into memory.
 */

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Create the device picker. This is done in code rather than in the nib file to avoid a bug in
    // iOS 6.1 that causes the picker to be resized when the view is rerdawn.
    float y = knownDevicesLabel.frame.origin.y + knownDevicesLabel.frame.size.height + 10;
    if (IS_4_INCH_IPHONE)
        devicePicker = [[UIPickerView alloc] initWithFrame: CGRectMake(0, y, 320, 216)];
    else
        devicePicker = [[UIPickerView alloc] initWithFrame: CGRectMake(0, y, 320, 162)];
    devicePicker.delegate = self;
    devicePicker.dataSource = self;
    devicePicker.showsSelectionIndicator = YES;
    [self.view addSubview: devicePicker];
    
	// Add a glass view, used for animating the progress view.
    self.glassView = [[UIView alloc] initWithFrame: self.view.frame];
    [self.view addSubview: glassView];
    [glassView setHidden: YES];
}

/*!
 * Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 * @param animated		If YES, the view is being added to the window using an animation.
 */

- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear: animated];
    [self.navigationController setNavigationBarHidden: NO animated: YES];
    [self loadPreferences];
    [self selectCurrentDevice];
}

/*!
 * Notifies the view controller that its view is about to be removed from a view hierarchy.
 *
 * @param animated		If YES, the view is being removed using an animation.
 */

- (void) viewWillDisappear: (BOOL) animated {
    [self.navigationController setNavigationBarHidden: YES animated: NO];
    [super viewWillDisappear: animated];
}

#pragma mark - LoaderDelegate

/*!
 * When the delegate calls scan:port:, this class begins a process of collecting a list of available XBee WiFi
 * devices. Once the process is complete, this method is called on the delegate.
 *
 * @param devices		An array of devices found. This may be empty, but will not be null. Each element in the
 *						array (if any) is a TXBee object with all relevant information about the device filled in.
 */

- (void) loaderDevices: (NSArray *) devices {
	// Remember the devices.
    xBeeDevices = devices;
    
    // Reload the picker's contents.
    [devicePicker reloadAllComponents];
    
    // Select the current device.
    [self selectCurrentDevice];
    
    // Restore the superview's delegate in the loader.
    [Loader defaultLoader].delegate = delegate;
    self.delegate = nil;
    
    // Close the progress dialog.
    [UIView transitionWithView: glassView
                      duration: 0.5
                       options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionFlipFromRight
                    animations: ^(void){[self.progress removeFromSuperview];}
                    completion: ^(BOOL finished) {
                        [glassView setHidden: YES];
                        self.progress = nil;
                        totalScanTime = CFAbsoluteTimeGetCurrent() - startScanTime;
                    }];
}

/*!
 * Return a list of the currently known XBee devices.
 *
 * This list is generated by the Scan command. It may be nil or empty, even if there are valid XBee devices in the
 * cloud. It will not be filled in until the user does a scan, but it is usedul after that point for things like
 * getting the name of an XBee device without the need to look for it via WiFi.
 *
 * @return		The list of known XBee devices.
 */

+ (NSArray *) xBeeDevices {
    return xBeeDevices;
}

#pragma mark - UIPickerViewDataSource

/*!
 * Called by the picker view when it needs the number of components.
 *
 * @param pickerView		The picker view requesting the data.
 *
 * @return					The number of components (or “columns”) that the picker view should display.
 */

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {
    return 1;
}

/*!
 * Called by the picker view when it needs the number of rows for a specified component.
 *
 * @param pickerView		The picker view requesting the data.
 * @param component			A zero-indexed number identifying a component of pickerView. Components are
 *							numbered left-to-right.
 *
 * @return					The number of rows for the component.
 */

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {
    if (xBeeDevices == nil || xBeeDevices.count == 0)
        return 1;
    return xBeeDevices.count;
}

#pragma mark - UIPickerViewDelegate

/*!
 * Called by the picker view when it needs the title to use for a given row in a given component.
 *
 * @param pickerView		An object representing the picker view requesting the data.
 * @param row				A zero-indexed number identifying a row of component. Rows are numbered
 *							top-to-bottom.
 * @param component			A zero-indexed number identifying a component of pickerView. Components
 *							are numbered left-to-right.
 *
 * @return					The string to use as the title of the indicated component row.
 */

- (NSString *) pickerView: (UIPickerView *) pickerView titleForRow: (NSInteger) row forComponent: (NSInteger) component {
    if (xBeeDevices == nil || xBeeDevices.count == 0)
        return @"(None: Press Scan for …)";
    NSString *ipAddr = ((TXBee *) xBeeDevices[row]).ipAddr;
    NSString *name = ((TXBee *) xBeeDevices[row]).name;
    if ([name length] > 0)
        return [NSString stringWithFormat: @"%@ (%@)", ipAddr, name];
    return ipAddr;
}

/*!
 * Called by the picker view when the user selects a row in a component.
 *
 * NOTE: This method does not currently use the pickerView or component parameters. If that changes, rethink the
 * call in selectCurrentDevice.
 *
 * @param pickerView		An object representing the picker view requesting the data.
 * @param row				A zero-indexed number identifying a row of component. Rows are numbered 
 *							top-to-bottom.
 * @param component			A zero-indexed number identifying a component of pickerView. Components 
 *							are numbered left-to-right.
 */

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {
    if (xBeeDevices != nil && xBeeDevices.count > row) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *ipAddr = ((TXBee *) xBeeDevices[row]).ipAddr;
        ipAddressTextField.text = ipAddr;
        [defaults setValue: ipAddr forKey: @"ip_address_preference"];
        [defaults setValue: ((TXBee *) xBeeDevices[row]).name forKey: @"device_name_preference"];
    }
}

#pragma mark - UITextFieldDelegate

/*!
 * Asks the delegate if the text field should process the pressing of the return button. We use this
 * to dismiss the keyboard when the user is entering text in one of the UITextField objects and to
 * record the new values.
 *
 * @param textField		The text field whose return button was pressed.
 */

- (BOOL) textFieldShouldReturn: (UITextField *) textField {
    // Set the preferences.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue: ipAddressTextField.text forKey: @"ip_address_preference"];
    [defaults setValue: portTextField.text forKey: @"serial_port_preference"];
    [defaults setValue: subnetTextField.text forKey: @"subnet_preference"];
    
    // Hide the keyboard.
    [textField resignFirstResponder];
    return NO;
}

@end
