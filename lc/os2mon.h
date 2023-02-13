#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

OS2API DosMonOpen (char far *,unsigned far *);
OS2API DosMonClose (unsigned);
OS2API DosMonReg (unsigned,unsigned char far *,unsigned char far *,unsigned,unsigned);
OS2API DosMonRead (unsigned char far *,unsigned char,unsigned char far *,unsigned far *);
OS2API DosMonWrite (unsigned char far *,unsigned char far *,unsigned);

#if OS2CAPS
#define DOSMONOPEN DosMonOpen 
#define DOSMONCLOSE DosMonClose 
#define DOSMONREG DosMonReg 
#define DOSMONREAD DosMonRead 
#define DOSMONWRITE DosMonWrite 
#endif
