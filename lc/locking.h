/**
*
* This header file defines the information needed to use the locking
* function, which is a XENIX-compatible file lock mechanism.
*
**/

#define LK_UNLCK 0	/* unlock a region */
#define LK_LOCK	1	/* lock a region */
#define LK_NBLCK 2	/* non-blocking lock */
#define LK_RLCK	3	/* lock a region for writing */
#define LK_NBRLCK 4	/* non-blocking lock for writing */

/**
*
* Define NULL if it's not already defined
*
*/
#ifndef NULL
#if SPTR
#define NULL 0			/* null pointer value */
#else
#define NULL 0L
#endif
#endif
