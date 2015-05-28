//
//  DetailViewController.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/29/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NewFileOrProjectViewController.h"
#import "OpenFileViewController.h"
#import "OpenProjectViewController.h"
#import "RenameFileOrProjectViewController.h"
#import "ShareViewController.h"
#import "SourceConsoleSplitView.h"

@protocol DetailViewControllerDelegate <NSObject>

/*!
 * Build the currently open project.
 *
 * Passes the user's request to build the current project to the delegate.
 */

- (void) detailViewControllerBuildProject;

/*!
 * Close the open file.
 *
 * Passes the user's request to delete the current file to the delegate.
 */

- (void) detailViewControllerCloseFile;

/*!
 * Copy a file to the currently open project.
 *
 * The new file name is garanteed not to exist in the current project. The source file may, however,
 * be in the current project (although toFileName will differ in that case).
 *
 * @param fromPath		The full path of the file to copy.
 * @param toFileName	The file name for the file in the project.
 */

- (void) detailViewControllerCopyFrom: (NSString *) fromPath to: (NSString *) toFileName;

/*!
 * Delete the open file.
 *
 * Passes the user's request to delete the current file to the delegate.
 */

- (void) detailViewControllerDeleteFile;

/*!
 * Delete the open project.
 *
 * Passes the user's request to delete the current project to the delegate.
 */

- (void) detailViewControllerDeleteProject;

/*!
 * Tells the delegate to share the current project via email.
 */

- (void) detailViewControllerEMail;

/*!
 * Open a new file in the current project.
 *
 * @param name		The name for the new file.
 */

- (void) detailViewControllerNewFile: (NSString *) name;

/*!
 * Open a project.
 *
 * The project must be in the sandbox. The name is the name of the project folder and the .side file. For example, if the
 * project name is foo, there must be a project file named <sandbox>/foo/foo.side.
 *
 * Opening a project wipes out information about the previously open project (but it should have been saved by this point).
 *
 * @param name		The name of the project to open.
 */

- (void) detailViewControllerOpenProject: (NSString *) name;

/*!
 * Open a file.
 *
 * The project must be in a project in the sandbox.
 *
 * @param project	The name of the project containing the file.
 * @param file		The the name of the file (with extension) in the project.
 */

- (void) detailViewControllerOpenProject: (NSString *) project file: (NSString *) file;

/*!
 * Rename a file in the current project.
 *
 * The name is garanteed not to already exist as a project.
 *
 * @param oldName		The current name of the file.
 * @param newName		The new name of the file.
 */

- (void) detailViewControllerRenameFile: (NSString *) oldName newName: (NSString *) newName;

/*!
 * Rename a project.
 *
 * The current project is renamed. The new name is passed. The name is garanteed not to already exist as a project.
 *
 * @param name		The new name of the project.
 */

- (void) detailViewControllerRenameProject: (NSString *) name;

/*!
 * Run the currently open project.
 *
 * Passes the user's request to run the current project to the delegate.
 *
 * @param sender		The UI component that triggered this call. Used to position the popover.
 */

- (void) detailViewControllerRunProject: (UIView *) sender;

/*!
 * Seelct an XBee device.
 *
 * Passes the user's request to select an XBee device to the delegate.
 *
 * @param sender		The UI component that triggered this call. Used to position the popover.
 */

- (void) detailViewControllerXBeeProject: (UIView *) sender;

@end


typedef enum {stateNothingOpen, stateOpenProject, stateOpenFiles, stateOpenProjectAndFilesEditingProjectFile, stateOpenProjectAndFilesEditingNonProjectFile} buttonStates;


@interface DetailViewController : UIViewController <NewFileOrProjectViewControllerDelegate, OpenFileViewControllerDelegate, OpenProjectViewControllerDelegate, RenameFileOrProjectViewControllerDelegate, UIPopoverControllerDelegate, SourceViewDelegate,
    ShareViewControllerDelegate>

@property (nonatomic) buttonStates buttonState;
@property (weak, nonatomic) id<DetailViewControllerDelegate> delegate;
@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) IBOutlet SourceConsoleSplitView *sourceConsoleSplitView;
@property (nonatomic, retain) IBOutlet UINavigationItem *sourceNavigationItem;

- (void) checkButtonState;
+ (DetailViewController *) defaultDetailViewController;
- (void) reloadButtons;
- (void) removeProject: (NSString *) name;

@end
