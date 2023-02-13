/* stddef.h - This file contains "standard definitions" 
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,22-nov-85,creation"
#pragma REVISED "nlp,21-jan-87,fpos_t type"
#pragma REVISED "zap,12-aug-87,move types to sys/types.h"
#endif

#ifndef _stddefh
#define _stddefh

#include <sys/types.h>

#ifndef NULL
#define NULL ((void *)0)
#endif

#define offsetof(s_type, memb)  ((size_t)(char *)&((s_type *)0)->memb)

#ifndef errno
extern int errno;
#endif

#endif

