//
//  SourceConsoleSplitView.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/12/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import "SplitView.h"

#import "SourceView.h"

@interface SourceConsoleSplitView : SplitView

@property (nonatomic, retain) UITextView *consoleView;
@property (nonatomic, retain) SourceView *sourceView;

@end
