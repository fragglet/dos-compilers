#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

struct Mou_Event 
	{
	unsigned Mask;
	unsigned long Time;
	unsigned Row;
	unsigned Col;
	};

struct Mou_NoPtr
	{
	unsigned ulrow;			/* upper left row */
	unsigned ulcol;			/* upper left column */
	unsigned lrrow;			/* lower right row */
	unsigned lrcol;			/* lower right column */
	};

struct Mou_Pos
	{
	unsigned row;			/* row position */
	unsigned col;			/* column position */
	};

struct Mou_Ptr
	{
	unsigned size;			/* image size in bytes */
	unsigned width;			/* pointer width */
	unsigned height;		/* pointer height */
	unsigned hotcol;		/* offset to hot column */
	unsigned hotrow;		/* offset to hot row */
	};

struct Mou_QInfo
	{
	unsigned events;		/* current number of events */
	unsigned maxev;			/* maximum number of events */
	};

struct Mou_Scale
	{
	unsigned row;			/* row scale factor */
	unsigned col;			/* column scale factor */
	};

OS2API MouClose (unsigned);
OS2API MouDeRegister (void);
OS2API MouDrawPtr (unsigned);
OS2API MouFlushQue (unsigned);
OS2API MouGetDevStatus (unsigned far *,unsigned);
OS2API MouGetEventMask (unsigned far *,unsigned);
OS2API MouGetHotKey (unsigned far *,unsigned);
OS2API MouGetNumButtons (unsigned far *,unsigned);
OS2API MouGetNumMickeys (unsigned far *,unsigned);
OS2API MouGetNumQueEl (struct Mou_QInfo far *,unsigned);
OS2API MouGetPtrPos (struct Mou_Pos far *,unsigned);
OS2API MouGetPtrShape (unsigned char far *,struct Mou_Ptr far *,unsigned);
OS2API MouGetMouScale (struct Mou_Scale far *,unsigned);
OS2API MouInitReal (char far *);
OS2API MouOpen (char far *,unsigned far *);
OS2API MouReadEventQue (struct Mou_Event far *,unsigned far *,unsigned);
OS2API MouRegister (char far *,char far *,unsigned long);
OS2API MouRemovePtr (struct Mou_NoPtr far *,unsigned);
OS2API MouSetDevStatus (unsigned far *,unsigned);
OS2API MouSetEventMask (unsigned far *,unsigned);
OS2API MouSetHotKey (unsigned far *,unsigned);
OS2API MouSetPtrPos (struct Mou_Pos far *,unsigned);
OS2API MouSetPtrShape (unsigned char far *,struct Mou_Ptr far *,unsigned);
OS2API MouSetMouScale (struct Mou_Scale far *,unsigned);
OS2API MouSynch (unsigned);

#if OS2CAPS
#define MOUCLOSE MouClose
#define MOUDEREGISTER MouDeRegister
#define MOUDRAWPTR MouDrawPtr
#define MOUFLUSHQUE MouFlushQue
#define MOUGETDEVSTATUS MouGetDevStatus
#define MOUGETEVENTMASK MouGetEventMask
#define MOUGETHOTKEY MouGetHotKey
#define MOUGETNUMBUTTONS MouGetNumButtons
#define MOUGETNUMMICKEYS MouGetNumMickeys
#define MOUGETNUMQUEEL  MouGetNumQueEl
#define MOUGETPTRPOS MouGetPtrPos
#define MOUGETPTRSHAPE  MouGetPtrShape
#define MOUGETSCALEFACT MouGetMou_Scale
#define MOUINITREAL MouInitReal
#define MOUOPEN MouOpen
#define MOUREADEVENTQUE MouReadEventQue
#define MOUREGISTER MouRegister
#define MOUREMOVEPTR MouRemovePtr
#define MOUSETDEVSTATUS MouSetDevStatus
#define MOUSETEVENTMASK MouSetEventMask
#define MOUSETHOTKEY MouSetHotKey
#define MOUSETPTRPOS MouSetPtrPos
#define MOUSETPTRSHAPE MouSetPtrShape
#define MOUSETSCALEFACT MouSetMou_Scale
#define MOUSYNCH MouSynch
#endif
