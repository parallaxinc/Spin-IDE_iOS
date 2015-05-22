Spin IDE 1.0.0.10
-----------------

This project implements an IDE on iPads for programming Propeller based boards using an XBee radio to move the project binaries from the iPad to the Propeller board.

Changes in this release
-----------------------

1. The terminal is complete. The UI allows selection of BAUD rate, clearing the contents, and turning input echo on or off.

2. The terminal supports the following control characters:

    0x00: Clear screen
    0x01: Home Cursor (Moves the intersion point to the start of the window)
    0x02: Position X, Y (The next two bytes are used as the column & row index for the insertion point.)
    0x03: Move Left (The insterion point moves one column to the left, unless it is in column 0, in which case nothing happens.)
    0x04: Move right (The insertion point moves one column to the right, adding a blank if needed.)
    0x05: Move up (The insertion point moves up one line, adding spaces to the line above if needed to maintain the column.)
    0x06: Move down (The insertion point moves donw one line, adding lines and spaces if needed.)
    0x07: Beep (Plays a system beep.)
    0x08: Backspace (Deletes the character to the left of the insertion point, including linefeeds.)
    0x09: Tab (Inserts spaces to move text to the next 8 column mark.)
    0x0a: Line feed (Same as Move down)
    0x0b: Clear to end of line
    0x0c: Clear lines below (Clears to the end of hte current line, and removes all lines below the insertion point.)
    0x0d: Carriage return (Moves tot he first character in the next line, inserting a new line if needed.)
    0x0e: Position(x) (Uses the next byte as a column offset, moving the insertion point, adding spaces if needed.)
    0x0f: Position(y) (Uses the next byte as a row offset, moving the insertion point, adding lines and spaces if needed.)
    0x10: Clear screen

Other features and fixes needed for a solid release
---------------------------------------------------

1. Support download to EPROM, not just RAM.

2. Allow emailing (in and out) of zipped spin projects.

Other features and fixes that would be nice someday
---------------------------------------------------

1. Support C, C++.

2. Allow sending/downloading files from an FTP site.

3. "Tour" mode that would point out major features and describe how to use the program's UI.

4. Sumbit iOS Changes to the Spin compiler as a repository branch.

5. Turn the loader into a library so it is easier to use in other iOS projects.
