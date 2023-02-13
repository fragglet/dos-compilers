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

/**
*
* Level 3 memory allocation services
*
**/
#ifndef NARGS
extern char *malloc(unsigned);
extern char *calloc(unsigned,unsigned);
extern char *realloc(char*, unsigned);
extern int free(char *);
#else
extern char *malloc();
extern char *calloc();
extern char *realloc();
extern int free();
#endif

/**
*
* Level 2 memory allocation services
*
**/
#ifndef NARGS
extern int allmem(void);
extern char *getmem(unsigned);
extern char *getml(long);
extern int rlsmem(char *, unsigned);
extern int rlsml(char *, long);
extern int bldmem(int);
extern long sizmem(void);
extern long chkml(void);
extern void rstmem(void);
#else
extern char *getmem();
extern char *getml();
extern int rlsmem();
extern int rlsml();
extern int bldmem();
extern long sizmem();
extern long chkml();
extern void rstmem();
#endif

/**
*
* Level 1 memory allocation services
*
**/
#ifndef NARGS
extern char *sbrk(unsigned);
extern char *lsbrk(long);
extern void rbrk(void);
#else
extern char *sbrk();
extern char *lsbrk();
extern void rbrk();
#endif

/**
*
* Sort functions
*
*/
#ifndef NARGS
extern void dqsort(double *, int);
extern void fqsort(float *, int);
extern void lqsort(long *, int);
extern void qsort(char *, int, int, int (*)());
extern void sqsort(short *, int);
extern void tqsort(char **, int);
#else
extern void dqsort();
extern void fqsort();
extern void lqsort();
extern void qsort();
extern void sqsort();
extern void tqsort();
#endif

/**
*
* fork/exec functions
*
*/
#ifndef NARGS
extern int execl(char *, char *,);
extern int execv(char *, char **);
extern int execle(char *, char *,);
extern int execve(char *, char **, char **);
extern int execlp(char *, char *,);
extern int execvp(char *, char **);
extern int execlpe(char *, char *,);
extern int execvpe(char *, char **, char **);

extern int forkl(char *, char *,);
extern int forkv(char *, char **);
extern int forkle(char *, char *,);
extern int forkve(char *, char **, char **);
extern int forklp(char *, char *,);
extern int forkvp(char *, char **);
extern int forklpe(char *, char *,);
extern int forkvpe(char *, char **, char **);

extern unsigned int wait(void);
extern int system(char *);
#endif

/**
*
* Miscellaneous functions
*
*/
#ifndef NARGS
extern void abort(void);
extern char *argopt(int, char**, char *, int *, char *);
extern int atoi(char *);
extern long atol(char *);
extern void exit(int);
extern void _exit(int);
extern char *getenv(char *);
extern int getfnl(char *, char *, unsigned, int);
extern int getpid(void);
extern int iabs(int);
extern int isauto(char *);
extern int isdata(char *, unsigned);
extern int isdptr(char *);
extern int isheap(char *);
extern int ispptr(int(*)());
extern int isstatic(char *);
extern long labs(long);
extern int onexit(int(*)());
extern int putenv(char *);
extern int rand(void);
extern int rmvenv(char *);
extern void srand(unsigned);
extern long utpack(char *);
extern void utunpk(long, char *);
#else
extern void abort();
extern char *argopt();
extern int atoi();
extern long atol();
extern void exit();
extern void _exit();
extern char *getenv();
extern int getfnl();
extern int getpid();
extern int iabs();
extern int isauto();
extern int isdata();
extern int isdptr();
extern int isheap();
extern int ispptr();
extern int isstatic();
extern long labs();
extern int onexit();
extern int putenv();
extern int rand();
extern int rmvenv();
extern void srand();
extern long utpack();
extern void utunpk();
#endif


