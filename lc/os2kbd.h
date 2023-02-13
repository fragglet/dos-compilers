#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

struct Kbd_Data 
	{
	unsigned char acode;		/* ASCII code */
	unsigned char scode;		/* scan code */
	unsigned char state;		/* character state */
	unsigned char nls;		/* NLS shift state */
	unsigned shift;			/* shift state */
	unsigned long time;		/* keystroke time stamp */
	};

struct Kbd_Status 
	{
	unsigned size;			/* size in bytes (must be 10) */
	unsigned status;		/* status flags */
	unsigned turn;			/* turn-around character(s) */
	unsigned state;			/* interim character state flags */
	unsigned shift;			/* shift flags */
	};


struct Kbd_Xlate
	{
	unsigned char acode;		/* ASCII code */
	unsigned char scode;		/* scan code */
	unsigned char state;		/* character state */
	unsigned char nls;		/* NLS shift state */
	unsigned shift;			/* shift state */
	unsigned long time;		/* keystroke time stamp */
	unsigned monitor;		/* monitor packet flags */
	unsigned xflags;		/* translation flags */
	unsigned resv[2];		/* reserved */
	};

OS2API KbdCharIn (struct Kbd_Data far *,unsigned,unsigned);
OS2API KbdClose (unsigned);
OS2API KbdDeregister (void);
OS2API KbdFlushBuffer (unsigned);
OS2API KbdFreeFocus (unsigned);
OS2API KbdGetCP (unsigned long,unsigned far *,unsigned);
OS2API KbdGetFocus (unsigned,unsigned);
OS2API KbdGetStatus (struct Kbd_Status far *,unsigned);
OS2API KbdOpen (unsigned far *);
OS2API KbdPeek (struct Kbd_Data far *,unsigned);
OS2API KbdRegister (char far *,char far *,unsigned long);
OS2API KbdSetCP (unsigned,unsigned,unsigned);
OS2API KbdSetCustXT (unsigned far *,unsigned);
OS2API KbdSetFgnd (void);
OS2API KbdSetStatus (struct Kbd_Status far *,unsigned);
OS2API KbdStringIn (char far *,unsigned far *,unsigned,unsigned);
OS2API KbdSynch (unsigned);
OS2API KbdXlate (struct Kbd_Xlate far *,unsigned);

#if OS2CAPS
#define KBDCHARIN KbdCharIn
#define KBDCLOSE KbdClose
#define KBDFLUSHBUFFER KbdFlushBuffer
#define KBDFREEFOCUS KbdFreeFocus
#define KBDGETCP KbdGetCP
#define KBDGETFOCUS KbdGetFocus
#define KBDGETSTATUS KbdGetStatus
#define KBDOPEN KbdOpen
#define KBDPEEK KbdPeek
#define KBDREGISTER KbdRegister
#define KBDSETCP KbdSetCP
#define KBDSETCUSTXT KbdSetCustXT
#define KBDSETFGND KbdSetFgnd
#define KBDSETSTATUS KbdSetStatus
#define KBDSTRINGIN KbdStringIn
#define KBDSYNCH KbdSynch
#define KBDXLATE KbdXlate
#endif



