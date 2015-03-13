//
//  CodeView.h
//  Spin IDE
//
//  Created by Mike Westerfield on 3/4/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Common.h"

@interface CodeView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic) UIFont *font;						// The font for the view. This must be a monospaced font.
@property (nonatomic) languageType language;			// The language for the text in this view.
@property (nonatomic) NSRange selectedRange;			// The current selection.
@property (nonatomic, retain) NSString *text;			// The current contents of the view.

- (CGRect) firstRectForRange: (NSRange) range;
- (void) scrollRangeToVisible: (NSRange) range;

@end
