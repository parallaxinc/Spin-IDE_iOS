Spin IDE 1.0.0.12
-----------------

This project implements an IDE on iPads for programming Propeller based boards using an XBee radio to move the project binaries from the iPad to the Propeller board.

Changes in this release
-----------------------

1. Exported and imported projects now use the flie suffix zipspin rather than pzip.

2. The number of lines inthe terminal window is pinned to 8192 lines to improve responsiveness.

3. Control characters no longer scroll the edit view.

4. The edit view no longer scrolls if you anaully scroll to view specific text. Restore normal operation by scrolling to the insertion point.

5. Terminal control character 0x0C now clears characters to the left of hte current column, as well as all characters for the remainder of the view.

6. The Terminal pane now has TX and RX indicators.

7. Characters 0-7, 9, 11-12, 14-31 and 127-159 now display as spaces in the terminal views.

8. The terminal output window is now blue with white text.

9. The terminal input window is now white with black text.

10. There is now an indicator for text that appears without scrolling the window.

11. Scrolling the terminal view only occurs with a visible selection. You can manually scroll the view to look at somthing and new terminal output will not disturb you.

12. The software keyboard no longer hides the spin compiler options field.

13. When a scan for XBee devices is unsuccessful, an error dialog is shown and the IP address field is emptied.

14. When the Run button is pressed, the system looks for an XBee device. This scan takes about 7 seconds. If no device is found at all, the loader no longer retries the load, creating a faster abort in the case that no radio is available.

Other features and fixes needed for a solid release
---------------------------------------------------

1. Support download to EPROM, not just RAM.

Other features and fixes that would be nice someday
---------------------------------------------------

1. Support C, C++.

2. Allow sending/downloading files from an FTP site.

3. "Tour" mode that would point out major features and describe how to use the program's UI.

4. Sumbit iOS Changes to the Spin compiler as a repository branch.

5. Turn the loader into a library so it is easier to use in other iOS projects.
