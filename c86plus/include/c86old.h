/* c86old.h - old functions and macros from C86 v2.30
** Copyright (c) 1986, 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,22oct85,Creation"
#pragma REVISED "zap,19may87,add abort, remove setmem and movmem"
#pragma REVISED "zap,8jun87,gets"
#pragma REVISED "zap,14jul87,remove toascii"
#pragma REVISED "zap,15jul87,move gets() macro to end"
#pragma REVISED "nlp,28jul87,abort"
#pragma REVISED "zap,27aug87,add localtim (as opposed to localtime)"
#endif

#define envfind(name)   getenv(name)
#define index(s,c)      strchr(s,c)
#define rindex(s,c)     strrchr(s,c)
#define unlink(name)    remove(name)
#define cfree(ptr)      free(ptr)
#define localtim(t)     localtime(t)

#ifndef stderr
#include <stdio.h>
#endif
#ifndef SIGABRT
#include <signal.h>
#endif
#define abort(mess)     {fputs(mess,stderr);  raise(SIGABRT);}

/*  C86 v2 I/O defines - this may not be exactly what you had in mind
 */
#ifndef O_RDONLY
#include <fcntl.h>
#endif
#ifndef S_IREAD
#include <sys/stat.h>
#endif
#define AREAD   (O_RDONLY | O_TEXT),   (S_IREAD | S_IWRITE)
#define AWRITE  (O_WRONLY | O_TEXT),   (S_IREAD | S_IWRITE)
#define AUPDATE (O_RDWR   | O_TEXT),   (S_IREAD | S_IWRITE)
#define BREAD   (O_RDONLY | O_BINARY), (S_IREAD | S_IWRITE)
#define BWRITE  (O_WRONLY | O_BINARY), (S_IREAD | S_IWRITE)
#define BUPDATE (O_RDWR   | O_BINARY), (S_IREAD | S_IWRITE)

#define gets(buf,len)	oldgets(buf,len)  /* must be defined after stdio.h */

