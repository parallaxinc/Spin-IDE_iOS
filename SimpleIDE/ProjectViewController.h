//
//  ProjectViewController.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/29/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html ).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "CompilerOptionsView.h"
#include "LinkerOptionsView.h"
#include "ProjectOptionsView.h"
#include "PickerViewController.h"

@interface ProjectViewController : UIViewController <PickerViewControllerDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UIButton *boardTypeButton;
@property (nonatomic, retain) IBOutlet UITextField *compilerOptionsTextField;
@property (nonatomic, retain) IBOutlet CompilerOptionsView *compilerOptionsView;
@property (nonatomic, retain) IBOutlet UIButton *compilerTypeButton;
@property (nonatomic, retain) IBOutlet UITextField *linkerOptionsTextField;
@property (nonatomic, retain) IBOutlet LinkerOptionsView *linkerOptionsView;
@property (nonatomic, retain) IBOutlet UIButton *memoryModelButton;
@property (nonatomic, retain) IBOutlet UITableView *namesTableView;
@property (nonatomic, retain) IBOutlet UIButton *optimizationButton;
@property (nonatomic, retain) IBOutlet UIView *optionsView;
@property (nonatomic, retain) IBOutlet ProjectOptionsView *projectOptionsView;

- (IBAction) boardTypeAction: (id) sender;
- (IBAction) compilerTypeAction: (id) sender;
- (IBAction) memoryModelAction: (id) sender;
- (IBAction) optimizationAction: (id) sender;
- (IBAction) optionViewSelected: (id) sender;

@end
