//
//  ShareViewController.m
//  SpinIDE
//
//  Created by Mike Westerfield on 5/26/15.
//  Copyright (c) 2015 Parallax, Inc. All rights reserved.
//

#import "ShareViewController.h"


@implementation ShareViewController

@synthesize shareViewControllerDelegate;

#pragma mark - Actions

/*!
 * Handle a hit on the EMail Project button.
 *
 * @param sender			The button that triggered this call.
 */

- (IBAction) emailAction: (id) sender {
    if ([shareViewControllerDelegate respondsToSelector: @selector(shareViewControllerEMail)])
        [shareViewControllerDelegate shareViewControllerEMail];
}

/*!
 * Handle a hit on the Print File button.
 *
 * @param sender			The button that triggered this call.
 */

- (IBAction) printAction: (id) sender {
    if ([shareViewControllerDelegate respondsToSelector: @selector(shareViewControllerPrint)])
        [shareViewControllerDelegate shareViewControllerPrint];
}

@end
