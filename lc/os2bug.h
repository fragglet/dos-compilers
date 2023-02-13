#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

struct Dos_TraceBuf
	{
	unsigned short pid;	/* process ID */
	unsigned short tid;	/* thread ID */
	unsigned short cmd;	/* command or result code */
	unsigned short data;	/* data or error code */
	unsigned short offset;	/* offset */
	unsigned short segment;	/* segment */
	unsigned short mh;	/* module handle */
	unsigned short AX;	/* AX register */
	unsigned short BX;	/* BX register */
	unsigned short CX;	/* CX register */
	unsigned short DX;	/* DX register */
	unsigned short SI;	/* SI register */
	unsigned short DI;	/* DI register */
	unsigned short BP;	/* BP register */
	unsigned short DS;	/* DS register */
	unsigned short ES;	/* ES register */
	unsigned short IP;	/* IP register */
	unsigned short CS;	/* CS register */
	unsigned short F;	/* Flag register */
	unsigned short SP;	/* SP register */
	unsigned short SS;	/* SS register */
	};

OS2API DosPtrace (struct Dos_TraceBuf far *);

#if OS2CAPS
#define DOSPTRACE DosPtrace
#endif
