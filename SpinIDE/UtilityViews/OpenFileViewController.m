//
//  OpenFileViewController.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 2/3/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "OpenFileViewController.h"

#import "Common.h"

@interface OpenFileViewController () {
    int selectedRow;				// The selected project row.
}

@property (nonatomic, retain) NSMutableArray *filePickerElements;	// The elements displayed in the file wheel of the picker.
@property (nonatomic, retain) NSString *selectedName;				// The name of the selected file.

@end

@implementation OpenFileViewController

@synthesize delegate;
@synthesize filePickerElements;
@synthesize openButton;
@synthesize navController;
@synthesize picker;
@synthesize projectPickerElements;
@synthesize selectedName;
@synthesize selectedProject;
@synthesize tag;

/*!
 * Returns a newly initialized view controller with the nib file in the specified bundle.
 *
 * @param nibNameOrNil		The nib name.
 * @param bundle			The bundle.
 * @param prompt			The string that will appear at the top of the dialog.
 * @param tag				An identifying tag.
 */

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
                prompt: (NSString *) prompt
                   tag: (int) atag
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
        self.title = prompt;
        self.tag = atag;
        selectedRow = -1;
    }
    return self;
}

/*!
 * Set the file list to show the files in the specified project.
 *
 * @param index			The index of the project (in projectPickerElements) whose files will be displayed.
 */

- (void) showFilesFor: (int) index {
    // Get the list of files.
    NSString *path = [[Common sandbox] stringByAppendingPathComponent: selectedProject];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: path error: nil];
    
    // Select the files that are editable source files.
    self.filePickerElements = [[NSMutableArray alloc] init];
    for (NSString *file in files) {
        NSString *extension = [file pathExtension];
        for (NSString *validExtension in [Common validExtensions]) {
            if ([validExtension caseInsensitiveCompare: extension] == NSOrderedSame) {
                [filePickerElements addObject: file];
                break;
            }
        }
    }
    
    // Set the initially selected file.
	if (filePickerElements && filePickerElements.count > 0)
        self.selectedName = filePickerElements[0];
    else
        self.selectedName = @"";
    
    // Redraw the file picker.
    [picker reloadComponent: 1];
}

#pragma mark - Actions

/*!
 * Called when the Cancel button is hit.
 *
 * @param sender		The button that triggered this call.
 */

- (IBAction) cancelButtonAction: (id) sender {
    if ([delegate respondsToSelector: @selector(openFileViewController:selectedProject:name:)])
        [delegate openFileViewController: self selectedProject: -1 name: nil];
}

/*!
 * Called when the Open button is hit.
 *
 * @param sender		The button that triggered this call.
 */

- (IBAction) openButtonAction: (id) sender {
    if ([delegate respondsToSelector: @selector(openFileViewController:selectedProject:name:)])
        [delegate openFileViewController: self selectedProject: selectedRow name: selectedName];
}

#pragma mark - Getters and setters

/*!
 * Set the new list of picker elements; these are the project names.
 *
 * @param thePickerElements		The new list of picker elements.
 */

- (void) setProjectPickerElements: (NSArray *) thePickerElements {
    // Set the new picker elements.
    projectPickerElements = thePickerElements;
    
    // Make sure the current value for hte selected row is valid.
    if (projectPickerElements.count > 0 && selectedRow == -1)
        selectedRow = 0;
    if (selectedRow > projectPickerElements.count - 1)
        selectedRow = (int) projectPickerElements.count - 1;
    if (selectedRow >= 0) {
        selectedProject = projectPickerElements[selectedRow];
        if ([selectedProject isEqualToString: SPIN_LIBRARY_PICKER_NAME])
            selectedProject = SPIN_LIBRARY;
        [self showFilesFor: selectedRow];
    }
}

/*!
 * Set the selected file name.
 *
 * @param theSelectedName		The new selected element.
 */

- (void) setSelectedName: (NSString *) theSelectedName {
    selectedName = theSelectedName;
    openButton.enabled = selectedName && selectedName.length > 0;
}

/*!
 * Set the selected project.
 *
 * This call is ignored if the project does not exist in the picker.
 *
 * @param theSelectedProject	The new selected element.
 */

- (void) setSelectedProject: (NSString *) theSelectedProject {
    for (int i = 0; i < projectPickerElements.count; ++i) {
        if ([theSelectedProject caseInsensitiveCompare: projectPickerElements[i]] == NSOrderedSame) {
            selectedRow = i;
            [picker selectRow: i inComponent: 0 animated: YES];
            selectedProject = theSelectedProject;
            if ([selectedProject isEqualToString: SPIN_LIBRARY_PICKER_NAME])
                selectedProject = SPIN_LIBRARY;
            [self showFilesFor: selectedRow];
            break;
        }
    }
}

#pragma mark - View maintenance

/*!
 * Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 * @param animated		If YES, the view is being added to the window using an animation.
 */

- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear: animated];
    
    if (selectedRow >= 0 && selectedRow < projectPickerElements.count) {
        [picker selectRow: selectedRow inComponent: 0 animated: NO];
        selectedProject = projectPickerElements[selectedRow];
        if ([selectedProject isEqualToString: SPIN_LIBRARY_PICKER_NAME])
            selectedProject = SPIN_LIBRARY;
        [self showFilesFor: selectedRow];
    }
}

#pragma mark - UIPickerViewDataSource

/*!
 * Called by the picker view when it needs the number of components.
 *
 * @param pickerView		The picker view requesting the data.
 */

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {
    return 2;
}

/*!
 * Called by the picker view when it needs the number of rows for a specified component.
 *
 * @param pickerView		The picker view requesting the data.
 * @param component			A zero-indexed number identifying a component of pickerView. Components are 
 *							numbered left-to-right.
 */

- (NSInteger) pickerView: (UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger) component {
    return component == 0 ? projectPickerElements.count : filePickerElements.count;
}

#pragma mark - UIPickerViewDelegate

/*!
 * Called by the picker view when the user selects a row in a component.
 *
 * @param pickerView		An object representing the picker view requesting the data.
 * @param row				A zero-indexed number identifying a row of component. Rows are numbered top-to-bottom.
 * @param component			A zero-indexed number identifying a component of pickerView. Components are numbered
 *							left-to-right.
 */

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component {
    if (component == 0) {
        // Select a new project.
        selectedRow = (int) row;
        selectedProject = projectPickerElements[row]; // Deliberately does not use the setter, which is for external consumption.
        if ([selectedProject isEqualToString: SPIN_LIBRARY_PICKER_NAME])
            selectedProject = SPIN_LIBRARY;
        [self showFilesFor: (int) row];
    } else {
        // Select a new file.
        self.selectedName = filePickerElements[row];
    }
}

/*!
 * Called by the picker view when it needs the title to use for a given row in a given component.
 *
 * @param pickerView		An object representing the picker view requesting the data.
 * @param row				A zero-indexed number identifying a row of component. Rows are numbered 
 *							top-to-bottom.
 * @param component			A zero-indexed number identifying a component of pickerView. Components 
 *							are numbered left-to-right.
 *
 * @return					The string to use as the title of the indicated component row.
 */

- (NSString *) pickerView: (UIPickerView *) pickerView titleForRow: (NSInteger) row forComponent: (NSInteger) component {
    return component == 0 ? [projectPickerElements objectAtIndex: row] : [filePickerElements objectAtIndex: row];
}

@end
