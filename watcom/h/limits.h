/***************************************************************************
 * FILE: limits.h/climits (Machine and OS limits)
 *
 * =========================================================================
 *
 *                          Open Watcom Project
 *
 * Copyright (c) 2004-2023 The Open Watcom Contributors. All Rights Reserved.
 * Portions Copyright (c) 1983-2002 Sybase, Inc. All Rights Reserved.
 *
 *    This file is automatically generated. Do not edit directly.
 *
 * =========================================================================
 *
 * Description: This header is part of the C/C++ standard library. It
 *              describes implementation limits.
 ***************************************************************************/
#ifndef _LIMITS_H_INCLUDED
#define _LIMITS_H_INCLUDED

#ifndef _ENABLE_AUTODEPEND
 #pragma read_only_file
#endif

#ifndef MB_LEN_MAX
 #define MB_LEN_MAX     2
#endif

/*
 *  ANSI required limits
 */
#define CHAR_BIT    8           /*  number of bits in a byte        */
#ifdef __CHAR_SIGNED__
 #define CHAR_MIN   (-128)      /*  minimum value of a char         */
 #define CHAR_MAX   127         /*  maximum value of a char         */
#else
 #define CHAR_MIN   0           /*  minimum value of a char         */
 #define CHAR_MAX   255         /*  maximum value of a char         */
#endif
#define SCHAR_MIN   (-128)      /*  minimum value of a signed char      */
#define SCHAR_MAX   127         /*  maximum value of a signed char      */
#define UCHAR_MAX   255         /*  maximum value of an unsigned char   */

#define SHRT_MIN    (-32767-1)  /*  minimum value of a short        */
#define SHRT_MAX    32767       /*  maximum value of a short        */
#ifdef _M_I86
 #define USHRT_MAX  65535U      /*  maximum value of an unsigned short  */
#else
 #define USHRT_MAX  65535       /*  maximum value of an unsigned short  */
#endif
#ifdef _M_I86
 #define INT_MIN    (-32767-1)      /* minimum value of an int          */
 #define INT_MAX    32767           /* maximum value of an int          */
 #define UINT_MAX   65535U          /* maximum value of an unsigned int */
#else
 #define INT_MIN    (-2147483647-1) /* minimum value of an int          */
 #define INT_MAX    2147483647      /* maximum value of an int          */
 #define UINT_MAX   4294967295U     /* maximum value of an unsigned int */
#endif
#define LONG_MIN    (-2147483647L-1L) /* minimum value of a long           */
#define LONG_MAX    2147483647L       /* maximum value of a long           */
#define ULONG_MAX   4294967295UL      /* maximum value of an unsigned long */
#if !defined( _NO_EXT_KEYS ) || __STDC_VERSION__ >= 199901L /* extensions enabled or C99 */
 #define LLONG_MIN  (-9223372036854775807LL-1LL) /* minimum value of a long long           */
 #define LLONG_MAX  9223372036854775807LL        /* maximum value of a long long           */
 #define ULLONG_MAX 18446744073709551615ULL      /* maximum value of an unsigned long long */
#endif /* extensions enabled */

#if !defined( _NO_EXT_KEYS ) /* extensions enabled */
 #define LONGLONG_MIN   (-9223372036854775807I64-1I64)
                                    /* minimum value of an __int64          */
 #define LONGLONG_MAX   9223372036854775807I64
                                    /* maximum value of an __int64          */
 #define ULONGLONG_MAX  18446744073709551615UI64
                                    /* maximum value of an unsigned __int64 */

 #define _I8_MIN    SCHAR_MIN       /* minimum value of a signed 8 bit type    */
 #define _I8_MAX    SCHAR_MAX       /* maximum value of a signed 8 bit type    */
 #define _UI8_MAX   255U            /* maximum value of an unsigned 8 bit type */

 #define _I16_MIN   SHRT_MIN        /* minimum value of a signed 16 bit type    */
 #define _I16_MAX   SHRT_MAX        /* maximum value of a signed 16 bit type    */
 #define _UI16_MAX  65535U          /* maximum value of an unsigned 16 bit type */

 #define _I32_MIN   LONG_MIN        /* minimum value of a signed 32 bit type    */
 #define _I32_MAX   LONG_MAX        /* maximum value of a signed 32 bit type    */
 #define _UI32_MAX  ULONG_MAX       /* maximum value of an unsigned 32 bit type */

 #define _I64_MIN   LONGLONG_MIN    /* minimum value of a signed 64 bit type    */
 #define _I64_MAX   LONGLONG_MAX    /* maximum value of a signed 64 bit type    */
 #define _UI64_MAX  ULONGLONG_MAX   /* maximum value of an unsigned 64 bit type */
#endif /* extensions enabled */

#define TZNAME_MAX  128             /*  The maximum number of bytes         */
                                    /*  supported for the name of a time    */
                                    /*  zone (not of the TZ variable).      */

#endif
