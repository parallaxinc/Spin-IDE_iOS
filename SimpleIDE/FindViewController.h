//
//  FindViewController.h
//  Spin IDE
//
//  Created by Mike Westerfield on 2/17/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindViewController : UIViewController

@property (nonatomic, retain) IBOutlet UISwitch *caseSensitiveSwitch;
@property (nonatomic, retain) IBOutlet UIButton *findButton;
@property (nonatomic, retain) IBOutlet UITextField *findTextField;
@property (nonatomic, retain) UITextView *referenceTextView;
@property (nonatomic, retain) IBOutlet UIButton *replaceAllButton;
@property (nonatomic, retain) IBOutlet UIButton *replaceAndFindButton;
@property (nonatomic, retain) IBOutlet UIButton *replaceButton;
@property (nonatomic, retain) IBOutlet UITextField *replaceTextField;
@property (nonatomic, retain) IBOutlet UISwitch *wholeWordSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *wrapSwitch;

- (IBAction) checkButtons;
- (IBAction) findButtonAction;
- (IBAction) replaceAllButtonAction;
- (IBAction) replaceAndFindButtonAction;
- (IBAction) replaceButtonAction;
- (IBAction) textFieldDoneEditing: (id) sender;

@end
