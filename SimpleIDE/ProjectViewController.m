//
//  ProjectViewController.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/29/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "ProjectViewController.h"

#import "Common.h"
#import "ConfigurationViewController.h"
#import "openspin.h"
#import "PickerViewController.h"


#define DEBUG_SPEW NO


typedef enum {tagBoardType, tagCompilerType, tagMemoryModel, tagOptimization} alertTags;

static ProjectViewController *this;						// This singleton instance of this class.


// TODO: New project
// TODO: Delete project
// TODO: Rename project

// TODO: Open file (not in project)
// TODO: New file (in project)
// TODO: Close a file (not in project)
// TODO: Delete a file (in project or not, must be open)
// TODO: Save as (save to other projects?
// TODO: Copy file to project
// TODO: Allow multiple files in a project.
// TODO: Rename file

// TODO: Use libraries.
// TODO: Display errors in a user fiendly way.

// TODO: EPROM Support
// TODO: Navigation control does not show up on main view until the program rotates to landscape once
// TODO: Use the user supplied compiler flags
// TODO: Opening a file takes a long time
// TODO: Collapse the side panel in landscape view
// TODO: Allow pinch zoom in the editor.
// TODO: Temporarily hide the ability to create C projects.
// TODO: Turn the loader into a library.
// TODO: Add a terminal
// TODO: Share zipped files.


@interface ProjectViewController () <UIPopoverControllerDelegate> {
    CGRect keyboardViewRect;							// View rectangle when the keyboard was shwn.
    BOOL keyboardVisible;								// Is the keyboard visible?
    int selectedBoardTypePickerElementIndex;			// The index of the selected Board Type picker element.
    int selectedCompilerTypePickerElementIndex;			// The index of the selected Compiler Type picker element.
    int selectedMemoryModelPickerElementIndex;			// The index of the selected Memory Model picker element.
    int selectedOptimizationPickerElementIndex;			// The index of the selected Optimization picker element.
}

@property (nonatomic, retain) NSString *binaryFile;		// The most recently compiled binary file.
@property (nonatomic, retain) NSArray *boardTypePickerElements;
@property (nonatomic, retain) NSArray *compilerTypePickerElements;
@property (nonatomic, retain) UIPopoverController *loadImagePopoverController;
@property (nonatomic, retain) NSArray *memoryModelPickerElements;
@property (nonatomic, retain) NSArray *optimizationPickerElements;
@property (nonatomic, retain) UIPopoverController *pickerPopoverController;
@property (nonatomic, retain) UIPopoverController *xbeePopoverController;

@end


@implementation ProjectViewController

@synthesize binaryFile;
@synthesize boardTypeButton;
@synthesize boardTypePickerElements;
@synthesize compilerOptionsTextField;
@synthesize compilerOptionsView;
@synthesize compilerTypeButton;
@synthesize compilerTypePickerElements;
@synthesize linkerOptionsTextField;
@synthesize linkerOptionsView;
@synthesize loadImagePopoverController;
@synthesize memoryModelButton;
@synthesize memoryModelPickerElements;
@synthesize namesTableView;
@synthesize optimizationButton;
@synthesize optimizationPickerElements;
@synthesize optionsSegmentedControl;
@synthesize optionsView;
@synthesize pickerPopoverController;
@synthesize project;
@synthesize projectOptionsView;
@synthesize spinCompilerOptionsView;
@synthesize xbeePopoverController;

#pragma mark - Misc

/*!
 * Build the currently open project.
 *
 * @return				YES if the project build successfully, else NO.
 */

- (BOOL) build {
    BOOL result = NO;
    
    // Save the current source.
    DetailViewController *detailViewController = [DetailViewController defaultDetailViewController];
    [detailViewController.sourceConsoleSplitView.sourceView save];
    
    // TODO:    int count;
    //    char **args = [self commandLineArgumentsFor: "propeller-elf-gcc -v" count: &count];
    //    maingcc(2, args);
    //    free(args);
    //    
    //    NSString *sandboxPath = [Common sandbox];
    //    
    //    NSString *commandLine = @"propeller-elf-gcc -I ";
    //    NSString *include = [sandboxPath stringByAppendingPathComponent: @"include/"];
    //    commandLine = [commandLine stringByAppendingString: include];
    //    
    //    commandLine = [commandLine stringByAppendingString: @" -L "];
    //    NSString *libsimpletools = sandboxPath;
    //    commandLine = [commandLine stringByAppendingString: libsimpletools];
    //    
    //    commandLine = [commandLine stringByAppendingString: @" -I "];
    //    libsimpletools = [sandboxPath stringByAppendingPathComponent: @"libraries/Utility/libsimpletools"];
    //    commandLine = [commandLine stringByAppendingString: libsimpletools];
    //    
    //    commandLine = [commandLine stringByAppendingString: @" -L "];
    //    NSString *libsimpletools_cmm = [sandboxPath stringByAppendingPathComponent: @"libraries/Utility/libsimpletools/cmm/"];
    //    commandLine = [commandLine stringByAppendingString: libsimpletools_cmm];
    //    
    //    commandLine = [commandLine stringByAppendingString: @" -I "];
    //    NSString *libsimpletext = [sandboxPath stringByAppendingPathComponent: @"libraries/TextDevices/libsimpletext"];
    //    commandLine = [commandLine stringByAppendingString: libsimpletext];
    //    
    //    commandLine = [commandLine stringByAppendingString: @" -L "];
    //    NSString *libsimpletext_cmm = [sandboxPath stringByAppendingPathComponent: @"libraries/Utility/libsimpletools/cmm/"];
    //    commandLine = [commandLine stringByAppendingString: libsimpletext_cmm];
    //    
    //    commandLine = [commandLine stringByAppendingString: @" -I "];
    //    NSString *libsimplei2c = [sandboxPath stringByAppendingPathComponent: @"libraries/Protocol/libsimplei2c"];
    //    commandLine = [commandLine stringByAppendingString: libsimplei2c];
    //    
    //    commandLine = [commandLine stringByAppendingString: @" -L "];
    //    NSString *libsimplei2c_cmm = [sandboxPath stringByAppendingPathComponent: @"libraries/Protocol/libsimplei2c/cmm/"];
    //    commandLine = [commandLine stringByAppendingString: libsimplei2c_cmm];
    //    
    //    commandLine = [commandLine stringByAppendingString: @"\" -o "];
    //    NSString *outfile = [sandboxPath stringByAppendingPathComponent: @"cmm/Hello_Message.elf"];
    //    commandLine = [commandLine stringByAppendingString: outfile];
    //
    //    commandLine = [commandLine stringByAppendingString: @" -Os -mcmm -m32bit-doubles -fno-exceptions -std=c99 "];
    //    NSString *source = [sandboxPath stringByAppendingPathComponent: @"Hello_Message.c"];
    //    commandLine = [commandLine stringByAppendingString: source];
    //    
    //    commandLine = [commandLine stringByAppendingString: @" -lm -lsimpletools -lsimpletext -lsimplei2c -lm -lsimpletools -lsimpletext -lm -lsimpletools -lm"];
    //    
    //    args = [self commandLineArgumentsFor: [commandLine UTF8String] count: &count];
    //    for (int i = 0; i < count; ++i) printf("%2d: %s\n", i, args[i]);
    //    maingcc(count, args);
    //    free(args);
    
    if (project.files && project.files.count > 0) {
        if (project.language == languageSpin) {
            // Compile the files in this project.
            for (NSString *file in project.files) {
                // Build the command line.
                NSString *commandLine = @"openspin";
                
                NSString *stdoutPath = [project.path stringByAppendingPathComponent: @"stdout.txt"];
                commandLine = [NSString stringWithFormat: @"%@ -r %@", commandLine, stdoutPath];
                
                NSString *stderrPath = [project.path stringByAppendingPathComponent: @"stderr.txt"];
                commandLine = [NSString stringWithFormat: @"%@ -R %@", commandLine, stderrPath];
                
                NSString *path = [project.path stringByAppendingPathComponent: file];
                commandLine = [NSString stringWithFormat: @"%@ %@", commandLine, path];
                
                // Compile the program.
                int count;
                char **args = [self commandLineArgumentsFor: [commandLine UTF8String] count: &count];
#if DEBUG_SPEW
                for (int i = 0; i < count; ++i) 
                    printf("%2d: %s\n", i, args[i]);
#endif
                mainOpenSpin(count, args);
                free(args);
                
                // Display the standard and error out streams to the console.
                NSFileManager *manager = [NSFileManager defaultManager];
                NSString *console = @"";
                if ([manager fileExistsAtPath: stdoutPath])
                    console = [NSString stringWithContentsOfFile: stdoutPath encoding: NSUTF8StringEncoding error: nil];
                if ([manager fileExistsAtPath: stderrPath])
                    console = [NSString stringWithFormat: @"%@\n%@", console, [NSString stringWithContentsOfFile: stderrPath encoding: NSUTF8StringEncoding error: nil]];
                detailViewController.sourceConsoleSplitView.consoleView.text = console;
                
                // Record the binary file name for use by the loader.
                binaryFile = [[path stringByDeletingPathExtension] stringByAppendingPathExtension: @"binary"];
                
                // Check for an error. If one is found, display it. Return the result.
                NSString *out = [NSString stringWithContentsOfFile: stdoutPath encoding: NSUTF8StringEncoding error: nil];
                if ([out rangeOfString: @"Done"].location != NSNotFound && [out rangeOfString: @"Program size is "].location != NSNotFound) {
                    result = YES;
                } else {
                    NSArray *lines = [out componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
                    NSString *message = @"See the console for details about the error.";
                    NSString *file = nil;
                    int lineNumber = -1;
                    int offset = -1;
                    for (NSString *line in lines) {
                        NSRange range = [line rangeOfString: @" : error : "];
                        if (range.location != NSNotFound) {
                            message = [line substringFromIndex: range.location + range.length];
                            file = [line substringToIndex: range.location];
                            int index = line.length - 1;
                            while (index > -1 && [line characterAtIndex: index] != '(')
                                --index;
                            if (index > -1) {
                                NSString *str = [file substringFromIndex: index + 1];
                                file = [file substringToIndex: index];
                                lineNumber = [str intValue];
                                while (str.length > 0 && [str characterAtIndex: 0] != ':')
                                    str = [str substringFromIndex: 1];
                                if (str.length > 1) {
                                    str = [str substringFromIndex: 1];
                                    offset = [str intValue];
                                }
                            }
                            break;
                        }
                    }
                    [self reportError: message inFile: file line: lineNumber offset: offset];
                }
                
                // Remove the temporary files.
                if ([manager fileExistsAtPath: stdoutPath])
                    [manager removeItemAtPath: stdoutPath error: nil];
                if ([manager fileExistsAtPath: stderrPath])
                    [manager removeItemAtPath: stderrPath error: nil];
            }
        } else if (project.language == languageC) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"C is not yet supported.", NSLocalizedDescriptionKey,
                                  nil];
            NSError *error = [NSError errorWithDomain: simpleIDEDomain code: 1 userInfo: dict];
            [Common reportError: error];
            
            //            int count;
            //            NSString *sandboxPath = [Common sandbox];
            //            
            //            NSString *commandLine = @"as -lmm -cmm -o ";
            //            
            //            NSString *output = [sandboxPath stringByAppendingPathComponent: @"ccgnIafg.o"];
            //            commandLine = [commandLine stringByAppendingString: output];
            //            commandLine = [commandLine stringByAppendingString: @" "];
            //            NSString *input = [sandboxPath stringByAppendingPathComponent: @"ccZQFKcl.s"];
            //            commandLine = [commandLine stringByAppendingString: input];
            //            
            //            char **args = [self commandLineArgumentsFor: [commandLine UTF8String] count: &count];
            //            for (int i = 0; i < count; ++i) 
            //                printf("%2d: %s\n", i, args[i]);
            //            toplev_as_main(count, args);
            //            free(args);
        } else if (project.language == languageCPP) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"C++ is not yet supported.", NSLocalizedDescriptionKey,
                                  nil];
            NSError *error = [NSError errorWithDomain: simpleIDEDomain code: 1 userInfo: dict];
            [Common reportError: error];
        }
    } else {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"There is no file to build.", NSLocalizedDescriptionKey,
                              @"Open an existing project or create a new one.", NSLocalizedRecoverySuggestionErrorKey,
                              nil];
        NSError *error = [NSError errorWithDomain: simpleIDEDomain code: 1 userInfo: dict];
        [Common reportError: error];
    }
    
    return result;
}

/*!
 * Change the project language.
 *
 * @param language		The new project language.
 */

- (void) changeLanguage: (languageType) language {
    // Set the language for the source view.
    DetailViewController *detailViewController = [DetailViewController defaultDetailViewController];
    detailViewController.sourceConsoleSplitView.sourceView.language = language;
    
    // Set the language in the project.
    project.language = language;
    
    // Convert the language to a picker index.
    switch (language) {
        case languageC:
            selectedCompilerTypePickerElementIndex = 0;
            break;
            
        case languageCPP:
            selectedCompilerTypePickerElementIndex = 1;
            break;
            
        case languageSpin:
            selectedCompilerTypePickerElementIndex = 2;
            break;
    }
    
    // Set the title of the compiler type button to match the selected language.
    [compilerTypeButton setTitle: compilerTypePickerElements[selectedCompilerTypePickerElementIndex] forState: UIControlStateNormal];
    
    // Update the UI elements based on the selected language.
    [self hideLinker: language == languageSpin];
    boardTypeButton.enabled = language != languageSpin;
    memoryModelButton.enabled = language != languageSpin;
    optimizationButton.enabled = language != languageSpin;
}

/*!
 * Break a command line up into space delimited tokens.
 *
 * @param line		The command line to break up.
 * @param count		NOTE: Indirect pointer to a value that is set to the number of command line argments. Must not be NULL.
 *
 * @return			The array of command line arguments. The caller is responsible for disposal of the array and all
 *					strings pointed to by the array; call freeCommandLine for disposal.
 */

- (char **) commandLineArgumentsFor: (const char *) line count: (int *) count {
    // Break the line up into an array of space delimited NSStrings.
    NSString *nsline = [NSString stringWithUTF8String: line];
    NSArray *nsargs = [nsline componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    // Setthe number of arguments.
    *count = nsargs.count;
    
    // Form the array of arguments.
    char **args = malloc(sizeof(char *)*nsargs.count);
    for (int i = 0; i < nsargs.count; ++i) {
        args[i] = malloc(sizeof(char)*(strlen([nsargs[i] UTF8String]) + 1));
        strcpy(args[i], [nsargs[i] UTF8String]);
    }
    
    // Retrun the array.
    return args;
}

/*!
 * There is only one project view controller in the program, and there is always a project view 
 * controller, assuming initialization is complete. This call returns the singleton instance of 
 * the project view controller.
 *
 * @return			The project view controller.
 */

+ (ProjectViewController *) defaultProjectViewController {
    return this;
}

/*!
 * Hide or show th elinker option in optionsSegmentedControl.
 *
 * @param hide			YES to hide this option, or NO to show it.
 */

- (void) hideLinker: (BOOL) hide {
    if (hide)
        [optionsSegmentedControl removeSegmentAtIndex: 2 animated: YES];
    else if (optionsSegmentedControl.numberOfSegments < 3)
        [optionsSegmentedControl insertSegmentWithTitle: @"Linker" atIndex: 2 animated: YES];
}

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
        PickerViewController *pickerController = [[PickerViewController alloc] initWithNibName: @"PickerViewController_7"
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

/*!
 * Report a compilation error to the user.
 *
 * @param message		The user viewable error message.
 * @param file			The path of the file containing the error. Pass nil if hte file is not known.
 * @param line			The index of the line containing the error. Pass -1 if the line is not known.
 * @param offset		The offset of the error in the file. Pass 0 if the offset is not known.
 */

- (void) reportError: (NSString *) message inFile: (NSString *) file line: (int) line offset: (int) offset {
    // TODO: Open the file containing the error.
    // TODO: Show the error at the line containing the error.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Build Error"
                                                    message: message
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];
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

- (IBAction) optionsAction: (id) sender {
    [UIView transitionWithView: optionsView
                      duration: 0.5
                       options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCurlDown
                    animations: ^(void) {
                        switch ([sender selectedSegmentIndex]) {
                            case 0:
                                [projectOptionsView setHidden: NO];
                                [compilerOptionsView setHidden: YES];
                                [spinCompilerOptionsView setHidden: YES];
                                [linkerOptionsView setHidden: YES];
                                break;
                                
                            case 1:
                                [projectOptionsView setHidden: YES];
                                if (project.language == languageSpin) {
                                    [compilerOptionsView setHidden: YES];
                                    [spinCompilerOptionsView setHidden: NO];
                                } else {
                                    [compilerOptionsView setHidden: NO];
                                    [spinCompilerOptionsView setHidden: YES];
                                }
                                [linkerOptionsView setHidden: YES];
                                break;
                                
                            case 2:
                                [projectOptionsView setHidden: YES];
                                [compilerOptionsView setHidden: YES];
                                [spinCompilerOptionsView setHidden: YES];
                                [linkerOptionsView setHidden: NO];
                                break;
                        }
                    }
                    completion: nil
     ];
}

#pragma mark - View Maintenance

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
    
    // Set up an initial project object.
    // TODO: This should be replaced by a mechanism to open the previously used project or create a new one. Most of the stuff in this view should be disabled until that happens.
    self.project = [[Project alloc] init];
    [self changeLanguage: languageSpin];
    
    // Register as a delegate with the detail view controller.
    UINavigationController *navigationController = (UINavigationController *) self.splitViewController.viewControllers[1];
    DetailViewController *detailViewController = (DetailViewController *) navigationController.topViewController;
    detailViewController.delegate = self;
    
    // Record our ingleton instance.
    this = self;
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
    else if (popoverController == loadImagePopoverController)
        self.loadImagePopoverController = nil;
    else if (popoverController == xbeePopoverController)
        self.xbeePopoverController = nil;
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
            switch (row) {
                case 0: // C
                    [self changeLanguage: languageC];
                    break;
                    
                case 1: // C++
                    [self changeLanguage: languageCPP];
                    break;
                    
                case 2: // Spin
                    [self changeLanguage: languageSpin];
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

#pragma mark - LoadImageViewControllerDelegate

/*!
 * Called when the laoder has completed loading the binary.
 *
 * The loader is now in a dormant state, waiting for a new load.
 *
 * This method is not called if loaderFatalError is called to report an unsuccessful load.
 *
 * This method is always called from the main thread.
 */

- (void) loadImageViewControllerLoadComplete {
    [loadImagePopoverController dismissPopoverAnimated: YES];
    self.loadImagePopoverController = nil;
}

/*!
 * Called when the internal status of the loader changes, this method supplies a status string suitable for
 * display in a UI to provide textual progress information.
 *
 * Errors whose domain is [[Loader defaultLoader] loaderDomain] indicate internal errors in the loader, as follows:
 *
 *		id		error
 *		--		-----
 *		1		The Propeller did not respond to a reset/handshake attempt, even after the maximum allowed number
 *				of tries, as specified when starting the laod.
 *		2		The handshake was successfu, but the Propeller did not respond. This is only reported if the
 *				load has failed the maximum number of allowed times, as specified when starting the laod.
 *		3		The Propeller reaponded to a load, but the checksum was invalid. This is only reported if the
 *				load has failed the maximum number of allowed times, as specified when starting the load.
 *
 * Any other error is passed up from iOS, and generally indicates an error that inticates a fundamental problem
 * that makes trying again pointless.
 *
 * The loader is now in a dormant state, waiting for a new load.
 *
 * This method is always called from the main thread.
 *
 * @param error			The error.
 */

- (void) loadImageViewControllerFatalError: (NSError *) error {
    [loadImagePopoverController dismissPopoverAnimated: YES];
    self.loadImagePopoverController = nil;
}

#pragma mark - DetailViewControllerDelegate

/*!
 * Build the currently open project.
 *
 * Passes the user's request to build the current project to the delegate.
 */

- (void) detailViewControllerDelegateBuildProject {
    [self build];
}

/*!
 * Open a project.
 *
 * The project must be in the sandbox. The name is the name of the project folder and the .side file. For example, if the
 * project name is foo, there must be a project file named <sandbox>/foo/foo.side.
 *
 * Opening a project wipes out information about the previously open project (but it should have been saved by this point).
 *
 * @param name		The name of the project to open.
 */

- (void) detailViewControllerDelegateOpenProject: (NSString *) name {
    // Get the various paths.
    project.name = name;
    project.path = [[Common sandbox] stringByAppendingPathComponent: name];
    project.sidePath = [project.path stringByAppendingPathComponent: [name stringByAppendingPathExtension: @"side"]];
    
    // Scan the .side file for files and the language.
    project.files = [[NSMutableArray alloc] init];
    NSArray *lines = [[NSString stringWithContentsOfFile: project.sidePath 
                                                encoding: NSUTF8StringEncoding 
                                                   error: nil] componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        if ([line stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
            if ([line characterAtIndex: 0] == '>') {
                NSString *command = [line substringFromIndex: 1];
                if ([[command lowercaseString] hasPrefix: @"compiler="]) {
                    command = [[command substringFromIndex: 9] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if ([command caseInsensitiveCompare: @"C"] == NSOrderedSame)
                        project.language = languageC;
                    else if ([command caseInsensitiveCompare: @"CPP"] == NSOrderedSame)
                        project.language = languageCPP;
                    else
                        project.language = languageSpin;
                }
            } else {
                NSString *path = [project.path stringByAppendingPathComponent: line];
                if ([[NSFileManager defaultManager] fileExistsAtPath: path])
                    [project.files addObject: line];
            }
        }
    }
    
    // Remove old text. This keeps setting the language from taking a long time, and also clears the console.
    DetailViewController *detailViewController = [DetailViewController defaultDetailViewController];
    [detailViewController.sourceConsoleSplitView.sourceView setSource: @"" forPath: nil];

    detailViewController.sourceConsoleSplitView.consoleView.text = @"";
    
    // Set the language in the UI.
    [self changeLanguage: project.language];
        
    // Select and open the initial file.
    detailViewController.sourceConsoleSplitView.sourceView.language = project.language;
    if (project.files.count > 0) {
        NSString *path = [project.path stringByAppendingPathComponent: project.files[0]];
        NSError *error = nil;
        NSStringEncoding encoding = 0;
        NSString *source = [NSString stringWithContentsOfFile: path usedEncoding: &encoding error: &error];
        if (error) {
            [Common reportError: error];
        } else {
            [detailViewController.sourceConsoleSplitView.sourceView setSource: source forPath: path];
        }
    }
    
    // Repaint the table with the new file list.
    [namesTableView reloadData];
}

/*!
 * Run the currently open project.
 *
 * Passes the user's request to run the current project to the delegate.
 *
 * @param sender		The UI component that triggered this call. Used to position the popover.
 */

- (void) detailViewControllerDelegateRunProject: (UIView *) sender {
    if (loadImagePopoverController == nil && xbeePopoverController == nil)
        if ([self build]) {
            // Create the controller and add the root controller.
            LoadImageViewController *loadImageController = [[LoadImageViewController alloc] initWithNibName: @"LoadImageViewController"
                                                                                                     bundle: nil];
            loadImageController.delegate = self;
            
            // Create the popover.
            UIPopoverController *loadImagePopover = [[NSClassFromString(@"UIPopoverController") alloc]
                                                     initWithContentViewController: loadImageController];
            [loadImagePopover setPopoverContentSize: loadImageController.view.frame.size];
            CGRect viewSize = loadImageController.view.frame;
            [loadImagePopover setPopoverContentSize: viewSize.size];
            [loadImagePopover setDelegate: self];
            
            // Display the popover.
            self.loadImagePopoverController = loadImagePopover;
            [self.loadImagePopoverController presentPopoverFromRect: sender.bounds
                                                             inView: sender
                                           permittedArrowDirections: UIPopoverArrowDirectionUp
                                                           animated: YES];
            
            // Begin the load.
            [loadImageController performSelectorInBackground: @selector(load:) withObject: binaryFile];
        }
}

/*!
 * Seelct an XBee device.
 *
 * Passes the user's request to select an XBee device to the delegate.
 *
 * @param sender		The UI component that triggered this call. Used to position the popover.
 */

- (void) detailViewControllerDelegateXBeeProject: (UIView *) sender {
    if (loadImagePopoverController == nil && xbeePopoverController == nil) {
        // Create the controller and add the root controller.
        ConfigurationViewController *configurationController = [[ConfigurationViewController alloc] initWithNibName: @"ConfigurationViewController"
                                                                                                             bundle: nil];
        
        // Create the popover.
        UIPopoverController *xbeePopover = [[NSClassFromString(@"UIPopoverController") alloc]
                                            initWithContentViewController: configurationController];
        [xbeePopover setPopoverContentSize: configurationController.view.frame.size];
        CGRect viewSize = configurationController.view.frame;
        [xbeePopover setPopoverContentSize: viewSize.size];
        [xbeePopover setDelegate: self];
        
        // Display the popover.
        self.xbeePopoverController = xbeePopover;
        [self.xbeePopoverController presentPopoverFromRect: sender.bounds
                                                    inView: sender
                                  permittedArrowDirections: UIPopoverArrowDirectionUp
                                                  animated: YES];
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
    return 2;
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
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    if (section == 0) {
        cell.textLabel.text = [@"   " stringByAppendingString: project.files[row]];
    } else
        cell.textLabel.text = @""; // TODO: Once we have other files, return the name of the file here.
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
    int count = 0;
    if (section == 0 && project)
        count = project.files.count;
    else if (section == 1)
        count = 0; // TODO: Once we can load files, put the number of files loaded here.
    return count;
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

/*!
 * Asks the data source for the title of the header of the specified section of the table view.
 *
 * The table view uses a fixed font style for section header titles. If you want a different font style, return 
 * a custom view (for example, a UILabel object) in the delegate method tableView:viewForHeaderInSection: instead.
 *
 * @param tableView		The table-view object asking for the title.
 * @param section		An index number identifying a section of tableView.
 *
 * @return				A string to use as the title of the section header. If you return nil , the section will 
 *						have no title.
 */

- (NSString *) tableView: (UITableView *) tableView titleForHeaderInSection: (NSInteger) section {
    if (section == 0) {
        if (project == nil || project.name == nil)
            return @"Project:";
        else
            return [NSString stringWithFormat: @"Project: %@", project.name];
    }
    return @"Other open files:";
}

@end
