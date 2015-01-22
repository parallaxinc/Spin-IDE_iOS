//
//  DetailViewController.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/29/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OpenProjectViewController.h"
#include "SourceConsoleSplitView.h"

@protocol DetailViewControllerDelegate <NSObject>

/*!
 * Build the currently open project.
 *
 * Passes the user's request to build the current project to the delegate.
 */

- (void) detailViewControllerDelegateBuildProject;

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

- (void) detailViewControllerDelegateOpenProject: (NSString *) name;

/*!
 * Run the currently open project.
 *
 * Passes the user's request to run the current project to the delegate.
 *
 * @param sender		The UI component that triggered this call. Used to position the popover.
 */

- (void) detailViewControllerDelegateRunProject: (UIView *) sender;

/*!
 * Seelct an XBee device.
 *
 * Passes the user's request to select an XBee device to the delegate.
 *
 * @param sender		The UI component that triggered this call. Used to position the popover.
 */

- (void) detailViewControllerDelegateXBeeProject: (UIView *) sender;

@end


@interface DetailViewController : UIViewController <OpenProjectViewControllerDelegate, UISplitViewControllerDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) id<DetailViewControllerDelegate> delegate;
@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) IBOutlet SourceConsoleSplitView *sourceConsoleSplitView;
@property (nonatomic, retain) IBOutlet UINavigationItem *sourceNavigationItem;

+ (DetailViewController *) defaultDetailViewController;
- (void) splitViewController: (UISplitViewController *) svc
     willChangeToDisplayMode: (UISplitViewControllerDisplayMode) displayMode;

@end
