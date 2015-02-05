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


typedef enum {tagNewFile, tagNewProject, tagOpenProject, tagRenameFile, tagRenameProject, tagOpenFile} alertTags;

static DetailViewController *this;						// This singleton instance of this class.


@interface DetailViewController () {
    BOOL initialized;									// Has the view been initialized?
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSMutableArray *projects;	// Array of NSString; the names of the projects.
@property (nonatomic, retain) UIView *toolBarView;

@property (nonatomic, retain) UIButton *buildButton;
@property (nonatomic, retain) UIButton *closeFileButton;
@property (nonatomic, retain) UIButton *acopyFileButton;
@property (nonatomic, retain) UIButton *deleteFileButton;
@property (nonatomic, retain) UIButton *deleteProjectButton;
@property (nonatomic, retain) UIButton *anewFileButton;
@property (nonatomic, retain) UIButton *renameFileButton;
@property (nonatomic, retain) UIButton *renameProjectButton;
@property (nonatomic, retain) UIButton *runButton;
@property (nonatomic, retain) UIButton *xbeeButton;

@end


@implementation DetailViewController

@synthesize buttonState;
@synthesize delegate;
@synthesize popoverController;
@synthesize projects;
@synthesize sourceConsoleSplitView;
@synthesize sourceNavigationItem;
@synthesize toolBarView;

@synthesize buildButton;
@synthesize closeFileButton;
@synthesize acopyFileButton;
@synthesize deleteFileButton;
@synthesize deleteProjectButton;
@synthesize anewFileButton;
@synthesize renameFileButton;
@synthesize renameProjectButton;
@synthesize runButton;
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
    if (action)
	    [button addTarget: self action: action forControlEvents: UIControlEventTouchUpInside];
    [toolBarView addSubview: button];
    
    *x += image.size.width;
    
    return button;
}

/*!
 * Check the current state of the project and set button states accordingly.
 *
 * Call this method when projects or files open, close, etc.
 */

- (void) checkButtonState {
    Project *project = [ProjectViewController defaultProjectViewController].project;
    NSArray *openFiles = [ProjectViewController defaultProjectViewController].openFiles;
    if (project && project.files && project.files.count > 0) {
        if (openFiles && openFiles.count > 0) {
            NSString *projectName = [[sourceConsoleSplitView.sourceView.path stringByDeletingLastPathComponent] lastPathComponent];
            if ([projectName isEqualToString: project.name])
                self.buttonState = stateOpenProjectAndFilesEditingProjectFile;
            else
                self.buttonState = stateOpenProjectAndFilesEditingNonProjectFile;
        } else
            self.buttonState = stateOpenProject;
    } else {
        if (openFiles && openFiles.count > 0)
            self.buttonState = stateOpenFiles;
        else
            self.buttonState = stateNothingOpen;
    }
}

/*!
 * See if a name is the same as the name of an existing file in the current project.
 *
 * @param name		The name to check.
 *
 * @return			YES if the name is the name of an existing project, else NO.
 */

- (BOOL) exists: (NSString *) name {
    for (NSString *project in [ProjectViewController defaultProjectViewController].project.files) {
        if ([project isEqualToString: name])
            return YES;
    }
    return NO;
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
 * Locate all of the projects on disk and return a list of those projects.
 *
 * @return			A ist of the existing projects as an array on NSString objects.
 */

- (NSMutableArray *) findProjects {
    NSMutableArray *availableProjects = [[NSMutableArray alloc] init];
    
    NSString *sandBoxPath = [Common sandbox];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *files = [manager contentsOfDirectoryAtPath: sandBoxPath error: nil];
    for (NSString *projectName in files) {
        NSString *fullPath = [sandBoxPath stringByAppendingPathComponent: projectName];
        BOOL isDirectory;
        if ([manager fileExistsAtPath: fullPath isDirectory: &isDirectory] && isDirectory) {
            NSString *projectPath = [fullPath stringByAppendingPathComponent: [projectName stringByAppendingPathExtension: @"side"]];
            if ([manager fileExistsAtPath: projectPath])
                [availableProjects addObject: projectName];
        }
    }
    
    return availableProjects;
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
 * This workhorse method handles the heavy lifting for all of the buttons that use a popover view to
 * communicate with the user.
 *
 * @param tag			The tag identifying the action for this view.
 * @param prompt		The prompt that appear at the top of the view.
 * @param elements		An array of strings to display in the picker. When renaming a file, the first 
 *						element should be the file being renamed. It may be duplicated in the list.
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
    UIViewController *pickerController = nil;
    UINavigationController *navigationController = nil;
    switch (tag) {
        case tagOpenFile: {
            OpenFileViewController *openFileViewController = [[OpenFileViewController alloc] initWithNibName: @"OpenFileViewController"
                                                                                                               bundle: nil
                                                                                                               prompt: prompt
                                                                                                                  tag: tag];
            pickerController = openFileViewController;
            navigationController = [[UINavigationController alloc] initWithRootViewController: pickerController];
            openFileViewController.navController = navigationController;
            openFileViewController.projectPickerElements = elements;
            openFileViewController.delegate = self;
            
            ProjectViewController *projectViewController = [ProjectViewController defaultProjectViewController];
            if (projectViewController.project && projectViewController.project.name)
                [openFileViewController setSelectedProject: projectViewController.project.name];
            
            // Select the proper row in the picker.
            if (index < elements.count)
                [openFileViewController.picker selectRow: index inComponent: 0 animated: NO];
            break;
        }
            
        case tagOpenProject: {
            OpenProjectViewController *openProjectViewController = [[OpenProjectViewController alloc] initWithNibName: @"OpenProjectViewController"
                                                                                                               bundle: nil
                                                                                                               prompt: prompt
                                                                                                                  tag: tag];
            pickerController = openProjectViewController;
            navigationController = [[UINavigationController alloc] initWithRootViewController: pickerController];
            openProjectViewController.navController = navigationController;
            openProjectViewController.pickerElements = elements;
            openProjectViewController.delegate = self;
            
            ProjectViewController *projectViewController = [ProjectViewController defaultProjectViewController];
            if (projectViewController.project && projectViewController.project.name)
                [openProjectViewController setSelectedElement: projectViewController.project.name];
            
            // Select the proper row in the picker.
            if (index < elements.count)
                [openProjectViewController.picker selectRow: index inComponent: 0 animated: NO];
            break;
        }
            
        case tagNewProject: {
            NewFileOrProjectViewController *newProjectViewController = [[NewFileOrProjectViewController alloc] initWithNibName: @"NewFileOrProjectViewController" 
                                                                                                                        bundle: nil 
                                                                                                                        prompt: prompt
                                                                                                                     isProject: YES];
            pickerController = newProjectViewController;
            navigationController = [[UINavigationController alloc] initWithRootViewController: newProjectViewController];
            newProjectViewController.navController = navigationController;
            newProjectViewController.projects = elements;
            newProjectViewController.delegate = self;
            break;
        }
            
        case tagRenameFile: {
            RenameFileOrProjectViewController *renameProjectViewController = 
                [[RenameFileOrProjectViewController alloc] initWithNibName: @"RenameFileOrProjectViewController" 
                                                                    bundle: nil 
                                                                    prompt: prompt
                                                                 isProject: NO 
                                                                  fileName: elements[0]];
            pickerController = renameProjectViewController;
            navigationController = [[UINavigationController alloc] initWithRootViewController: renameProjectViewController];
            renameProjectViewController.navController = navigationController;
            renameProjectViewController.currentNames = elements;
            renameProjectViewController.delegate = self;
            break;
        }
            
        case tagRenameProject: {
            RenameFileOrProjectViewController *renameProjectViewController = 
            [[RenameFileOrProjectViewController alloc] initWithNibName: @"RenameFileOrProjectViewController" 
                                                                bundle: nil 
                                                                prompt: prompt
                                                             isProject: YES 
                                                              fileName: nil];
            pickerController = renameProjectViewController;
            navigationController = [[UINavigationController alloc] initWithRootViewController: renameProjectViewController];
            renameProjectViewController.navController = navigationController;
            renameProjectViewController.currentNames = elements;
            renameProjectViewController.delegate = self;
            break;
        }
            
        case tagNewFile: {
            NewFileOrProjectViewController *newFileViewController = [[NewFileOrProjectViewController alloc] initWithNibName: @"NewFileOrProjectViewController" 
                                                                                                                     bundle: nil 
                                                                                                                     prompt: prompt
                                                                                                                  isProject: NO];
            pickerController = newFileViewController;
            navigationController = [[UINavigationController alloc] initWithRootViewController: newFileViewController];
            newFileViewController.navController = navigationController;
            newFileViewController.projects = elements;
            newFileViewController.delegate = self;
            break;
        }
    }
    
    // Create the popover.
    UIPopoverController *pickerPopover = [[NSClassFromString(@"UIPopoverController") alloc]
                                          initWithContentViewController: navigationController];
    [pickerPopover setPopoverContentSize: pickerController.view.frame.size];
    CGRect viewSize = pickerController.view.frame;
    [pickerPopover setPopoverContentSize: viewSize.size];
    [pickerPopover setDelegate: self];
    
    // Display the popover.
    self.popoverController = pickerPopover;
    [self.popoverController presentPopoverFromRect: button.frame
                                            inView: toolBarView
                          permittedArrowDirections: UIPopoverArrowDirectionUp
                                          animated: YES];
}

/*!
 * Remove a project from the lsit of projects.
 *
 * This removes the project from the list, but does not remove it from disk.
 *
 * @param name		The name of the project to remove.
 */

- (void) removeProject: (NSString *) name {
    [projects removeObject: name];
}

#pragma mark - Setters

/*!
 * Set the button state.
 *
 * This also updates any related UI elements, which is really the point of the setter.
 *
 * @param theButtonState		The new button state.
 */

- (void) setButtonState: (buttonStates) theButtonState {
    buttonState = theButtonState;
    switch (buttonState) {
        case stateNothingOpen: 
            renameProjectButton.enabled = NO;
            deleteFileButton.enabled = NO;
            deleteProjectButton.enabled = NO;
            anewFileButton.enabled = NO;
            closeFileButton.enabled = NO;
            acopyFileButton.enabled = NO;
            renameFileButton.enabled = NO;
            buildButton.enabled = NO;
            xbeeButton.enabled = NO;
            runButton.enabled = NO;
            break;
            
        case stateOpenProject: 
            renameProjectButton.enabled = YES;
            deleteFileButton.enabled = YES;
            deleteProjectButton.enabled = YES;
            anewFileButton.enabled = YES;
            closeFileButton.enabled = NO;
            acopyFileButton.enabled = YES;
            renameFileButton.enabled = YES;
            buildButton.enabled = YES;
            xbeeButton.enabled = YES;
            runButton.enabled = YES;
            break;
            
        case stateOpenFiles: 
            renameProjectButton.enabled = NO;
            deleteFileButton.enabled = NO;
            deleteProjectButton.enabled = NO;
            anewFileButton.enabled = NO;
            closeFileButton.enabled = YES;
            acopyFileButton.enabled = NO;
            renameFileButton.enabled = NO;
            buildButton.enabled = NO;
            xbeeButton.enabled = NO;
            runButton.enabled = NO;
            break;
            
        case stateOpenProjectAndFilesEditingProjectFile: 
            renameProjectButton.enabled = YES;
            deleteFileButton.enabled = YES;
            deleteProjectButton.enabled = YES;
            anewFileButton.enabled = YES;
            closeFileButton.enabled = NO;
            acopyFileButton.enabled = YES;
            renameFileButton.enabled = YES;
            buildButton.enabled = YES;
            xbeeButton.enabled = YES;
            runButton.enabled = YES;
            break;
            
        case stateOpenProjectAndFilesEditingNonProjectFile: 
            renameProjectButton.enabled = YES;
            deleteFileButton.enabled = NO;
            deleteProjectButton.enabled = YES;
            anewFileButton.enabled = YES;
            closeFileButton.enabled = YES;
            acopyFileButton.enabled = YES;
            renameFileButton.enabled = NO;
            buildButton.enabled = YES;
            xbeeButton.enabled = YES;
            runButton.enabled = YES;
            break;
    }
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
 * Handle a hit on the Close File button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) closeFileAction: (id) sender {
    if ([delegate respondsToSelector: @selector(detailViewControllerDelegateCloseFile)])
        [delegate detailViewControllerDelegateCloseFile];
}

/*!
 * Handle a hit on the Copy File button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) copyFileAction: (id) sender {
    NSString *path = sourceConsoleSplitView.sourceView.path;
    NSString *name = [path lastPathComponent];
    
    // Find an acceptable name.
    if ([self exists: name]) {
        BOOL done = NO;
        int index = 1;
        while (!done) {
            NSString *newName = nil;
            if ([name pathExtension].length > 0)
                newName = [NSString stringWithFormat: @"%@%d.%@", [name stringByDeletingPathExtension], index++, [name pathExtension]];
            else
                newName = [NSString stringWithFormat: @"%@%d", name, index++];
            if (![self exists: newName]) {
                done = YES;
                name = newName;
            }
        }
    }
    
    // Copy the file.
    if ([delegate respondsToSelector: @selector(detailViewControllerDelegateCopyFrom:to:)])
        [delegate detailViewControllerDelegateCopyFrom: path to: name];
}

/*!
 * Handle a hit on the Delete File button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) deleteFileAction: (id) sender {
    if ([delegate respondsToSelector: @selector(detailViewControllerDelegateDeleteFile)])
        [delegate detailViewControllerDelegateDeleteFile];
}

/*!
 * Handle a hit on the Delete Project button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) deleteProjectAction: (id) sender {
    if ([delegate respondsToSelector: @selector(detailViewControllerDelegateDeleteProject)])
        [delegate detailViewControllerDelegateDeleteProject];
}

/*!
 * Handle a hit on the New File button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) newFileAction: (id) sender {
    Project *project = [[ProjectViewController defaultProjectViewController] project];
    [self pickerAction: tagNewFile prompt: @"New File" elements: project.files button: sender index: 0];
}

/*!
 * Handle a hit on the New Project button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) newProjectAction: (id) sender {
    projects = [self findProjects];
    [self pickerAction: tagNewProject prompt: @"New Project" elements: projects button: sender index: 0];
}

/*!
 * Handle a hit on the Open File button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) openFileAction: (id) sender {
    projects = [self findProjects];
    [self pickerAction: tagOpenFile prompt: @"Open a File" elements: projects button: sender index: 0];
}

/*!
 * Handle a hit on the Open Project button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) openProjectAction: (id) sender {
    projects = [self findProjects];
    [self pickerAction: tagOpenProject prompt: @"Open a Project" elements: projects button: sender index: 0];
}

/*!
 * Handle a hit on the Rename File button. The file must be in the current project.
 *
 * @param sender		The button that triggered this action.
 */

- (void) renameFileAction: (id) sender {
    NSString *oldName = [sourceConsoleSplitView.sourceView.path lastPathComponent];
    if (oldName && oldName.length > 0) {
        NSString *prompt = [NSString stringWithFormat: @"Rename the %@ file", oldName];
        Project *project = [ProjectViewController defaultProjectViewController].project;
        NSMutableArray *names = [NSMutableArray arrayWithArray: project.files];
        [names insertObject: oldName atIndex: 0];
        [self pickerAction: tagRenameFile prompt: prompt elements: names button: sender index: 0];
    }
}

/*!
 * Handle a hit on the Rename Project button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) renameProjectAction: (id) sender {
    NSString *oldName = [[ProjectViewController defaultProjectViewController] project].name;
    if (oldName && oldName.length > 0) {
        NSString *prompt = [NSString stringWithFormat: @"Rename the %@ project", oldName];
        projects = [self findProjects];
        [self pickerAction: tagRenameProject prompt: prompt elements: projects button: sender index: 0];
    }
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
        const float space = 8;
        const float shortSpace = 4;
        
        float x = 0;
        [self addButtonWithImageNamed: @"project.png" x: &x action: nil];
        x += shortSpace;
        [self addButtonWithImageNamed: @"new.png" x: &x action: @selector(newProjectAction:)];
        x += space;
        [self addButtonWithImageNamed: @"openproj.png" x: &x action: @selector(openProjectAction:)];
        x += space;
        self.renameProjectButton = [self addButtonWithImageNamed: @"rename.png" x: &x action: @selector(renameProjectAction:)];
        x += space;
        self.deleteProjectButton = [self addButtonWithImageNamed: @"delete.png" x: &x action: @selector(deleteProjectAction:)];
        
        x += shortSpace;
        [self addButtonWithImageNamed: @"file.png" x: &x action: nil];
        x += space;
        self.anewFileButton = [self addButtonWithImageNamed: @"new.png" x: &x action: @selector(newFileAction:)];
        x += space;
        self.renameFileButton = [self addButtonWithImageNamed: @"rename.png" x: &x action: @selector(renameFileAction:)];
        x += space;
        self.deleteFileButton = [self addButtonWithImageNamed: @"delete.png" x: &x action: @selector(deleteFileAction:)];
        x += space;
        [self addButtonWithImageNamed: @"openproj.png" x: &x action: @selector(openFileAction:)];
        x += space;
        self.closeFileButton = [self addButtonWithImageNamed: @"close.png" x: &x action: @selector(closeFileAction:)];
        x += space;
        self.acopyFileButton = [self addButtonWithImageNamed: @"copy.png" x: &x action: @selector(copyFileAction:)];
        
        x += shortSpace;
        [self addButtonWithImageNamed: @"build_caption.png" x: &x action: nil];
        x += space;
        self.buildButton = [self addButtonWithImageNamed: @"build.png" x: &x action: @selector(buildProjectAction)];
        x += space;
        self.xbeeButton = [self addButtonWithImageNamed: @"xbee.png" x: &x action: @selector(xbeeAction)];
        x += space;
        self.runButton = [self addButtonWithImageNamed: @"run.png" x: &x action: @selector(runProjectAction)];
        
        // Use our button view as the navigation title view.
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.titleView = self.toolBarView;
        if ([self respondsToSelector: @selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
        // Set the initial buton state.
        [self checkButtonState];

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
 *  thePopoverController: The popover controller that was dismissed.
 */

- (void) popoverControllerDidDismissPopover: (UIPopoverController *) thePopoverController {
    if (popoverController == thePopoverController)
        self.popoverController = nil;
}

#pragma mark - NewFileOrProjectViewControllerDelegate

/*!
 * Called if the user taps Open or Cancel, this method passes the name of the new project.
 *
 * @param picker		The picker object that made this call.
 * @param name			The name of hte new project, or nil if none was slected.
 * @param isProject		YES if we are creating a new project, or NO if we are creating a new file.
 */

- (void) newFileOrProjectViewController: (NewFileOrProjectViewController *) picker name: (NSString *) name isProject: (BOOL) isProject {
    [popoverController dismissPopoverAnimated: YES];
    if (isProject) {
        // Create a new project.
        if (name) {
            // Create the new project.
            NSFileManager *file = [NSFileManager defaultManager];
            NSString *sandbox = [Common sandbox];
            
            Project *project = [[Project alloc] init];
            project.language = languageSpin;
            project.name = name;
            project.path = [sandbox stringByAppendingPathComponent: name];
            
            NSError *error = nil;
            [file createDirectoryAtPath: project.path withIntermediateDirectories: YES attributes: nil error: &error];
            
            // Create the initial spin file.
            if (!error) {
                NSString *spinName = [name stringByAppendingPathExtension: @"spin"];
                NSString *spinPath = [project.path stringByAppendingPathComponent: spinName];
                [@"PUB Mail\n" writeToFile: spinPath atomically: NO encoding: NSUTF8StringEncoding error: &error];
                
                project.files = [NSMutableArray arrayWithObject: spinName];
            }
            
            // Create the .side file.
            if (!error) {
                project.sidePath = [project.path stringByAppendingPathComponent: [name stringByAppendingPathExtension: @"side"]];
                NSString *sideFile = [NSString stringWithFormat: @"%@\n>compiler=SPIN\n", [project.files[0] lastPathComponent]];
                [sideFile writeToFile: project.sidePath atomically: NO encoding: NSUTF8StringEncoding error: &error];
            }
            
            if (!error) {
                // Add the project to the project list.
                [projects addObject: project.name];
                
                // Sort the list of projects.
                [projects sortUsingComparator: ^NSComparisonResult (NSString *obj1, NSString *obj2) {
                    return [obj1 compare: obj2];
                }];
                
                // Open the new project.
                if ([delegate respondsToSelector: @selector(detailViewControllerDelegateOpenProject:)])
                    [delegate detailViewControllerDelegateOpenProject: project.name];
            }
            
            // Handle any errors.
            if (error) {
                if (project) {
                    if (project.sidePath)
                        [file removeItemAtPath: project.sidePath error: nil];
                    if (project.files && project.files.count > 0)
                        [file removeItemAtPath: project.files[0] error: nil];
                    [file removeItemAtPath: project.path error: nil];
                }
                [Common reportError: error];
            }
        }
    } else {
        // Add a new file to the current project.
        if ([delegate respondsToSelector: @selector(detailViewControllerDelegateNewFile:)])
            [delegate detailViewControllerDelegateNewFile: name];
    }
}

#pragma mark - OpenFileViewControllerDelegate

/*!
 * Called if the user taps Open or Cancel, this method passes the file selection information.
 *
 * @param picker		The picker object that made this call.
 * @param row			The index of the selected project, or -1 if Cancel was selected.
 * @param name			The file name of hte selected file, or nil for Cancel. Includes the extension, but not the path.
 */

- (void) openFileViewController: (OpenFileViewController *) picker selectedProject: (int) row name: (NSString *) name {
    [popoverController dismissPopoverAnimated: YES];
    
    if (row >= 0 && name && name.length > 0)
        if ([delegate respondsToSelector: @selector(detailViewControllerDelegateOpenProject:file:)])
            [delegate detailViewControllerDelegateOpenProject: projects[row] file: name];
}

#pragma mark - OpenProjectViewControllerDelegate

/*!
 * Called if the user taps Open or Cancel, this method passes the index of the selected project file.
 *
 * @param picker		The picker object that made this call.
 * @param row			The newly selected row, or -1 if Cancel was selected.
 */

- (void) openProjectViewController: (OpenProjectViewController *) picker didSelectProject: (int) row {
    [popoverController dismissPopoverAnimated: YES];
    
    if (row >= 0) {
        // Open the selected project.
        if ([delegate respondsToSelector: @selector(detailViewControllerDelegateOpenProject:)])
            [delegate detailViewControllerDelegateOpenProject: projects[row]];
    }
}

#pragma mark - RenameProjectViewControllerDelegate

/*!
 * Called if the user taps Rename or Cancel, this method passes the name for a new project.
 *
 * @param picker		The picker object that made this call.
 * @param name			The new name for the new project, or nil of Cancel was pressed.
 * @param oldName		The old name for the file or project, or nil of Cancel was pressed.
 * @param isProject		YES if we are renaming a project, or NO if we are renaming a file.
 */

- (void) renameFileOrProjectViewControllerRename: (RenameFileOrProjectViewController *) picker 
                                            name: (NSString *) name 
                                         oldName: (NSString *) oldName 
                                       isProject: (BOOL) isProject 
{
    [popoverController dismissPopoverAnimated: YES];
    if (name) {
        if (isProject) {
            // Rename the current project.
            if ([delegate respondsToSelector: @selector(detailViewControllerDelegateRenameProject:)])
                [delegate detailViewControllerDelegateRenameProject: name];
            
            // Resort the projects list.
            [projects sortUsingComparator: ^NSComparisonResult (NSString *obj1, NSString *obj2) {
                return [obj1 compare: obj2];
            }];
        } else {
            if ([delegate respondsToSelector: @selector(detailViewControllerDelegateRenameFile:newName:)])
                [delegate detailViewControllerDelegateRenameFile: oldName newName: name];
        }
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
