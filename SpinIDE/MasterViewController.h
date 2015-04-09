//
//  MasterViewController.h
//  SpinIDE
//
//  Created by Mike Westerfield on 4/8/15.
//  Copyright (c) 2015 Parallax, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;


@end

