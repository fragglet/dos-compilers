/**
*
* This header file contains definitions associated with the lockf function.
*
**/

#define F_ULOCK 0	/* Unlock a region */
#define F_LOCK 1	/* Lock a region */
#define F_TLOCK 2	/* Test and lock a region */
#define F_TEST 3	/* Test if a region is locked */

extern int lockf(int,int,long); 

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
