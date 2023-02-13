#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

OS2API DosErrClass (unsigned,unsigned far *,unsigned far *,unsigned far *);
OS2API DosError (unsigned);
OS2API DosGetEnv (unsigned far *,unsigned far *);
OS2API DosGetInfoSeg (unsigned far *,unsigned far *);
OS2API DosGetMachineMode (unsigned char far *);
OS2API DosGetMessage (char far * far *,unsigned,char far *,unsigned,unsigned,char far *,unsigned far *);
OS2API DosGetVersion (unsigned far *);
OS2API DosInsMessage (char far * far *,unsigned,char far *,unsigned,char far *,unsigned,unsigned far *);
OS2API DosPutMessage (unsigned,unsigned,char far *);
OS2API DosScanEnv (char far *,char far * far *);
OS2API DosSearchPath (unsigned,char far *,char far *,char far *,unsigned);
OS2API DosSetVec (unsigned,void (far *)(void),void (far * far *)(void));

#if OS2CAPS
#define DOSERRCLASS DosErrClass 
#define DOSERROR DosError 
#define DOSGETENV DosGetEnv 
#define DOSGETINFOSEG DosGetInfoSeg 
#define DOSGETMACHINEMODE DosGetMachineMode 
#define DOSGETMESSAGE DosGetMessage 
#define DOSGETVERSION DosGetVersion 
#define DOSINSMESSAGE DosInsMessage 
#define DOSPUTMESSAGE DosPutMessage 
#define DOSSCANENV DosScanEnv 
#define DOSSEARCHPATH DosSearchPath 
#define DOSSETVEC DosSetVec 
#endif
