//
//  OpenProjectViewController.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/9/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "OpenProjectViewController.h"

@interface OpenProjectViewController () {
    int selectedRow;				// The selected row.
}

@end

@implementation OpenProjectViewController

@synthesize delegate;
@synthesize navController;
@synthesize picker;
@synthesize pickerElements;
@synthesize selectedElement;
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

#pragma mark - Actions

/*!
 * Called when the Cancel button is hit.
 *
 * @param sender		The button that triggered this call.
 */

- (IBAction) cancelButtonAction: (id) sender {
    if ([delegate respondsToSelector: @selector(openProjectViewController:didSelectProject:)])
        [delegate openProjectViewController: self didSelectProject: -1];
}

/*!
 * Called when the Open button is hit.
 *
 * @param sender		The button that triggered this call.
 */

- (IBAction) openButtonAction: (id) sender {
    if ([delegate respondsToSelector: @selector(openProjectViewController:didSelectProject:)])
        [delegate openProjectViewController: self didSelectProject: selectedRow];
}

#pragma mark - Getters and setters

/*!
 * Set the new list of picker elements.
 *
 * @param thePickerElements		The new list of picker elements.
 */

- (void) setPickerElements: (NSArray *) thePickerElements {
    // Set the new picker elements.
    pickerElements = thePickerElements;
    
    // Make sure the current value for hte selected row is valid.
    if (pickerElements.count > 0 && selectedRow == -1)
        selectedRow = 0;
    if (selectedRow > pickerElements.count - 1)
        selectedRow = pickerElements.count - 1;
}

/*!
 * Set the selected element.
 *
 * This call is ognored if the parameter does not exist in the picker.
 *
 * @param theSelectedElement	The new selected element.
 */

- (void) setSelectedElement: (NSString *) theSelectedElement {
    for (int i = 0; i < pickerElements.count; ++i) {
        if ([theSelectedElement caseInsensitiveCompare: pickerElements[i]] == NSOrderedSame) {
            selectedRow = i;
            [picker selectRow: i inComponent: 0 animated: YES];
            selectedElement = theSelectedElement;
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
    
    if (selectedRow >= 0 && selectedRow < pickerElements.count)
        [picker selectRow: selectedRow inComponent: 0 animated: NO];
}

#pragma mark - UIPickerViewDataSource

/*!
 * Called by the picker view when it needs the number of components.
 *
 * @param pickerView		The picker view requesting the data.
 */

- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {
    return 1;
}

/*!
 * Called by the picker view when it needs the number of rows for a specified component.
 *
 * @param pickerView		The picker view requesting the data.
 * @param component			A zero-indexed number identifying a component of pickerView. Components are 
 *							numbered left-to-right.
 */

- (NSInteger) pickerView: (UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger) component {
    return pickerElements.count;
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
    selectedRow = row;
    selectedElement = pickerElements[row]; // Deliberately does not use the setter, which is for external consumption.
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
    return [pickerElements objectAtIndex: row];
}

@end
