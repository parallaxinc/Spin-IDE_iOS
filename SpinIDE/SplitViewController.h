//
//  SplitViewController.h
//  SpinIDE
//
//  Created by Mike Westerfield on 4/27/15.
//  Copyright (c) 2015 Parallax, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplitViewController : UISplitViewController <UISplitViewControllerDelegate>

@property (nonatomic, retain) UIBarButtonItem *barButtonItem;

+ (SplitViewController *) defaultSplitViewController;

@end
