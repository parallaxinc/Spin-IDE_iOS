//
//  RenameProjectViewController.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 2/2/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RenameFileOrProjectViewController;

@protocol RenameFileOrProjectViewControllerDelegate <NSObject>

/*!
 * Called if the user taps Rename or Cancel, this method passes the new name for a file or project.
 *
 * @param picker		The picker object that made this call.
 * @param name			The new name for the file or project, or nil of Cancel was pressed.
 * @param oldName		The old name for the file or project, or nil of Cancel was pressed.
 * @param isProject		YES if we are renaming a project, or NO if we are renaming a file.
 */

- (void) renameFileOrProjectViewControllerRename: (RenameFileOrProjectViewController *) picker 
                                            name: (NSString *) name 
                                         oldName: (NSString *) oldName 
                                       isProject: (BOOL) isProject;

@end


@interface RenameFileOrProjectViewController : UIViewController

@property (weak, nonatomic) id<RenameFileOrProjectViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) UINavigationController *navController;	// The navigation controller.
@property (nonatomic, retain) NSArray *currentNames;					// An array of NSString; the names of all current projects or files.
@property (nonatomic, retain) IBOutlet UIButton *renameButton;

- (IBAction) cancelButtonAction: (id) sender;
- (IBAction) renameButtonAction: (id) sender;
- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
                prompt: (NSString *) prompt
             isProject: (BOOL) isProject
              fileName: (NSString *) fileName;

@end
