/* process.h - process control function prototypes
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifndef _processh
#define _processh

#define P_WAIT 	0
#define P_NOWAIT 	1
#define P_OVERLAY 2

void abort(void);
void exit(int );
void exit_tsr(void);
int  getpid(void);
int  system(char *);

#endif

