/* errno.h - error number definitions
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap, 9-oct-85,add this comment, copyright, DOS3 err numbers"
#pragma REVISED "zap,19-may-86,common conventions"
#endif

extern int errno;		/* contains the error indicator */

#define ENOENT 2	/* file or path not found */
#define E2BIG 7	/* size of argument too large */
#define ENOEXEC 8	/* file is not executable */
#define EBADF 9	/* invalid file descriptor */
#define ENOMEM 12	/* out of memory */
#define EACCES 13	/* file access denied */
#define EEXIST 17	/* file already exists */
#define EXDEV 18	/* attempt to move a file to a different device */
#define EINVAL 22	/* invalid argument or operation */
#define EMFILE 24	/* too many open files */
#define ENOSPC 28	/* device is full */

#ifndef EDOM
#define EDOM 33	/* argument out of range */
#endif
#ifndef ERANGE
#define ERANGE 34	/* result out of range */
#endif

#define EDEADLOCK 36	/* locking violation */
#define ESIGNAL 37	/* Bad signal vector */
#define EFREE 38		/* Bad free pointer */

#define _NUM_ERR_NUMS 39	/* for perror() */

