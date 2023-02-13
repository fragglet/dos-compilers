/* search.h - searching and sorting function prototypes
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifndef _searchh
#define _searchh

void *bsearch(void *, void *, unsigned , unsigned , int (*)());
void *lfind(void *, void *, unsigned *, unsigned , int (*)());
void *lsearch(void *, void *, unsigned *, unsigned , int (*)());
void qsort(void *, unsigned , unsigned , int (*)());
void wqsort(unsigned , int (*)(), int (*)(), char *);

#endif

