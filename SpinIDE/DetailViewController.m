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

#import <MobileCoreServices/UTCoreTypes.h>

#import "libpropeller-elf-cpp.h"
#import "Find.h"
#import "FindViewController.h"
#import "NavToolBar.h"
#import "ProjectViewController.h"
#import "SplitViewController.h"


typedef enum {tagFind, tagNewFile, tagNewProject, tagOpenProject, tagRenameFile, tagRenameProject, tagOpenFile} alertTags;
typedef enum {textCommandUndo, textCommandRedo} textCommands;

static DetailViewController *this;						// This singleton instance of this class.


@interface DetailViewController () {
    BOOL initialized;									// Has the view been initialized?
    
    CGRect keyboardViewRect;							// View rectangle when the keyboard was shwn.
    BOOL keyboardVisible;								// Is the keyboard visible?
    BOOL showBuildButtons;								// YES to display the build buttons, else NO.
    BOOL showEditButtons;								// YES to display the edit buttons, else NO.
    BOOL showFileButtons;								// YES to display the file buttons, else NO.
    BOOL showProjectButtons;							// YES to display the project buttons, else NO.
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) NSMutableArray *projects;	// Array of NSString; the names of the projects.
@property (nonatomic, retain) UIView *toolBarView;

@property (nonatomic, retain) UIButton *buildButton;
@property (nonatomic, retain) UIButton *closeFileButton;
@property (nonatomic, retain) UIButton *acopyFileButton;
@property (nonatomic, retain) UIButton *deleteFileButton;
@property (nonatomic, retain) UIButton *deleteProjectButton;
@property (nonatomic, retain) UIButton *epromButton;
@property (nonatomic, retain) UIButton *findButton;
@property (nonatomic, retain) UIButton *anewFileButton;
@property (nonatomic, retain) UIButton *redoButton;
@property (nonatomic, retain) UIButton *renameFileButton;
@property (nonatomic, retain) UIButton *renameProjectButton;
@property (nonatomic, retain) UIButton *runButton;
@property (nonatomic, retain) UIButton *shareButton;
@property (nonatomic, retain) UIButton *undoButton;
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
@synthesize epromButton;
@synthesize findButton;
@synthesize anewFileButton;
@synthesize redoButton;
@synthesize renameFileButton;
@synthesize renameProjectButton;
@synthesize runButton;
@synthesize shareButton;
@synthesize undoButton;
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
            if ([projectName caseInsensitiveCompare: project.name] == NSOrderedSame)
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
 * Check the state of the undo and redo buttons. These are separate from checkButtonState because they 
 * change so often they don't diserve a state.
 */

- (void) checkUndRedoButtons {
    redoButton.enabled = [sourceConsoleSplitView.sourceView.undoManager canRedo];
    undoButton.enabled = [sourceConsoleSplitView.sourceView.undoManager canUndo];
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
        if ([project caseInsensitiveCompare: name] == NSOrderedSame)
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
        case tagFind: {
            FindViewController *findViewController = [[FindViewController alloc] initWithNibName: @"FindViewController" bundle: nil];
            findViewController.referenceTextView = sourceConsoleSplitView.sourceView;
            pickerController = findViewController;
            navigationController = [[UINavigationController alloc] initWithRootViewController: pickerController];
            break;
        }
            
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
 * Reload the buttons on the button bar.
 */

- (void) reloadButtons {
    [UIView transitionWithView: toolBarView
                      duration: 0.50
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^{ 
                        while (toolBarView.subviews.count > 0) {
                            UIView *subview = toolBarView.subviews[0];
                            [subview removeFromSuperview];
                        }
                    } 
                    completion: nil];
    [self setUpButtonBar];
    self.buttonState = buttonState;
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

/*!
 * Get the range of the selected text in a text view.
 *
 * @param textView		The text view from which to extract the range.
 *
 * @return				The range of the current selection.
 */

- (NSRange) selectedRangeInTextView: (UITextView *) textView {
    UITextPosition *beginning = textView.beginningOfDocument;
    UITextRange *selectedRange = textView.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    const NSInteger location = [textView offsetFromPosition: beginning toPosition: selectionStart];
    const NSInteger length = [textView offsetFromPosition: selectionStart toPosition: selectionEnd];
    
    return NSMakeRange(location, length);
}

/*!
 * Set up the list of buttons in the button bar.
 */

- (void) setUpButtonBar {
    // Add the buttons to the button view.
    const float space = 8;
    const float shortSpace = 4;
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
	    self.navigationItem.leftBarButtonItem = [SplitViewController defaultSplitViewController].barButtonItem;
    
    float x = 0;
    if (showProjectButtons) {
        [self addButtonWithImageNamed: @"project-open.png" x: &x action: @selector(showHideProjectButtonsAction)];
        x += shortSpace;
        [self addButtonWithImageNamed: @"new.png" x: &x action: @selector(newProjectAction:)];
        x += space;
        [self addButtonWithImageNamed: @"open.png" x: &x action: @selector(openProjectAction:)];
        x += space;
        self.renameProjectButton = [self addButtonWithImageNamed: @"rename.png" x: &x action: @selector(renameProjectAction:)];
        x += space;
        self.deleteProjectButton = [self addButtonWithImageNamed: @"delete.png" x: &x action: @selector(deleteProjectAction:)];
    } else {
        [self addButtonWithImageNamed: @"project-closed.png" x: &x action: @selector(showHideProjectButtonsAction)];
    }
    
    x += shortSpace;
    if (showFileButtons) {
        [self addButtonWithImageNamed: @"file-open.png" x: &x action: @selector(showHideFileButtonsAction)];
        x += space;
        self.anewFileButton = [self addButtonWithImageNamed: @"new.png" x: &x action: @selector(newFileAction:)];
        x += space;
        self.renameFileButton = [self addButtonWithImageNamed: @"rename.png" x: &x action: @selector(renameFileAction:)];
        x += space;
        self.deleteFileButton = [self addButtonWithImageNamed: @"delete.png" x: &x action: @selector(deleteFileAction:)];
        x += space;
        [self addButtonWithImageNamed: @"open.png" x: &x action: @selector(openFileAction:)];
        x += space;
        self.closeFileButton = [self addButtonWithImageNamed: @"close.png" x: &x action: @selector(closeFileAction:)];
        x += space;
        self.acopyFileButton = [self addButtonWithImageNamed: @"copy.png" x: &x action: @selector(copyFileAction:)];
    } else {
        [self addButtonWithImageNamed: @"file-closed.png" x: &x action: @selector(showHideFileButtonsAction)];
    }
    
    x += shortSpace;
    if (showEditButtons) {
        [self addButtonWithImageNamed: @"edit-open.png" x: &x action: @selector(showHideEditButtonsAction)];
        x += space;
        self.undoButton = [self addButtonWithImageNamed: @"undo.png" x: &x action: @selector(textCommandButtonAction:)];
        undoButton.tag = textCommandUndo;
        x += space;
        self.redoButton = [self addButtonWithImageNamed: @"redo.png" x: &x action: @selector(textCommandButtonAction:)];
        redoButton.tag = textCommandRedo;
        x += space;
        self.findButton = [self addButtonWithImageNamed: @"find.png" x: &x action: @selector(findAction:)];
        x += space;
        self.shareButton = [self addButtonWithImageNamed: @"share.png" x: &x action: @selector(shareAction:)];
        [self checkUndRedoButtons];
    } else {
        [self addButtonWithImageNamed: @"edit-closed.png" x: &x action: @selector(showHideEditButtonsAction)];
    }
        
    x += shortSpace;
    if (showBuildButtons) {
        [self addButtonWithImageNamed: @"build-open.png" x: &x action: @selector(showHideBuildButtonsAction)];
        x += space;
        self.buildButton = [self addButtonWithImageNamed: @"build.png" x: &x action: @selector(buildProjectAction)];
        x += space;
        self.xbeeButton = [self addButtonWithImageNamed: @"xbee.png" x: &x action: @selector(xbeeAction)];
        x += space;
        self.runButton = [self addButtonWithImageNamed: @"run.png" x: &x action: @selector(runProjectAction)];
        x += space;
        self.epromButton = [self addButtonWithImageNamed: @"eeprom.png" x: &x action: @selector(runProjectAction)]; // TODO: Implement
    } else {
        [self addButtonWithImageNamed: @"build-closed.png" x: &x action: @selector(showHideBuildButtonsAction)];
    }
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
            findButton.enabled = NO;
            break;
            
        case stateOpenProject: {
            renameProjectButton.enabled = YES;
            deleteFileButton.enabled = YES;
            deleteProjectButton.enabled = YES;
            anewFileButton.enabled = YES;
            closeFileButton.enabled = NO;
            acopyFileButton.enabled = YES;
            buildButton.enabled = YES;
            xbeeButton.enabled = YES;
            runButton.enabled = YES;
            findButton.enabled = YES;
            
            Project *project = [ProjectViewController defaultProjectViewController].project;
            NSString *file = [[sourceConsoleSplitView.sourceView.path lastPathComponent] stringByDeletingPathExtension];
            renameFileButton.enabled = [project.name caseInsensitiveCompare: file] != NSOrderedSame;
            break;
        }
            
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
            findButton.enabled = YES;
            break;
            
        case stateOpenProjectAndFilesEditingProjectFile: {
            renameProjectButton.enabled = YES;
            deleteFileButton.enabled = YES;
            deleteProjectButton.enabled = YES;
            anewFileButton.enabled = YES;
            closeFileButton.enabled = NO;
            acopyFileButton.enabled = YES;
            buildButton.enabled = YES;
            xbeeButton.enabled = YES;
            runButton.enabled = YES;
            findButton.enabled = YES;
            
            Project *project = [ProjectViewController defaultProjectViewController].project;
            NSString *file = [[sourceConsoleSplitView.sourceView.path lastPathComponent] stringByDeletingPathExtension];
            renameFileButton.enabled = [project.name caseInsensitiveCompare: file] != NSOrderedSame;
            break;
        }
            
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
            findButton.enabled = YES;
            break;
    }
}

#pragma mark - Actions

/*!
 * Handle a hit on the Build Project button.
 */

- (void) buildProjectAction {
    if ([delegate respondsToSelector: @selector(detailViewControllerBuildProject)])
        [delegate detailViewControllerBuildProject];
}

/*!
 * Check the syntax coloring preference.
 */

- (void) syntaxColorPreference {
    sourceConsoleSplitView.sourceView.useSyntaxColoring = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *color = [defaults stringForKey: @"syntax_coloring_preference"];
    if (color != nil)
        sourceConsoleSplitView.sourceView.useSyntaxColoring = [defaults boolForKey: @"syntax_coloring_preference"];
}

/*!
 * Handle a hit on the Close File button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) closeFileAction: (id) sender {
    if ([delegate respondsToSelector: @selector(detailViewControllerCloseFile)])
        [delegate detailViewControllerCloseFile];
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
    if ([delegate respondsToSelector: @selector(detailViewControllerCopyFrom:to:)])
        [delegate detailViewControllerCopyFrom: path to: name];
}

/*!
 * Handle a hit on the Delete File button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) deleteFileAction: (id) sender {
    if ([delegate respondsToSelector: @selector(detailViewControllerDeleteFile)])
        [delegate detailViewControllerDeleteFile];
}

/*!
 * Handle a hit on the Delete Project button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) deleteProjectAction: (id) sender {
    if ([delegate respondsToSelector: @selector(detailViewControllerDeleteProject)])
        [delegate detailViewControllerDeleteProject];
}

/*!
 * Handle a hit on the Open Project button.
 *
 * @param sender		The button that triggered this action.
 */

- (void) findAction: (id) sender {
    [self pickerAction: tagFind prompt: @"Find & Replace" elements: nil button: sender index: 0];
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
    projects = [NSMutableArray arrayWithObject: SPIN_LIBRARY_PICKER_NAME];
    [projects addObjectsFromArray: [self findProjects]];
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
 * Handle a hit on the Share button.
 *
 * At the moment, the only sharing method is printing, so this defaults to a print operation.
 *
 * @param sender		The button that triggered this action.
 */

- (void) shareAction: (UIButton *) sender {
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.jobName = [sourceConsoleSplitView.sourceView.path lastPathComponent];

    UIPrintInteractionController *print = [UIPrintInteractionController sharedPrintController];
    print.printInfo = printInfo;
    print.showsPageRange = YES;
    print.printFormatter = sourceConsoleSplitView.sourceView.viewPrintFormatter;
    
    void (^completionHandler) (UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *print, BOOL completed, NSError *error) {
        if (!completed && error) {
            [Common reportError: error];
        }
    };
    [print presentFromRect: sender.frame inView: toolBarView animated: YES completionHandler: completionHandler];
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
 */

- (void) runProjectAction {
    if ([delegate respondsToSelector: @selector(detailViewControllerRunProject:)])
        [delegate detailViewControllerRunProject: runButton];
}

/*!
 * Handle a hit on the Show/Hide Build Buttons button.
 */

- (void) showHideBuildButtonsAction {
    showBuildButtons = !showBuildButtons;
    [self reloadButtons];
}

/*!
 * Handle a hit on the Show/Hide Edit Buttons button.
 */

- (void) showHideEditButtonsAction {
    showEditButtons = !showEditButtons;
    [self reloadButtons];
}

/*!
 * Handle a hit on the Show/Hide File Buttons button.
 */

- (void) showHideFileButtonsAction {
    showFileButtons = !showFileButtons;
    [self reloadButtons];
}

/*!
 * Handle a hit on the Show/Hide Project Buttons button.
 */

- (void) showHideProjectButtonsAction {
    showProjectButtons = !showProjectButtons;
    [self reloadButtons];
}

/*!
 * Handle a hit on one of hte text command buttons.
 *
 * The tag for the button is one of the enumeration textCommands, indicating the command to execute.
 *
 * @param sender		The button that triggered this action.
 */

- (void) textCommandButtonAction: (UIButton *) sender {
    switch ((textCommands) sender.tag) {
        case textCommandRedo:
            [sourceConsoleSplitView.sourceView.undoManager redo];
            break;
            
        case textCommandUndo:
            [sourceConsoleSplitView.sourceView.undoManager undo];
            break;
    }
    [self checkUndRedoButtons];
}
                                        
/*!
 * Handle a hit on the XBee button.
 */

- (void) xbeeAction {
    if ([delegate respondsToSelector: @selector(detailViewControllerXBeeProject:)])
        [delegate detailViewControllerXBeeProject: xbeeButton];
}

#pragma mark - View Maintenance

/*!
 * Handle a low memory situation.
 */

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [sourceConsoleSplitView.sourceView didReceiveMemoryWarning];
    [self checkUndRedoButtons];
}

/*
 * Called when the virtual keyboard is shown, this method should adjust the size of the views to
 * prevent text from appearing under the keybaord.
 *
 * Parameters:
 *  notification - The notification.
 */

- (void) keyboardWasShown: (NSNotification *) notification {
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect rect = sourceConsoleSplitView.frame;
    if (keyboardVisible)
        rect = keyboardViewRect;
    else
        keyboardViewRect = rect;
    rect.size.height -= keyboardSize.height < keyboardSize.width ? keyboardSize.height : keyboardSize.width;
    sourceConsoleSplitView.frame = rect;
    [UIView animateWithDuration: 0.1 animations: ^{
        [self.view layoutIfNeeded];
    }];
    
    SourceView *sourceView = sourceConsoleSplitView.sourceView;
    [sourceView scrollRangeToVisible: sourceView.selectedRange];
    
    keyboardVisible = YES;
}

/*
 * Called when the virtual keyboard is about to be hidden, this method should adjust the size of the
 * text view to the values before the keyboard was shown.
 *
 * Parameters:
 *  notification - The notification.
 */

- (void) keyboardWillBeHidden: (NSNotification *) notification {
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect rect = sourceConsoleSplitView.frame;
    if (keyboardVisible)
        rect = keyboardViewRect;
    else
        rect.size.height += keyboardSize.height < keyboardSize.width ? keyboardSize.height : keyboardSize.width;
    sourceConsoleSplitView.frame = rect;
    [UIView animateWithDuration: 0.5 animations: ^{
        [self.view layoutIfNeeded];
    }];
    
    keyboardVisible = NO;
}

/*!
 * Called after the controller’s view is loaded into memory.
 */

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Record our singleton instance.
    this = self;
    
    // Initialize the button view options.
    showProjectButtons = YES;
    showEditButtons = NO;
    showFileButtons = NO;
    showBuildButtons = YES;
    
    // Listen for text changes.
    sourceConsoleSplitView.sourceView.sourceViewDelegate = self;
    
    // Watch for keyboard notifications.
	[[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(resignFirstResponder) 
                                                 name: UIKeyboardWillHideNotification 
                                               object: nil];
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
        
        // Set up the button bar.
        [self setUpButtonBar];
        
        // Use our button view as the navigation title view.
        self.navigationItem.titleView = self.toolBarView;
        if ([self respondsToSelector: @selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }

        // Register for keyboard events.
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(keyboardWasShown:)
                                                     name: UIKeyboardDidShowNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(keyboardWillBeHidden:)
                                                     name: UIKeyboardWillHideNotification object: nil];
        
        // Set the initial buton state.
        [self checkButtonState];

        initialized = YES;
    }
    
    // Check our preferences.
    [self syntaxColorPreference];

    // Call super.
    [super viewWillAppear: animated];
}

/*!
 * UIKit calls this method before changing the size of a presented view controller’s view. You can override 
 * this method in your own objects and use it to perform additional tasks related to the size change. For 
 * example, a container view controller might use this method to override the traits of its embedded child 
 * view controllers. Use the provided coordinator object to animate any changes you make.
 *
 * If you override this method in your custom view controllers, always call super at some point in your 
 * implementation so that UIKit can forward the size change message appropriately. View controllers forward 
 * the size change message to their views and child view controllers. Presentation controllers forward the 
 * size change to their presented view controller.
 *
 * @param size			The new size for the container’s view.
 * @param coordinator	The transition coordinator object managing the size change. You can use this object 
 *						to animate your changes or get information about the transition that is in progress.
 */

- (void) viewWillTransitionToSize: (CGSize) size
        withTransitionCoordinator: (id<UIViewControllerTransitionCoordinator>) coordinator
{
    [super viewWillTransitionToSize: size withTransitionCoordinator: coordinator];
    [self syntaxColorPreference];
}

#pragma mark - PopoverController Delegate Methods

/*!
 * Tells the delegate that the popover was dismissed.
 *
 * @param thePopoverController		The popover controller that was dismissed.
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
                [project writeSideFile: &error];
            }
            
            if (!error) {
                // Add the project to the project list.
                [projects addObject: project.name];
                
                // Sort the list of projects.
                [projects sortUsingComparator: ^NSComparisonResult (NSString *obj1, NSString *obj2) {
                    return [obj1 compare: obj2];
                }];
                
                // Open the new project.
                if ([delegate respondsToSelector: @selector(detailViewControllerOpenProject:)])
                    [delegate detailViewControllerOpenProject: project.name];
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
        if ([delegate respondsToSelector: @selector(detailViewControllerNewFile:)])
            [delegate detailViewControllerNewFile: name];
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
        if ([delegate respondsToSelector: @selector(detailViewControllerOpenProject:file:)]) {
            NSString *project = projects[row];
            if ([project isEqualToString: SPIN_LIBRARY_PICKER_NAME])
                project = SPIN_LIBRARY;
            [delegate detailViewControllerOpenProject: project file: name];
        }
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
        if ([delegate respondsToSelector: @selector(detailViewControllerOpenProject:)])
            [delegate detailViewControllerOpenProject: projects[row]];
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
            if ([delegate respondsToSelector: @selector(detailViewControllerRenameProject:)])
                [delegate detailViewControllerRenameProject: name];
            
            // Resort the projects list.
            [projects sortUsingComparator: ^NSComparisonResult (NSString *obj1, NSString *obj2) {
                return [obj1 compare: obj2];
            }];
        } else {
            if ([delegate respondsToSelector: @selector(detailViewControllerRenameFile:newName:)])
                [delegate detailViewControllerRenameFile: oldName newName: name];
        }
    }
}

#pragma mark - SourceViewDelegate

/*!
 * Notify the delegate that the text has changed in some way.
 */

- (void) sourceViewTextChanged {
    [self checkUndRedoButtons];
}

/*!
 * Tells the delegate that user has requested a Find command via a keyboard shortcut.
 */

- (void) sourceViewFind {
    if (!showEditButtons)
        [self showHideEditButtonsAction];
    [self findAction: findButton];
}

/*!
 * Tells the delegate that user has requested a Find Next command via a keyboard shortcut.
 */

- (void) sourceViewFindNext {
    Find *find = [Find defaultFind];
    BOOL backwards = find.backwardSearch;
    find.backwardSearch = NO;
    [find find: sourceConsoleSplitView.sourceView];
    find.backwardSearch = backwards;
}

/*!
 * Tells the delegate that user has requested a Find Previous command via a keyboard shortcut.
 */

- (void) sourceViewFindPrevious {
    Find *find = [Find defaultFind];
    BOOL backwards = find.backwardSearch;
    find.backwardSearch = YES;
    [find find: sourceConsoleSplitView.sourceView];
    find.backwardSearch = backwards;
}

@end
