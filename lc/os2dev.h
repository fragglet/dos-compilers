#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

OS2API DosBeep (unsigned,unsigned);
OS2API DosCLIAccess (void);
OS2API DosDevConfig (unsigned char far *,unsigned,unsigned);
OS2API DosDevIOCtl (char far *,char far *,unsigned,unsigned,unsigned);
OS2API DosPortAccess (unsigned,unsigned,unsigned,unsigned);

#if OS2CAPS
#define DOSBEEP DosBeep
#define DOSCLIACCESS DosCLIAccess
#define DOSDEVCONFIG DosDevConfig
#define DOSDEVIOCTL DosDevIOCtl
#define DOSPORTACCESS DosPortAccess
#endif
