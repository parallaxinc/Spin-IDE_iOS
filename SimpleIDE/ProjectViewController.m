//
//  ProjectViewController.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/29/14.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "ProjectViewController.h"

#import "Common.h"
#import "DetailViewController.h"
#import "PickerViewController.h"


typedef enum {tagBoardType, tagCompilerType, tagMemoryModel, tagOptimization} alertTags;


@interface ProjectViewController () <UIPopoverControllerDelegate> {
    CGRect keyboardViewRect;							// View rectangle when the keyboard was shwn.
    BOOL keyboardVisible;								// Is the keyboard visible?
    int selectedBoardTypePickerElementIndex;			// The index of the selected Board Type picker element.
    int selectedCompilerTypePickerElementIndex;			// The index of the selected Compiler Type picker element.
    int selectedMemoryModelPickerElementIndex;			// The index of the selected Memory Model picker element.
    int selectedOptimizationPickerElementIndex;			// The index of the selected Optimization picker element.
}

@property (nonatomic, retain) NSArray *boardTypePickerElements;
@property (nonatomic, retain) NSArray *compilerTypePickerElements;
@property (nonatomic, retain) NSArray *memoryModelPickerElements;
@property (nonatomic, retain) NSArray *optimizationPickerElements;
@property (nonatomic, retain) UIPopoverController *pickerPopoverController;

@end


@implementation ProjectViewController

@synthesize boardTypeButton;
@synthesize boardTypePickerElements;
@synthesize compilerOptionsTextField;
@synthesize compilerOptionsView;
@synthesize compilerTypeButton;
@synthesize compilerTypePickerElements;
@synthesize linkerOptionsTextField;
@synthesize linkerOptionsView;
@synthesize memoryModelButton;
@synthesize memoryModelPickerElements;
@synthesize namesTableView;
@synthesize optionsView;
@synthesize optimizationButton;
@synthesize optimizationPickerElements;
@synthesize pickerPopoverController;
@synthesize projectOptionsView;

#pragma mark - Misc

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
    if (pickerPopoverController == nil) {
        // Create the controller and add the root controller.
        NSString *nibName = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")
        ? @"PickerViewController_7"
        : @"PickerViewController";
        PickerViewController *pickerController = [[PickerViewController alloc] initWithNibName: nibName
                                                                                        bundle: nil
                                                                                        prompt: prompt
                                                                                           tag: tag];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: pickerController];
        pickerController.navController = navigationController;
        pickerController.pickerElements = elements;
        pickerController.delegate = self;
        
        // Create the popover.
        UIPopoverController *pickerPopover = [[NSClassFromString(@"UIPopoverController") alloc]
                                              initWithContentViewController: navigationController];
        [pickerPopover setPopoverContentSize: pickerController.view.frame.size];
        CGRect viewSize = pickerController.view.frame;
        viewSize.size.height += 40;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            viewSize.size.height += 5;
        [pickerPopover setPopoverContentSize: viewSize.size];
        [pickerPopover setDelegate: self];
        
        // Display the popover.
        self.pickerPopoverController = pickerPopover;
        [self.pickerPopoverController presentPopoverFromRect: button.frame
                                                      inView: projectOptionsView
                                    permittedArrowDirections: UIPopoverArrowDirectionLeft
                                                    animated: YES];
        
        // Select the proper row in the picker.
        [pickerController.picker selectRow: index inComponent: 0 animated: NO];
    }
}

#pragma mark - Actions

/*!
 * Called when the Board Type button is hit, this method allows the user to select a new board type.
 *
 * @param sender		The button that triggered this call.
 */

- (IBAction) boardTypeAction: (id) sender {
    [self pickerAction: tagBoardType
                prompt: @"Board Type"
              elements: boardTypePickerElements
                button: (UIButton *) sender
                 index: selectedBoardTypePickerElementIndex];
}

/*!
 * Called when the Compiler Type button is hit, this method allows the user to select a new compiler type.
 *
 * @param sender		The button that triggered this call.
 */

- (IBAction) compilerTypeAction: (id) sender {
    [self pickerAction: tagCompilerType
                prompt: @"Compiler Type"
              elements: compilerTypePickerElements
                button: (UIButton *) sender
                 index: selectedCompilerTypePickerElementIndex];
}

/*!
 * Called when the Memory Model button is hit, this method allows the user to select a new memory model.
 *
 * @param sender		The button that triggered this call.
 */

- (IBAction) memoryModelAction: (id) sender {
    [self pickerAction: tagMemoryModel
                prompt: @"Memory Model"
              elements: memoryModelPickerElements
                button: (UIButton *) sender
                 index: selectedMemoryModelPickerElementIndex];
}

/*!
 * Called when the Optimization button is hit, this method allows the user to select a new optimization model.
 *
 * @param sender		The button that triggered this call.
 */

- (IBAction) optimizationAction: (id) sender {
    [self pickerAction: tagOptimization
                prompt: @"Optimization"
              elements: optimizationPickerElements
                button: (UIButton *) sender
                 index: selectedOptimizationPickerElementIndex];
}

/*!
 * Called when the segmented control that selects between Project Options, Compiler Options and Linker Options is
 * tapped. This method handles the transition from one to the other.
 *
 * @param sender		The segmented control that triggered this call.
 */

- (IBAction) optionViewSelected: (id) sender {
    [UIView transitionWithView: optionsView
                      duration: 0.5
                       options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCurlDown
                    animations: ^(void) {
                        switch ([sender selectedSegmentIndex]) {
                            case 0:
                                [projectOptionsView setHidden: NO];
                                [compilerOptionsView setHidden: YES];
                                [linkerOptionsView setHidden: YES];
                                break;
                                
                            case 1:
                                [projectOptionsView setHidden: YES];
                                [compilerOptionsView setHidden: NO];
                                [linkerOptionsView setHidden: YES];
                                break;
                                
                            case 2:
                                [projectOptionsView setHidden: YES];
                                [compilerOptionsView setHidden: YES];
                                [linkerOptionsView setHidden: NO];
                                break;
                        }
                    }
                    completion: nil
     ];
}

#pragma mark - View Maintenance

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

/*
 * Called when the virtual keyboard is shown, this method should adjust the size of the views to
 * prevent text from appearing under the keybaord.
 *
 * Parameters:
 *  notification - The notification.
 */

- (void) keyboardWasShown: (NSNotification *) notification {
    if ([compilerOptionsTextField isFirstResponder] || [linkerOptionsTextField isFirstResponder]) {
        NSDictionary *info = [notification userInfo];
        CGSize keyboardSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
        CGRect rect = self.view.frame;
        if (keyboardVisible)
            rect = keyboardViewRect;
        else
            keyboardViewRect = rect;
        rect.size.height -= keyboardSize.height < keyboardSize.width ? keyboardSize.height : keyboardSize.width;
        self.view.frame = rect;
        
        keyboardVisible = YES;
    }
}

/*
 * Called when the virtual keyboard is about to be hidden, this method should adjust the size of the
 * text view to the values before the keyboard was shown.
 *
 * Parameters:
 *  notification - The notification.
 */

- (void) keyboardWillBeHidden: (NSNotification *) notification {
    if ([compilerOptionsTextField isFirstResponder] || [linkerOptionsTextField isFirstResponder]) {
        NSDictionary *info = [notification userInfo];
        CGSize keyboardSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        CGRect rect = self.view.frame;
        if (keyboardVisible)
            rect = keyboardViewRect;
        else
            rect.size.height += keyboardSize.height < keyboardSize.width ? keyboardSize.height : keyboardSize.width;
        self.view.frame = rect;
        
        keyboardVisible = NO;
    }
}

/*!
 * Notifies the view controller that its view was added to a window.
 *
 * @param animated		If YES, the view was added to the window using an animation.
 */

- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear: animated];
    namesTableView.dataSource = self;
    [namesTableView reloadData];
}

/*!
 * Called after the controller’s view is loaded into memory.
 */

- (void) viewDidLoad {
    // Initialize the picker lists and default values.
    self.boardTypePickerElements = [[NSArray alloc] initWithObjects: @"ACTIVITYBOARD", @"ACTIVITYBOARD-SDXMMC", @"C3",
                                    @"C3-SDLOAD", @"C3-SDXMMC", @"C3F", @"C3F-SDLOAD", @"C3F-SDXMMC", @"DEMOBOARD",
                                    @"EEPROM", @"GENERIC", @"HYDRA", @"PROPBOE", @"PROPBOE-SDXMMC", @"PROPSTICK",
                                    @"QUICKSTART", @"RCFAST", @"RCSLOW", @"SPINSTAMP", @"SYNAPSE", nil];
    selectedBoardTypePickerElementIndex = [boardTypePickerElements indexOfObject: @"GENERIC"];
    
    self.compilerTypePickerElements = [[NSArray alloc] initWithObjects: @"C", @"C++", @"SPIN", nil];
    selectedCompilerTypePickerElementIndex = [compilerTypePickerElements indexOfObject: @"C"];
    
    self.memoryModelPickerElements = [[NSArray alloc] initWithObjects: @"LMM Main RAM", @"CMM Main RAM Compact",
                                      @"COG Cog RAM", @"XMMC External Flash Code Main RAM Data",
                                      @"XMM Single External RAM", @"XMM-Split External Flash Code + RAM Data", nil];
    selectedMemoryModelPickerElementIndex = [memoryModelPickerElements indexOfObject: @"CMM Main RAM Compact"];
    
    self.optimizationPickerElements = [[NSArray alloc] initWithObjects: @"-Os Size", @"-O2 Speed", @"-O1 Mixed",
                                       @"-O0 None", nil];
    selectedOptimizationPickerElementIndex = [optimizationPickerElements indexOfObject: @"-Os Size"];
    
    // Register for keyboard events.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWasShown:)
                                                 name: UIKeyboardDidShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillBeHidden:)
                                                 name: UIKeyboardWillHideNotification object: nil];

    [super viewDidLoad];
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

#pragma mark - PickerViewControllerDelegate

/*!
 * Called when the selected row changes in the picker.
 *
 * @param picker		The picker object that made this call.
 * @param row			The newly selected row.
 */

- (void) pickerViewController: (PickerViewController *) picker didSelectRow: (int) row {
    switch (picker.tag) {
        case tagBoardType:
            selectedBoardTypePickerElementIndex = row;
            [boardTypeButton setTitle: boardTypePickerElements[row] forState: UIControlStateNormal];
            break;

        case tagCompilerType: {
            selectedCompilerTypePickerElementIndex = row;
            [compilerTypeButton setTitle: compilerTypePickerElements[row] forState: UIControlStateNormal];
            UINavigationController *navigationController = (UINavigationController *) self.splitViewController.viewControllers[1];
            DetailViewController *detailViewController = (DetailViewController *) navigationController.topViewController;
            switch (row) {
                case 0: // C
                    detailViewController.sourceView.language = languageC;
                    break;
                    
                case 1: // C++
                    detailViewController.sourceView.language = languageCPP;
                    break;
                    
                case 2: // Spin
                    detailViewController.sourceView.language = languageSpin;
                    break;
            }
            break;
        }

        case tagMemoryModel:
            selectedMemoryModelPickerElementIndex = row;
            [memoryModelButton setTitle: memoryModelPickerElements[row] forState: UIControlStateNormal];
            break;

        case tagOptimization:
            selectedOptimizationPickerElementIndex = row;
            [optimizationButton setTitle: optimizationPickerElements[row] forState: UIControlStateNormal];
            break;
    }
}

#pragma mark - UITableViewDataSource

/*!
 * Asks the data source to return the number of sections in the table view.
 *
 * @param tableView		The table-view object requesting this information.
 *
 * @return				The number of sections in tableView.
 */

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
    return 1;
}

/*!
 * Asks the data source for a cell to insert in a particular location of the table view. (required)
 *
 * @param tableView		A table-view object requesting the cell.
 * @param indexPath		An index path locating a row in tableView.
 *
 * Returns: An object inheriting from UITableViewCellthat the table view can use for the specified row.
 */

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    NSString *tableID = @"SimpleIDE_Names";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: tableID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault 
                                      reuseIdentifier: tableID];
    }
//    NSUInteger section = [indexPath section];
//    NSUInteger row = [indexPath row];
    cell.textLabel.text = @"(Names of programs go here)"; // [[sections objectAtIndex: section] objectAtIndex: row];
    return cell;
}

/*!
 * Tells the data source to return the number of rows in a given section of a table view. (required)
 *
 * @param tableView		The table-view object requesting this information.
 * @param section		An index number identifying a section in tableView.
 *
 * Returns: The number of rows in section.
 */

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
    return 1; // [[sections objectAtIndex: section] count];
}

/*!
 * Tells the delegate that the specified row is now selected.
 *
 * @param tableView		A table-view object informing the delegate about the new row selection.
 * @param indexPath		An index path locating the new selected row in tableView.
 */

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
//    environmentAddEvent(event_cellSelected, 0, NULL, CFAbsoluteTimeGetCurrent(), tableObject, 0, 0, NULL);
}

@end
