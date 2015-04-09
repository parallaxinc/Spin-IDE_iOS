//
//  ErrorViewController.h
//  Spin IDE
//
//  Created by Mike Westerfield on 2/25/15.
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ErrorViewController : UIViewController

@property (nonatomic, retain) NSString *errorMessage;
@property (nonatomic, retain) IBOutlet UITextView *errorTextView;

@end
