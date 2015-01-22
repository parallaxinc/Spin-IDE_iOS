//
//  OpenProjectViewController.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/9/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenProjectViewController;


@protocol OpenProjectViewControllerDelegate <NSObject>

/*!
 * Called if the user taps Open or Cancel, this method passes the index of the selected project file.
 *
 * @param picker		The picker object that made this call.
 * @param row			The newly selected row, or -1 if Cancel was selected.
 */

- (void) openProjectViewController: (OpenProjectViewController *) picker didSelectProject: (int) row;

@end


@interface OpenProjectViewController : UIViewController

@property (weak, nonatomic) id<OpenProjectViewControllerDelegate> delegate;
@property (nonatomic, retain) UINavigationController *navController;	// The navigation controller.
@property (nonatomic, retain) IBOutlet UIPickerView *picker;			// The picker.
@property (nonatomic, retain) NSArray *pickerElements;					// The elements displayed in the picker.
@property (nonatomic, retain) NSString *selectedElement;				// The name of the selected element.
@property (nonatomic) int tag;											// Caller supplied ID tag.

- (IBAction) cancelButtonAction: (id) sender;
- (IBAction) openButtonAction: (id) sender;
- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
                prompt: (NSString *) prompt
                   tag: (int) atag;

@end
