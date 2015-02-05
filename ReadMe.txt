SimpleIDE 1.0.0.4
-----------------

This project implements an IDE on iPads for programming Propeller based boards using an XBee radio to move the project binaries from the iPad to the Propeller board.

The current build of the IDE supports opening a small number of sample projects, some of which are not yet useful because the IDE does not yet have a console. Start with Blink16-32; it does work, and you can see that it works because the LEDs on the Propeller board will blink.

You can create new projects, open samples, and delete or rename existing projects.

You can open fies from other projects and copy them into the current project, or duplicate files in the current project.

You can build a project locally, or connect to a configured XBee radio and run the project in RAM.

Changes in this release
-----------------------

1. You can now compile spin projects with multiple files.

2. Spin projects that have spaced in the file names work, now.

Other features and fixes needed for alpha
-----------------------------------------

1. The last line in a spin file is not always highlighted properly.

2. When a file is opened, the previous selection and position should be restored.

3. Temporarily hide the ability to create C projects (since we don't support them yet, anyway).

4. Support a standard library of spin objects.

5. Add cut/copy/paste/undo/redo. (These are available now as keyboard shortcuts on Bluetooth keyboards.)

6. Add find/replace.

7. Final code clean up.

Other features and fixes needed for a solid release
---------------------------------------------------

1. Support a terminal.

2. Get final artwork.

3. Display errors in a more friendly way.

4. Support download to EPROM, not just RAM.

5. The navigation control does not show up on main view until the program rotates to landscape once.

6. Allow use of user supplied compiler flags.

7. Opening and editing large files takes too long due to syntax coloring.

8. Support collapsing the side panel in landscape view.

9. Support different font sizes in the editor.

10. Allow emailing (in and out) of zipped spin projects.

Other features and fixes that would be nice someday
---------------------------------------------------

1. Turn the loader into a library so it is easier to use in other iOS projects.

2. Support C, C++.

3. Allow sending/downloading files from an FTP site.

4. "Tour" mode that would point out major features and describe how to use the program's UI.
