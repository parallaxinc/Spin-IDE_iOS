//
//  ShareViewController.h
//  SpinIDE
//
//  Created by Mike Westerfield on 5/26/15.
//  Copyright (c) 2015 Parallax, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareViewControllerDelegate <NSObject>

@optional

/*!
 * Tells the delegate the EMail button was tapped.
 */

- (void) shareViewControllerEMail;

/*!
 * Tells the delegate the print button was tapped.
 */

- (void) shareViewControllerPrint;

@end


@interface ShareViewController : UIViewController

@property (weak, nonatomic) id<ShareViewControllerDelegate> shareViewControllerDelegate;

- (IBAction) emailAction: (id) sender;
- (IBAction) printAction: (id) sender;

@end
