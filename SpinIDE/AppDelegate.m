//
//  AppDelegate.m
//  SpinIDE
//
//  Created by Mike Westerfield on 4/8/15.
//  Copyright (c) 2015 Parallax, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"

#import "Common.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
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
