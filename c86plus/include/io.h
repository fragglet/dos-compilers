/* io.h - file access function prototypes
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifndef _ioh
#define _ioh

int  access(char *, int );
int  chmod(char *, unsigned );
int  chsize(int , long );
int  close(int );
int  creat(char *, int );
int  dup(int );
int  dup2(int , int );
int  eof(int );
long filelength(int );
int  isatty(int );
int  locking(int , unsigned , long );
long lseek(int , long , int );
long ltell(int );
char *mktemp(char *);
int  open(char *, unsigned , ...);
int  read(int , char *, unsigned );
int  remove(char *);
int  rename(char *, char *);
int  setmode(int , unsigned );
int  sopen(char *, unsigned , unsigned , ...);
long tell(int );
int  umask(int );
int  unlink(char *);
int  write(int , char *, unsigned );

#endif

