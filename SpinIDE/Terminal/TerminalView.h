//
//  TerminalView.h
//  SpinIDE
//
//  Created by Mike Westerfield on 4/10/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CodeView.h"
#import "GCDAsyncUdpSocket.h"
#import "TXBee.h"


@protocol TerminalViewDelegate <NSObject>

/*!
 * Characters were received from the device.
 *
 * @param string		The characters received.
 */

- (void) terminalViewCharactersReceived: (NSString *) string;

/*!
 * Characters were sent to the device.
 *
 * @param string		The characters sent.
 */

- (void) terminalViewCharactersSent: (NSString *) string;

@end


@interface TerminalView : UIView <CodeViewDelegate, GCDAsyncUdpSocketDelegate>

@property (nonatomic) int baudRate;							// The terminal BAUD rate.
@property (weak, nonatomic) id<TerminalViewDelegate> delegate;
@property (nonatomic) BOOL echo;							// Echo terminal input to the output window?.

- (void) clear;
+ (TerminalView *) defaultTerminalView;
- (void) startTerminal: (TXBee *) theXBee;
- (void) stopTerminal;

@end
