/**
*
* The following structure is a UNIX file block that retains information about
* a file being accessed via the level 1 I/O functions.
*/
struct UFB
{
int ufbflg;		/* flags */
int ufbfh;		/* file handle */
};
#define NUFBS 20	/* number of UFBs defined */

/*
*
* UFB.ufbflg definitions
*
*/
#define UFB_RA 1	/* reading is allowed */
#define UFB_WA 2	/* writing is allowed */

/**
*
* External definitions
*
*/
#ifndef NARGS
extern struct UFB *chkufb(int);
#else
extern struct UFB *chkufb();
#endif

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


