#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

OS2API DosCloseSem (unsigned long);
OS2API DosCreateQueue (unsigned far *,unsigned,char far *);
OS2API DosCreateSem (unsigned,unsigned long far *,char far *);
OS2API DosFlagProcess (unsigned,unsigned,unsigned,unsigned);
OS2API DosHoldSignal (unsigned);
OS2API DosMakePipe (unsigned far *,unsigned far *,unsigned);
OS2API DosMuxSemWait (unsigned far *,unsigned far *,long);
OS2API DosOpenQueue (unsigned far *,unsigned far *,char far *);
OS2API DosOpenSem (unsigned long far *,char far *);
OS2API DosPeekQueue (unsigned,unsigned long far *,unsigned far *,unsigned long far *,unsigned far *,unsigned char,unsigned char far *,unsigned long);
OS2API DosPurgeQueue (unsigned);
OS2API DosQueryQueue (unsigned,unsigned far *);
OS2API DosReadQueue (unsigned,unsigned long far *,unsigned far *,unsigned long far *,unsigned,unsigned char,unsigned char far *,unsigned long);
OS2API DosSemClear (unsigned long);
OS2API DosSemRequest (unsigned long,long);
OS2API DosSemSet (unsigned long);
OS2API DosSemSetWait (unsigned long,long);
OS2API DosSemWait (unsigned long,long);
OS2API DosSendSignal (unsigned,unsigned);
OS2API DosSetSigHandler (void (far pascal *)(),unsigned long far *,unsigned far *,unsigned,unsigned);
OS2API DosWriteQueue (unsigned,unsigned,unsigned,unsigned char far *,unsigned char);

#if OS2CAPS
#define DOSCLOSEQUEUE DosCloseQueue
#define DOSCLOSESEM DosCloseSem
#define DOSCREATEQUEUE DosCreateQueue
#define DOSCREATESEM DosCreateSem
#define DOSFLAGPROCESS DosFlagProcess
#define DOSHOLDSIGNAL DosHoldSignal
#define DOSMAKEPIPE DosMakePipe
#define DOSMUXSEMWAIT DosMuxSemWait
#define DOSOPENQUEUE DosOpenQueue
#define DOSOPENSEM DosOpenSem
#define DOSPEEKQUEUE DosPeekQueue
#define DOSPURGEQUEUE DosPurgeQueue
#define DOSQUERYQUEUE DosQueryQueue
#define DOSREADQUEUE DosReadQueue
#define DOSSEMCLEAR DosSemClear
#define DOSSEMREQUEST DosSemRequest
#define DOSSEMSET DosSemSet
#define DOSSEMSETWAIT DosSemSetWait
#define DOSSEMWAIT DosSemWait
#define DOSSENDSIGNAL DosSendSignal
#define DOSSETSIGHANDLER DosSetSigHandler
#define DOSWRITEQUEUE DosWriteQueue
#endif