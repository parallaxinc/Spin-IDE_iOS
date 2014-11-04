//
//  DetailViewController.m
//  SimpleIDE
//
//	This singleton class controls the detail view for the app.
//
//  Created by Mike Westerfield on 4/29/14.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "DetailViewController.h"

#import "libpropeller-elf-cpp.h"
#import "NavToolBar.h"

typedef enum buttons {                                  // Indexes for the buttons on the button bar.
    newIndex, runIndex
} buttons;

// The number of buttons that can appear on the button bar.
#define buttonCount (1 + runIndex)


@interface DetailViewController () {
    BOOL initialized;								// Has the view been initialized?
    UIBarButtonItem *barButtons[buttonCount];		// The current bar buttons.
}

@property (nonatomic, retain) IBOutlet UIToolbar *tbToolbar;
@property (nonatomic, retain) UIView *toolBarView;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void) configureView;

@end


@implementation DetailViewController

@synthesize sourceView;
@synthesize sourceNavigationItem;
@synthesize tbToolbar;
@synthesize toolBarView;


#pragma mark - Managing the detail item

- (void) setDetailItem: (id) newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void) configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

/*!
 * Called after the controller’s view is loaded into memory.
 */

- (void) viewDidLoad {
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    [sourceView setHighlightedText: @"/*\n"
                        "  Hello Message.c\n"
                        "\n"
                        "  Version 0.94 for use with SimpleIDE 9.40 and its Simple Libraries\n"
                        "\n"
                        "  Display a hello message in the serial terminal.\n"
                        "\n"
                        "  http://learn.parallax.com/propeller-c-start-simple/simple-hello-message\n"
                        "*/\n"
                        "\n"
                        "#include \"simpletools.h\"                      // Include simpletools header\n"
                        "\n"
                        "int main()                                    // main function\n"
                        "{\n"
     					"  for(int i = 0; i < 10; ++i)\n"
                        "    print(\"Hello!!!\");                        // Display a message\n"
                        "}\n"]; // TODO: Remove
}

#pragma mark - Misc

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
 * Frees memory allocated by commandLineArgumentsFor:count:.
 *
 * @param args		The command line arguments to dispose of.
 * @param count		The number of command line arguments.
 */

- (void) freeCommandLineArguments: (char **) args count: (int) count {
    for (int i = 0; i < count; ++i)
        free(args[i]);
    free(args);
}

#pragma mark - Actions

- (void) newButtonAction {
    printf("Implement newButtonAction\n"); // TODO:
}

/*!
 * Handle a hit on the Run Program button.
 */

- (void) runProgramAction {
    int count;
    char **args = [self commandLineArgumentsFor: "propeller-elf-gcc -v" count: &count];
    maingcc(2, args);
    free(args);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *sandboxPath = [paths objectAtIndex: 0];
    NSString *source = [sandboxPath stringByAppendingPathComponent: @"Hello_Message.c"];
    NSString *outfile = [sandboxPath stringByAppendingPathComponent: @"cmm/Hello_Message.elf"];
    NSString *commandLine = [@"propeller-elf-gcc -I . -L . -I libraries/Utility/libsimpletools -L libraries/Utility/libsimpletools/cmm/ -I libraries/TextDevices/libsimpletext -L libraries/TextDevices/libsimpletext/cmm/ -I libraries/Protocol/libsimplei2c -L libraries/Protocol/libsimplei2c/cmm/ -o " stringByAppendingString: outfile];
    commandLine = [commandLine stringByAppendingString: @" -Os -mcmm -m32bit-doubles -fno-exceptions -std=c99 "];
    commandLine = [commandLine stringByAppendingString: source];
    commandLine = [commandLine stringByAppendingString: @" -lm -lsimpletools -lsimpletext -lsimplei2c -lm -lsimpletools -lsimpletext -lm -lsimpletools -lm"];
    args = [self commandLineArgumentsFor: [commandLine UTF8String] count: &count];
    for (int i = 0; i < count; ++i) printf("%2d: %s\n", i, args[i]);
    maingcc(count, args);
    free(args);
}

/*
 * Update the buttons on the button bar to match the ones selected in visibleButtons.
 */

- (void) updateButtons {
    // Build and show the new button bar.
    NSArray *barItems = [NSArray array];
    // TODO: Handle programs button    if (programsButton != nil)
    //        barItems = [barItems arrayByAddingObject: programsButton];
    for (int i = 0; i < buttonCount; ++i)
        if (barButtons[i] != nil)
            barItems = [barItems arrayByAddingObject: barButtons[i]];
    if (barItems.count > 0)
        [self.tbToolbar setItems: barItems animated: NO];
    self.navigationItem.titleView = self.tbToolbar;
    self.navigationItem.leftBarButtonItem = nil;
}


- (void) viewWillAppear: (BOOL) animated {
    if (!initialized) {
        // Add some color to the nav bar.
        self.navigationController.navigationBar.backgroundColor = [UIColor grayColor];
        
        // Create the default button bar items.
        
        // Make the content view controller the root view for the navigation item.
        self.tbToolbar = [[NavToolBar alloc] initWithFrame: CGRectMake(0, 0, 1024, 30)];
        if ([self.tbToolbar respondsToSelector: @selector(setBarTintColor:)]) {
            self.tbToolbar.barTintColor = [UIColor clearColor];
        }
        self.navigationItem.titleView = tbToolbar;
        self.navigationItem.leftBarButtonItem = nil;
        if ([self respondsToSelector: @selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
        // Add the bar buttons.
//        barButtons[newIndex] = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"newfile.png"]
//                                                                style: UIBarButtonItemStylePlain
//                                                               target: self
//                                                               action: @selector(newButtonAction)];
        barButtons[runIndex] = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"run_ipad.png"]
                                                                style: UIBarButtonItemStylePlain
                                                               target: self
                                                               action: @selector(runProgramAction)];
        
        initialized = YES;
    }
    
    // Miscellaneous setup.
    [self updateButtons];
    
    // Call super.
    [super viewWillAppear: animated];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
