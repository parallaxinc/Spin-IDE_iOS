//
//  ConfigurationViewController.h
//  XBee Loader
//
//  Created by Mike Westerfield on 4/15/14 at the Byte Works, Inc.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Loader.h"

@interface ConfigurationViewController : UIViewController <UITextFieldDelegate, LoaderDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, retain) IBOutlet UITextField *ipAddressTextField;
@property (nonatomic, retain) IBOutlet UITextField *portTextField;
@property (nonatomic, retain) IBOutlet UITextField *subnetTextField;
@property (nonatomic, retain) IBOutlet UILabel *knownDevicesLabel;

- (IBAction) scanButtonPressed: (id) sender;
+ (NSArray *) xBeeDevices;

@end
