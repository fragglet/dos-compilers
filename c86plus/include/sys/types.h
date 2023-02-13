/* types.h - defined data types
** Copyright (C) 1987 Computer Innovations, Inc.  ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,12-aug-87,creation"
#endif

#ifndef _typesh
#define _typesh

typedef int ptrdiff_t;  /* result of pointer difference */
typedef int size_t;     /* result of sizeof operator */
typedef long fpos_t;    /* file position offset */
typedef int sig_atomic_t;  /* */
typedef struct{int quot,rem;} div_t;
typedef struct{long quot,rem;} ldiv_t;
typedef unsigned long clock_t;  /* returned by clock() */
#ifndef _time_t
#define _time_t
typedef unsigned long time_t;  /* returned by time() */
#endif
#endif

