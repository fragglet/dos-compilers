/*
 *  sys/stat.h  Equates and prototype for fstat, stat functions
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
#ifndef _SYS_STAT_H_INCLUDED
#define _SYS_STAT_H_INCLUDED

#ifndef _ENABLE_AUTODEPEND
 #pragma read_only_file
#endif

#if defined( _POSIX_SOURCE ) || !defined( _NO_EXT_KEYS ) /* extensions enabled */

#ifndef __COMDEF_H_INCLUDED
 #include <_comdef.h>
#endif

#if !defined(_SYS__LFNDOS_H_INCLUDED) && defined(__WATCOM_LFN__) && defined(__DOS__)
 #include <sys/_lfndos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _M_IX86
 #pragma pack( __push, 1 )
#else
 #pragma pack( __push, 8 )
#endif

/*
 *  ISO C types
 */
#ifdef __cplusplus
 #ifndef _STDTIME_T_DEFINED
 #define _STDTIME_T_DEFINED
  namespace std {
    typedef unsigned long time_t;
  }
  typedef std::time_t __w_time_t;
 #endif
 #ifndef _TIME_T_DEFINED
 #define _TIME_T_DEFINED
  #define _TIME_T_DEFINED_
  using std::time_t;
 #endif
#else  /* __cplusplus not defined */
 #ifndef _TIME_T_DEFINED
 #define _TIME_T_DEFINED
  #define _TIME_T_DEFINED_
  typedef unsigned long time_t;
  typedef time_t __w_time_t;
 #endif
#endif /* __cplusplus not defined */
#if !defined( _NO_EXT_KEYS ) /* extensions enabled */
#ifndef __cplusplus
 #ifndef _WCHAR_T_DEFINED
 #define _WCHAR_T_DEFINED
  #define _WCHAR_T_DEFINED_
  typedef unsigned short wchar_t;
 #endif
#endif
#endif /* extensions enabled */

/*
 *  POSIX 1003.1 types
 */
#ifndef _OFF_T_DEFINED_
 #define _OFF_T_DEFINED_
 typedef long           off_t;  /* file offset value */
#endif
#ifndef _DEV_T_DEFINED_
 #define _DEV_T_DEFINED_
 typedef int            dev_t;  /* device code (drive #) */
#endif
#ifndef _INO_T_DEFINED_
 #define _INO_T_DEFINED_
 typedef unsigned int   ino_t;  /* i-node # type */
#endif
#ifndef _MODE_T_DEFINED_
 #define _MODE_T_DEFINED_
 typedef unsigned short mode_t; /* Used for some file attributes    */
#endif
#ifndef _NLINK_T_DEFINED_
 #define _NLINK_T_DEFINED_
 typedef unsigned short nlink_t;/* Used for link counts             */
#endif
#ifndef _UID_T_DEFINED_
 #define _UID_T_DEFINED_
 typedef long           uid_t;  /* user identifier */
#endif
#ifndef _GID_T_DEFINED_
 #define _GID_T_DEFINED_
 typedef short          gid_t;  /* group identifier */
#endif

struct stat {
    dev_t           st_dev;         /* disk drive file resides on */
    ino_t           st_ino;         /* this inode's #, not used for DOS */
    mode_t          st_mode;        /* file mode */
    nlink_t         st_nlink;       /* # of hard links */
    uid_t           st_uid;         /* user-id, always 'root' */
    gid_t           st_gid;         /* group-id, always 'root' */
    dev_t           st_rdev;        /* should be device type */
                                    /* but same as st_dev for the time being */
    off_t           st_size;        /* total file size */
    time_t          st_atime;       /* should be file last access time */
    time_t          st_mtime;       /* file last modify time */
    time_t          st_ctime;       /* should be file last status change time */

    time_t          st_btime;       /* last archived date and time */
    unsigned long   st_attr;        /* file attributes */
                                    /* next 4 fields Netware only */
    unsigned long   st_archivedID;  /* user/object ID that last archived file */
    unsigned long   st_updatedID;   /* user/object ID that last updated file */
    unsigned short  st_inheritedRightsMask;
    unsigned char   st_originatingNameSpace;
};

#if !defined( _NO_EXT_KEYS ) /* extensions enabled */
struct _stat {
    dev_t           st_dev;         /* disk drive file resides on */
    ino_t           st_ino;         /* this inode's #, not used for DOS */
    mode_t          st_mode;        /* file mode */
    nlink_t         st_nlink;       /* # of hard links */
    uid_t           st_uid;         /* user-id, always 'root' */
    gid_t           st_gid;         /* group-id, always 'root' */
    dev_t           st_rdev;        /* should be device type */
                                    /* but same as st_dev for the time being */
    off_t           st_size;        /* total file size */
    time_t          st_atime;       /* should be file last access time */
    time_t          st_mtime;       /* file last modify time */
    time_t          st_ctime;       /* should be file last status change time */

    time_t          st_btime;       /* last archived date and time */
    unsigned long   st_attr;        /* file attributes */
                                    /* next 4 fields Netware only */
    unsigned long   st_archivedID;  /* user/object ID that last archived file */
    unsigned long   st_updatedID;   /* user/object ID that last updated file */
    unsigned short  st_inheritedRightsMask;
    unsigned char   st_originatingNameSpace;
};

struct _stati64 {
    dev_t           st_dev;         /* disk drive file resides on */
    ino_t           st_ino;         /* this inode's #, not used for DOS */
    mode_t          st_mode;        /* file mode */
    nlink_t         st_nlink;       /* # of hard links */
    uid_t           st_uid;         /* user-id, always 'root' */
    gid_t           st_gid;         /* group-id, always 'root' */
    dev_t           st_rdev;        /* should be device type */
                                    /* but same as st_dev for the time being */
    __int64         st_size;        /* total file size */
    time_t          st_atime;       /* should be file last access time */
    time_t          st_mtime;       /* file last modify time */
    time_t          st_ctime;       /* should be file last status change time */

    time_t          st_btime;       /* last archived date and time */
    unsigned long   st_attr;        /* file attributes */
                                    /* next 4 fields Netware only */
    unsigned long   st_archivedID;  /* user/object ID that last archived file */
    unsigned long   st_updatedID;   /* user/object ID that last updated file */
    unsigned short  st_inheritedRightsMask;
    unsigned char   st_originatingNameSpace;
};
#endif /* extensions enabled */

/*
 *  Common filetype macros
 */
#define S_ISUID     004000      /* set user id on execution         */
#define S_ISGID     002000      /* set group id on execution        */
#define S_ISVTX     001000      /* sticky bit (does nothing yet)    */

#define S_ENFMT     002000      /* enforcement mode locking         */

/*
 *  Owner permissions
 */
#define S_IRWXU     000700      /* Read, write, execute/search      */
#define S_IRUSR     000400      /* Read permission                  */
#define S_IWUSR     000200      /* Write permission                 */
#define S_IXUSR     000100      /* Execute/search permission        */

#define S_IREAD     S_IRUSR     /* Read permission                  */
#define S_IWRITE    S_IWUSR     /* Write permission                 */
#define S_IEXEC     S_IXUSR     /* Execute/search permission        */

#if !defined( _NO_EXT_KEYS ) /* extensions enabled */
#define _S_IREAD    S_IREAD
#define _S_IWRITE   S_IWRITE
#define _S_IEXEC    S_IEXEC
#endif /* extensions enabled */

/*
 *  Group permissions
 */
#define S_IRWXG     000070      /* Read, write, execute/search      */
#define S_IRGRP     000040      /* Read permission                  */
#define S_IWGRP     000020      /* Write permission                 */
#define S_IXGRP     000010      /* Execute/search permission        */

/*
 *  Other permissions
 */
#define S_IRWXO     000007      /* Read, write, execute/search      */
#define S_IROTH     000004      /* Read permission                  */
#define S_IWOTH     000002      /* Write permission                 */
#define S_IXOTH     000001      /* Execute/search permission        */

/*
 *  Encoding of the file mode
 */
#define S_IFMT      0xF000          /* Type of file mask    */
#define S_IFIFO     0x1000          /* FIFO (pipe)          */
#define S_IFCHR     0x2000          /* Character special    */
#define S_IFDIR     0x4000          /* Directory            */
#define S_IFNAM     0x5000          /* Special named file   */
#define S_IFBLK     0               /* Block special        */
#define S_IFREG     0x8000          /* Regular              */
#define S_IFLNK     0               /* Symbolic link        */
#define S_IFSOCK    0               /* Socket               */

#if !defined( _NO_EXT_KEYS ) /* extensions enabled */
#define _S_IFMT     S_IFMT
#define _S_IFIFO    S_IFIFO
#define _S_IFCHR    S_IFCHR
#define _S_IFDIR    S_IFDIR
#define _S_IFNAM    S_IFNAM
#define _S_IFBLK    S_IFBLK
#define _S_IFREG    S_IFREG
#define _S_IFLNK    S_IFLNK
#define _S_IFSOCK   S_IFSOCK
#endif /* extensions enabled */

#define S_ISFIFO(__m) (((__m)&S_IFMT)==S_IFIFO)    /* Test for FIFO (pipe)        */
#define S_ISCHR(__m)  (((__m)&S_IFMT)==S_IFCHR)    /* Test for char special file  */
#define S_ISDIR(__m)  (((__m)&S_IFMT)==S_IFDIR)    /* Test for directory file     */
#define S_ISBLK(__m)  (((__m)&S_IFMT)==S_IFBLK)    /* Test for block specl file   */
#define S_ISREG(__m)  (((__m)&S_IFMT)==S_IFREG)    /* Test for regular file       */
#define S_ISLNK(__m)  (((__m)&S_IFMT)==S_IFLNK)    /* Test for symbolic link      */
#define S_ISNAM(__m)  (((__m)&S_IFMT)==S_IFNAM)    /* Test for special named file */
#define S_ISSOCK(__m) (((__m)&S_IFMT)==S_IFSOCK)   /* Test for socket             */

/*
 *  POSIX 1003.1 Prototypes.
 */
_WCRTLINK extern int        chmod( const char *__path, mode_t __pmode );
_WCRTLINK extern mode_t     umask( mode_t __cmask );
_WCRTLINK extern int        mkdir( const char *__path );
_WCRTLINK extern int        stat( const char *__path, struct stat *__buf );
_WCRTLINK extern int        fstat( int __fildes, struct stat *__buf );
_WCRTLINK extern int        lstat( const char *__path, struct stat *__buf );
#if !defined( _NO_EXT_KEYS ) /* extensions enabled */
_WCRTLINK extern int        _mkdir( const char *__path );
_WCRTLINK extern int        _stat( const char *__path, struct stat *__buf );
_WCRTLINK extern int        _stati64( const char *__path, struct _stati64 *__buf );
_WCRTLINK extern int        _fstat( int __fildes, struct stat *__buf );
_WCRTLINK extern int        _fstati64( int __fildes, struct _stati64 *__buf );
_WCRTLINK extern int        _wmkdir( const wchar_t *__path );
_WCRTLINK extern int        _wstat( const wchar_t *__path, struct stat *__buf );
_WCRTLINK extern int        _wstati64( const wchar_t *__path, struct _stati64 *__buf );
#endif /* extensions enabled */

#pragma pack( __pop )

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* extensions enabled */

#endif