/**
*
* This header file defines the information used by the standard I/O
* package.
*
**/
/**
*
* Size parameters
*
*/
#define _BUFSIZ 512		/* standard buffer size */
#define BUFSIZ 512		/* standard buffer size */
#define _NFILE 20		/* maximum number of files */
/**
*
* One of these structures is provided for each Level 2 file.  The file
* is identified to the various Level 2 I/O functions by means of a pointer
* to its corresponding _iobuf structure.
*
*/
struct _iobuf
{
unsigned char *_ptr;		/* current buffer pointer */
int _rcnt;			/* current byte count for reading */
int _wcnt;			/* current byte count for writing */
unsigned char *_base;	 	/* base address of I/O buffer */
int _size;			/* size of buffer */
int _flag;			/* control flags */
unsigned char _file;		/* file number */
unsigned char _cbuff;		/* single char buffer */
};

extern struct _iobuf _iob[_NFILE];

/**
*
* Definitions associated with _iobuf._flag
*
*/
#define _IOFBF 0		/* fully buffered (for setvbuf) */
#define _IOREAD 1		/* read flag */
#define _IOWRT 2		/* write flag */
#define _IONBF 4		/* non-buffered flag */
#define _IOMYBUF 8		/* private buffer flag */
#define _IOEOF 16		/* end-of-file flag */
#define _IOERR 32		/* error flag */
#define _IOLBF 64		/* line-buffered flag */
#define _IORW 128		/* read-write (update) flag */
#define _IOAPP 0x4000		/* append flag */
#define _IOXLAT 0x8000		/* translation flag */
/**
*
* Miscellaneous definitions
*
*/
#ifndef NULL
#if SPTR
#define NULL 0			/* null pointer value */
#else
#define NULL 0L
#endif
#endif
#define FILE struct _iobuf	/* shorthand */
#define EOF (-1)		/* end-of-file code */
/**
*
* Standard Level 2 files
*
*/
#define stdin (&_iob[0])	/* standard input file pointer */
#define stdout (&_iob[1])	/* standard output file pointer */
#define stderr (&_iob[2])	/* standard error file pointer */
#define stdaux (&_iob[3])	/* standard auxiliary file pointer */
#define stdprt (&_iob[4])	/* standard printer file pointer */
/**
*
* Level 2 I/O macros
*
*/
#define getc(p) fgetc(p)
#define getchar() fgetchar()
#define putc(c,p) fputc(c,p)
#define putchar(c) fputchar(c)
#define feof(p) (((p)->_flag&_IOEOF)!=0)
#define ferror(p) (((p)->_flag&_IOERR)!=0)
#define fileno(p) (p)->_file
#define rewind(fp) fseek(fp,0L,0)
#define clearerr(fp) clrerr(fp)
/**
*
* The following kludge takes care of short/long name inconsistencies.
*
*/
#define fcloseall
#ifdef fcloseal
#undef fcloseal
#else
#undef fcloseall
#define fcloseall fcloseal
#endif
/**
*
* Function declarations
*
*/
#ifndef NARGS
extern void clrerr(FILE *);
extern int cprintf(char *, );
extern int cscanf(char *, );
extern int fclose(FILE *);
extern int fcloseall(void);
extern FILE *fdopen(int, char *);
extern int fgetc(FILE *);
extern int fgetchar(void);
extern char *fgets(char *, int, FILE *);
extern int flushall(void);
extern int fmode(FILE *, int);
extern FILE *fopen(char *, char *);
extern FILE *fopene(char *, char *, char *);
extern int fprintf(FILE *, char *, );
extern int fputc(int, FILE *);
extern int fputchar(int);
extern int fputs(char *, FILE *);
extern int fread(char *, int, int, FILE *);
extern FILE *freopen(char *, char *, FILE *);
extern int fscanf(FILE*, char *, );
extern int fseek(FILE *, long, int);
extern long ftell(FILE *);
extern int fwrite(char *, int, int, FILE *);
extern char *gets(char *);
extern int lprintf(char *, );
extern int printf(char *, );
extern int puts(char *);
extern scanf(char *, );
extern int setbuf(FILE *, char *);
extern int setnbf(FILE *);
extern int setvbuf(FILE*, char *, int, int);
extern int sprintf(char *, char *, );
extern sscanf(char *, char *, );
extern int ungetc(int, FILE *);
extern int _filbf(FILE *);
extern int _flsbf(int, FILE *);

#else
extern void clrerr();
extern int cprintf();
extern int cscanf();
extern int fclose();
extern int fcloseall();
extern FILE *fdopen();
extern int fgetc();
extern int fgetchar();
extern char *fgets();
extern int flushall();
extern int fmode();
extern FILE *fopen();
extern FILE *fopene();
extern int fprintf();
extern int fputc();
extern int fputchar();
extern int fputs();
extern int fread();
extern FILE *freopen();
extern int fscanf();
extern int fseek();
extern long ftell();
extern int fwrite();
extern char *gets();
extern int lprintf();
extern int printf();
extern int puts();
extern scanf();
extern int setbuf();
extern int setnbf();
extern int setvbuf();
extern int sprintf();
extern sscanf();
extern int ungetc();
extern int _filbf();
extern int _flsbf();
#endif

/**
*
* Miscellaneous I/O services
*
*/
#ifndef NARGS
extern int access(char *, int);
extern int chdir(char *);
extern int chmod(char *, int);
extern char *getcwd(char *, int);
extern int mkdir(char *);
extern int perror(char *);
extern int rename(char *, char *);
extern int rmdir(char *);
extern char *tmpnam(char *);
#else
extern int access();
extern int chdir();
extern int chmod();
extern char *getcwd();
extern int mkdir();
extern int perror();
extern int rename();
extern int rmdir();
extern char *tmpnam();
#endif
/**
*
* Define _mlist according to the memory model.
*
*/
#if SPTR
#define _mlist _nlist
#else
#define _mlist _flist
#endif
#ifndef NARGS
extern int _flist(FILE *);
extern int _nlist(FILE *);
#else
extern int _flist();
extern int _nlist();
#endif


