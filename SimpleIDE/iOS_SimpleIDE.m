//
//  iOS_SimpleIDE.c
//  SimpleIDE
//
//	This is hte interface between the GCC compiler and iOS. THis is needed because, for securty reasons, iOS does not
// 	allow apps to run external executables. The normal external executables have been modified so they can be called
//	directly, and the internal calls to execute the files have been redirected through these files to allow the iOS
//	app to call those programs.
//
//  Created by Mike Westerfield on 11/7/14 at the Byte Works, Inc (http://www.byteworks.us/Byte_Works/Consulting.html).
//  Copyright (c) 2014 Parallax. All rights reserved.
//

#include "iOS_SimpleIDE.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "pex-common.h"

#import "Common.h"

// Main entry point for cc1.
extern int toplev_main (int, char * const *);

// Main entry point for gas.
extern int toplev_as_main (int, char * const *);

// Main entry point for ld.
extern int toplev_ldmain (int, char * const *);

#define DEBUG_GCC YES

/* Prepare to execute one or more programs, with standard output of
 each program fed to standard input of the next.
 FLAGS	As above.
 PNAME	The name of the program to report in error messages.
 TEMPBASE	A base name to use for temporary files; may be NULL to
 use a random name.
 Returns NULL on error.  */

static struct pex_obj pex;

/* Clean up a pex_obj.  If you have not called pex_get_times or
 pex_get_status, this will try to kill the subprocesses.  */

extern void ios_ex_free (struct pex_obj *obj) {
#if DEBUG_GCC
    printf("ios_ex_free\n");
#endif
}

/* Prepare to execute one or more programs, with standard output of
 each program fed to standard input of the next.
 FLAGS	As above.
 PNAME	The name of the program to report in error messages.
 TEMPBASE	A base name to use for temporary files; may be NULL to
 use a random name.
 Returns NULL on error.  */

extern struct pex_obj *ios_ex_init (int flags, const char *pname,
                                    const char *tempbase)
{
#if DEBUG_GCC
    printf("ios_ex_init:\n");
    printf("      flags: %d\n", flags);
    printf("      pname: %s\n", pname);
    printf("   tempbase: %s\n", tempbase ? tempbase : "<null>");
#endif
    return &pex;
}

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
                               int *err)
{
#if DEBUG_GCC
    printf("ios_ex_run  :\n");
    printf("         obj: %08X\n", (int) obj);
    printf("       flags: %d\n", flags);
    printf("  executable: %s\n", executable ? executable : "<null>");
    printf("        argv:");
    char * const *argv2 = argv;
    while (*argv2)
        printf(" %s", *argv2++);
    printf("\n");
    printf("     outname: %s\n", outname ? outname : "<null>");
    printf("     errname: %s\n", errname ? errname : "<null>");
#endif
    
    // Count the arguments.
    int argc = 0;
    char * const *argv3 = argv;
    while (*argv3++)
        ++argc;
    
    if (strcmp(executable, "cc1") == 0) {
        // The compiler is calling cc1. Redirect this call to toplev_main, the gcc-defined alternate
        // entry point for cc1. (See propgcc/gcc/gcc/main.c.)
// TODO:        toplev_main (argc, argv);
    } else if (strcmp(executable, "as") == 0) {
        // The compiler is calling gas. Redirect this call to toplev_as_main, the alternate
        // entry point for gas. (See propgcc/binutils/gas/as.c and propgcc/binutils/gas/toplev_as_main.c.)
// TODO:        toplev_as_main (argc, argv);
    } else if (strcmp(executable, "ld") == 0) {
        // The compiler is calling ld. Redirect this call to toplev_ldmain, the alternate
        // entry point for ld. (See propgcc/binutils/gas/toplev_ldmain.c.)
        
// TODO:        char **argv4 = (char **) malloc(sizeof(char *)*(argc + 2));
//        for (int i = 0; i < argc; ++i)
//            argv4[i] = argv[i];
//        argv4[argc++] = "-o";
//        char *outname = "a.out";
//        char *out = (char *) malloc(sizeof(char)*(strlen([Common csandbox]) + strlen(outname) + 1));
//        strcpy(out, [Common csandbox]);
//        strcat(out, outname);
//        argv4[argc++] = out;
//        printf("     added -o %s\n", out); // TODO: Remove
//        
//        toplev_ldmain (argc, argv4);
//        
//        free(argv4);
//        free(out);
    }
    
    // TODO: Remove the following debug code.
    char *o = NULL;
    for (int i = 0; i < argc; ++i)
        if (strcmp(argv[i], "-o") == 0) {
            o = argv[i + 1];
            break;
        }
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithCString: o encoding: NSUTF8StringEncoding]];
    printf("%s %s\n", o ? o : "<null>", exists ? "exists" : "does not exist");
    if (exists) {
        FILE *f = fopen(o, "r");
        int ch = 1;
        int i = 0;
        printf("%04X: ", 0);
        while ((ch = fgetc(f)) != -1) {
            printf("%02X", ch);
            if (++i%16 == 0)
                printf("\n%04X: ", i);
            else if (i%4 == 0)
                putchar(' ');
        }
        putchar('\n');
        fclose(f);
        
        f = fopen(o, "r");
        ch = 1;
        while ((ch = fgetc(f)) != -1) {
            if (ch >= ' ' || ch == '\n' || ch == '\t')
                printf("%c", ch);
        }
        putchar('\n');
        fclose(f);
    }
    
    return NULL;
}

/*
 Returns the sandbox prefix for iOS.
 */

static char *sandbox_path = NULL;

extern const char *ios_sandbox () {
    if (sandbox_path == NULL) {
        const char *sandbox = [Common csandbox];
        sandbox_path = (char *) malloc(sizeof(char)*(2 + strlen(sandbox)));
        strcpy(sandbox_path, sandbox);
        if (sandbox_path[strlen(sandbox_path) - 1] != '/')
            strcat(sandbox_path, "/");
    }
    return sandbox_path;
}

/*
 Returns the prefix for the propeller-elf version-specific library in the sandbox.
 */

static char *sandbox_propeller_elf_path = NULL;

extern const char *ios_sandbox_propeller_elf () {
    if (sandbox_propeller_elf_path == NULL) {
        const char *sandbox = [Common csandbox];
        const char *propeller_elf = "propeller-elf/4.6.1/";
        sandbox_propeller_elf_path = (char *) malloc(sizeof(char)*(2 + strlen(sandbox) + strlen(propeller_elf)));
        strcpy(sandbox_propeller_elf_path, sandbox);
        if (sandbox_propeller_elf_path[strlen(sandbox_propeller_elf_path) - 1] != '/')
            strcat(sandbox_propeller_elf_path, "/");
        strcat(sandbox_propeller_elf_path, propeller_elf);
    }
    return sandbox_propeller_elf_path;
}
