/* malloc.h - memory management function prototypes
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,12-aug-87,add defines for malloc and free"
#endif

#ifndef _malloch
#define _malloch

#ifndef NULL
#define NULL ((void *)0)
#endif

void  _ffree(void far *);
void far  *_fmalloc(unsigned );
unsigned  _freect(unsigned );
unsigned  _msize(char *);
void  _nfree(void near *);
void near  *_nmalloc(unsigned );
void  *alloc(unsigned );
void  *alloca(unsigned );
void  *calloc(unsigned , unsigned );
void  free(char *);
unsigned long free_lst(void);
unsigned  free_max(void);
unsigned long free_mem(void);
void huge  *halloc(long , unsigned );
void  hfree(void huge *);
void  *malloc(unsigned );
void  *realloc(char *, unsigned );
void far  *sbrk(unsigned );
unsigned  stackavail(void);
void *_expand(char *,unsigned);

#ifndef _FLAGS_Od
#ifdef _FLAGS_An
#define malloc(x) _nmalloc(x)
#define free(p)   _nfree(p)
#define _msize(p) _nmsize(p)
#else
#define malloc(x) _fmalloc(x)
#define free(p)   _ffree(p)
#define _msize(p) _fmsize(p)
#endif
#endif
	
#endif

