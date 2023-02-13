/* share.h - file sharing permission levels
** Copyright (C) 1987 Computer Innovations, Inc.  ALL RIGHTS RESERVED
*/
#ifdef HISTORY
#pragma REVISED "zap,24-mar-87,created"
#endif

#define SH_COMPAT 0 /* compatibility */
#define SH_DENYRW 0x10 /* deny read and write */
#define SH_DENYWR 0x20 /* deny write */
#define SH_DENYRD 0x30 /* deny read */
#define SH_DENYNO 0x40 /* deny none */


