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


@interface TerminalView : UIView <CodeViewDelegate, GCDAsyncUdpSocketDelegate>

@property (nonatomic) int baudRate;							// The terminal BAUD rate.
@property (nonatomic) BOOL echo;							// Echo terminal input to the output window?.

- (void) clear;
+ (TerminalView *) defaultTerminalView;
- (void) startTerminal: (TXBee *) theXBee;
- (void) stopTerminal;

@end
