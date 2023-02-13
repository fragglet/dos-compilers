/* dos.h - This file defines data structures for DOS access.
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap, 3-aug-87,Remove near/farness. They have to coexist."
#endif

#ifndef _dosh
#define _dosh

/* used by sysint() sysint21() */
struct regval {
  unsigned short ax,bx,cx,dx,si,di,ds,es;
};

/* used by segread() */
struct segregs {
  unsigned short scs,  /* code segment */
    sss,   /* stack segment */
    sds,   /* data segment */
    ses;   /* extra segment */
};

/* used by functions needing the DS register or seg. and off. of a pointer */

extern unsigned _dataseg;

#define DATASEG() _dataseg

#define FP_OFF(p) (((unsigned *)(&(p)))[0])
#define FP_SEG(p) (((unsigned *)(&(p)))[1])

#define NP_OFF(p) ((unsigned)p)
#define NP_SEG(p) _dataseg

#ifdef _FLAGS_An          /* near data */

#define P_SEG(p) NP_SEG(p)
#define P_OFF(p) NP_OFF(p)

#else                     /* far or huge data */

#define  P_SEG(p) FP_SEG(p)
#define  P_OFF(p) FP_OFF(p)

#endif

struct derrbuf{
  int error, class, action, locus;
};

#define DOSERROR derrbuf

struct pblock{   /* for loadexec() */
  unsigned env;  /* segment address of environment */
  char far *com_line;  /* program command line */
  char far *fcb1;
  char far *fcb2;
};

void far *abstoptr(unsigned long);
unsigned long ptrtoabs(void far *);
#define  abstoptr(a) \
	(char far *)((((unsigned long)a>>4)<<16)|(unsigned long)(a&0xF))
#define  ptrtoabs(p) (((unsigned long)FP_SEG(p)<<4)+(unsigned long)FP_OFF(p))

union REGS{
  struct WORDREGS{ int ax, bx, cx, dx, si, di, cflag; } x;
  struct BYTEREGS{ char al, ah, bl, bh, cl, ch, dl, dh; } h;
};
struct SREGS{
  int es, cs, ss, ds;
};

int  bdos(int , ...);
int  dosexterr(struct derrbuf *);
int  int86(int , union REGS *, union REGS *);
int  int86x(int , union REGS *, union REGS *, struct SREGS *);
int  intdos(union REGS *, union REGS *);
int  intdosx(union REGS *, union REGS *, struct SREGS *);
int  intrinit(void (*)(void), unsigned , int );
int  intrrst(int );
int  loadexec(char far *, struct pblock far *, int );
long ptrdiff(void *, void *);
void segread(struct segregs *);
void settrace(int );
int  sysint(unsigned , struct regval *, struct regval *);
int  sysint21(struct regval *, struct regval *);

#endif

