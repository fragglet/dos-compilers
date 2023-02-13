/* stdio.h - standard i/o header file for C86
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-oct-85,go over to ANSI naming conventions"
#pragma REVISED "zap,1-nuv-85,change fputc (again)"
#pragma REVISED "zap,20-may-86,new opening conventions"
#pragma REVISED "zap,29-aug-86,new definition of NULL"
#pragma REVISED "zap,24-mar-87,remove v2 open() defines and sharing defines"
#pragma REVISED "zap,10-apr-87,_IOFBF et. al."
#endif

#ifndef _stdioh 
#define _stdioh

#include <sys/types.h>

#ifndef NULL
#define NULL ((void *)0)
#endif

#define NUL '\0'	/* standard end of string */
#define EOS '\0'	/* end of string - v2 */

#define BUFSIZ 512
#define SYS_OPEN 20
#define TMP_MAX 25
#define L_tmpnam 8
#define FILE   struct _iobuf
#define EOF    (-1)

extern FILE {
  unsigned char *_ptr;
  int  _cnt;
  char *_base;
  char _flag;
  char _fd;
} _iob[SYS_OPEN];

#define stdin  (&_iob[0])
#define stdout (&_iob[1])
#define stderr (&_iob[2])
#define stdaux (&_iob[3])
#define stdprn (&_iob[4])

int getc(FILE *);
#define getc(s)   (((s)->_cnt-->0) ? ((unsigned char)(*(s)->_ptr++)) : _filbuf(s))

int putc(char , FILE *);
#ifdef _CIISAFE
#define putc(c,s) ((s)->_c=(c),(s)->_c!='\n' && ((s)->_cnt-->0) \
                       ? (*((s)->_ptr++)=(s)->_c) : _flsbuf((s)->_c,(s)))
#else
#ifdef _LINE_BUF	/* line buffering */
#define putc(c,s) ((c)!='\n' && ((s)->_cnt-->0) \
                       ? (*((s)->_ptr++)=(c)) : _flsbuf((c),(s)))
#else
#define putc(c,s) ((--(s)->_cnt>=0) \
                       ? (*((s)->_ptr++)=(c)) : _flsbuf((c),(s)))
#endif
#endif

int getchar(void);
#define getchar()  getc(stdin)
int putchar(char );
#define putchar(c) putc((c),stdout)
int ungetch(int );
#define ungetch(c) ungetc(c,stdin)

#define _IOREAD  0x01
#define _IOWRT   0x02
#define _IONBF   0x04
#define _IOMYBUF 0x08
#define _IOEOF   0x10
#define _IOERR   0x20
#define _IOLBF   0x40
#define _IORW    0x80

#define _IOFBF   0x00  /* neither line- nor character-buffering */

#define feof(f)   ((f)->_flag & _IOEOF)
#define ferror(f) ((f)->_flag & _IOERR)
#define fileno(f) ((f)->_fd)

/*  seek
 */
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

void clearerr(FILE *);
int  fclose(FILE *);
int  fcloseall(void);
FILE *fdopen(int , char *);
int  fflush(FILE *);
int  fgetc(FILE *);
int  fgetchar(void);
char *fgets(char *, int , FILE *);
int  flushall(void);
FILE *fopen(char *, char *);
int  fprintf(FILE *, char *, ...);
int  fputc(int , FILE *);
int  fputchar(int);
int  fputs(char *, FILE *);
size_t fread(char *, size_t , size_t , FILE *);
FILE *freopen(char *, char *, FILE *);
int  fscanf(FILE *, char *, ...);
int  fseek(FILE *, long , int );
long ftell(FILE *);
size_t fwrite(char *, size_t , size_t , FILE *);
char *gets(char *);
int  getw(FILE *);
int  printf(char *, ...);
int  puts(char *);
int  putw(int , FILE *);
void rewind(FILE *);
int  rmtmp(void);
int  scanf(char *, ...);
void setbuf(FILE *, char *);
int  setvbuf(FILE *, char *, unsigned , int );
int  sprintf(char *, char *, ...);
int  sscanf(char *, char *, ...);
char *tempnam(char *, char *);
FILE *tmpfile(void);
char *tmpnam(char *);
int  ungetc(int , FILE *);

#ifndef _va_list
#define _va_list
typedef char *va_list;
#endif

int  _doprnt(char *, va_list *, FILE *);
int  _doscan(char *, va_list *, FILE *);
int  vfprintf(FILE *, char *, va_list );
int  vprintf( char *, va_list );
int  vsprintf(char *,  char *, va_list );

#endif /* _stdioh */

