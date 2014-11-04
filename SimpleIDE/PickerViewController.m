//
//  PickerViewController.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/29/14.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "PickerViewController.h"

@interface PickerViewController ()

@end

@implementation PickerViewController

@synthesize delegate;
@synthesize navController;
@synthesize pickerElements;
@synthesize tag;

#pragma mark - View Maintenance

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
    }
    return self;
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

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
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
    if ([delegate respondsToSelector: @selector(pickerViewController:didSelectRow:)])
        [delegate pickerViewController: self didSelectRow: row];
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
