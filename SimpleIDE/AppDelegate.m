//
//  AppDelegate.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/29/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "AppDelegate.h"

#import "Common.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create projects for the various sample files.
    NSArray *sources = [[NSBundle mainBundle] pathsForResourcesOfType: @"spin" inDirectory: nil];
    NSString *sandboxPath = [Common sandbox];
    NSFileManager *manager = [NSFileManager defaultManager];
    for (NSString *path in sources) {
        NSError *error;
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

    sources = [[NSBundle mainBundle] pathsForResourcesOfType: @"c" inDirectory: nil];
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

    // Set up the split view controller.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)navigationController.topViewController;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
