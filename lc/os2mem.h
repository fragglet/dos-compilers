#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

OS2API DosAllocHuge (unsigned,unsigned,unsigned far *,unsigned,unsigned);
OS2API DosAllocSeg (unsigned,unsigned far *,unsigned);
OS2API DosAllocShrSeg (unsigned,char far *,unsigned far *);
OS2API DosCreateCSAlias (unsigned,unsigned far *);
OS2API DosFreeSeg (unsigned);
OS2API DosGetHugeShift (unsigned far *);
OS2API DosGetSeg (unsigned);
OS2API DosGetShrSeg (char far *,unsigned far *);
OS2API DosGiveSeg (unsigned,unsigned,unsigned far *);
OS2API DosLockSeg (unsigned);
OS2API DosMemAvail (unsigned long far *);
OS2API DosReallocHuge (unsigned,unsigned,unsigned);
OS2API DosReallocSeg (unsigned,unsigned);
OS2API DosSubAlloc (unsigned,unsigned far *,unsigned);
OS2API DosSubFree (unsigned,unsigned,unsigned);
OS2API DosSubSet (unsigned,unsigned,unsigned);
OS2API DosUnlockSeg (unsigned);

#if OS2CAPS
#define DOSALLOCHUGE DosAllocHuge
#define DOSALLOCSEG DosAllocSeg
#define DOSALLOCSHRSEG DosAllocShrSeg
#define DOSCREATECSALIAS DosCreateCSAlias
#define DOSFREESEG DosFreeSeg
#define DOSGETHUGESHIFT DosGetHugeShift
#define DOSGETSEG DosGetSeg
#define DOSGETSHRSEG DosGetShrSeg
#define DOSGIVESEG DosGiveSeg
#define DOSLOCKSEG DosLockSeg
#define DOSMEMAVAIL DosMemAvail
#define DOSREALLOCHUGE DosReallocHuge
#define DOSREALLOCSEG DosReallocSeg
#define DOSSUBALLOC DosSubAlloc
#define DOSSUBFREE DosSubFree
#define DOSSUBSET DosSubSet
#define DOSUNLOCKSEG DosUnlockSeg
#endif