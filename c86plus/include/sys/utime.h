/* basic struct for utime()
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,17-nov-85,recreation"
#endif

struct utimbuf{
  time_t actime;  /* time of last access - not available under DOS */
  time_t modtime;  /* time of last modification */
};

int utime(char * , struct utimbuf * );

