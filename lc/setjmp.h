/**
*
* This structure is used by the setjmp/longjmp functions to save the
* current environment on the 8086.
*
*/
struct JMP_BUF
	{
	long jmpret;		/* return address */
	int jmpbp;		/* BP register */
	int jmpsp;		/* SP register */
	int jmpds;		/* DS register */
	int jmpes;		/* ES register */
	};

typedef struct JMP_BUF jmp_buf[1];

#ifndef NARGS
extern int setjmp(jmp_buf);
extern void longjmp(jmp_buf, int);
#else
extern int setjmp();
extern void longjmp();
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
