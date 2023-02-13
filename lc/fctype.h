/**
*
* This header file defines the function forms of the various "is" and
* "to" operations.
*
**/
#ifndef NARGS
extern int isalpha(int);
extern int isupper(int);
extern int islower(int);
extern int isdigit(int);
extern int isxdigit(int);
extern int isspace(int);
extern int ispunct(int);
extern int isalnum(int);
extern int isprint(int);
extern int isgraph(int);
extern int iscntrl(int);
extern int isascii(int);
extern int iscsym(int);
extern int iscsymf(int);
extern int toupper(int);
extern int tolower(int);
extern int toascii(int);
#else
extern int isalpha();
extern int isupper();
extern int islower();
extern int isdigit();
extern int isxdigit();
extern int isspace();
extern int ispunct();
extern int isalnum();
extern int isprint();
extern int isgraph();
extern int iscntrl();
extern int isascii();
extern int iscsym();
extern int iscsymf();
extern int toupper();
extern int tolower();
extern int toascii();
#endif

/**
*
* Define NULL if it's not already defined
*
*/
#ifndef NULL
#if SPTR
#define NULL 0			/* null pointer value */
#else
#define NULL 0L
#endif
#endif
