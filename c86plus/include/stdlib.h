/* stdlib.h
** Copyright (C) 1986,87 Computer Innovations, Inc. ALL RIGHTS RESERVED
*/
#ifdef HISTORY
#pragma REVISED "zap,12-aug-87,move in the div functions and sys/types.h"
#pragma REVISED "zap,12-aug-87,RAND_MAX"
#endif

#ifndef _stdlibh
#define _stdlibh

#include <sys/types.h>

#ifndef HUGE_VAL
#define HUGE_VAL 1e308
#endif

#ifndef ERANGE
#define ERANGE 34  /* result too large */
#endif

#ifndef RAND_MAX
#define RAND_MAX 0x7fff
#endif

int    abs(int);
double atof(char *);
int    atoi(char *);
long   atol(char *);
div_t  div(int ,int );
char   *ecvt(double , int , int *, int *);
char   *fcvt(double , int , int *, int *);
int    ftoa(double , char *, unsigned , unsigned );
char   *gcvt(double , int , int *, int *);
char   *getenv(char *);
char   *horse(void);
int    itoa(int , char *);
int    itoh(int , char *);
long   labs(long );
ldiv_t ldiv(long ,long );

#if 0
#error Following not legal yet
long long llabs(long long );
#endif

char   *ltoa(long , char * );
typedef int onexit_t;
onexit_t onexit(onexit_t *);
void   perror(char *);
char   *putenv(char *);
int    rand(void);
double strtod(char *, char **);
long   strtol(char *, char **, int );
void   swab(char *, char *, int );
char   *ultoa(unsigned long , char *, int );
int    utoa(unsigned , char *);

#endif  /* _stdlibh */

