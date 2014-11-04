//
//  DetailViewController.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/29/14.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "SourceView.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) IBOutlet SourceView *sourceView;
@property (nonatomic, retain) IBOutlet UINavigationItem *sourceNavigationItem;

@end
