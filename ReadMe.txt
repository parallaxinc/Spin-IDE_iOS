Spin IDE 1.0.0.6
----------------

This project implements an IDE on iPads for programming Propeller based boards using an XBee radio to move the project binaries from the iPad to the Propeller board.

The current build of the IDE supports opening a small number of sample projects, some of which are not yet useful because the IDE does not yet have a console. Start with Blink16-32; it does work, and you can see that it works because the LEDs on the Propeller board will blink.

You can create new projects, open samples, and delete or rename existing projects.

You can open fies from other projects and copy them into the current project, or duplicate files in the current project.

You can build a project locally, or connect to a configured XBee radio and run the project in RAM.

Changes in this release
-----------------------

1. The error message now shows the location of the error in the source view.

2. Large files now display and edit faster. It may take a while for formatting to show up, depending on the size of the file and the speed of the iPad, since the formatting is done on another thread and only displays when ytping pauses long enough for it to complete.

Other features and fixes needed for a solid release
---------------------------------------------------

1. Support a terminal.

2. Support download to EPROM, not just RAM.

3. The navigation control does not show up on main view until the program rotates to landscape once.

4. Support collapsing the side panel in landscape view.

5. Support different font sizes in the editor.

6. Allow emailing (in and out) of zipped spin projects.

7. Sumbit iOS Changes to the Spin comopiler as a repository branch.

Other features and fixes that would be nice someday
---------------------------------------------------

1. Turn the loader into a library so it is easier to use in other iOS projects.

2. Support C, C++.

3. Allow sending/downloading files from an FTP site.

4. "Tour" mode that would point out major features and describe how to use the program's UI.
