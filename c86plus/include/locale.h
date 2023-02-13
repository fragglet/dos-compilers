/* locale.h - sort of an internal environment
** Copyright (C) 1987 Computer Innovations, Inc,  ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,12-aug-87,creation"
#pragma REVISED "gee,30-oct-87,localblock definition removed"
#endif

#ifndef _localeh
#define _localeh

#define LC_ALL 0
#define LC_COLLATE 1
#define LC_CTYPE 2
#define LC_NUMERIC 3
#define LC_TIME 4
#define LC_MAX 5

char *setlocale(int, char *);

#endif
