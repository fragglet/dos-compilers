/**
*
* This header file contains definitions that are specific to the IBM-PC
* and equivalent clones.
*
**/

#ifndef NARGS
extern int isibmat(void);
extern int isibmjr(void);
extern int isibmpc(void);
extern unsigned pcvdevs(void);
extern unsigned pcmems(void);
extern unsigned pcmemx(void);
extern int pcngdr(int, char *, char *, int *);
extern int pcngmn(char *);
extern int pcngpi(int, char *);
extern int pcnrdr(char *);
extern int pcnsdr(int, char *, char *, int);
extern int pcnspi(int, char *, int);
extern unsigned pcvgvm(void);
extern int pcvsdp(int);
extern int pcvsrp(int);
extern unsigned pcmsvm(unsigned);
#else
extern int isibmat();
extern int isibmjr();
extern int isibmpc();
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
