//
//  TerminalView.m
//  SpinIDE
//
//	Implements the top level view for the terminal pane. This includes the button bar, terminal input pane and 
//	terminal output pane.
//
//  Created by Mike Westerfield on 4/10/15 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2015 Parallax, Inc. All rights reserved.
//

#import "TerminalView.h"

#import "Common.h"
#import "SplitView.h"
#import "XBeeCommon.h"

#define DEBUG_ME (1)

typedef struct {
    // Application Header
    UInt16 number1;							// Can be any random number.
    UInt16 number2;							// Must be number1 ^ 0x4242
    UInt8 packetID;							// Reserved (use 0)
    UInt8 encryptionPad;					// Reserved (use 0)
    UInt8 commandID;						// $00 = Data, $02 = Remote Command, $03 = General Purpose Memory Command, $04 = I/O Sample
    UInt8 commandOptions;					// Bit 0 : Encrypt (Reserved), Bit 1 : Request Packet ACK, Bits 2..7 : (Reserved)
    UInt8 xbData[0];						// The serial data. Allocate the struct with an appropriate number of bytes for the actual data.
} txPacket, *txPacketPtr;


static TerminalView *this;


@interface TerminalView ()

@property (nonatomic, retain) SplitView *splitView;			// The split view that holds the terminal input and output views.
@property (nonatomic, retain) CodeView *terminalInputView;	// The view that shows terminal input.
@property (nonatomic, retain) CodeView *terminalOutputView;	// The view that shows terminal output.
@property (nonatomic, retain) GCDAsyncUdpSocket *udpDataSocket;	// A UDP socket manager object.
@property (nonatomic, retain) TXBee *xBee;					// The XBee device for sends.
@end



@implementation TerminalView

@synthesize splitView;
@synthesize terminalInputView;
@synthesize terminalOutputView;
@synthesize udpDataSocket;
@synthesize xBee;

#pragma mark - Misc

/*!
 * Do initializetion common to all initialization methods.
 */

- (void) initTermialCommon {
    self.splitView = [[SplitView alloc] initWithFrame: self.bounds];
    
    self.terminalInputView = [[CodeView alloc] initWithFrame: [splitView.topView frame]];
    terminalInputView.backgroundColor = [UIColor colorWithRed: 1.0 green: 1.0 blue: 0.8 alpha: 1.0];
    terminalOutputView.editable = NO;
    terminalInputView.codeViewDelegate = self;
    splitView.topView = terminalInputView;
    
    self.terminalOutputView = [[CodeView alloc] initWithFrame: [splitView.bottomView frame]];
    terminalOutputView.backgroundColor = [UIColor colorWithRed: 0.8 green: 0.8 blue: 1.0 alpha: 1.0];
    terminalOutputView.editable = NO;
    splitView.bottomView = terminalOutputView;
    
    splitView.location = 0.2;
    splitView.minimum = 0.1;
    splitView.maximum = 0.9;
    
    [self addSubview: splitView];
    
    this = self;
}

/*!
 * Return the singleton instance of the terminal class.
 *
 * @param theXBee		Information about the XBee device.
 *
 * @return		The singleton instance of this class, or nil if it has not been created.
 */

+ (TerminalView *) defaultTerminalView {
    return this;
}

/*!
 * Prepare the Serial Data Command buffer. Data shuld be copied to the xbData field before sending the packet.
 *
 * @param dataSize			The number of bytes of data that will be sent.
 *
 * @return					The initialized command buffer. The caller is responsible for disposal with free.
 */

- (txPacketPtr) prepareSerialBuffer: (int) dataSize {
    txPacketPtr packet = malloc(sizeof(txPacket) + dataSize);
    packet->number1 = 0;
    packet->number2 = 0x4242;
    packet->packetID = 0;
    packet->encryptionPad = 0;
    packet->commandID = 0;
    packet->commandOptions = 0;
    return packet;
}

/*!
 * Start the terminal.
 *
 * @param theXBee		The XBee device for transmission. Reception will be from anything.
 */

- (void) startTerminal: (TXBee *) theXBee {
    // Remember the XBee device for sends.
    self.xBee = theXBee;
    
    // Set up the UDP data socket. This is the one that will receive data back from the Propeller board, and be used for
    // serial output.
    NSError *err = nil;
    if (!udpDataSocket) {
        udpDataSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate: self delegateQueue: dispatch_get_main_queue()];
        [udpDataSocket bindToPort: SERIAL_PORT error: &err];
        if (err == nil)
            [udpDataSocket beginReceiving: &err];
	}
}

- (void) stopTerminal {
    if (udpDataSocket != nil) {
        [udpDataSocket close];
        udpDataSocket = nil;
    }
}

#pragma mark - View Maintenance

/*!
 * Returns an object initialized from data in a given unarchiver.
 *
 * @param encoder		An archiver object.
 *
 * @return				self, initialized using the data in decoder.
 */

- (id) initWithCoder: (NSCoder *) decoder {
    self = [super initWithCoder: decoder];
    if (self) {
        [self initTermialCommon];
    }
    return self;
}

/*!
 * Returns an initialized object.
 *
 * @param frame			A rectangle defining the frame of the UISwitch object.
 *
 * @return				An initialized AccessorizedTextView object or nil if the object could not be initialized.
 */

- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame: frame];
    if (self) {
        [self initTermialCommon];
    }
    return self;
}

/*!
 * Specifies receiver’s bounds rectangle.
 *
 * @param frame			The new bounds.
 */

- (void) setBounds: (CGRect) bounds {
    splitView.bounds = bounds;
    [super setBounds: bounds];
}

/*!
 * Specifies receiver’s frame rectangle in the super-layer’s coordinate space.
 *
 * @param frame			The new frame.
 */

- (void) setFrame: (CGRect) frame {
    splitView.frame = frame;
    [super setFrame: frame];
}

#pragma mark - GCDAsyncUdpSocketDelegate

/*!
 * Called when the datagram with the given tag has been sent.
 *
 * @param sock		The object handling the UDP socket.
 * @param tag		An optional tag that was sent with the original write.
 */

- (void) udpSocket: (GCDAsyncUdpSocket *) sock didSendDataWithTag: (long) tag {
#if DEBUG_ME
    printf("udpSocket:didSendDataWithTag:%ld\n", tag);
#endif
}

/*!
 * Called when the socket has received the requested datagram.
 *
 * @param sock				The object handling the UDP socket.
 * @param data				The data received.
 * @param address			The address from which the data was received.
 * @param filterContext		The filter.
 */

- (void) udpSocket: (GCDAsyncUdpSocket *) sock
    didReceiveData: (NSData *) data
       fromAddress: (NSData *) address
 withFilterContext: (id) filterContext
{
#if DEBUG_ME
    printf("didReceiveData at %f from: ", CFAbsoluteTimeGetCurrent());
    //    for (int i = 0; i < address.length; ++i)
    //        printf("%02X", ((UInt8 *) address.bytes)[i]);
    //    printf(": ");
    for (int i = 0; i < address.length; ++i)
        printf(" %02X", ((UInt8 *) address.bytes)[i]);
    printf(": ");
    for (int i = 0; i < data.length; ++i)
        printf(" %02X", ((UInt8 *) data.bytes)[i]);
    printf("\n");
#endif
    // If this arrived from the serial port, add the text to the console output.
    NSMutableData *bytes = [NSMutableData dataWithData: data];
    int zero = 0;
    [bytes appendBytes: &zero length: 1];
    NSString *string = [NSString stringWithUTF8String: bytes.bytes]; 
    
    NSRange range = {terminalOutputView.text.length, 0};
    [terminalOutputView replaceRange: range withText: string];
    [terminalOutputView scrollRangeToVisible: terminalOutputView.selectedRange];
}

/*!
 * Called if an error occurs while trying to send a datagram. This could be due to a timeout, or something
 * more serious such as the data being too large to fit in a single packet.
 *
 * @param sock		The object handling the UDP socket.
 * @param tag		An optional tag that was sent with the original write.
 * @param error		The error.
 */

- (void) udpSocket: (GCDAsyncUdpSocket *)sock didNotSendDataWithTag: (long) tag dueToError: (NSError *) error {
#if DEBUG_ME
    printf("didNotSendDataWithTag: %ld dueToError: %s\n", tag, [error.localizedDescription cStringUsingEncoding: NSUTF8StringEncoding]);
#endif
}

#pragma mark - CodeViewDelegate

/*
 * Asks the delegate whether the specified text should be replaced in the text view.
 *
 * Parameters:
 *  tView -  The text view containing the changes.
 *	range - The current selection range.
 *	text - The text to insert.
 *
 * Returns: YES if the old text should be replaced by the new text; NO if the replacement operation should be aborted.
 */

- (BOOL) codeView: (CodeView *) tView shouldChangeTextInRange: (NSRange) range replacementText: (NSString *) text {
    if (udpDataSocket != nil) {
        // Convert the string to a UTF8 data object with \r for end of line marks.
        NSString *text2 = [text stringByReplacingOccurrencesOfString: @"\n" withString: @"\r"];
        const char *utf8 = [text2 UTF8String];
        NSData *data = [NSData dataWithBytes: utf8 length: strlen(utf8)];
        
        // Set up the XBee serial transmission packet.
        txPacketPtr packet = [self prepareSerialBuffer: data.length];
        [data getBytes: packet->xbData length: data.length];
        NSData *dataPacket = [[NSData alloc] initWithBytes: packet length: sizeof(txPacket) + data.length];
        free(packet);

        [udpDataSocket sendData: dataPacket toHost: xBee.ipAddr port: [XBeeCommon udpPort] withTimeout: 0.1 tag: 0];
#if DEBUG_ME
        printf("sending: ");
        for (int i = 0; i < dataPacket.length; ++i) {
            printf("%02X ", ((UInt8 *) dataPacket.bytes)[i]);
        }
        putchar('\n');
#endif
    }
    return YES;
}

@end
