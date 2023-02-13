/* signal handling header file for C86
** Copyright (c) 1985,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifndef _signalh
#define _signalh

/** signal definitions
 **/

#define SIGABRT  0    /* abort - I assume that this is the UNIX "quit" */
#define SIGILL   1    /* illegal instruction signal */
#define SIGINT   2    /* ^C */
#define SIGALLOC 3    /* alloc, malloc, realloc */
#define SIGFREE  4    /* bad free pointer */
#define SIGTERM  5    /* terminate signal */
#define SIGREAD  6    /* read error */
#define SIGWRITE 7    /* write error */
#define SIGFPE   8    /* floating point exception signal */
#define SIGSEGV  9    /* segment violation signal */
#define SIGUSR1  10   /* user-defined signal */
#define SIGUSR2  11   /* user-defined signal */
#define SIGSIZE  12   /* number of defined signals */

extern void _sig_abrt_dfl(void);
extern void _sig_fpe_dfl(void);
extern void _sig_ill_dfl(void);
extern void _sig_int_dfl(void);
extern void _sig_segv_dfl(void);
extern void _sig_term_dfl(void);
extern void _sig_read_dfl(void);
extern void _sig_write_dfl(void);
extern void _sig_alloc_dfl(void);
extern void _sig_free_dfl(void);
extern void _sig_null(void);
extern void _sig_err_dummy(void);
extern void _sig_dfl_dummy(void);
extern void _sig_ign_dummy(void);

/** Signal vector arrays.
 **/
extern void (*_sig_eval[SIGSIZE])();
extern void (*_sig_dfl[SIGSIZE])();

/** Signal processing macros
 **/
#define  SIG_IGN  (_sig_ign_dummy)
#define  SIG_DFL  (_sig_dfl_dummy)
#define  SIG_ERR  (_sig_err_dummy)

void (*signal (int , void (*)(void)))() ;
int raise(int );

#endif

