/* setjmp.h - define the set jump stuff
** Copyright (C) 1986 Computer Innovations, Inc. ALL RIGHTS RESERVED
*/

#ifndef _setjmph
#define _setjmph

typedef int jmp_buf[9];

void longjmp(jmp_buf , int );
int setjmp(jmp_buf );

#endif

