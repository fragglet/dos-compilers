#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

OS2API DosLoadModule (char far *,unsigned,char far *,unsigned far *);
OS2API DosFreeModule (unsigned);
OS2API DosGetProcAddr (unsigned,char far *,unsigned long far *);
OS2API DosGetModHandle (char far *,unsigned far *);
OS2API DosGetModName (unsigned,unsigned,char far *);

#if OS2CAPS
#define DOSLOADMODULE DosLoadModule
#define DOSFREEMODULE DosFreeModule
#define DOSGETPROCADDR DosGetProcAddr
#define DOSGETMODHANDLE DosGetModHandle
#define DOSGETMODNAME DosGetModName
#endif

