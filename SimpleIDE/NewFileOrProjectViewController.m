//
//  NewProjectViewController.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/26/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "NewFileOrProjectViewController.h"

#import "ProjectViewController.h"

@interface NewFileOrProjectViewController () {
    BOOL creatingProject;
}

@end

@implementation NewFileOrProjectViewController

@synthesize createButton;
@synthesize delegate;
@synthesize nameTextField;
@synthesize navController;
@synthesize projects;

#pragma mark - Misc.

/*!
 * Moves the cursor to the start of nameTextField. This must be called from the main thread after nameTextField is the first responder.
 */

- (void) beginningOfDocument {
    UITextPosition *beginningOfDocument = [nameTextField beginningOfDocument];
    UITextRange *newRange = [nameTextField textRangeFromPosition: beginningOfDocument toPosition: beginningOfDocument];
    [nameTextField setSelectedTextRange: newRange];
}

#pragma mark - Actions

/*!
 * Returns a newly initialized view controller with the nib file in the specified bundle.
 *
 * @param nibNameOrNil		The nib name.
 * @param bundle			The bundle.
 * @param prompt			The string that will appear at the top of the dialog.
 * @param isProject			YES if we are creating a new project, or NO if we are creating a new file.
 */

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
                prompt: (NSString *) prompt
             isProject: (BOOL) isProject
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
        self.title = prompt;
        creatingProject = isProject;
    }
    return self;
}

/*!
 * Called when the Cancel button is hit.
 *
 * @param sender		The button that triggered this call.
 */

- (IBAction) cancelButtonAction: (id) sender {
    if ([delegate respondsToSelector: @selector(newFileOrProjectViewController:name:isProject:)])
        [delegate newFileOrProjectViewController: self name: nil isProject: creatingProject];
}

/*!
 * See if a name is the same as the name of an existing file or project.
 *
 * @param name		The name to check.
 *
 * @return			YES if the name is the name of an existing project, else NO.
 */

- (BOOL) exists: (NSString *) name {
    for (NSString *project in projects) {
        if ([project caseInsensitiveCompare: name] == NSOrderedSame)
            return YES;
    }
    return NO;
}

/*!
 * Called when the Create button is hit.
 *
 * @param sender		The button that triggered this call.
 */

- (IBAction) createButtonAction: (id) sender {
    // Get the name.
    NSString *name = [nameTextField.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    // Make sure a name has been entered.
    BOOL goodName = name != nil && name.length > 0;
    if (!goodName) {
        NSString *message = [NSString stringWithFormat: @"Please enter a non-blank name for the %@.", creatingProject ? @"project" : @"file"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Missing Name"
                                                        message: message
                                                       delegate: nil
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    
    // Make sure the file name extension is valid.
    if (goodName && !creatingProject) {
        NSString *extension = [name pathExtension];
        goodName = NO;
        for (NSString *validExtension in [Common validExtensions])
            if ([validExtension caseInsensitiveCompare: extension] == NSOrderedSame) {
                goodName = YES;
                break;
            }
        
        if (!goodName) {
            NSArray *validExtensions = [Common validExtensions];
            if (validExtensions.count > 0) {
                NSString *extensions = validExtensions[0];
                for (int i = 1; i < validExtensions.count -1; ++i)
                    extensions = [NSString stringWithFormat: @"%@, %@", extensions, validExtensions[i]];
                if (validExtensions.count > 1)
	                extensions = [NSString stringWithFormat: @"%@ or %@", extensions, validExtensions[validExtensions.count -1]];
                NSString *message = [NSString stringWithFormat: @"Please use a non-blank file name with a valid file extension.\n\nThe valid file extensions are %@.", extensions];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Name"
                                                                message: message
                                                               delegate: nil
                                                      cancelButtonTitle: @"OK"
                                                      otherButtonTitles: nil];
                [alert show];
            }
        }
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
                if (!creatingProject && [name pathExtension].length > 0)
                    newName = [NSString stringWithFormat: @"%@%d.%@", [name stringByDeletingPathExtension], index++, [name pathExtension]];
                else
                    newName = [NSString stringWithFormat: @"%@%d", name, index++];
                if (![self exists: newName]) {
                    done = YES;
                    nameTextField.text = newName;
                }
            }
            
            // Tell the suer what we did.
            NSString *kind = creatingProject ? @"project" : @"file";
            NSString *message = [NSString stringWithFormat: @"%@ is the name of an existing %@. It has been changed to a similar name that does not exist.\n\nPress Create again if the new %@ name is acceptable, or edit it if the new name is not acceptable.", name, kind, kind];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Duplicate"
                                                            message: message
                                                           delegate: nil
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }
    
    // Tell the delegate to create the project.
    if (goodName && [delegate respondsToSelector: @selector(newFileOrProjectViewController:name:isProject:)])
        [delegate newFileOrProjectViewController: self name: name isProject: creatingProject];
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
    if (!creatingProject) {
        NSString *extension = @".spin";
        switch ([ProjectViewController defaultProjectViewController].project.language) {
            case languageC:
                extension = @".c";
                break;
                
            case languageCPP:
                extension = @".cpp";
                break;
                
            default:
                break;
        }
        
        createButton.enabled = YES;
        
        nameTextField.text = extension;
        [nameTextField becomeFirstResponder];
        [self performSelectorOnMainThread: @selector(beginningOfDocument) withObject: nil waitUntilDone: NO];
    } else
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
    createButton.enabled = text.length > 0;
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
    [self createButtonAction: textField];
    return NO;
}

@end
