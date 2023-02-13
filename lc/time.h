/**
*
* This structure contains the unpacked time as returned by "gmtime".
*
*/
struct tm 
	{
	int tm_sec;
	int tm_min;
	int tm_hour;
	int tm_mday;
	int tm_mon;
	int tm_year;
	int tm_wday;
	int tm_yday;
	int tm_isdst;
	};

/**
*
* External data
*
*/
extern long timezone;
extern int daylight;
extern char *tzname[];
extern char tzstn[];
extern char tzdtn[];

/**
*
* The following kludge takes care of short/long name inconsistencies.
*
*/
#define localtime
#ifdef localtim
#undef localtim
#else
#undef localtime
#define localtime localtim
#endif

/**
*
* External functions
*
*/
#ifndef NARGS
extern char *asctime(struct tm *);
extern char *ctime(long *);
extern struct tm *gmtime(long *);
extern struct tm *localtim(long *);
extern long time(long *);
extern void tzset();
#else
extern char *asctime();
extern char *ctime();
extern struct tm *gmtime();
extern struct tm *localtim();
extern long time();
extern void tzset();
#endif

/*
*
* External variables
*
*/
extern int daylight;
extern long timezone;
extern char *tzname[2];
extern char tzstn[4];
extern char tzdtn[4];

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
