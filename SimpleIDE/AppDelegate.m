//
//  AppDelegate.m
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/29/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html ).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import "AppDelegate.h"

#import "Common.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Place compiler files in the sandbox.
    NSString *sandboxPath = [Common sandbox];

    NSArray *files = [[NSArray alloc] initWithObjects: @"Hello_Message", nil];
    for (int i = 0; i < [files count]; ++i) {
        NSString *name  = [files objectAtIndex: i];
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource: name ofType: @"c"];
        NSString *destinationPath = [sandboxPath stringByAppendingPathComponent: [name stringByAppendingPathExtension: @"c"]];
        [[NSFileManager defaultManager] removeItemAtPath: destinationPath error: nil];
        [[NSFileManager defaultManager] copyItemAtPath: sourcePath toPath: destinationPath error: nil];
    }
    
    NSString *folder = [sandboxPath stringByAppendingPathComponent: @"libraries/Protocol/libsimplei2c/cmm"];
    [[NSFileManager defaultManager] createDirectoryAtPath: folder
                              withIntermediateDirectories: YES
                                               attributes: nil
                                                    error: nil];
    NSString *name  = @"simplei2c";
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource: name ofType: @"h"];
    NSString *destinationPath = [[folder stringByDeletingLastPathComponent] stringByAppendingPathComponent: [name stringByAppendingPathExtension: @"h"]];
    [[NSFileManager defaultManager] removeItemAtPath: destinationPath error: nil];
    [[NSFileManager defaultManager] copyItemAtPath: sourcePath toPath: destinationPath error: nil];
    name  = @"libsimplei2c";
    sourcePath = [[NSBundle mainBundle] pathForResource: name ofType: @"a"];
    destinationPath = [folder stringByAppendingPathComponent: [name stringByAppendingPathExtension: @"a"]];
    [[NSFileManager defaultManager] removeItemAtPath: destinationPath error: nil];
    [[NSFileManager defaultManager] copyItemAtPath: sourcePath toPath: destinationPath error: nil];
    
    folder = [sandboxPath stringByAppendingPathComponent: @"libraries/TextDevices/libsimpletext/cmm"];
    [[NSFileManager defaultManager] createDirectoryAtPath: folder
                              withIntermediateDirectories: YES
                                               attributes: nil
                                                    error: nil];
    files = [[NSArray alloc] initWithObjects: @"serial", @"simpletext", nil];
    for (int i = 0; i < [files count]; ++i) {
        NSString *name  = [files objectAtIndex: i];
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource: name ofType: @"h"];
        NSString *destinationPath = [[folder stringByDeletingLastPathComponent] stringByAppendingPathComponent: [name stringByAppendingPathExtension: @"h"]];
        [[NSFileManager defaultManager] removeItemAtPath: destinationPath error: nil];
        [[NSFileManager defaultManager] copyItemAtPath: sourcePath toPath: destinationPath error: nil];
    }
    name  = @"libsimpletext";
    sourcePath = [[NSBundle mainBundle] pathForResource: name ofType: @"a"];
    destinationPath = [folder stringByAppendingPathComponent: [name stringByAppendingPathExtension: @"a"]];
    [[NSFileManager defaultManager] removeItemAtPath: destinationPath error: nil];
    [[NSFileManager defaultManager] copyItemAtPath: sourcePath toPath: destinationPath error: nil];
    
    folder = [sandboxPath stringByAppendingPathComponent: @"libraries/Utility/libsimpletools/cmm"];
    [[NSFileManager defaultManager] createDirectoryAtPath: folder
                              withIntermediateDirectories: YES
                                               attributes: nil
                                                    error: nil];
    name  = @"simpletools";
    sourcePath = [[NSBundle mainBundle] pathForResource: name ofType: @"h"];
    destinationPath = [[folder stringByDeletingLastPathComponent] stringByAppendingPathComponent: [name stringByAppendingPathExtension: @"h"]];
    [[NSFileManager defaultManager] removeItemAtPath: destinationPath error: nil];
    [[NSFileManager defaultManager] copyItemAtPath: sourcePath toPath: destinationPath error: nil];
    name  = @"libsimpletools";
    sourcePath = [[NSBundle mainBundle] pathForResource: name ofType: @"a"];
    destinationPath = [folder stringByAppendingPathComponent: [name stringByAppendingPathExtension: @"a"]];
    [[NSFileManager defaultManager] removeItemAtPath: destinationPath error: nil];
    [[NSFileManager defaultManager] copyItemAtPath: sourcePath toPath: destinationPath error: nil];

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
