/* fcntl.h - file control options for the open function
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-mar-87,add v2 defines"
#pragma REVISED "zap,19-may-87,v2 defines to c86old.h"
#endif

#define  O_RDONLY  0x0000  /* read only */
#define  O_WRONLY  0x0001  /* write only */
#define  O_RDWR    0x0002  /* read/write, update mode */
#define  O_APPEND  0x0008  /* append mode */

#define  O_CREAT   0x0100  /* create and open file */
#define  O_TRUNC   0x0200  /* length is truncated to 0 */
#define  O_EXCL    0x0400  /* exclusive open, used with O_CREAT */

#define  O_TEXT    0x4000  /* ascii mode, <cr><lf> xlates, CNTL-Z */
#define  O_BINARY  0x8000  /* mode is binary (no translation) */



