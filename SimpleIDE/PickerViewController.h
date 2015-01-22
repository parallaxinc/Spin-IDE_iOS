//
//  PickerViewController.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/29/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickerViewController;


@protocol PickerViewControllerDelegate <NSObject>

/*!
 * Called when the selected row changes in the picker.
 *
 * @param picker		The picker object that made this call.
 * @param row			The newly selected row.
 */

- (void) pickerViewController: (PickerViewController *) picker didSelectRow: (int) row;

@end


@interface PickerViewController : UIViewController <UIPickerViewDataSource>

@property (weak, nonatomic) id<PickerViewControllerDelegate> delegate;
@property (nonatomic, retain) UINavigationController *navController;	// The navigation controller.
@property (nonatomic, retain) IBOutlet UIPickerView *picker;			// The picker.
@property (nonatomic, retain) NSArray *pickerElements;					// The elements displayed in the picker.
@property (nonatomic) int tag;											// Caller supplied ID tag.

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
                prompt: (NSString *) prompt
                   tag: (int) atag;

@end
