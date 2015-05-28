//
//  AppDelegate.m
//  SpinIDE
//
//  Created by Mike Westerfield on 4/8/15.
//  Copyright (c) 2015 Parallax, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "ProjectViewController.h"

#import "Common.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

/*!
 * Asks the delegate to open a resource identified by URL.
 *
 * Your implementation of this method should open the specified URL and update its user interface accordingly. If your 
 * app had to be launched to open the URL, the app calls the application:willFinishLaunchingWithOptions: and
 * application:didFinishLaunchingWithOptions: methods first, followed by this method. The return values of those methods 
 * can be used to prevent this method from being called. (If the app is already running, only this method is called.)
 *
 * If the URL refers to a file that was opened through a document interaction controller, the annotation parameter may 
 * contain additional data that the source app wanted to send along with the URL. The format of this data is defined by 
 * the app that sent it but the data must consist of objects that can be put into a property list.
 *
 * Files sent to your app through AirDrop or a document interaction controller are placed in the Documents/Inbox directory 
 * of your app’s home directory. Your app has permission to read and delete files in this directory but does not have 
 * permission to write to them. If you want to modify a file, you must move it to a different directory first. In addition, 
 * files in that directory are usually encrypted using data protection. If the file is protected and the user locks the 
 * device before this method is called, you will be unable to read the file’s contents immediately. In that case, you 
 * should save the URL and try to open the file later rather than return NO from this method. Use the 
 * protectedDataAvailable property of the app object to determine if data protection is currently enabled.
 *
 * There is no matching notification for this method.
 *
 * @param application		The singleton app object.
 * @param url				The URL resource to open. This resource can be a network resource or a file. For information 
 *							about the Apple-registered URL schemes, see Apple URL Scheme Reference.
 * @param sourceApplication	The bundle ID of the app that is requesting your app to open the URL (url).
 * @param annotation		A property list object supplied by the source app to communicate information to the receiving 
 *							app.
 * @return					YES if the delegate successfully handled the request or NO if the attempt to open the URL 
 *							resource failed.
 */

- (BOOL) application: (UIApplication *) application
             openURL: (NSURL *) url
   sourceApplication: (NSString *) sourceApplication
          annotation: (id) annotation 
{
    ProjectViewController *projectViewController = [ProjectViewController defaultProjectViewController];
    [projectViewController openProject: url];
    return YES;
}

/*!
 * Tells the delegate that the launch process is almost done and the app is almost ready to run.
 *
 * Use this method (and the corresponding application:willFinishLaunchingWithOptions: method) to complete your app’s 
 * initialization and make any final tweaks. This method is called after state restoration has occurred but before 
 * your app’s window and other UI have been presented. At some point after this method returns, the system calls 
 * another of your app delegate’s methods to move the app to the active (foreground) state or the background state.
 *
 * This method represents your last chance to process any keys in the launchOptions dictionary. If you did not evaluate 
 * the keys in your application:willFinishLaunchingWithOptions: method, you should look at them in this method and 
 * provide an appropriate response.
 *
 * Objects that are not the app delegate can access the same launchOptions dictionary values by observing the notification 
 * named UIApplicationDidFinishLaunchingNotification and accessing the notification’s userInfo dictionary. That 
 * notification is sent shortly after this method returns.
 *
 * Important
 *
 * For app initialization, it is highly recommended that you use this method and the 
 * application:willFinishLaunchingWithOptions: method and do not use the applicationDidFinishLaunching: method, which 
 * is intended only for apps that run on older versions of iOS.
 * 
 * The return result from this method is combined with the return result from the 
 * application:willFinishLaunchingWithOptions: method to determine if a URL should be handled. If either method returns 
 * NO, the URL is not handled. If you do not implement one of the methods, only the return value of the implemented 
 * method is considered.
 */

- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions {
    // Create projects for the various sample files.
    NSArray *samples = [NSArray arrayWithObjects: @"Blank", @"Blink16-23", @"Blink16", @"Clock", @"ClockDemo", @"Float-Blink_Demo", 
                        @"FloatMath", @"FloatString", @"LargeSpinCode", @"Serial Terminal Demo", nil];
    NSMutableArray *sources = [[NSMutableArray alloc] init];
    for (NSString *name in samples)
        [sources addObject: [[NSBundle mainBundle] pathForResource: name ofType: @"spin"]];
    NSString *sandboxPath = [Common sandbox];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    for (NSString *path in sources) {
        NSString *projectName = [[path lastPathComponent] stringByDeletingPathExtension];
        NSString *destFolder = [sandboxPath stringByAppendingPathComponent: projectName];
        if (![manager fileExistsAtPath: destFolder]) {
            if ([manager createDirectoryAtPath: destFolder withIntermediateDirectories: YES attributes: nil error: &error]) {
                NSString *destinationPath = [destFolder stringByAppendingPathComponent: [path lastPathComponent]];
                [manager copyItemAtPath: path toPath: destinationPath error: &error];
                
                NSString *sideFile = [NSString stringWithFormat: @"%@\n>compiler=SPIN\n", [path lastPathComponent]];
                destinationPath = [destFolder stringByAppendingPathComponent: [projectName stringByAppendingPathExtension: @"side"]];
                [sideFile writeToFile: destinationPath atomically: NO encoding: NSUTF8StringEncoding error: &error];
            }
        }
    }
    
    sources = [NSMutableArray arrayWithArray: [[NSBundle mainBundle] pathsForResourcesOfType: @"c" inDirectory: nil]];
    for (NSString *path in sources) {
        NSString *projectName = [[path lastPathComponent] stringByDeletingPathExtension];
        NSString *destFolder = [sandboxPath stringByAppendingPathComponent: projectName];
        if (![manager fileExistsAtPath: destFolder]) {
            if ([manager createDirectoryAtPath: destFolder withIntermediateDirectories: YES attributes: nil error: nil]) {
                NSString *destinationPath = [destFolder stringByAppendingPathComponent: [path lastPathComponent]];
                [manager copyItemAtPath: path toPath: destinationPath error: nil];
                
                NSString *sideFile = [NSString stringWithFormat: @"%@\n>compiler=C\n", [path lastPathComponent]];
                destinationPath = [destFolder stringByAppendingPathComponent: [projectName stringByAppendingPathExtension: @"side"]];
                [sideFile writeToFile: destinationPath atomically: NO encoding: NSUTF8StringEncoding error: nil];
            }
        }
    }
    
    // Create the library folder.
    NSArray *libraries = [NSArray arrayWithObjects: @"4x4 Keypad Reader", @"AD8803", @"ADC", @"COILREAD", @"CTR", @"Clock", 
                          @"Debug_Lcd", @"Float32", @"Float32A", @"Float32Full", @"FloatMath", @"FloatString", @"FullDuplexSerial", 
                          @"Graphics", @"H48C Tri-Axis Accelerometer", @"HM55B Compass Module Asm", @"Inductor", @"Keyboard", 
                          @"License", @"MCP3208", @"MXD2125 Simple", @"MXD2125", @"Memsic2125_v1.2", @"Monitor", @"Mouse", 
                          @"Numbers", @"Parallax Serial Terminal", @"Ping", @"PropellerLoader", @"PropellerRTC_Emulator", 
                          @"Quadrature Encoder", @"RCTIME", @"RealRandom", 
                          @"SPI_Asm", @"SPI_Spin", @"Serial_Lcd", @"Servo32_Ramp_v2", @"Servo32v7", @"SimpleDebug", 
                          @"Simple_Numbers", @"Simple_Serial", @"Stack Length", @"StereoSpatializer", @"Synth", 
                          @"TV", @"TV_Terminal", @"TV_Text", 
                          @"VGA", @"VGA_512x384_Bitmap", @"VGA_HiRes_Text", @"VGA_Text", @"VocalTract", @"tsl230", 
                          @"vga_1280x1024_tile_driver_with_cursor", @"vga_1600x1200_tile_driver_with_cursor", nil];
    NSString *destinationFolder = [sandboxPath stringByAppendingPathComponent: SPIN_LIBRARY];
    if ([manager createDirectoryAtPath: destinationFolder withIntermediateDirectories: YES attributes: nil error: &error]) {
        for (NSString *name in libraries) {
            NSString *sourcePath = [[NSBundle mainBundle] pathForResource: name ofType: @"spin"];
            NSString *destinationPath = [destinationFolder stringByAppendingPathComponent: [name stringByAppendingPathExtension: @"spin"]];
            [[NSFileManager defaultManager] removeItemAtPath: destinationPath error: nil];
            [[NSFileManager defaultManager] copyItemAtPath: sourcePath toPath: destinationPath error: nil];
        }
    }
    
    // Set up the split view controller.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    if ([splitViewController respondsToSelector: @selector(displayModeButtonItem)])
	    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

@end
