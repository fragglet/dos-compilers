#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

struct Dos_CtryCode
	{
	unsigned cc;	/* country code */
	unsigned cp;	/* code page */
	};

struct Dos_CtryInfo
	{
	unsigned cc;	/* country code */
	unsigned cp;	/* code page */
	short fdate;	/* date format */
			/* 0 => USA (m d y) */
			/* 1 => Europe (d m y) */
			/* 2 => Japan (d m y) */
	char curr[5];	/* currency symbol, null-terminated */
	char sthou[2];	/* thousands separator and null */
	char sdec[2];	/* decimal separator and null */
	char sdate[2];	/* date separator and null */
	char stime[2];	/* time separator and null */
	char fcurr;	/* currency format */
			/* Bit 0 => 0 if symbol precedes value */
			/*       => 1 if symbol follows value */
			/* Bit 1 => number of spaces between value */
			/*          and symbol */
	char dcurr;	/* number of decimals in currency */
	char ftime;	/* time format */
			/* Bit 0 => 0 if 12-hour clock */
			/*       => 1 if 24-hour clock */
	long resv2;	/* far pointer to case map function */
	char sdata[2];	/* data list separator and null */
	short resv3[5];	/* reserved */
	};

OS2API DosGetCtryInfo (unsigned,struct Dos_CtryCode far *,struct Dos_CtryInfo far *,unsigned far *);
OS2API DosGetDBCSEv (unsigned,struct Dos_CtryCode far *,char far *);
OS2API DosCaseMap (unsigned,struct Dos_CtryCode far *,char far *);
OS2API DosGetCollate (unsigned,struct Dos_CtryCode far *,char far *,unsigned far *);
OS2API DosGetCP (unsigned,unsigned far *,unsigned far *);
OS2API DosPFSActivate (unsigned,unsigned long far *,char far *,unsigned,unsigned,unsigned,unsigned long);
OS2API DosPFSCloseUser (char far *,unsigned,unsigned long);
OS2API DosPFSInit (unsigned far *,char far *,char far *,char far *,unsigned,unsigned long);
OS2API DosPFSQueryAct (char far *,unsigned far *,unsigned far *,unsigned,unsigned long);
OS2API DosPFSVerifyFont (char far *,unsigned,unsigned,unsigned long);
OS2API DosSetCP (unsigned,unsigned);
OS2API DosSetProcCP (unsigned,unsigned);

#if OS2CAPS
#define DOSGETCTRY INFO DosGetCtryInfo 
#define DOSGETDBCSEV DosGetDBCSEv 
#define DOSCASEMAP DosCaseMap 
#define DOSGETCOLLATE DosGetCollate 
#define DOSGETCP DosGetCP 
#define DOSPFSACTIVATE DosPFSActivate 
#define DOSPFSCLOSEUSER DosPFSCloseUser 
#define DOSPFSINIT DosPFSInit 
#define DOSPFSQUERYACT DosPFSQueryAct 
#define DOSPFSVERIFYFONT DosPFSVerifyFont 
#define DOSSETCP DosSetCP 
#define DOSSETPROCCP DosSetProcCP 
#endif


