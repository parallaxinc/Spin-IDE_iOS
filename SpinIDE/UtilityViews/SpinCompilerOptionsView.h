//
//  SpinCompilerOptionsView.h
//  SimpleIDE
//
//  Created by Mike Westerfield on 1/8/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SpinCompilerOptionsViewDelegate <NSObject>

/*!
 * Called if the user taps Open or Cancel, this method passes the file selection information.
 *
 * @param options		The new compiler options.
 */

- (void) spinCompilerOptionsViewOptionsChanged: (NSString *) options;

@end


@interface SpinCompilerOptionsView : UIView <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITextField *compilerOptionsTextField;
@property (weak, nonatomic) id<SpinCompilerOptionsViewDelegate> delegate;

- (IBAction) optionsEditingChanged: (UITextField *) sender;

@end
