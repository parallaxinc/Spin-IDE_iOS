Spin IDE 1.0.0.7
----------------

This project implements an IDE on iPads for programming Propeller based boards using an XBee radio to move the project binaries from the iPad to the Propeller board.

The current build of the IDE supports opening a small number of sample projects, some of which are not yet useful because the IDE does not yet have a console. Start with Blink16-32; it does work, and you can see that it works because the LEDs on the Propeller board will blink.

You can create new projects, open samples, and delete or rename existing projects.

You can open fies from other projects and copy them into the current project, or duplicate files in the current project.

You can build a project locally, or connect to a configured XBee radio and run the project in RAM.

Changes in this release
-----------------------

The big change in this release is replacing Apple's UITextView with a new custom view that is optimized for program editing. This allowed us to do many things that are not supported by Apple's UIText View (that's not a criticism; it wasn't intended to support programming) and fix a lot of bugs that have been in UITextView on and off since iOS 6 (yes, that's a criticism). Please be especially viginant about reporting editor issues so we get any kinks out of the new editor.

1. Errors that are specific to a position in the source now show up as an alert over the appropriate spot in the source code.

2. The navigation control shows up on main view when the program rotates to landscape once.

3. Opening and editing large files now works quickly, event with syntax coloring.

4. You can use a pinch gesture to enlarge and shrink the source code font.

5. Large files edit faster. Don't blink. ;)

6. Many bluetooth keyboard shortcuts are now supported:

	a. The old stuff still works: Arrow keys move the selection, Command-C, -V, -X do copy, paste and cut, Command-Z and shift-Command-Z do undo and redo.

	b. Command with arrow keys moves the selection to the end or start of a line, or the end or start of a file.

	c. Option with arrow keys moves the selection by words or lines.

	d. Holding down the shift key while moving the selection with any of the above options extends the selection.

	e. Command-f opens the Find dialog.

	f. Command-g finds the next occurance of the last string entered it he Find dialog.

	g. Command-] shifts any selected line right by two spaces.

	h. Command-[ shifts any selected line left by two spaces (provided it has any spaces at the start, of course).

7. Using the mouse to extend a selection will now scroll the display.

8. Lines are no longer wrapped. Horizontal scrolling is supported to see the full line.

9. The screen follows the cursor in all known situations where it should do so.

Other features and fixes needed for a solid release
---------------------------------------------------

1. Support a terminal.

2. Support download to EPROM, not just RAM.

3. Support collapsing the side panel in landscape view.

4. Allow emailing (in and out) of zipped spin projects.

5. Sumbit iOS Changes to the Spin compiler as a repository branch.

6. Turn the loader into a library so it is easier to use in other iOS projects.

Other features and fixes that would be nice someday
---------------------------------------------------

1. Support C, C++.

2. Allow sending/downloading files from an FTP site.

3. "Tour" mode that would point out major features and describe how to use the program's UI.
