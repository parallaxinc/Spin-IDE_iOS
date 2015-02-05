//
//  ProjectViewController.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/29/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "CompilerOptionsView.h"
#import "DetailViewController.h"
#include "LinkerOptionsView.h"
#include "LoadImageViewController.h"
#include "Project.h"
#include "ProjectOptionsView.h"
#include "PickerViewController.h"
#include "SpinCompilerOptionsView.h"

@interface ProjectViewController : UIViewController <DetailViewControllerDelegate, PickerViewControllerDelegate, LoadImageViewControllerDelegate, UITableViewDataSource, UIPopoverControllerDelegate, UIAlertViewDelegate>

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
@property (nonatomic, retain) IBOutlet SpinCompilerOptionsView *spinCompilerOptionsView;

- (IBAction) boardTypeAction: (id) sender;
- (IBAction) compilerTypeAction: (id) sender;
+ (ProjectViewController *) defaultProjectViewController;
- (IBAction) memoryModelAction: (id) sender;
- (IBAction) optimizationAction: (id) sender;
- (IBAction) optionsAction: (id) sender;

@end
