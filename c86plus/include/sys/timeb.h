/*  timeb.h
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

struct timeb{
  long time;
  unsigned short millitm;
  short timezone;
  short dstflag;
};

