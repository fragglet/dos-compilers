/*
 *  direct.h    Defines the types and structures used by the directory routines
 *
 * =========================================================================
 *
 *                          Open Watcom Project
 *
 * Copyright (c) 2004-2023 The Open Watcom Contributors. All Rights Reserved.
 * Portions Copyright (c) 1983-2002 Sybase, Inc. All Rights Reserved.
 *
 *    This file is automatically generated. Do not edit directly.
 *
 * =========================================================================
 */
#ifndef _DIRECT_H_INCLUDED
#define _DIRECT_H_INCLUDED

#ifndef _ENABLE_AUTODEPEND
 #pragma read_only_file
#endif

#ifndef __COMDEF_H_INCLUDED
 #include <_comdef.h>
#endif

#if !defined(_SYS__LFNDOS_H_INCLUDED) && defined(__WATCOM_LFN__) && defined(__DOS__)
 #include <sys/_lfndos.h>
#endif

#ifndef _SYS_TYPES_H_INCLUDED
 #include <sys/types.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _M_IX86
 #pragma pack( __push, 1 )
#else
 #pragma pack( __push, 8 )
#endif

#ifndef __cplusplus
 #ifndef _WCHAR_T_DEFINED
 #define _WCHAR_T_DEFINED
  #define _WCHAR_T_DEFINED_
  typedef unsigned short wchar_t;
 #endif
#endif

#ifndef NAME_MAX
 #if defined(__OS2__)
  #define NAME_MAX      255     /* maximum filename for HPFS          */
 #elif defined(__NT__) || defined(__WATCOM_LFN__) && defined(__DOS__)
  #define NAME_MAX      259     /* maximum filename for NTFS, FAT LFN and DOS LFN */
 #else
#define NAME_MAX        12      /* 8 chars + '.' +  3 chars */
 #endif
#endif

struct _wdirent {
    char                d_dta[21];          /* disk transfer area */
    char                d_attr;             /* file's attribute */
    unsigned short      d_time;             /* file's modification time */
    unsigned short      d_date;             /* file's modification date */
    long                d_size;             /* file's size */
    unsigned short      d_ino;              /* serial number (not used) */
    char                d_first;            /* flag for 1st time */
    wchar_t             *d_openpath;        /* path specified to _wopendir */
    wchar_t             d_name[NAME_MAX+1]; /* file's name */
};
typedef struct _wdirent WDIR;

struct dirent {
    char                d_dta[21];          /* disk transfer area */
    char                d_attr;             /* file's attribute */
    unsigned short      d_time;             /* file's time */
    unsigned short      d_date;             /* file's date */
    long                d_size;             /* file's size */
    unsigned short      d_ino;              /* serial number (not used) */
    char                d_first;            /* flag for 1st time */
    char                *d_openpath;        /* path specified to opendir */
    char                d_name[NAME_MAX+1]; /* file's name */
};
typedef struct dirent   DIR;

/* File attribute constants for d_attr field */

#define _A_NORMAL       0x00    /* Normal file - read/write permitted */
#define _A_RDONLY       0x01    /* Read-only file */
#define _A_HIDDEN       0x02    /* Hidden file */
#define _A_SYSTEM       0x04    /* System file */
#define _A_VOLID        0x08    /* Volume-ID entry */
#define _A_SUBDIR       0x10    /* Subdirectory */
#define _A_ARCH         0x20    /* Archive file */

#ifndef _DISKFREE_T_DEFINED
#define _DISKFREE_T_DEFINED
 #define _DISKFREE_T_DEFINED_
 struct _diskfree_t {
     unsigned    total_clusters;
     unsigned    avail_clusters;
     unsigned    sectors_per_cluster;
     unsigned    bytes_per_sector;
 };
 #define diskfree_t _diskfree_t
#endif

_WCRTLINK extern int        _chdrive( int __drive );
_WCRTLINK extern int        _getdrive( void );
_WCRTLINK extern unsigned   _getdiskfree( unsigned __drive, struct _diskfree_t *__diskspace );

_WCRTLINK extern char       *getcwd( char *__buf, __w_size_t __size );
_WCRTLINK extern int        chdir( const char *__path );
_WCRTLINK extern int        mkdir( const char *__path );
_WCRTLINK extern int        rmdir( const char *__path );
_WCRTLINK extern DIR        *opendir( const char * );
_WCRTLINK extern struct dirent *readdir( DIR * );
_WCRTLINK extern void       rewinddir( DIR * );
_WCRTLINK extern int        closedir( DIR * );

_WCRTLINK extern char       *_getdcwd( int __drive, char *__buffer, __w_size_t __maxlen );
_WCRTLINK extern char       *_getcwd( char *__buf, __w_size_t __size );
_WCRTLINK extern int        _chdir( const char *__path );
_WCRTLINK extern int        _mkdir( const char *__path );
_WCRTLINK extern int        _rmdir( const char *__path );

_WCRTLINK extern wchar_t    *_wgetdcwd( int __drive, wchar_t *__buffer, __w_size_t __maxlen );
_WCRTLINK extern wchar_t    *_wgetcwd( wchar_t *__buf, __w_size_t __size );
_WCRTLINK extern int        _wchdir( const wchar_t *__path );
_WCRTLINK extern int        _wmkdir( const wchar_t *__path );
_WCRTLINK extern int        _wrmdir( const wchar_t *__path );
_WCRTLINK extern WDIR       *_wopendir( const wchar_t * );
_WCRTLINK extern struct _wdirent *_wreaddir( WDIR * );
_WCRTLINK extern void       _wrewinddir( WDIR * );
_WCRTLINK extern int        _wclosedir( WDIR * );

#pragma pack( __pop )

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif
