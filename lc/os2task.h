#ifndef OS2DEFS
typedef OS2API extern unsigned far pascal
#define OS2DEFS
#endif

struct Dos_ResultCodes
	{
	unsigned termcode;	/* termination code (or PID) */
	unsigned exitcode;	/* exit code (from child process) */
	};

struct Dos_PIDInfo
	{
	unsigned cpid;		/* current process ID */
	unsigned ctid;		/* current thread ID */
	unsigned ppid;		/* parent process ID */
	};		

struct Dos_SessionInfo
	{
	unsigned size;		/* structure size */
	unsigned relation;	/* 0=independent, 1=child */
	unsigned fgbg;		/* 0=foreground, 1=background */
	unsigned trace;		/* 0=no trace, 1=trace */
	char far *title;	/* program title */
	char far *name;		/* program name */
	char far *inputs;	/* program inputs */
	char far *qname;	/* name of termination queue */
	};
	
struct Dos_SessionStatus
	{
	unsigned size;		/* structure size */
	unsigned select;	/* select indicator */
	unsigned bond;		/* bond indicator */
	};

OS2API DosCreateThread (void (far *)(void),unsigned far *,unsigned char far *);
OS2API DosCWait (unsigned,unsigned,struct Dos_ResultCodes far *,unsigned far *,unsigned);
extern void far pascal DosEnterCritSec (void);
OS2API DosExecPgm (char far *,unsigned,unsigned,char far *,char far *,struct Dos_ResultCodes far *,char far *);
extern void far pascal DosExit (unsigned,unsigned);
extern void far pascal DosExitCritSec (void);
OS2API DosExitList (unsigned,void (far *)(void));
OS2API DosGetPID (struct Dos_PIDInfo far *);
OS2API DosGetPrty (unsigned,unsigned far *,unsigned);
OS2API DosKillProcess (unsigned,unsigned);
OS2API DosResumeThread (unsigned);
OS2API DosSelectSession (unsigned,unsigned long);
OS2API DosSetPrty (unsigned,unsigned,unsigned,unsigned);
OS2API DosSetSession (unsigned,struct Dos_SessionStatus far *);
OS2API DosStartSession (struct Dos_SessionInfo far *,unsigned far *,unsigned far *);
OS2API DosStopSession (unsigned,unsigned,unsigned long);
OS2API DosSuspendThread (unsigned);

#if OS2CAPS
#define DOSCREATETHREAD DosCreateThread
#define DosCWait DOSCWAIT
#define DOSENTERCRITSEC DosEnterCritSec
#define DOSEXECPGM DosExecPgm
#define DOSEXIT DosExit
#define DOSEXITCRITSEC DosExitCritSec
#define DOSEXITLIST DosExitList
#define DOSGETPID DosGetPid
#define DOSGETPRTY DosGetPrty
#define DOSKILLPROCESS DosKillProcess
#define DOSRESUMETHREAD DosResumeThread
#define DOSSELECTSESSION DosSelectSession
#define DOSSETPRTY DosSetPrty
#define DOSSETSESSION DosSetSession
#define DOSSTARTSESSION DosStartSession
#define DOSSTOPSESSION DosStopSession
#define DOSSUSPENDTHREAD DosSuspendThread
#endif