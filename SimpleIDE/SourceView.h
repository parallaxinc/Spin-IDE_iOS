//
//  SourceView.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 4/30/14.
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Common.h"

@interface SourceView : UITextView <UITextViewDelegate>

@property (nonatomic) languageType language;

- (void) setHighlightedText: (NSString *) text;

@end
