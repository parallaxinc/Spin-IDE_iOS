///////////////////////////////////////////////////////////////
//                                                           //
// Propeller Spin/PASM Compiler Command Line Tool 'OpenSpin' //
// (c)2012-2013 Parallax Inc. DBA Parallax Semiconductor.    //
// See end of file for terms of use.                         //
//                                                           //
///////////////////////////////////////////////////////////////
//
// pathentry.cpp
//
// 18 Feb 2015, Mike Westerfield: Reset pNextPathEntry in 
//		CleanupPathEntries to make the compiler reentrant.
// 19 Feb 2015, Mike Westerfield: Added code to MakeNextPath
//		to handle case insensitive file names--but not path
//		names. The passed name is adjusted for case before the
//		function returns. Set CASE_SENSITIVE to 1 to disable
//		this code.
//
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "pathentry.h"

#define CASE_SENSITIVE 0

PathEntry *path = NULL;
static PathEntry **pNextPathEntry = &path;

static char lastfullpath[PATH_MAX];

int strcasecmp(char const *a, char const *b)
{
    for (;; a++, b++) {
        int d = tolower(*a) - tolower(*b);
        if (d != 0 || !*a)
            return d;
    }
}

const char *MakeNextPath(PathEntry **entry, const char *name)
{
    if (!*entry)
    {
        *entry = path;
    }
    else
    {
        *entry = (*entry)->next;
    }
    if (*entry)
    {
        char *caseName = (char *) name;
        if (!CASE_SENSITIVE) {
            DIR *dir;
            struct dirent *ent;
            if ((dir = opendir((*entry)->path)) != NULL) {
                while ((ent = readdir (dir)) != NULL) {
                    if (strcasecmp(ent->d_name, name) == 0)
                        caseName = ent->d_name;
                }
                closedir (dir);
            }
        }
        sprintf(lastfullpath, "%s%c%s", (*entry)->path, DIR_SEP, caseName);
        return lastfullpath;
    }
    return NULL;
}

bool AddPath(const char *path)
{
    PathEntry* entry = (PathEntry*)new char[(sizeof(PathEntry) + strlen(path))];
    if (!(entry))
    {
        return false;
    }
    strcpy(entry->path, path);
    *pNextPathEntry = entry;
    pNextPathEntry = &entry->next;
    entry->next = NULL;
    return true;
}

bool AddFilePath(const char *name)
{
    const char* end = strrchr(name, DIR_SEP);
    if (!end)
    {
        return false;
    }
    int len = (int)(end - name);
    PathEntry *entry = (PathEntry*)new char[(sizeof(PathEntry) + len)];
    if (!entry)
    {
        return false;
    }
    strncpy(entry->path, name, len);
    entry->path[len] = '\0';
    *pNextPathEntry = entry;
    pNextPathEntry = &entry->next;
    entry->next = NULL;

    return true;
}

void CleanupPathEntries()
{
    PathEntry *entry = path;
    while (entry != NULL)
    {
        PathEntry *nextEntry = entry->next;
        delete [] entry;
        entry = nextEntry;
    }
    path = NULL;
    lastfullpath[0] = 0;
    pNextPathEntry = &path;
}



///////////////////////////////////////////////////////////////////////////////////////////
//                           TERMS OF USE: MIT License                                   //
///////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this  //
// software and associated documentation files (the "Software"), to deal in the Software //
// without restriction, including without limitation the rights to use, copy, modify,    //
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    //
// permit persons to whom the Software is furnished to do so, subject to the following   //
// conditions:                                                                           //
//                                                                                       //
// The above copyright notice and this permission notice shall be included in all copies //
// or substantial portions of the Software.                                              //
//                                                                                       //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   //
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         //
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    //
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     //
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        //
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                //
///////////////////////////////////////////////////////////////////////////////////////////
