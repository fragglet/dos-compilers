/* Many functions have reserved words and double words.
Use these to differentiate them from true zero values */
#define RESV_WORD	0
#define RESV_DWORD	0L

/* Special time values for timeouts */
#define ZEROTIME	0L
#define INFINITE	-1L
/* SECONDS can be used to build readable time as in 5*SECONDS or 250*MILLI
and will insure that a long is passed */
#define MILLI		1L
#define SECONDS		1000*MILLI
#define MINUTES		60*SECONDS
#define HOURS		60*MINUTES
#define DAYS		24*HOURS
#define WEEKS		7*DAYS

/* Scope for proc or thread id used in GET/SET priority calls*/
#define SCOPEPROC	0
#define SCOPEFAMILY	1
#define SCOPETHREAD	2

/* Priority classes */
#define NOCHANGE	0
#define IDLE		1
#define REGULAR		2
#define TIMECRIT	3

/* Options on DOSEXIT */
#define KILLSELF	0
#define KILLALL		1

/* Strategies for the DOSOPEN call */
#define EXISTS_FAIL	0
#define EXISTS_OPEN	1
#define EXISTS_CREATE	2
#define NOEXISTS_FAIL	0
#define NOEXISTS_CREATE	0x10

/* action codes for DOSOPEN */
#define EXISTED		1
#define CREATED		2
#define REPLACED	3

/* High end bit options for DOSOPEN mode can be used in
conjunction with values from FCNTL.H */
#define DASD		0x8000
#define UNBUFFERED	0x4000 /* Also used for DOSSETFHANDSTATE */
#define FAIL_ERRORS	0x2000 /* Also used for DOSSETFHANDSTATE */
#define INHERIT		0x80   /* Also used for DOSSETFHANDSTATE */
#define CLEAR_MODE	0x1f08 /* &'ed with result from DOSQFHANDSTATE to
				  clear fields that must be cleared as in 
				  (result & CLEAR_MODE)|INHERIT */

/* DOSOPEN share values, must choose one of these in mode value */
#define DENY_ALL	0x10
#define DENY_READ	0x20
#define DENY_WRITE	0x30
#define DENY_NONE	0x40

/* DOSOPEN access values, must chosse one of these in mode value */
#define READ_ONLY	0
#define WRITE_ONLY	1
#define READ_WRITE	2

#define EXCLUSIVE_MODE	DENY_ALL | READ_WRITE
#define SHARE_MODE	DENY_NONE | READ_WRITE
#define DEVICE_MODE	UNBUFFERED | EXCLUSIVE_MODE

/* Used in DOSQCURDIR call */
#define DEFAULT_DRIVE	0

/* Levels of info available from DOSQFSINFO */
#define FILE_SYS_STATS	1
#define VOL_LABLE_INFO	2

/* Choices for DOSSETVERIFY and DOSQVERIFY */
#define VERIFY_OFF	0
#define VERIFY_ON	1

/* Handle Types returned by DOSQHANDTYPE */
#define DISKFILE		0
#define DEVICE		1
#define PIPE		2
#define NETWORK		0x80
#define REMOTE_FILE	NETWORK|DISKFILE
#define REMOTE_DEVICE	NETWORK|DEVICE
#define REMOTE_PIPE	NETWORK|PIPE

/* Names for Code Pages */
#define US		437
#define MULTILINGUAL	850
#define PORTUGESE	860
#define FRCANADIAN	863
#define NORDIC		865

/* Specify which kind of DOSEXECPGM you wish */
#define SYNCH_EXEC	0
#define ASYNCH_NOSAVE	1
#define ASYNCH_SAVE	2
#define DEBUG_MODE	3
#define DETACHED	4
#define FROZEN		5

/* Resultcodes possible from DOSExecPgm and DOSCWAIT */
#define NORMAL_EXIT	0
#define HARD_ERROR	1
#define TRAP		2
#define KILLED		3

#define WAIT		0
#define NOWAIT		1

/* Choices for KBDCHARIN */
#define KBDWAIT		0
#define KBDNOWAIT	1

/* Allocation Sharing Flags */
#define SHAREGIVE	1
#define SHAREGET	2
#define DISCARDABLE	4

/* DOSBUFRESET Option */
#define ALLBUFFERS	0xffff

/* ChgFilePtr MoveType */
#define FROMFRONT	0
#define FROMCURRENT	1
#define FROMEND		2

/* QUEUE types */
#define FIFO		0
#define LIFO		1
#define PRIORITY	2

/* Semaphore Ownership */
#define EXCLUSIVE	0
#define NOEXCLUSIVE     1

/* KBDCHARIN values */
/* shift status */
#define SYSREQ		0x8000
#define CAPSLOCK	0x4000
#define NUMLOCK		0x2000
#define SCROLLLOCK	0x1000
#define RIGHTALT	0x0800
#define RIGHTCTRL	0x0400
#define LEFTALT		0x0200
#define LEFTCTRL	0x0100

#define INSERT_ON	0x0080
#define CAPSLOCK_ON	0x0040
#define NUMLOCK_ON	0x0020
#define SCROLLLOCK_ON	0x0010
#define EITHERALT	0x0008
#define EITHERCTRL	0x0004
#define LEFTSHIFT	0x0002
#define RIGHTSHIFT	0x0001

#define EITHERSHIFT	0x0003

/* VIO ANSI state */
#define ANSI_ON		1
#define ANSI_OFF	0

