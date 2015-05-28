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

#import <AVFoundation/AVFoundation.h>

#import "Common.h"
#import "Loader.h"
#import "SplitView.h"
#import "XBeeCommon.h"

#define DEBUG_ME (0)
#define TEST_TERMINAL (0)

#define MAX_COLUMNS (256)
#define MAX_LINES (1024)
#define TAB_SIZE (8)

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

typedef struct {							// Used to strore cursor locations
    int x, y;
} cursorLocation;


static TerminalView *this;


@interface TerminalView () {
    int cursorCommand;						// When processing a multi-character terminal control sequence, this is the control character.
    int cursorPositionX;					// The x position when processing control character 2.
    int needsCursorPosition;				// Set to a non-zero value if a terminal control sequence needs additional characters.
}

@property (nonatomic, retain) NSCharacterSet *controlCharacters;	// The control characters recognized during terminal output.
@property (nonatomic, retain) SplitView *splitView;			// The split view that holds the terminal input and output views.
@property (nonatomic, retain) CodeView *terminalInputView;	// The view that shows terminal input.
@property (nonatomic, retain) CodeView *terminalOutputView;	// The view that shows terminal output.
@property (nonatomic, retain) GCDAsyncUdpSocket *udpDataSocket;	// A UDP socket manager object.
@property (nonatomic, retain) TXBee *xBee;					// The XBee device for sends.

@end



@implementation TerminalView

@synthesize baudRate;
@synthesize controlCharacters;
@synthesize echo;
@synthesize splitView;
@synthesize terminalInputView;
@synthesize terminalOutputView;
@synthesize udpDataSocket;
@synthesize xBee;

#pragma mark - Misc

/*!
 * Clear the terminal.
 */

- (void) clear {
    terminalInputView.text = @"";
    terminalOutputView.text = @"";
}

/*!
 * Do initializetion common to all initialization methods.
 */

- (void) initTermialCommon {
    self.splitView = [[SplitView alloc] initWithFrame: self.bounds];
    self.splitView.splitControl.splitTitle = @"Terminal      Input \u2191     Output \u2193";
    
    self.terminalInputView = [[CodeView alloc] initWithFrame: [splitView.topView frame]];
    terminalInputView.backgroundColor = [UIColor colorWithRed: 1.0 green: 1.0 blue: 0.8 alpha: 1.0];
    terminalInputView.codeViewDelegate = self;
    terminalInputView.followIndentation = NO;
    splitView.topView = terminalInputView;
    
    self.terminalOutputView = [[CodeView alloc] initWithFrame: [splitView.bottomView frame]];
    terminalOutputView.backgroundColor = [UIColor colorWithRed: 0.8 green: 0.8 blue: 1.0 alpha: 1.0];
    terminalOutputView.codeViewDelegate = self;
    terminalOutputView.editable = NO;
    terminalOutputView.followIndentation = NO;
    splitView.bottomView = terminalOutputView;
    
    splitView.location = 0.2;
    splitView.minimum = 0.1;
    splitView.maximum = 0.9;
    
    [self addSubview: splitView];
    
    self.baudRate = 115200;
    echo = YES;
    
    self.controlCharacters = [NSCharacterSet characterSetWithCharactersInString: @"\0\1\2\3\4\5\6\7\10\11\12\13\14\15\16\17\20"];
    
#if TEST_TERMINAL
    [self performSelectorInBackground: @selector(testTerminal) withObject: nil];
#endif
    
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
        else
            [Common reportError: err];
	}
    
    // Set the initial BAUD rate. This can be changed at any time using the baud configuration button.
    self.baudRate = baudRate;
}

/*!
 * Stop the terminal.
 */

- (void) stopTerminal {
    if (udpDataSocket != nil) {
        [udpDataSocket close];
        self.udpDataSocket = nil;
    }
}

#if TEST_TERMINAL
/*!
 * Test the terminal.
 */

- (void) testTerminal {
    // Give instructions.
    [self processTerminalOuput: 
     @"Size the terminal window so you can see at least 80 columns of text and 24\r"
     @"lines.\r"
     @"00000000001111111111222222222233333333334444444444555555555566666666667777777777\r"
     @"01234567890123456789012345678901234567890123456789012345678901234567890123456789\r"
     @"line 5\r"
     @"line 6\r"
     @"line 7\r"
     @"line 8\r"
     @"line 9\r"
     @"line 10\r"
     @"line 11\r"
     @"line 12\r"
     @"line 13\r"
     @"line 14\r"
     @"line 15\r"
     @"line 16\r"
     @"line 17\r"
     @"line 18\r"
     @"line 19\r"
     @"line 20\r"
     @"line 21\r"
     @"line 22\r"
     @"line 23\r"
     @"line 24\r"];
    
    // Test clear screen, beep.
    [NSThread sleepForTimeInterval: 15.0];
    [self processTerminalOuput: @"\0\7"];
    [terminalOutputView performSelectorOnMainThread: @selector(setNeedsDisplay) withObject: nil waitUntilDone: YES];
    
    // Test cursor positioning.
    [NSThread sleepForTimeInterval: 2.0];
    [self processTerminalOuput: 
     @"The screen should have cleared, and you should have heard a beep.\r"
     @"\r"
     @"Now check for cursor positioning. You should see a diagonal of 1 across a\r"
     @"field of 0. The last few will extend past the zeros, and the very last will\r"
     @"be on an otherwise blank line.\r"
     @"0000000000\r"
     @"0000000000\r"
     @"0000000000\r"
     @"0000000000\r"
     @"0000000000\r"
     @"0000000000\r"
     @"0000000000\r"
     @"0000000000\r"
     @"0000000000\r"
     @"0000000000\r"
     @"0000000000\r"
     @"0000000000\r"];
    [self processTerminalOuput: @"\2\0\5" @"1"];
    for (int i = 2; i <= 10; ++i) {
        [self processTerminalOuput: [NSString stringWithFormat: @"%c%c%c1", 2, i - 1, i + 4]];
    }
    for (int i = 11; i <= 13; ++i) {
        [self processTerminalOuput: @"\2"];
        [self processTerminalOuput: [NSString stringWithFormat: @"%c", i - 1]];
        [self processTerminalOuput: [NSString stringWithFormat: @"%c", i + 4]];
        [self processTerminalOuput: @"1"];
    }
    [terminalOutputView performSelectorOnMainThread: @selector(setNeedsDisplay) withObject: nil waitUntilDone: YES];
    
    // Test clear to end of line, backsapce and clear to end of screen.
    [NSThread sleepForTimeInterval: 9.0];
    [self processTerminalOuput: @"\1\13"];
    [self processTerminalOuput: @"\6\6\13"];
    [self processTerminalOuput: @"\6\13"];
    [self processTerminalOuput: @"\6\13"];
    [self processTerminalOuput: @"\2\0\6The 1 in the next line should be deleted."];
    [self processTerminalOuput: @"\2\3\7\10"];
    [self processTerminalOuput: @"\2\0\10Nothing should appear after the 1 in the following line."];
    [self processTerminalOuput: @"\2\5\11\13"];
    [self processTerminalOuput: @"\2\0\13Nothing should appear after the next 1, even on other lines."];
    [self processTerminalOuput: @"\2\10\14\14"];
    [terminalOutputView performSelectorOnMainThread: @selector(setNeedsDisplay) withObject: nil waitUntilDone: YES];
    
    // Test cursor movement with just X and Y and tabs.
    [NSThread sleepForTimeInterval: 9.0];
    [self processTerminalOuput: @"\1The following should have a diagonal of * across an otherwise\rblank screen.\14"];
    [self processTerminalOuput: @"\16\0\17\2*"];
    for (int i = 2; i <= 10; ++i) {
        [self processTerminalOuput: [NSString stringWithFormat: @"%c%c%c%c*", 14, i - 1, 15, i + 1]];
    }
    [self processTerminalOuput: @"\r\rThe following should be on 8 character tab stops.\r"];
    [self processTerminalOuput: @"        |       |       |       |       |\r"];
    [self processTerminalOuput: @"\t# \t#   \t#      \t#\t#\r"];
    [terminalOutputView performSelectorOnMainThread: @selector(setNeedsDisplay) withObject: nil waitUntilDone: YES];
    
    // Test cursor movement by direction.
    [NSThread sleepForTimeInterval: 9.0];
    [self processTerminalOuput: @"\1And now for a little spiral screen art.\14"];
    char ch = 'a';
    [self processTerminalOuput: @"\2\36\12a\3"];
    int count = 1;
    int total = 0;
    BOOL change = YES;
    int direction = 3;
    while (ch < 'z') {
        if (--count == 0) {
            if (change)
                ++total;
            count = total;
            change = !change;
            direction = (direction + 1)%4;
        }
        int dir = 0;
        switch (direction) {
            case 0: dir = 4; break;
            case 1: dir = 5; break;
            case 2: dir = 3; break;
            case 3: dir = 6; break;
        }
        [self processTerminalOuput: [NSString stringWithFormat: @"%c%c\3", dir, ++ch]];
    }
    [terminalOutputView performSelectorOnMainThread: @selector(setNeedsDisplay) withObject: nil waitUntilDone: YES];
}
#endif

#pragma mark - Setters

/*!
 * Set the BAUD rate.
 *
 * If the terminal has been started, this immediately updates the baud rate by sending a configuration command to the XBee.
 *
 * @param theBaudRate			The new BAUD rate.
 */

- (void) setBaudRate: (int) theBaudRate {
    baudRate = theBaudRate;
    if (udpDataSocket != nil) {
        Loader *loader = [Loader defaultLoader];
        NSError *err = nil;
        [loader validate: xbSerialBaud value: [loader baudToXBeeIndex: baudRate] readOnly: NO err: &err];
        if (err != nil)
            [Common reportError: err];
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

#pragma mark - Handling control characters

/*!
 * Find the cursor location as an x,y (column,line) index from the start of the terminal output window.
 *
 * @return				The cursor location.
 */

- (cursorLocation) findCursorLocation {
    cursorLocation loc;
    
    // Scan the text for complete lines before the current location. Update the column as we go.
    NSString *text = terminalOutputView.text;
    int index = 0;
    loc.y = 0;
    loc.x = (int) terminalOutputView.selectedRange.location;
    while (index < terminalOutputView.selectedRange.location) {
        loc.x = (int) terminalOutputView.selectedRange.location - index;
        NSRange searchRange;
        searchRange.location = index;
        searchRange.length = text.length - index;
        searchRange = [text rangeOfCharacterFromSet: [NSCharacterSet newlineCharacterSet] options: 0 range: searchRange];
        if (searchRange.location == NSNotFound)
            index = (int) text.length + 1;
        else {
            index = (int) searchRange.location + 1;
            if (index <= terminalOutputView.selectedRange.location) {
                ++loc.y;
                loc.x = 0;
            }
        }
    }
    
    return loc;
}

/*!
 * Returns the index of the first control character in a string.
 *
 * @param theText		The text to check.
 *
 * @return				The index of the first control character, or -1 if there are none.
 */

- (int) firstIndexOfControlCharacter: (NSString *) theText {
    int result = -1;
    NSRange range = [theText rangeOfCharacterFromSet: controlCharacters options: 0];
    if (range.location != NSNotFound)
        result = (int) range.location;
    return result;
}

/*!
 * See if a string has any control characters.
 *
 * @param theText		The text to check.
 *
 * @return				YES if theText has any control characters, else NO.
 */

- (BOOL) hasControlCharacters: (NSString *) theText {
    return [self firstIndexOfControlCharacter: theText] >= 0;
}

/*!
 * Send a control character to the terminal.
 *
 * Some control characters require additional input to position a cursor. If additional characters are needed, the
 * needsCursorPosition value is set to the number of characters still needed. Call this method with all characters 
 * until that value is 0.
 *
 * @param ch			The control caracter to send.
 */

- (void) handleControlCharacter: (int) ch {
    if (needsCursorPosition > 0) {
        switch (cursorCommand) {
            case 2: // Position cursor X,Y
                if (needsCursorPosition == 2) {
                    cursorPositionX = ch;
                    needsCursorPosition = 1;
                } else {
                    needsCursorPosition = 0;
                    [self setCursorPositionX: cursorPositionX y: ch];
                }
                break;
                
            case 14: { // Position cursor (x)
                needsCursorPosition = 0;
                cursorLocation loc = [self findCursorLocation];
                [self setCursorPositionX: ch y: loc.y];
                break;
            }
                
            case 15: { // Position cursor (y)
                needsCursorPosition = 0;
                cursorLocation loc = [self findCursorLocation];
                [self setCursorPositionX: loc.x y: ch];
                break;
            }
        }
    } else {
        switch (ch) {
            case 0: // Clear screen
            case 16: // Clear screen
                [terminalOutputView setText: @""];
                break;
                
            case 1: { // Home cursor
                NSRange range = {0, 0};
                [terminalOutputView setSelectedRange: range];
                break;
            }
                
            case 2: // Position cursor X,Y
                cursorCommand = ch;
                needsCursorPosition = 2;
                break;
                
            case 3: { // Move cursor left
                cursorLocation loc = [self findCursorLocation];
                if (loc.x > 0)
	                [self setCursorPositionX: loc.x - 1 y: loc.y];
                break;
            }
                
            case 4: { // Move cursor right
                cursorLocation loc = [self findCursorLocation];
                [self setCursorPositionX: loc.x + 1 y: loc.y];
                break;
            }
                
            case 5: { // Move cursor up
                cursorLocation loc = [self findCursorLocation];
                if (loc.y > 0)
                    [self setCursorPositionX: loc.x y: loc.y - 1];
                break;
            }
                
            case 6: // Move cursor down
            case 10: { // New line
                cursorLocation loc = [self findCursorLocation];
                [self setCursorPositionX: loc.x y: loc.y + 1];
                break;
            }
            
            case 7: // Beep
                AudioServicesPlaySystemSound(1106);
                break;
                
            case 8: // Backspace
                [terminalOutputView deleteBackward];
                break;
                
            case 9: { // Tab
                cursorLocation loc = [self findCursorLocation];
                int count = TAB_SIZE - loc.x%TAB_SIZE;
                NSString *spaces = @"";
                while (count--)
                    spaces = [spaces stringByAppendingString: @" "];
                [terminalOutputView insertText: spaces];
                break;
            }
            
            case 11: { // Clear to end of line
                NSRange range = terminalOutputView.selectedRange;
                NSString *text = terminalOutputView.text;
                while (range.location + range.length < text.length
                       && ![[NSCharacterSet newlineCharacterSet] characterIsMember: [text characterAtIndex: range.location + range.length]])
                    ++range.length;
                if (range.length > 0) {
                    [terminalOutputView setSelectedRange: range];
                    [terminalOutputView deleteBackward];
                }
                break;
            }
            
            case 12: { // Clear lines below
                NSRange range = terminalOutputView.selectedRange;
                range.length = terminalOutputView.text.length - range.location;
                if (range.length > 0) {
                    [terminalOutputView setSelectedRange: range];
                    [terminalOutputView deleteBackward];
                }
                break;
            }
            
            case 13: { // Carriage return
                cursorLocation loc = [self findCursorLocation];
                [self setCursorPositionX: 0 y: loc.y + 1];
                break;
            }
            
            case 14: // Position cursor (x)
            case 15: // Position cursor (y)
                cursorCommand = ch;
                needsCursorPosition = 1;
                break;
        }
    }
}

/*!
 * Send some characters to the terminal window. Handle control characters as we go.
 *
 * @param theText		The characters to send to the terminal window.
 */

- (void) processTerminalOuput: (NSString *) theText {
    // Check for control characters, giving them special treatment if found.
    if ([self hasControlCharacters: theText] || needsCursorPosition > 0) {
        while (theText.length > 0) {
            int index = [self firstIndexOfControlCharacter: theText];
            if (index == 0 || needsCursorPosition > 0) {
                [self handleControlCharacter: [theText characterAtIndex: 0]];
                theText = [theText substringFromIndex: 1];
            } else {
                if (index < 0)
                    index = (int) theText.length;
                NSString *text = [theText substringToIndex: index];
                NSRange range = terminalOutputView.selectedRange;
                int length = (int) text.length;
                int pos = (int) range.location;
                while (length-- && pos < terminalOutputView.text.length && [terminalOutputView.text characterAtIndex: pos] != '\n') {
                    ++range.length;
                    ++pos;
                }
                [terminalOutputView replaceRange: range withText: text];
                theText = [theText substringFromIndex: index];
            }
        }
    } else
        [terminalOutputView replaceRange: terminalOutputView.selectedRange withText: theText];
}

/*!
 * Set the cursor position in the terminal output window.
 *
 * If y is larger than the number of lines in the file, lines are added to accomodate the requested position.
 *
 * If x is larger than the number of characters in the line, spaces are added to the end of the line to accomodate the requested
 * position.
 *
 * The y position is pinned to MAX_LINES. The x position is pinned to MAX_COLUMNS.
 *
 * @param x			The horizontal offset.
 * @param y			The vertical offset.
 */

- (void) setCursorPositionX: (int) x y: (int) y {
    // Pin the input values.
    if (x > MAX_COLUMNS)
        x = MAX_COLUMNS;
    if (y > MAX_LINES)
        y = MAX_LINES;
    
    // Skip down to the appropriate line.
    int index = 0;
    NSRange searchRange = {0, 0};
    terminalOutputView.selectedRange = searchRange;
    while (y--) {
        searchRange.location = index;
        searchRange.length = terminalOutputView.text.length - index;
        searchRange = [terminalOutputView.text rangeOfCharacterFromSet: [NSCharacterSet newlineCharacterSet] options: 0 range: searchRange];
        if (searchRange.location == NSNotFound) {
            // There are not enough lines. Add one and set the selection to that point.
            NSRange range = {terminalOutputView.text.length, 0};
            [terminalOutputView replaceRange: range withText: @"\n"];
            ++range.location;
            terminalOutputView.selectedRange = range;
            index = (int) terminalOutputView.text.length;
        } else {
            // Next line.
            ++searchRange.location;
            searchRange.length = 0;
            terminalOutputView.selectedRange = searchRange;
            index = (int) searchRange.location;
        }
    }
    
    // Skip to the proper column.
    while (x--) {
        if (index >= terminalOutputView.text.length || [terminalOutputView.text characterAtIndex: index] == '\n') {
            NSRange range = {index, 0};
            [terminalOutputView replaceRange: range withText: @" "];
            ++index;
        } else {
            ++index;
            NSRange range = {index, 0};
            terminalOutputView.selectedRange = range;
        }
    }
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
    [self processTerminalOuput: string];
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
    BOOL result = YES;
    
    if (tView == terminalInputView) {
        // Handle text typed in the terminal input window.
        if (echo) {
            // Echo the characters to the terminal output window.
            terminalOutputView.editable = YES;
            [terminalOutputView insertText: text];
            terminalOutputView.editable = NO;
        }
        
        if (udpDataSocket != nil) {
            // Convert the string to a UTF8 data object with \r for end of line marks.
            NSString *text2 = [text stringByReplacingOccurrencesOfString: @"\n" withString: @"\r"];
            const char *utf8 = [text2 UTF8String];
            NSData *data = [NSData dataWithBytes: utf8 length: strlen(utf8)];
            
            // Set up the XBee serial transmission packet.
            txPacketPtr packet = [self prepareSerialBuffer: (int) data.length];
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
    }
    return result;
}

@end
