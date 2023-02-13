/* string.h - string function prototypes
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifndef _stringh
#define _stringh

#include <sys/types.h>

char *lower(char *);
char *strcat(char *, char *);
char *strchr( char *, char );
int  strcmp( char *,  char *);
int  stricmp( char *,  char *);
char *strcpy(char *,  char *);
size_t strcspn( char *,  char *);
char *strdup( char *);
char *strerror( char *);
unsigned strlen( char *);
char *strlwr(char *);
char *strncat(char *,  char *, size_t );
int  strncmp( char *,  char *, unsigned );
char *strncpy(char *,  char *, size_t );
int  strnicmp( char *,  char *, size_t );
char *strnset(char *, char , size_t );
char *strpbrk( char *,  char *);
char *strpot(char *);
char *strrchr( char *, char );
char *strrev(char *);
char *strset(char *, char );
int  strspn( char *,  char *);
char *strstr( char *,  char *);
char *strtok(char *,  char *);
char *strupr(char *);
char *upper(char *);

#ifndef _ioh
#define _ioh

char *memccpy(char *, char *, char , unsigned );
char *memchr(char *, char , unsigned );
int  memcmp(char *, char *, unsigned );
char *memcpy(char *, char *, unsigned );
int  memicmp(char *, char *, unsigned );
char *memset(char *, char , unsigned );
void *memmove(char *, char *, size_t);
void movblock(unsigned , unsigned , unsigned , unsigned ,unsigned );
void movedata(int , int , int , int , unsigned );

#endif
#endif /* _stringh */

