//
//  NewProjectViewController.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/26/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewFileOrProjectViewController;


@protocol NewFileOrProjectViewControllerDelegate <NSObject>

/*!
 * Called if the user taps Create or Cancel, this method passes the name for a new project.
 *
 * @param picker		The picker object that made this call.
 * @param name			The name for the new project, or nil of Cancel was pressed.
 * @param isProject		YES if we are creating a new project, or NO if we are creating a new file.
 */

- (void) newFileOrProjectViewController: (NewFileOrProjectViewController *) picker name: (NSString *) name isProject: (BOOL) isProject;

@end


@interface NewFileOrProjectViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UIButton *createButton;
@property (weak, nonatomic) id<NewFileOrProjectViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) UINavigationController *navController;	// The navigation controller.
@property (nonatomic, retain) NSArray *projects;						// An array of NSString; the names of all current projects.

- (IBAction) cancelButtonAction: (id) sender;
- (IBAction) createButtonAction: (id) sender;
- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
                prompt: (NSString *) prompt
             isProject: (BOOL) isProject;

@end
