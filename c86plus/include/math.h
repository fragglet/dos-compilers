/* math and trig definitions
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,28-apr-86,add header, copyright, struct complex"
#pragma REVISED "zap,7-may-86,add 2 typedefs, idiv_t and ldiv_t"
#pragma REVISED "nlp,21-jan-87,idiv_t -> div_t idiv() -> div()"
#pragma REVISED "zap,3-feb-87,creation of _math.h"
#pragma REVISED "zap,12-aug-87,move the div functions to stdlib"
#pragma REVISED "zap,9-oct-87,conditional definitions of some stuff"
#endif

#ifndef _mathh
#define _mathh

#ifndef HUGE_VAL
#define HUGE_VAL 1e308
#endif

#ifndef EDOM
#define EDOM   33  /* arg not in domain of function */
#endif

#ifndef ERANGE
#define ERANGE 34  /* result too large */
#endif

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

struct complex{
  double x,y;
};

double acos(double );
double asin(double );
double atan(double );
double atan2(double ,double);
double cabs(struct complex );
double cos(double );
double sin(double );
double tan(double );
double cotan(double );
double cosh(double );
double sinh(double );
double tanh(double );
double exp(double );
double frexp(double ,int *);
double hypot(double , double );
double ldexp(double ,int );
double log(double );
double log10(double );
double modf(double ,double *);
double pow(double, double );
double square(double );
double sqrt(double );
double ceil(double );
double fabs(double );
double floor(double );
double fmod(double,double);
double j0(double);
double j1(double);
double jn(int, double);
double y0(double);
double y1(double);
double yn(int, double);
#endif


