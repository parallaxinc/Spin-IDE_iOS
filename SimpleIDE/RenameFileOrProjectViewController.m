//
//  RenameFileOrProjectViewController.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 2/2/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "RenameFileOrProjectViewController.h"

#import "Common.h"

@interface RenameFileOrProjectViewController () {
    BOOL renamingProject;
}

@property (nonatomic, retain) NSString *oldFileName;

@end

@implementation RenameFileOrProjectViewController

@synthesize delegate;
@synthesize nameTextField;
@synthesize navController;
@synthesize oldFileName;
@synthesize currentNames;
@synthesize renameButton;

#pragma mark - Actions

/*!
 * Returns a newly initialized view controller with the nib file in the specified bundle.
 *
 * @param nibNameOrNil		The nib name.
 * @param bundle			The bundle.
 * @param prompt			The string that will appear at the top of the dialog.
 * @param isProject			YES if we are renaming the current project, or NO if we are renaming a file in the current project.
 * @param fileName			The name of the file to be renamed. Unused if renaming a project; pass nil.
 */

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
                prompt: (NSString *) prompt
             isProject: (BOOL) isProject
              fileName: (NSString *) fileName;
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
        self.title = prompt;
        renamingProject = isProject;
        self.oldFileName = fileName;
    }
    return self;
}

/*!
 * Called when the Cancel button is hit.
 *
 * @param sender		The button that triggered this call.
 */

- (IBAction) cancelButtonAction: (id) sender {
    if ([delegate respondsToSelector: @selector(renameFileOrProjectViewControllerRename:name:oldName:isProject:)])
        [delegate renameFileOrProjectViewControllerRename: self name: nil oldName: oldFileName isProject: renamingProject];
}

/*!
 * See if a name is the same as the name of an existing project.
 *
 * @param name		The name to check.
 *
 * @return			YES if the name is the name of an existing project, else NO.
 */

- (BOOL) exists: (NSString *) name {
    for (NSString *currentName in currentNames) {
        if ([currentName isEqualToString: name])
            return YES;
    }
    return NO;
}

/*!
 * Called when the Rename button is hit.
 *
 * @param sender		The button that triggered this call.
 */

- (IBAction) renameButtonAction: (id) sender {
    // Get the name.
    NSString *name = [nameTextField.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    // Make sure a name has been entered.
    BOOL goodName = name != nil && name.length > 0;
    if (!goodName) {
        NSString *message = [NSString stringWithFormat: @"Please enter a non-blank name for the %@.", renamingProject ? @"project" : @"file"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Missing Name"
                                                        message: message
                                                       delegate: nil
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    
    // If we are renaming a file, and the new name is missing a file extension or it is invalid, use the old file extension.
    NSString *extension = [name pathExtension];
    BOOL goodExtension = NO;
    if (extension && extension.length > 0) {
        for (NSString *validExtension in [Common validExtensions])
            if ([extension isEqualToString: validExtension]) {
                goodExtension = YES;
                break;
            }
    }
    if (!goodExtension) {
        extension = [oldFileName pathExtension];
        if (!extension || extension.length == 0)
            extension = @"spin";
        name = [[name stringByDeletingPathExtension] stringByAppendingPathExtension: extension];
    }
    
    // Check for duplicate names.
    if (goodName) {
        goodName = ![self exists: name];
        if (!goodName) {
            // Find an acceptable name.
            BOOL done = NO;
            int index = 1;
            while (!done) {
                NSString *newName = nil;
                if (renamingProject)
                	newName = [NSString stringWithFormat: @"%@%d", name, index++];
                else
                    newName = [NSString stringWithFormat: @"%@%d.%@", [name stringByDeletingPathExtension], index++, [name pathExtension]];
                if (![self exists: newName]) {
                    done = YES;
                    nameTextField.text = newName;
                }
            }
            
            // Tell the suer what we did.
            NSString *kind = renamingProject ? @"project" : @"file";
            NSString *message = [NSString stringWithFormat: @"%@ is the name of an existing %@. It has been changed to a similar name that does not exist.\n\nPress Rename again if the new %@ name is acceptable, or edit it if the new name is not acceptable.", name, kind, kind];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Duplicate"
                                                            message: message
                                                           delegate: nil
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }
    
    // Tell the delegate to create the project.
    if (goodName && [delegate respondsToSelector: @selector(renameFileOrProjectViewControllerRename:name:oldName:isProject:)])
        [delegate renameFileOrProjectViewControllerRename: self name: name oldName: oldFileName isProject: renamingProject];
}

#pragma mark - View Maintenance

/*!
 * Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 * @param animated		If YES, the view is being added to the window using an animation.
 */

- (void) viewWillAppear: (BOOL) animated {
    // Call super.
    [super viewWillAppear: animated];
    
    // Set up for file name entry.
    [nameTextField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

/*!
 * Asks the delegate if the specified text should be changed.
 *
 * The text field calls this method whenever the user types a new character in the text field or deletes an existing character.
 *
 * @param textField		The text field containing the text.
 * @param range			The range of characters to be replaced
 * @param string		The replacement string.
 *
 * @return				YES if the specified text range should be replaced; otherwise, NO to keep the old text.
 */

- (BOOL) textField: (UITextField *) textField
shouldChangeCharactersInRange: (NSRange) range
 replacementString: (NSString *) string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange: range withString: string];
    text = [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    renameButton.enabled = text.length > 0;
    return YES;
}

/*!
 * Asks the delegate if the text field should process the pressing of the return button. We use this
 * to dismiss the keyboard when the user is entering text in one of the UITextField objects and to
 * record the new values.
 *
 * @param textField		The text field whose return button was pressed.
 */

- (BOOL) textFieldShouldReturn: (UITextField *) textField {
    [nameTextField resignFirstResponder];
    [self renameButtonAction: textField];
    return NO;
}

@end
