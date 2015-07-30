Spin IDE 1.0.0.13
-----------------

This project implements an IDE on iPads for programming Propeller based boards using an XBee radio to move the project binaries from the iPad to the Propeller board.

Changes in this release
-----------------------

1. Fixed a bug in the EEPROM download machanism.

2. Added debug code to Loader.m to allow optional dumping of packets sent to and from the XBee.

Other features and fixes that would be nice someday
---------------------------------------------------

1. Support C, C++.

2. Allow sending/downloading files from an FTP site.

3. "Tour" mode that would point out major features and describe how to use the program's UI.

4. Sumbit iOS Changes to the Spin compiler as a repository branch.

5. Turn the loader into a library so it is easier to use in other iOS projects.
