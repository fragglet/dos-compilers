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

/**
*
* External definitions for string services
*
*/
#ifndef NARGS
extern int stcarg(char *, char *);
extern int stccpy(char *, char *, int);
extern int stcgfe(char *, char *);
extern int stcgfn(char *, char *);
extern int stcgfp(char *, char *);
extern int stcis(char *, char *);
extern int stcisn(char *, char *);
extern int stclen(char *);
extern int stcd_i(char *, int *);
extern int stcd_l(char *, long *);
extern int stch_i(char *, int *);
extern int stch_l(char *, long *);
extern int stci_d(char *, int);
extern int stci_h(char *, int);
extern int stci_o(char *, int);
extern int stcl_d(char *, long);
extern int stcl_h(char *, long);
extern int stcl_o(char *, long);
extern int stco_i(char *, int *);
extern int stco_l(char *, long *);
extern int stcpm(char *, char *, char **);
extern int stcpma(char *, char *);
extern int stcu_d(char *, unsigned);
extern int stcul_d(char *, unsigned long);

extern char *stoh(short,char *);

extern char *stpblk(char *);
extern char *stpbrk(char *, char *);
extern char *stpchr(char *, int);
extern char *stpchrn(char *, int);
extern char *stpcpy(char *, char *);
extern char *stpdate(char *, int, char *);
extern char *stpsym(char *, char *, int);
extern char *stptime(char *, int, char *);
extern char *stptok(char *, char *, int, char *);


extern int strbpl(char **, int, char *);
extern char *strcat(char *, char *);
extern char *strchr(char *, int);
extern int strcmp(char *, char *);
extern int stricmp(char *, char *);
extern char *strcpy(char *, char *);
extern int strcspn(char *, char *);
extern char *strdup(char *);
extern void strins(char *, char *);
extern int strlen(char *);
extern char *strlwr(char *);
extern void strmfe(char *, char *, char *);
extern void strmfn(char *, char *, char *, char *, char *);
extern void strmfp(char *, char *, char *);
extern char *strncat(char *, char *, unsigned);
extern int strncmp(char *, char *, unsigned);
extern char *strncpy(char *, char *, unsigned);
extern int strnicmp(char *, char *, unsigned);
extern char *strnset(char *, int, int);
extern char *strpbrk(char *, char *);
extern char *strrchr(char *, int);
extern char *strrev(char *);
extern char *strset(char *, int);
extern void strsfn(char *, char *, char *, char *, char *);
extern int strspn(char *, char *);
extern void strsrt(char **, int);
extern char *strtok(char *, char *);
extern long strtol(char *, char **, int);
extern char *strupr(char *);

extern int stscmp(char *, char *);
extern int stspfp(char *, int *);

#else
extern int stcarg();
extern int stccpy();
extern int stcgfe();
extern int stcgfn();
extern int stcgfp();
extern int stcis();
extern int stcisn();
extern int stclen();
extern int stcd_i();
extern int stcd_l();
extern int stch_i();
extern int stch_l();
extern int stci_d();
extern int stci_h();
extern int stci_o();
extern int stcl_d();
extern int stcl_h();
extern int stcl_o();
extern int stco_i();
extern int stco_l();
extern int stcpm();
extern int stcpma();
extern int stcu_d();
extern int stcul_d();

extern char *stoh();

extern char *stpblk();
extern char *stpbrk();
extern char *stpchr();
extern char *stpchrn();
extern char *stpcpy();
extern char *stpdate();
extern char *stpsym();
extern char *stptime();
extern char *stptok();

extern int strbpl();
extern char *strcat();
extern char *strchr();
extern int strcmp();
extern int stricmp();
extern char *strcpy();
extern int strcspn();
extern char *strdup();
extern void strins();
extern int strlen();
extern char *strlwr();
extern void strmfe();
extern void strmfn();
extern void strmfp();
extern char *strncat();
extern int strncmp();
extern char *strncpy();
extern int strnicmp();
extern char *strnset();
extern char *strpbrk();
extern char *strrchr();
extern char *strrev();
extern char *strset();
extern void strsfp();
extern void strsrt();
extern int strspn();
extern char *strtok();
extern long strtol();
extern char *strupr();

extern int stscmp();
extern int stspfp();
#endif

#define strcmpi stricmp		/* For Microsoft compatibility */

/**
*
* External definitions for memory block services
*
**/
#ifndef NARGS
extern char *memccpy(char *, char *, int, unsigned);
extern char *memchr(char *, int, unsigned);
extern int memcmp(char *, char *, unsigned);
extern char *memcpy(char *, char *, unsigned);
extern char *memset(char *, int, unsigned);

extern void movmem(char *, char *, unsigned);
extern void repmem(char *, char *, int, int);
extern void setmem(char *, unsigned, int);
extern void swmem(char *, char *, unsigned);
#else
extern char *memccpy();
extern char *memchr();
extern int memcmp();
extern char *memcpy();
extern char *memset();

extern void movmem();
extern void repmem();
extern void setmem();
extern void swmem();
#endif
