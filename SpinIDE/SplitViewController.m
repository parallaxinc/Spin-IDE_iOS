//
//  SplitViewController.m
//  SpinIDE
//
//  Created by Mike Westerfield on 4/27/15.
//  Copyright (c) 2015 Parallax, Inc. All rights reserved.
//

#import "SplitViewController.h"

#import "Common.h"
#import "DetailViewController.h"

static SplitViewController *this;						// This singleton instance of this class.


@interface SplitViewController ()

@end


@implementation SplitViewController

@synthesize barButtonItem;

#pragma mark - Misc

/*!
 * There is only one split view controller in the program, and there is always a split view 
 * controller, assuming initialization is complete. This call returns the singleton instance of 
 * the split view controller.
 *
 * @return			The project view controller.
 */

+ (SplitViewController *) defaultSplitViewController {
    return this;
}

#pragma mark - View Maintenance

/*!
 * Called after the controller’s view is loaded into memory.
 */

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Record our singleton instance.
    this = self;
    
    // Check the display mode.
    if ([self respondsToSelector: @selector(setPreferredDisplayMode:)])
        if ([Common hideFileListPreference])
            self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    
    // Set our delegate.
    self.delegate = self;
}

/*!
 * Notifies the container that the size of its view is about to change.
 *
 * UIKit calls this method before changing the size of a presented view controller’s view. You can 
 * override this method in your own objects and use it to perform additional tasks related to the 
 * size change. For example, a container view controller might use this method to override the traits 
 * of its embedded child view controllers. Use the provided coordinator object to animate any changes 
 * you make.
 *
 * If you override this method in your custom view controllers, always call super at some point in 
 * your implementation so that UIKit can forward the size change message appropriately. View controllers 
 * forward the size change message to their views and child view controllers. Presentation controllers 
 * forward the size change to their presented view controller.
 *
 * @param size				The new size for the container’s view.
 * @param coordinator		The transition coordinator object managing the size change. You can use 
 *							this object to animate your changes or get information about the transition 
 *							that is in progress.
 */

- (void) viewWillTransitionToSize: (CGSize) size
        withTransitionCoordinator: (id<UIViewControllerTransitionCoordinator>) coordinator
{
    [super viewWillTransitionToSize: size withTransitionCoordinator: coordinator];
    if ([Common hideFileListPreference])
        self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    else
        self.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
}

#pragma mark - UISplitViewControllerDelegate

/*!
 * Tells the delegate that the specified view controller is about to be hidden.
 *
 * When the split view controller rotates from a landscape to portrait orientation, it normally hides 
 * one of its view controllers. When that happens, it calls this method to coordinate the addition of 
 * a button to the toolbar (or navigation bar) of the remaining custom view controller. If you want 
 * the soon-to-be hidden view controller to be displayed in a popover, you must implement this method 
 * and use it to add the specified button to your interface.
 *
 * @param svc				The split view controller that owns the specified view controller.
 * @param aViewController	The view controller being hidden.
 * @param theBarButtonItem	A button you can add to your toolbar.
 * @param pc				The popover controller that uses taps in barButtonItem to display the 
 *							specified view controller.
 */

- (void) splitViewController: (UISplitViewController *) splitController 
      willHideViewController: (UIViewController *) viewController 
           withBarButtonItem: (UIBarButtonItem *) theBarButtonItem 
        forPopoverController: (UIPopoverController *) popoverController
{
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        self.barButtonItem = theBarButtonItem;
        barButtonItem.title = @"Files";
        [[DetailViewController defaultDetailViewController] reloadButtons];
    }
}

/*!
 * Tells the delegate that the specified view controller is about to be shown again.
 *
 * When the view controller rotates from a portrait to landscape orientation, it shows its hidden 
 * view controller once more. If you added the specified button to your toolbar to facilitate the 
 * display of the hidden view controller in a popover, you must implement this method and use it 
 * to remove that button.
 *
 * @param svc				The split view controller that owns the specified view controller.
 * @param aViewController	The view controller being hidden.
 * @param button			The button used to display the view controller while it was hidden. 
 */

- (void) splitViewController: (UISplitViewController *) svc
      willShowViewController: (UIViewController *) aViewController
   invalidatingBarButtonItem: (UIBarButtonItem *) button
{
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        self.barButtonItem = nil;
        [[DetailViewController defaultDetailViewController] reloadButtons];
    }
}

/*
 * Asks the delegate whether the first view controller should be hidden for the specified orientation.
 *
 * Parameters:
 *	svc: The split view controller that owns the first view controller.
 *	vc: The first view controller in the array of view controllers.
 *	orientation: The orientation being considered.
 *
 * Returns: YES if the view controller should be hidden in the specified orientation or NO if it should be visible.
 */

- (BOOL) splitViewController: (UISplitViewController *) svc 
    shouldHideViewController: (UIViewController *) vc 
               inOrientation: (UIInterfaceOrientation) orientation
{
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        return [Common hideFileListPreference];
    }
    return YES;
}

@end
