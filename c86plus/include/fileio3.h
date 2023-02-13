/* c86 header file for C86PLUS I/O system - internal to I/O source
** (not like stdio.h, which is a public header file)
** Copyright (c) 1985,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifndef _fileio3h
#define _fileio3h

/* defines for osfile (fd's) not used in streams
*/
#define  _IOTOUCHED 0x1000  /* for setvbuf */
#define  _IOAPPEND  0x2000
#define  _IOASCII   0x100
#define  _IODIRTY   0x200
#define  _IOCDEV    0x400
#define  _IOCONSOLE 0x800
	
extern int _osfile[];
extern int errno;

#ifndef SYS_OPEN
#include <stdio.h>
#endif
extern struct _piobuf{
  int __c;
  int _size;
  long _foffset;
} _piob[SYS_OPEN];

#define __READ 1
#define __WRITE 2

#include <assert.h>

#endif
