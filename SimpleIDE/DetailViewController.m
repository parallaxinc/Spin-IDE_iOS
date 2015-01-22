//
//  DetailViewController.m
//  SimpleIDE
//
//	This singleton class controls the detail view for the app.
//
//  Created by Mike Westerfield on 4/29/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "DetailViewController.h"

#import "libpropeller-elf-cpp.h"
#import "NavToolBar.h"
#import "ProjectViewController.h"


typedef enum {tagOpenProject} alertTags;

static DetailViewController *this;						// This singleton instance of this class.


@interface DetailViewController () {
    BOOL initialized;								// Has the view been initialized?
}

@property (nonatomic, retain) UIPopoverController *pickerPopoverController;
@property (nonatomic, retain) NSMutableArray *projects;
@property (nonatomic, retain) UIButton *runButton;
@property (nonatomic, retain) UIView *toolBarView;
@property (nonatomic, retain) UIButton *xbeeButton;

@end


@implementation DetailViewController

@synthesize delegate;
@synthesize pickerPopoverController;
@synthesize projects;
@synthesize runButton;
@synthesize sourceConsoleSplitView;
@synthesize sourceNavigationItem;
@synthesize toolBarView;
@synthesize xbeeButton;

#pragma mark - Misc

/*!
 * Add a new button to the toolBarView.
 *
 * @param imageName		The name of the image for the button.
 * @param x				The horizontal location for the button in the view. Updated to the pixel just 
 *						after the new button.
 * @param action		The action to trigger when the button is released.
 *
 * @return				The button created.
 */

- (UIButton *) addButtonWithImageNamed: (NSString *) imageName x: (float *) x action: (SEL) action {
    float toolBarHeight = self.navigationController.navigationBar.frame.size.height;

    UIImage *image = [UIImage imageNamed: imageName];
    UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    button.frame = CGRectMake(*x, (toolBarHeight - image.size.height)/2, image.size.width, image.size.height);
    [button setImage: image forState: UIControlStateNormal];
    [button addTarget: self action: action forControlEvents: UIControlEventTouchUpInside];
    [toolBarView addSubview: button];
    
    *x += image.size.width;
    
    return button;
}

/*!
 * There is only one detail view controller in the program, and there is always a default view 
 * controller, assuming initialization is complete. This call returns the singleton instance of 
 * the default view controller.
 *
 * @return			The project view controller.
 */

+ (DetailViewController *) defaultDetailViewController {
    return this;
}

/*!
 * Frees memory allocated by commandLineArgumentsFor:count:.
 *
 * @param args		The command line arguments to dispose of.
 * @param count		The number of command line arguments.
 */

- (void) freeCommandLineArguments: (char **) args count: (int) count {
    for (int i = 0; i < count; ++i)
        free(args[i]);
    free(args);
}

/*!
 * This workhorse method handles the heavy lifting for all of the buttons that use a picker view to
 * select options.
 *
 * @param tag			The tag identifying the action for this view.
 * @param prompt		The prompt that appear at the top of the view.
 * @param elements		An array of strings to display in the picker.
 * @param button		The button that started the action; used to position the view.
 * @param index			The index of the initially selected row.
 */

- (void) pickerAction: (alertTags) tag
               prompt: (NSString *) prompt
             elements: (NSArray *) elements
               button: (UIButton *) button
                index: (int) index
{
    // Create the controller and add the root controller.
    OpenProjectViewController *pickerController = [[OpenProjectViewController alloc] initWithNibName: @"OpenProjectViewController"
                                                                                              bundle: nil
                                                                                              prompt: prompt
                                                                                                 tag: tag];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: pickerController];
    pickerController.navController = navigationController;
    pickerController.pickerElements = elements;
    pickerController.delegate = self;
    ProjectViewController *projectViewController = [ProjectViewController defaultProjectViewController];
    if (projectViewController.project && projectViewController.project.name)
        [pickerController setSelectedElement: projectViewController.project.name];
    
    // Create the popover.
    UIPopoverController *pickerPopover = [[NSClassFromString(@"UIPopoverController") alloc]
                                          initWithContentViewController: navigationController];
    [pickerPopover setPopoverContentSize: pickerController.view.frame.size];
    CGRect viewSize = pickerController.view.frame;
    [pickerPopover setPopoverContentSize: viewSize.size];
    [pickerPopover setDelegate: self];
    
    // Display the popover.
    self.pickerPopoverController = pickerPopover;
    [self.pickerPopoverController presentPopoverFromRect: button.frame
                                                  inView: toolBarView
                                permittedArrowDirections: UIPopoverArrowDirectionUp
                                                animated: YES];
    
    // Select the proper row in the picker.
    if (index < elements.count)
        [pickerController.picker selectRow: index inComponent: 0 animated: NO];
}

#pragma mark - Actions

/*!
 * Handle a hit on the Build Project button.
 */

- (void) buildProjectAction {
    if ([delegate respondsToSelector: @selector(detailViewControllerDelegateBuildProject)])
        [delegate detailViewControllerDelegateBuildProject];
}

/*!
 * Handle a hit on the Delete Project button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) deleteProjectAction: (id) sender {
    // TODO: Implement deleteProjectAction.
}

/*!
 * Handle a hit on the New Project button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) newProjectAction: (id) sender {
    // TODO: Implement newProjectAction.
}

/*!
 * Handle a hit on the Open Project button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) openProjectAction: (id) sender {
    // Collect the available projects.
    projects = [[NSMutableArray alloc] init];
    
    NSString *sandBoxPath = [Common sandbox];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *files = [manager contentsOfDirectoryAtPath: sandBoxPath error: nil];
    for (NSString *projectName in files) {
        NSString *fullPath = [sandBoxPath stringByAppendingPathComponent: projectName];
        BOOL isDirectory;
        if ([manager fileExistsAtPath: fullPath isDirectory: &isDirectory] && isDirectory) {
            NSString *projectPath = [fullPath stringByAppendingPathComponent: [projectName stringByAppendingPathExtension: @"side"]];
            if ([manager fileExistsAtPath: projectPath])
                [projects addObject: projectName];
        }
    }
    
    // Present the project selection view.
    [self pickerAction: tagOpenProject prompt: @"Open a Project" elements: projects button: sender index: 0];
}

/*!
 * Handle a hit on the Rename Project button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) renameProjectAction: (id) sender {
    // TODO: Implement renameProjectAction.
}

/*!
 * Handle a hit on the Run Project button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) runProjectAction {
    if ([delegate respondsToSelector: @selector(detailViewControllerDelegateRunProject:)])
        [delegate detailViewControllerDelegateRunProject: runButton];
}

/*!
 * Handle a hit on the XBee button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) xbeeAction {
    if ([delegate respondsToSelector: @selector(detailViewControllerDelegateXBeeProject:)])
        [delegate detailViewControllerDelegateXBeeProject: xbeeButton];
}

#pragma mark - View Maintenance

/*!
 * Called after the controller’s view is loaded into memory.
 */

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Record our ingleton instance.
    this = self;
}

/*!
 * Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 * @param animated		If YES, the view is being added to the window using an animation.
 */

- (void) viewWillAppear: (BOOL) animated {
    if (!initialized) {
        // Add some color to the nav bar.
        self.navigationController.navigationBar.backgroundColor = [UIColor grayColor];
        
        // Create the default button bar items.
        
        // Create the button view.
        float toolBarHeight = self.navigationController.navigationBar.frame.size.height;
        float toolBarWidth = self.navigationController.navigationBar.frame.size.width;
        self.toolBarView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, toolBarWidth, toolBarHeight)];
        toolBarView.backgroundColor = [UIColor clearColor];
        
        // Add the buttons to the button view.
        float x = 0;
        [self addButtonWithImageNamed: @"new.png" x: &x action: @selector(newProjectAction:)];
        x += 10;
        [self addButtonWithImageNamed: @"openproj.png" x: &x action: @selector(openProjectAction:)];
        x += 10;
        [self addButtonWithImageNamed: @"rename.png" x: &x action: @selector(renameProjectAction:)];
        x += 10;
        [self addButtonWithImageNamed: @"delete.png" x: &x action: @selector(deleteProjectAction:)];
        x += 10;
        [self addButtonWithImageNamed: @"build.png" x: &x action: @selector(buildProjectAction)];
        x += 10;
        xbeeButton = [self addButtonWithImageNamed: @"xbee.png" x: &x action: @selector(xbeeAction)];
        x += 10;
        runButton = [self addButtonWithImageNamed: @"run.png" x: &x action: @selector(runProjectAction)];
        
        // Use our button view as the navigation title view.
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.titleView = self.toolBarView;
        if ([self respondsToSelector: @selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
        initialized = YES;
    }
    
    // Call super.
    [super viewWillAppear: animated];
}

#pragma mark - PopoverController Delegate Methods

/*!
 * Tells the delegate that the popover was dismissed.
 *
 * Parameters:
 *  popoverController: The popover controller that was dismissed.
 */

- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController {
    if (popoverController == pickerPopoverController)
        self.pickerPopoverController = nil;
}

#pragma mark - OpenProjectViewControllerDelegate

/*!
 * Called if the user taps Open or Cancel, this method passes the index of the selected project file.
 *
 * @param picker		The picker object that made this call.
 * @param row			The newly selected row, or -1 if Cancel was selected.
 */

- (void) openProjectViewController: (OpenProjectViewController *) picker didSelectProject: (int) row {
    switch (picker.tag) {
        case tagOpenProject:
            [pickerPopoverController dismissPopoverAnimated: YES];
            
            if (row >= 0) {
                // Open the selected project.
                if ([delegate respondsToSelector: @selector(detailViewControllerDelegateOpenProject:)])
	                [delegate detailViewControllerDelegateOpenProject: projects[row]];
            }
            break;
    }
}

#pragma mark - UISplitViewControllerDelegate

/*!
 * Tells the delegate that the display mode for the split view controller is about to change.
 *
 * The split view controller calls this method when its display mode is about to change. Because 
 * changing the display mode usually means hiding or showing one of the child view controllers, 
 * you can implement this method and use it to add or remove the controls for showing the primary 
 * view controller.
 *
 * @param svc			The split view controller whose display mode is changing.
 * @param displayMode	The new display mode that is about to be applied to the split view controller.
 */

- (void) splitViewController: (UISplitViewController *) svc
     willChangeToDisplayMode: (UISplitViewControllerDisplayMode) displayMode
{
    UIBarButtonItem *barButtonItem = svc.displayModeButtonItem;
    [self.navigationItem setLeftBarButtonItem: barButtonItem animated: YES];
}

- (void) splitViewController: (UISplitViewController *) splitController 
      willHideViewController: (UIViewController *) viewController 
           withBarButtonItem: (UIBarButtonItem *) barButtonItem 
        forPopoverController: (UIPopoverController *) popoverController
{
    // TODO: This method was deprecated in iOS 8. Test under iOS 7 to make sure all is OK.
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        barButtonItem.title = NSLocalizedString(@"Project", @"Project");
        [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    }
}

@end
