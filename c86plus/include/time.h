/* basic struct for time(), asctime(), localtime()
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,4-nov-85,add header, copyright"
#endif

#ifndef _timeh
#define _timeh

#include <sys\types.h>

#define CLK_TCK 1
struct tm {
  int tm_sec;   /* seconds (0-59) */
  int tm_min;   /* minutes (0-59) */
  int tm_hour;  /* hours   (0-23) */
  int tm_mday;  /* days    (1-31) */
  int tm_mon;   /* months  (0-11) */
  int tm_year;  /* year - 1900    */
  int tm_wday;  /* day of week (sun = 0) */
  int tm_yday;  /* day of year (0-365)   */
  int tm_isdst; /* non-zero if DST       */
};
extern long _time();

char *asctime(struct tm *);
clock_t clock(void);
char *ctime(time_t *);
double difftime(time_t , time_t );
void ftime(struct timeb *);
struct tm *gmtime(time_t *);
struct tm *localtime(time_t *);
time_t time(time_t *);
void tzset(void);
time_t mktime(struct tm *);

extern int daylight;
extern long timezone;

#ifndef NULL
#define NULL ((void *)0)
#endif

#endif


