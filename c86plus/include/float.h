/* float.h - 8087 control function prototypes
** Copyright (c) 1986,87 Computer Innovations Inc,  ALL RIGHTS RESERVED.
*/

#ifndef _floath
#define _floath

unsigned _clear87(void);
unsigned _control87(unsigned , unsigned);
void     _fpreset(void);
unsigned _status87(void);

#endif

#define FLT_RADIX        2    /* radix of the floating point number e.g. a binary machine  */
#define FLT_ROUNDS       0    /* we chop on floating point computation */

#define FLT_DIG          6   /* maximum decimal digits of float precision */
#define FLT_EPSILON		 5.96046e-8
#define FLT_MANT_DIG     24
#define FLT_MAX			 3.40282e38
#define FLT_MAX_EXP      0x7F
#define FLT_MAX_10_EXP	 38
#define FLT_MIN			 1.17549e-38
#define FLT_MIN_EXP		 -125
#define FLT_MIN_10_EXP   -37

#define DBL_DIG          15  /* maximum decimal digits of double precision */
#define DBL_EPSILON		 1.110223024625156e-16
#define DBL_MANT_DIG     53
#define DBL_MAX			 1.797693134862315e308
#define DBL_MAX_EXP      0x3FF
#define DBL_MAX_10_EXP	 308
#define DBL_MIN			 2.225073858507202e-308
#define DBL_MIN_EXP		 -1021
#define DBL_MIN_10_EXP   -307

#define LDBL_DIG         18  /* max decimal digits of long double precisn */
#define LDBL_EPSILON		 2.710505431213760960e-20
#define LDBL_MANT_DIG    64
#define LDBL_MAX			 1.797693134862315e308   /** update later for LD **/
#define LDBL_MAX_EXP     0x3FFF
#define LDBL_MAX_10_EXP	 32766
#define LDBL_MIN			 2.225073858507202e-308  /** update later for LD **/
#define LDBL_MIN_EXP		 -16381
#define LDBL_MIN_10_EXP  -4931




