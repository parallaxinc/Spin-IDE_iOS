/* Hooks to iOS for use with Simple IDE.
   Copyright (C) 2014
   Free Software Foundation, Inc.
   Contributed by Mike Westerfield at the Byte Works, Inc. (mike@byteworks.us)

This file is part of GCC.

GCC is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

GCC is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with GCC; see the file COPYING3.  If not see
<http://www.gnu.org/licenses/>.  */

#define iOS 1

#include "libiberty.h"

/* Clean up a pex_obj.  If you have not called pex_get_times or
 pex_get_status, this will try to kill the subprocesses.  */

extern void ios_ex_free (struct pex_obj *);

/* Prepare to execute one or more programs, with standard output of
   each program fed to standard input of the next.
   FLAGS	As above.
   PNAME	The name of the program to report in error messages.
   TEMPBASE	A base name to use for temporary files; may be NULL to
   		use a random name.
   Returns NULL on error.  */

extern struct pex_obj *ios_ex_init (int flags, const char *pname,
				 const char *tempbase);

/* Execute one program.  Returns NULL on success.  On error returns an
   error string (typically just the name of a system call); the error
   string is statically allocated.

   OBJ		Returned by pex_init.

   FLAGS	As above.

   EXECUTABLE	The program to execute.

   ARGV		NULL terminated array of arguments to pass to the program.

   OUTNAME	Sets the output file name as follows:

		PEX_SUFFIX set (OUTNAME may not be NULL):
		  TEMPBASE parameter to pex_init not NULL:
		    Output file name is the concatenation of TEMPBASE
		    and OUTNAME.
		  TEMPBASE is NULL:
		    Output file name is a random file name ending in
		    OUTNAME.
		PEX_SUFFIX not set:
		  OUTNAME not NULL:
		    Output file name is OUTNAME.
		  OUTNAME NULL, TEMPBASE not NULL:
		    Output file name is randomly chosen using
		    TEMPBASE.
		  OUTNAME NULL, TEMPBASE NULL:
		    Output file name is randomly chosen.

		If PEX_LAST is not set, the output file name is the
   		name to use for a temporary file holding stdout, if
   		any (there will not be a file if PEX_USE_PIPES is set
   		and the system supports pipes).  If a file is used, it
   		will be removed when no longer needed unless
   		PEX_SAVE_TEMPS is set.

		If PEX_LAST is set, and OUTNAME is not NULL, standard
   		output is written to the output file name.  The file
   		will not be removed.  If PEX_LAST and PEX_SUFFIX are
   		both set, TEMPBASE may not be NULL.

   ERRNAME	If not NULL, this is the name of a file to which
		standard error is written.  If NULL, standard error of
		the program is standard error of the caller.

   ERR		On an error return, *ERR is set to an errno value, or
   		to 0 if there is no relevant errno.
*/

extern const char *ios_ex_run (struct pex_obj *obj, int flags,
			    const char *executable, char * const *argv,
			    const char *outname, const char *errname,
			    int *err);

/*
 Returns the sandbox prefix for iOS.
 */

extern const char *ios_sandbox ();

/*
 Returns the prefix for the propeller-elf version-specific library in the sandbox.
 */

extern const char *ios_sandbox_propeller_elf ();

