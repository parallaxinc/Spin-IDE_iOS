//
//  TerminalOutputView.h
//  SpinIDE
//
//  Created by Mike Westerfield on 6/9/15.
//  Copyright (c) 2015 Parallax, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CodeView.h"

@interface TerminalOutputView : CodeView

@property (nonatomic, retain) UIColor *scrollIndicatorColor;
@property (nonatomic) BOOL showScrollDownIndicator;
@property (nonatomic) BOOL showScrollLeftIndicator;
@property (nonatomic) BOOL showScrollRightIndicator;
@property (nonatomic) BOOL showScrollUpIndicator;

@end
