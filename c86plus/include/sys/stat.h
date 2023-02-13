/* stat.h - file stat structure
** Copyright (C) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-nov-86,major hack"
#pragma REVISED "zap,15-jan-87,change st_ino from long to short"
#endif

#ifndef _stath
#define _stath

#include <sys/types.h>

struct stat{
  int st_dev;  /* drive number */
  unsigned st_ino;  /* not used under DOS */
  unsigned st_mode;  /* directory or file */
  int st_nlink;  /* not used under DOS */
  int st_uid;  /* not used under DOS */
  int st_gid;  /* not used under DOS */
  int st_rdev;  /* sams as st_dev */
  long st_size;  /* size of the file in bytes */
  time_t st_atime;  /* time of last modification */
  time_t st_mtime;  /* same as st_atime */
  time_t st_ctime;  /* same as st_atime */
};

#define S_IFMT  0xE000 /* mask */
#define S_IFCHR 0x2000 /* character device */
#define S_IFDIR 0x4000 /* directory */
#define S_IFREG 0x8000 /* regular file */
/*  file access permission levels
 */
#define S_IREAD 0x100
#define S_IWRITE 0x80


int fstat(int , struct stat * );
int stat(char * , struct stat * );
/* file stamp structure used by sysint21
*/
struct ff_str { 
  char dummy[21];  /* reserved for dos */ 
  char attribute;  /* returned attribute */ 
  unsigned time; 
  unsigned date; 
  long size;      /* size of file */ 
  char fn[13];    /* string containing the filename */ 
}; 

#endif


