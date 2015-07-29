Spin IDE 1.0.0.12
-----------------

This project implements an IDE on iPads for programming Propeller based boards using an XBee radio to move the project binaries from the iPad to the Propeller board.

Changes in this release
-----------------------

1. A new mechanism is used for finding the local machine IP address. This should make the loader code more portable to other platforms.

2. If you delete a project while a file that is not in the project is currently open, that file is no longer close. The file will still be closed if it is in the project being deleted, of course.

3. You can now download to EEPROM, not just RAM.

Other features and fixes that would be nice someday
---------------------------------------------------

1. Support C, C++.

2. Allow sending/downloading files from an FTP site.

3. "Tour" mode that would point out major features and describe how to use the program's UI.

4. Sumbit iOS Changes to the Spin compiler as a repository branch.

5. Turn the loader into a library so it is easier to use in other iOS projects.
