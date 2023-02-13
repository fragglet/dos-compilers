#ifndef OS2DEFS
#define OS2API extern unsigned far pascal
#define OS2DEFS
#endif

struct Dos_FileDesc
	{
	unsigned short cdate;		/* creation date */
	unsigned short ctime;		/* creation time */
	unsigned short adate;		/* access date */
	unsigned short atime;		/* access time */
	unsigned short wdate;		/* write date */
	unsigned short wtime;		/* write time */
	unsigned long eof;		/* end-of-file position */
	unsigned long fsize;		/* physical file size */
	unsigned short attr;		/* attribute */
	unsigned char nsize;		/* length of name string */
	char name[13];			/* file name */
	};

OS2API DosBufReset (unsigned);
OS2API DosChDir (char far *,unsigned long);
OS2API DosChgFilePtr (unsigned,long,unsigned,unsigned long far *);
OS2API DosClose (unsigned);
OS2API DosDelete (char far *,unsigned long);
OS2API DosDupHandle (unsigned,unsigned far *);
OS2API DosFileLocks (unsigned,long far *,long far *);
OS2API DosFindClose (unsigned);
OS2API DosFindFirst (char far *,unsigned far *,unsigned,struct Dos_FileDesc far *,unsigned,unsigned far *,unsigned long);
OS2API DosFindNext (unsigned,struct Dos_FileDesc far *,unsigned,unsigned far *);
OS2API DosMkDir (char far *,unsigned long);
OS2API DosMove (char far *,char far *,unsigned long);
OS2API DosNewSize (unsigned,unsigned long);
OS2API DosOpen (char far *,unsigned far *,unsigned far *,unsigned long,unsigned,unsigned,unsigned,unsigned long);
OS2API DosPhysicalDisk (unsigned,char far *,unsigned,char far *,unsigned);
OS2API DosQCurDir (unsigned,char far *,unsigned far *);
OS2API DosQCurDisk (unsigned far *,unsigned long far *);
OS2API DosQFHandState (unsigned,unsigned far *);
OS2API DosQFileInfo (unsigned,unsigned,char far *,unsigned);
OS2API DosQFileMode (char far *,unsigned far *,unsigned long);
OS2API DosQFSInfo (unsigned,unsigned,char far *,unsigned);
OS2API DosQHandType (unsigned,unsigned far *,unsigned far *);
OS2API DosQVerify (unsigned far *);
OS2API DosRead (unsigned,char far *,unsigned,unsigned far *);
OS2API DosReadAsync (unsigned,unsigned long far *,unsigned far *,char far *,unsigned,unsigned far *);
OS2API DosRmDir (char far *,unsigned long);
OS2API DosSelectDisk (unsigned);
OS2API DosSetFHandState (unsigned,unsigned);
OS2API DosSetFileInfo (unsigned,unsigned,char far *,unsigned);
OS2API DosSetFileMode (char far *,unsigned,unsigned long);
OS2API DosSetFSInfo (unsigned,unsigned,char far *,unsigned);
OS2API DosSetMaxFH (unsigned);
OS2API DosSetVerify (unsigned);
OS2API DosWrite (unsigned,char far *,unsigned,unsigned far *);
OS2API DosWriteAsync (unsigned,unsigned long far *,unsigned far *,char far *,unsigned,unsigned far *);

#if OS2CAPS
#define DOSBUFRESET DosBufReset 
#define DOSCHDIR DosChDir 
#define DOSCHGFILEPTR DosChgFilePtr 
#define DOSCLOSE DosClose 
#define DOSDELETE DosDelete 
#define DOSDUPHANDLE DosDupHandle
#define DOSFILELOCKS DosFileLocks
#define DOSFINDCLOSE DosFindClose
#define DOSFINDFIRST DosFindFirst
#define DOSFINDNEXT  DosFindNext
#define DOSMKDIR DosMkDir
#define DOSMOVE  DosMove
#define DOSNEWSIZE DosNewSize
#define DOSOPEN DosOpen
#define DOSPHYSICALDISK DosPhysicalDisk
#define DOSQCURDIR DosQCurDir
#define DOSQCURDISK DosQCurDisk
#define DOSQFHANDSTATE DosQFHandState
#define DOSQFILEINFO DosQFileInfo
#define DOSQFILEMODE DosQFileMode
#define DOSQFSINFO DosQFSInfo
#define DOSQHANDTYPE DosQHandType
#define DOSQVERIFY DosQVerify
#define DOSREAD DosRead
#define DOSREADASYNC DosReadAsync
#define DOSRMDIR DosRmDir
#define DOSSELECTDISK DosSelectDisk
#define DOSSETFHANDSTATE DosSetFHandState
#define DOSSETFILEINFO DosSetFileInfo
#define DOSSETFILEMODE DosSetFileMode
#define DOSSETFSINFO DosSetFSInfo
#define DOSSETMAXFH DosSetMaxFH
#define DOSSETVERIFY DosSetVerify
#define DOSWRITE DosWrite
#define DOSWRITEASYNC DosWriteAsync
#endif
