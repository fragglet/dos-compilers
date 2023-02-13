/* ctype.h - character tests
** Copyright (c) 1985,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifndef _ctypeh
#define _ctypeh

int isalnum(int );
int isalpha(int );
int isascii(int );
int iscntrl(int );
int iscsym(int );
int iscsymf(int );
int isdigit(int );
int isgraph(int );
int islower(int );
int isodigit(int );
int isprint(int );
int ispunct(int );
int isspace(int );
int isupper(int );
int isxdigit(int );
int toascii(int );
int tolower(int );
int toupper(int );

extern char _ctype[];

#define isalnum(c)  ((_ctype+1)[(int)(c)]&0x07)
#define isalpha(c)  ((_ctype+1)[(int)(c)]&0x03)
#define iscntrl(c)  ((_ctype+1)[(int)(c)]&0x20)
#define isdigit(c)  ((_ctype+1)[(int)(c)]&0x04)
#define isgraph(c)  ((_ctype+1)[(int)(c)]&0x17)
#define islower(c)  ((_ctype+1)[(int)(c)]&0x02)
#define isprint(c)  ((_ctype+1)[(int)(c)]&0x57)
#define ispunct(c)  ((_ctype+1)[(int)(c)]&0x10)
#define isspace(c)  ((_ctype+1)[(int)(c)]&0x08)
#define isupper(c)  ((_ctype+1)[(int)(c)]&0x01)
#define isxdigit(c) ((_ctype+1)[(int)(c)]&0x80)

#define _tolower(c) ((c)+'a'-'A')
#define _toupper(c) ((c)+'A'-'a')

#define isascii(c)  ((unsigned)(c)<=0x7f)
#define toascii(c)  ((c)&0x7f)

#endif /* _ctypeh */

