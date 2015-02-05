//
//  OpenFileViewController.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 2/3/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenFileViewController;


@protocol OpenFileViewControllerDelegate <NSObject>

/*!
 * Called if the user taps Open or Cancel, this method passes the file selection information.
 *
 * @param picker		The picker object that made this call.
 * @param row			The index of the selected project, or -1 if Cancel was selected.
 * @param name			The file name of hte selected file, or nil for Cancel. Includes the extension, but not the path.
 */

- (void) openFileViewController: (OpenFileViewController *) picker selectedProject: (int) row name: (NSString *) name;

@end


@interface OpenFileViewController : UIViewController

@property (weak, nonatomic) id<OpenFileViewControllerDelegate> delegate;
@property (nonatomic, retain) UINavigationController *navController;	// The navigation controller.
@property (nonatomic, retain) IBOutlet UIButton *openButton;			// The open button.
@property (nonatomic, retain) IBOutlet UIPickerView *picker;			// The picker.
@property (nonatomic, retain) NSArray *projectPickerElements;			// The elements displayed in the project wheel of the picker.
@property (nonatomic, retain) NSString *selectedProject;				// The name of the selected project.
@property (nonatomic) int tag;											// Caller supplied ID tag.

- (IBAction) cancelButtonAction: (id) sender;
- (IBAction) openButtonAction: (id) sender;
- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
                prompt: (NSString *) prompt
                   tag: (int) atag;
@end
