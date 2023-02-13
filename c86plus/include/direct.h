/* direct.h - directory manipulation function prototypes
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifndef _directh
#define _directh

int  chdir(char *);
char *filedir(char *, int );
char *gcdir(char *);
char *getcwd(char *, int );
char *makefnam(char *, char *, char *);
int  mkdir(char *);
int  rmdir(char *);

#endif

