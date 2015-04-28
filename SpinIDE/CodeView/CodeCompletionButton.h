//
//  CodeCompletionButton.h
//  iosBASIC
//
//  Created by Mike Westerfield on 4/24/15.
//  Copyright (c) 2015 Byte Works, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CodeCompletion.h"

@interface CodeCompletionButton : UIButton

@property (nonatomic, retain) CodeCompletion *codeCompletion;		// The code completion object for this button.

@end
