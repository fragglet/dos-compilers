/* internal math and trig definitions
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,3-feb-87,creation"
#pragma REVISED "zap,9-oct-87,functions return pointers, def of struct"
#endif

#ifndef __mathh
#define __mathh

double *_acos(double );
double *_asin(double );
double *_atan(double );
double *_cabs(double, double );
double *_cos(double );
double *_sin(double );
double *_tan(double );
double *_cotan(double );
double *_exp(double );
double *_log(double );
double *_log10(double );
double *_modf(double ,double *);
double *_pow(double, double );
double *_square(double );
double *_sqrt(double );
double *_ceil(double );
double *_floor(double );
double *_j0(double);
double *_j1(double);
double *_jn(int, double);
double *_y0(double);
double *_y1(double);
double *_yn(int, double);

#ifndef DOMAIN
#define DOMAIN 1  /* exception types for matherr() */
#define SING 2
#define OVERFLOW 3
#define UNDERFLOW 4
#define TLOSS 5
#define PLOSS 6

#endif

#ifndef _EXCEPTION_STR
#define _EXCEPTION_STR

struct exception{
  int type;
  char *name;
  double arg1, arg2, retval;
};

#endif

#endif

