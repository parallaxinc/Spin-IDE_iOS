//
//  ProjectViewController.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/29/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MFMailComposeViewController.h>

#include "CompilerOptionsView.h"
#import "DetailViewController.h"
#include "LinkerOptionsView.h"
#include "LoadImageViewController.h"
#include "Project.h"
#include "ProjectOptionsView.h"
#include "PickerViewController.h"
#include "SpinCompilerOptionsView.h"
#import "TerminalView.h"

@interface ProjectViewController : UIViewController <DetailViewControllerDelegate, PickerViewControllerDelegate, LoadImageViewControllerDelegate, UITableViewDataSource, UIPopoverControllerDelegate, UIAlertViewDelegate, 
	SpinCompilerOptionsViewDelegate, MFMailComposeViewControllerDelegate, TerminalViewDelegate>

@property (nonatomic, retain) IBOutlet UIButton *baudButton;
@property (nonatomic, retain) IBOutlet UIButton *boardTypeButton;
@property (nonatomic, retain) IBOutlet UITextField *compilerOptionsTextField;
@property (nonatomic, retain) IBOutlet CompilerOptionsView *compilerOptionsView;
@property (nonatomic, retain) IBOutlet UIButton *compilerTypeButton;
@property (nonatomic, retain) IBOutlet UITextField *linkerOptionsTextField;
@property (nonatomic, retain) IBOutlet LinkerOptionsView *linkerOptionsView;
@property (nonatomic, retain) IBOutlet UIButton *memoryModelButton;
@property (nonatomic, retain) IBOutlet UITableView *namesTableView;
@property (nonatomic, retain) NSMutableArray *openFiles;							// Open non-project files.
@property (nonatomic, retain) IBOutlet UIButton *optimizationButton;
@property (nonatomic, retain) IBOutlet UISegmentedControl *optionsSegmentedControl;
@property (nonatomic, retain) IBOutlet UIView *optionsView;
@property (nonatomic, retain) Project *project;
@property (nonatomic, retain) IBOutlet ProjectOptionsView *projectOptionsView;
@property (nonatomic, retain) IBOutlet UIImageView *rxLed;
@property (nonatomic, retain) IBOutlet UIView *simpleIDEOptionsView;
@property (nonatomic, retain) IBOutlet UIView *spinIDEOptionsView;
@property (nonatomic, retain) IBOutlet SpinCompilerOptionsView *spinOnlyCompilerView;
@property (nonatomic, retain) IBOutlet UIView *spinOptionsView;
@property (nonatomic, retain) IBOutlet SpinCompilerOptionsView *spinCompilerOptionsView;
@property (nonatomic, retain) IBOutlet UIView *spinTerminalOptionsView;
@property (nonatomic, retain) IBOutlet UITextField *spinCompilerOptionsTextField;
@property (nonatomic, retain) IBOutlet UIImageView *txLed;

- (IBAction) baudAction: (id) sender;
- (IBAction) boardTypeAction: (id) sender;
- (IBAction) clearButtonAction: (id) sender;
- (IBAction) compilerTypeAction: (id) sender;
+ (ProjectViewController *) defaultProjectViewController;
- (IBAction) echoValueChanged: (id) sender;
- (IBAction) memoryModelAction: (id) sender;
- (void) openProject: (NSURL *) url;
- (IBAction) optimizationAction: (id) sender;
- (IBAction) optionsAction: (id) sender;

@end
