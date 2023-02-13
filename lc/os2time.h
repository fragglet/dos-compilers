#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

struct Dos_DateTime
	{
	unsigned char hour;		/* hour (00 to 23) */
	unsigned char minute;		/* minute (00 to 59) */
	unsigned char second;		/* second (00 to 59) */
	unsigned char centisec;		/* hundredths (00 to 59) */
	unsigned char day;		/* day (01 to 31) */
	unsigned char month;		/* month (01 to 12) */
	unsigned short year;		/* year */
	short zone;			/* minutes from UTC */
	unsigned char dow;		/* day of week (0 for Sunday) */
	};
	

OS2API DosGetDateTime (struct Dos_DateTime far *);
OS2API DosSetDateTime (struct Dos_DateTime far *);
OS2API DosSleep (unsigned long);
OS2API DosTimerAsync (unsigned long,unsigned long,unsigned far *);
OS2API DosTimerStart (unsigned long,unsigned long,unsigned far *);
OS2API DosTimerStop (unsigned);

#if OS2CAPS
#define DOSGETDATETIME DosGetDateTime
#define DOSSETDATETIME DosSetDateTime
#define DOSSLEEP DosSleep
#define DOSTIMERASYNC DosTimerAsync
#define DOSTIMERSTART DosTimerStart
#define DOSTIMERSTOP DosTimerStop
#endif

