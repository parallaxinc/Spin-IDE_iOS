Spin IDE 1.0.0.9
----------------

This project implements an IDE on iPads for programming Propeller based boards using an XBee radio to move the project binaries from the iPad to the Propeller board.

The current build of the IDE supports opening a small number of sample projects, some of which are not yet useful because the IDE does not yet have a console. Start with Blink16-32; it does work, and you can see that it works because the LEDs on the Propeller board will blink.

You can create new projects, open samples, and delete or rename existing projects.

You can open fies from other projects and copy them into the current project, or duplicate files in the current project.

You can build a project locally, or connect to a configured XBee radio and run the project in RAM.

Changes in this release
-----------------------

1. Rudamentary terminal support.

Other features and fixes needed for a solid release
---------------------------------------------------

1. Support options for the terminal.

2. Support download to EPROM, not just RAM.

3. Allow emailing (in and out) of zipped spin projects.

4. Sumbit iOS Changes to the Spin compiler as a repository branch.

5. Turn the loader into a library so it is easier to use in other iOS projects.

Other features and fixes that would be nice someday
---------------------------------------------------

1. Support C, C++.

2. Allow sending/downloading files from an FTP site.

3. "Tour" mode that would point out major features and describe how to use the program's UI.
