+ARCHIVE+ __ffree.c     4289  9/11/87 18:00:26
/* __ffree - support routines for _fmalloc and _ffree
** Copyright (c) 1985,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,10-sep-85,Complete rewrite! New scheme!"
#pragma REVISED "zap,23-sep-85,add routine _find_block(address,size)"
#pragma REVISED "zap,23-sep-85,add routine _take_block(address,size)"
#pragma REVISED "zap,14-oct-85,New header file, alloc.h"
#pragma REVISED "zap,21-oct-86,rewrite for near and far"
#pragma REVISED "zap,19-jan-87,add case where primary==NULL"
#pragma REVISED "zap,6-feb-87,another lost pointer"
#pragma REVISED "zap,08-mar-87,traverse list twice - merge lists then blocks"
#pragma REVISED "zap,31-mar-87,traverse list once"
#pragma REVISED "zap,11-sep-87,remove add_to_ptr()"
#endif

#include <stdio.h>
#include <_alloc.h>

extern struct ffree_list_item far *_fprimary_free_list;
struct ffree_list_item far *_fsecondary_free_list=(void far *)0;
int _fsecondary_list_count=0;


void _fmerge_free_lists() /* merge the primary and secondary free lists */
{
  struct ffree_list_item far *lp=(struct ffree_list_item far *)0; /* NULL */
  struct ffree_list_item far *ls=(struct ffree_list_item far *)0; /* NULL */
  struct ffree_list_item far *p;  /* primary list "next" pointer */
  struct ffree_list_item far *s;  /* secondary list "next" pointer */

  if(!_fsecondary_free_list) return;

  if(!_fprimary_free_list){
    _fprimary_free_list=_fsecondary_free_list;
    goto merge_done;
  }
  if(ptrtoabs(_fsecondary_free_list)<ptrtoabs(_fprimary_free_list)){
    p=_fprimary_free_list;
    _fprimary_free_list=_fsecondary_free_list;
    _fsecondary_free_list=p;
  }
  p=_fprimary_free_list;
  s=_fsecondary_free_list;

  while(1){   /* forever */
prim:
    while(ptrtoabs(p)<ptrtoabs(s)){
      lp=p;
      p=p->next;
      if(!p){
        lp->next=s;
        _fmerge_free_blocks(lp);
        goto merge_done;
      }
    }
    lp->next=s;
    while(1){
      if(_fmerge_free_blocks(lp)) break;
      s=s->next;
      lp->next=p;
      if(_fmerge_free_blocks(lp)) break;
      p=p->next;
      lp->next=s;
    }
    if(!s){
      lp->next=p;
      goto merge_done;
    } else if(!p){
      lp->next=s;
      goto merge_done;
    }
    if(ptrtoabs(p)<ptrtoabs(s)) goto prim;
    else lp->next=s;

sec:
    while(ptrtoabs(s)<ptrtoabs(p)){
      ls=s;
      s=s->next;
      if(!s){
        ls->next=p;
        _fmerge_free_blocks(ls);
        goto merge_done;
      }
    }
    ls->next=p;
    while(1){
      if(_fmerge_free_blocks(ls)) break;
      p=p->next;
      ls->next=s;
      if(_fmerge_free_blocks(ls)) break;
      s=s->next;
      ls->next=p;
    }
    if(!s){
      ls->next=p;
      goto merge_done;
    } else if(!p){
      ls->next=s;
      goto merge_done;
    }
    if(ptrtoabs(s)<ptrtoabs(p)) goto sec;
    else ls->next=p;
  }

merge_done:
  _fsecondary_free_list=(struct ffree_list_item far *)0;
  _fsecondary_list_count=0;
}


int _fmerge_free_blocks(bptr)  /* return 1 if no merge, 0 if merged */
struct ffree_list_item far *bptr;
{
  if(ptrtoabs(bptr)+FHF_SIZE+bptr->length==ptrtoabs(bptr->next)){
    bptr->length+=FHF_SIZE+bptr->next->length;
    bptr->next=bptr->next->next;
    return 0;
  }
  return 1;
}


struct ffree_list_item far *_fmalloc_find(address,size) /* find a free */
struct ffree_list_item far *address;         /* block of the proper size */
unsigned size;
{
  struct ffree_list_item far *last_ptr=(struct ffree_list_item far *)0;

  while(address->length<(long)size){
    if(!address) break;
    last_ptr=address;
    address=address->next;
  }
  return last_ptr;
}


struct ffree_list_item far *_fmalloc_take(address,size) /* take a block */
struct ffree_list_item far *address;               /* from a free list */
unsigned size;
{
  struct ffree_list_item far *block;

  if(address->length>=(long)size+FHF_SIZE+MIN_FALLOC){
    block=(void far *)abstoptr(ptrtoabs(address)+size+FHF_SIZE);
    block->next=address->next;
    block->length=address->length-size-FHF_SIZE;
    address->length=(long)size;
  } else block=address->next;
  address->next=ptrtoabs(address);  /* ignore this warning */

  return block;
}
+ARCHIVE+ __nfree.c     4035  3/31/87 16:55:10
/* __nfree - support routines for _nmalloc and _nfree
** Copyright (c) 1985,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,10-sep-85,Complete rewrite! New scheme!"
#pragma REVISED "zap,23-sep-85,add routine _find_block(address,size)"
#pragma REVISED "zap,23-sep-85,add routine _take_block(address,size)"
#pragma REVISED "zap,14-oct-85,New header file, alloc.h"
#pragma REVISED "zap,21-oct-86,rewrite for near and far"
#pragma REVISED "zap,19-jan-87,add case where primary==NULL"
#pragma REVISED "zap,6-feb-87,another lost pointer"
#pragma REVISED "zap,08-mar-87,traverse list twice - merge lists then blocks"
#pragma REVISED "zap,31-mar-87,traverse list once"
#endif

#include <stdio.h>
#include <_alloc.h>

extern struct nfree_list_item near *_nprimary_free_list;
struct nfree_list_item near *_nsecondary_free_list=(void *)0;
int _nsecondary_list_count=0;


void _nmerge_free_lists()  /* merge the primary and secondary free lists */
{
  struct nfree_list_item near *lp=(struct nfree_list_item near *)0; /* NULL */
  struct nfree_list_item near *ls=(struct nfree_list_item near *)0; /* NULL */
  struct nfree_list_item near *p;  /* primary list "next" pointer */
  struct nfree_list_item near *s;  /* secondary list "next" pointer */

  if(!_nsecondary_free_list) return;

  if(!_nprimary_free_list){
    _nprimary_free_list=_nsecondary_free_list;
      goto merge_done;
  }
  if(_nsecondary_free_list<_nprimary_free_list){
    p=_nprimary_free_list;
    _nprimary_free_list=_nsecondary_free_list;
    _nsecondary_free_list=p;
  }
  p=_nprimary_free_list;
  s=_nsecondary_free_list;

  while(1){
prim:
    while(p<s){
      lp=p;
      p=p->next;
      if(!p){
        lp->next=s;
        _nmerge_free_blocks(lp);
        goto merge_done;
      }
    }
    lp->next=s;
    while(1){
      if(_nmerge_free_blocks(lp)) break;
      s=s->next;
      lp->next=p;
      if(_nmerge_free_blocks(lp)) break;
      p=p->next;
      lp->next=s;
    }
    if(!s){
      lp->next=p;
      goto merge_done;
    } else if(!p){
      lp->next=s;
      goto merge_done;
    }
    if(p<s) goto prim;
    else lp->next=s;

sec:
    while(s<p){
      ls=s;
      s=s->next;
      if(!s){
        ls->next=p;
        _nmerge_free_blocks(ls);
        goto merge_done;
      }
    }
    ls->next=p;
    while(1){
      if(_nmerge_free_blocks(ls)) break;
      p=p->next;
      ls->next=s;
      if(_nmerge_free_blocks(ls)) break;
      s=s->next;
      ls->next=p;
    }
    if(!s){
      ls->next=p;
      goto merge_done;
    } else if(!p){
      ls->next=s;
      goto merge_done;
    }
    if(s<p) goto sec;
    else ls->next=p;
  }

merge_done:
  _nsecondary_free_list=(struct nfree_list_item near *)0;
  _nsecondary_list_count=0;
}


int _nmerge_free_blocks(bptr)
struct nfree_list_item near *bptr;
{
  if((char near *)bptr+bptr->length+FHN_SIZE==bptr->next){
    bptr->length+=bptr->next->length+sizeof(struct nfree_list_item);
    bptr->next=bptr->next->next;
    return 0;
  }
  return 1;
}


struct nfree_list_item near *_nmalloc_find(address,size) /* find a free */
struct nfree_list_item near *address;        /* block of the proper size */
unsigned size;
{
  struct nfree_list_item near *last_ptr=(struct nfree_list_item near *)0;

  while(address->length<size){
    if(!address) break;
    last_ptr=address;
    address=address->next;
  }
  return last_ptr;
}


struct nfree_list_item near *_nmalloc_take(address,size)  /* take a block */
struct nfree_list_item near *address;              /* from a free list */
unsigned size;
{
  struct nfree_list_item near *block;

  if(address->length>=size+FHN_SIZE+MIN_NALLOC){
    block=(char near *)address+size+FHN_SIZE;
    block->next=address->next;
    block->length=address->length-size-FHN_SIZE;
    address->length=size;
  } else block=address->next;
  address->next=address;

  return block;
}
+ARCHIVE+ _assert.c      561 11/23/87 15:02:56
/* _assert.c - assert support function
** Copyright (C) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef	HISTORY
#pragma CREATED "nlp,20-nov-87, created"
#pragma REVISED "zap,23-nov-87,add stdio.h"
#endif

#include <stdio.h>

/* do the dirty work for assert
*/
void _assert(expstring,filename,lineno)
char *expstring, *filename;
int lineno;
{

  /* print assertion message */
  fprintf(stderr,"Assertion failed: %s, file %s, line %d\n"
		,(expstring ? expstring : "")
		,filename
	   ,lineno);

  /* die */
  abort();
}

+ARCHIVE+ _dodummy.c    2102  1/27/87  9:58:28
/* _dodummy - floating point support for nofloats
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,16-jan-87,creation"
#pragma REVISED "zap,26-jan-87,models"
#endif

#include <dos.h>
#include <process.h>

static void near dump()
{
  bdos(9,"Floating point not installed$");
  abort();
}

int near _fprntsn(precflg,precisn,ap,format,width
                    ,alternate,csign,leftadj,padchar,stream)
unsigned precflg;
unsigned precisn;
char *ap;
char *format;
unsigned width;
unsigned alternate;
char csign;
unsigned leftadj;
unsigned padchar;
char *stream;
{
  dump();
}


int far _fprntln(precflg,precisn,ap,format,width
                    ,alternate,csign,leftadj,padchar,stream)
unsigned precflg;
unsigned precisn;
char *ap;
char *format;
unsigned width;
unsigned alternate;
char csign;
unsigned leftadj;
unsigned padchar;
char *stream;
{
  dump();
}


int near _fprntsf(precflg,precisn,ap,format,width
                    ,alternate,csign,leftadj,padchar,stream)
unsigned precflg;
unsigned precisn;
char *ap;
char *format;
unsigned width;
unsigned alternate;
char csign;
unsigned leftadj;
unsigned padchar;
char *stream;
{
  dump();
}


int far _fprntlf(precflg,precisn,ap,format,width
                    ,alternate,csign,leftadj,padchar,stream)
unsigned precflg;
unsigned precisn;
char *ap;
char *format;
unsigned width;
unsigned alternate;
char csign;
unsigned leftadj;
unsigned padchar;
char *stream;
{
  dump();
}


int near _fscansn(stream,longflg,ap,suppress)
char *stream;
unsigned longflg;
char *ap;
unsigned suppress;
{
  dump();
}


int far _fscanln(stream,longflg,ap,suppress)
char *stream;
unsigned longflg;
char *ap;
unsigned suppress;
{
  dump();
}


int near _fscansf(stream,longflg,ap,suppress)
char *stream;
unsigned longflg;
char *ap;
unsigned suppress;
{
  dump();
}


int far _fscanlf(stream,longflg,ap,suppress)
char *stream;
unsigned longflg;
char *ap;
unsigned suppress;
{
  dump();
}



+ARCHIVE+ _dtos.c       4222 11/02/87 12:55:22
/* Convert floating point value to string.
** Return length of string converted.
**
** CAUTION: This is an unpublished function.  We may change it's 
** arguments in the future, etc.  If you use it, beware of future 
** releases. We suggest you use FTOA or SPRINTF, etc to get the 
** job done. 
**
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,19-jun-85,from scratch rewrite of old dtos"
#pragma REVISED "zap,6-aug-85,check for zero"
#pragma REVISED "nlp,24-dec-86,memset buf,'0',18"
#pragma REVISED "zap,17-feb-87,check for out of range on scaling"
#pragma REVISED "nlp,27-oct-87,change check out of range code"
#pragma REVISED "zap,30-oct-87,ditto"
#endif

#include <math.h>

#define FOREVER for(;;)

#define MAXPOW 10  /* number of entries in _npowten[] and _ppowten[] */

static unsigned int _ppowten[]={
	     0,     0,     0,0x3FF0,		/* 1e0 */
	0X0000,0X0000,0X0000,0X4024,		/* 1e1 */
	0X0000,0X0000,0X0000,0X4059,		/* 1e2 */
	0X0000,0X0000,0X8800,0X40C3,		/* 1e4 */
	0X0000,0X0000,0XD784,0X4197,		/* 1e8 */
	0X8000,0X37E0,0XC379,0X4341,		/* 1e16 */
	0X6E17,0XB505,0XB8B5,0X4693,		/* 1e32 */
	0XF9F6,0XE93F,0X4F03,0X4D38,		/* 1e64 */
	0X1D33,0XF930,0X7748,0X5A82,		/* 1e128 */
	0XBF3F,0X7F73,0X4FDD,0X7515		/* 1e256 */
};
static int _ppten[]={0,1,2,4,8,16,32,64,128,256,512};

static unsigned int _npowten[]={
	     0,     0,     0,0x3FF0,		/* 1e-0 */
	0X999A,0X9999,0X9999,0X3FB9,		/* 1e-1 */
	0X147B,0X47AE,0X7AE1,0X3F84,		/* 1e-2 */
	0X432D,0XEB1C,0X36E2,0X3F1A,		/* 1e-4 */
	0X8C3A,0XE230,0X798E,0X3E45,		/* 1e-8 */
	0X89BC,0X97D8,0XD2B2,0X3C9C,		/* 1e-16 */
	0XA732,0XD5A8,0XF623,0X3949,		/* 1e-32 */
	0XA73C,0X44F4,0X0FFD,0X32A5,		/* 1e-64 */
	0X979A,0XCF8C,0XBA08,0X255B,		/* 1e-128 */
	0X6F40,0X64AC,0X0628,0X0AC8		/* 1e-256 */
};
static int _npten[]={0,-1,-2,-4,-8,-16,-32,-64,-128,-256,-512};

#define MAXPOWPTEN 19
static int _pten[]={
	0x0000,0x0000,0x0000,0x3FF0,	/* 1e0 */
	0x0000,0x0000,0x0000,0x4024,	/* 1e1 */
	0x0000,0x0000,0x0000,0x4059,	/* 1e2 */
	0x0000,0x0000,0x4000,0x408F,	/* 1e3 */
	0x0000,0x0000,0x8800,0x40C3,	/* 1e4 */
	0x0000,0x0000,0x6A00,0x40F8,	/* 1e5 */
	0x0000,0x0000,0x8480,0x412E,	/* 1e6 */
	0x0000,0x0000,0x12D0,0x4163,	/* 1e7 */
	0x0000,0x0000,0xD784,0x4197,	/* 1e8 */
	0x0000,0x0000,0xCD65,0x41CD,	/* 1e9 */
	0x0000,0x2000,0xA05F,0x4202,	/* 1e10 */
	0x0000,0xE800,0x4876,0x4237,	/* 1e11 */
	0x0000,0xA200,0x1A94,0x426D,	/* 1e12 */
	0x0000,0xE540,0x309C,0x42A2,	/* 1e13 */
	0x0000,0x1E90,0xBCC4,0x42D6,	/* 1e14 */
	0x0000,0x2634,0x6BF5,0x430C,	/* 1e15 */
	0x8000,0x37E0,0xC379,0x4341,	/* 1e16 */
	0xA000,0x85D8,0x3457,0x4376,	/* 1e17 */
	0xC800,0x674E,0xC16D,0x43AB,	/* 1e18 */
	};

extern	int abs();

int _dtos(d,buff)
double d;             /* floating point to convert */ 
unsigned char *buff;  /* buffer to store result */
{
  int  bptr=0;
  register int i,exp=0;
  double d_value;

  if(d==0.0){
    memset(buff,'0',18);
    buff[18]='\0'; 
    return(0);
  }
  else if((((unsigned short *)(&d))[3] & 0x7ff0) == 0x7ff0) {
invalid_double_input:
	 /* overflow, return string if asterisks */
	 memset(buff,'*',18);
    buff[18]='\0';
    return 0;
  }
  if((d_value=d)<0.0){		/* put sign in output buffer if appropriate */
    buff[bptr++]='-';
    d_value= -(d_value);
  }

  while(d_value>((double *)_pten)[18]){    /* bring it down from overrange */
    for(i=5;d_value>=((double *)_ppowten)[i];) {
	   if(++i==MAXPOW) break;
    }
    if(i--<5)break;
    exp+=_ppten[i];
    d_value*=((double *)_npowten)[i];
  }
  while(d_value<((double *)_pten)[0]){   /* or bring it up from underrange */
    for(i=0;d_value<((double *)_npowten)[i];) {
	   if(++i==MAXPOW) break;
    }
    if(!--i){
      d_value*=((double *)_ppowten)[1];
      exp--;
      break;
    }
    exp+=_npten[i];
    d_value*=((double *)_ppowten)[i];
  }

  for(i=0;d_value>=((double *)_pten)[i];i++) {
	 if(i==MAXPOWPTEN) break;
  }
  exp+=i-1;
  d_value*=((double *)_pten)[18-i];
  bptr+=_dtobcd(d_value,&buff[bptr]);
  memset(&buff[bptr],'0',abs(exp));
  buff[bptr+abs(exp)]=0;

  return(exp);

}
+ARCHIVE+ _err_map.c     544 12/22/86 12:41:20
/* _err_map - support for floating matherr() error handling
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,10-nov-86,forgot to write this back in September"
#endif

#include <math.h>

static int _error[6]={DOMAIN,SING,OVERFLOW,UNDERFLOW,TLOSS,PLOSS};

int _err_map(stat)
int stat;  /* 8087 error status */
{
  register i=0;

  if(!(stat&0x3F)) return 0;  /* why was this function called? */
  while(!(stat&1)){
    i++;
    stat>>=1;
  }
  return _error[i];
}
+ARCHIVE+ _exec.c       4080 10/28/87 16:52:12
/* exec - all variations
** Copyright (C) 1987 Computer Innovations Inc,  ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-apr-87,stab"
#endif

#include <process.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <dos.h>
#include <errno.h>
#include <signal.h>


/* Find the program and return it. Return zero on success.
*/
static int near _scan_path(pathstr, store, psearch)
char *pathstr, *store;
int psearch;
{
  register char *ep;
  struct regval s;

  if(!access(pathstr,0)){  /* first try the CWD... */
    s.ax=0x4300;
    s.ds=P_SEG(pathstr);
    s.dx=P_OFF(pathstr);
    if(!(sysint21(&s,&s)&1)){  /* is it a directory or a file? */
      if(!(s.ax&0x10)){
        strcpy(store,pathstr);
        return 0;
      }
    }
  }

  /* ...then, if it's not a full path name... */
  if(!strchr(pathstr,':') && pathstr[0]!='\\' && psearch){
    if(ep=getenv("PATH")){  /* ...try the path... */
      strcpy(store,strtok(ep,";"));
      do {
        if(store[strlen(store)-1]!='\\') strcat(store,"\\");
        if(!access(strcat(store,pathstr),0)){
          s.ax=0x4300;
          s.ds=P_SEG(store);
          s.dx=P_OFF(store);
          if(!(sysint21(&s,&s)&1)) if(!(s.ax&0x10)) return 0;
        }
        ep=strtok(NULL,";");
        if(ep) strcpy(store,ep);
      } while(ep);
    }
  }
  if(!strchr(pathstr,'.')){  /* ...or maybe we should add an extention */
    return _scan_path(strcat(pathstr,".exe"),store,psearch);
  }
  return -1;  /* no go */
}


static int near doexec(pathname, cmdl, envp)    /* exec the process */
char *pathname, *cmdl, **envp;
{
  extern int errno;
  register i, envsize;
  char *cp, *dos_env, *p, *xp;
  int fd, prog_info[12];

  /* build new, expensive environment */
  for(envsize=0,i=0;envp[i];++i) {  /* find out how much */
    envsize += (strlen(envp[i])+1);
  }
  envsize += strlen(pathname) + 8; /* add path name and pad chars to env */
  envsize += (16+1);

  if(!(cp=dos_env=malloc(envsize))) {    /* allocate memory */
    raise(SIGALLOC);
    return -1;
  }

  for(i=0;envp[i];++i){
    strcpy(cp,envp[i]);
    cp += (strlen(cp)+1);
  }
  *cp++=0;
  *cp++=1;
  *cp++=0;

  /* put the EXE file name at the end of the environment */
  for(p=pathname,xp=NULL;*p;++p) {
	if(*p=='\\' || *p=='/' || *p==':') xp=p;
  }
  if(xp) strcpy(cp,xp+1);
  else strcpy(cp,pathname);

  /* get .exe file info */
  if((fd=open(pathname, O_BINARY|O_RDONLY))<0) return -1;  /* sets errno */
  if(read(fd,prog_info,24)!=24){
    close(fd);
    return -1;
  }
  close(fd);
  if(prog_info[0]!=0x5A4D){  /* check file format */
    errno=ENOEXEC;
    return -1;
  }

  errno = _doexec(
    prog_info[11],  /* offset for CS */
    prog_info[10],  /* IP */
    prog_info[8],   /* SP */
    prog_info[7],   /* offset for SS */
    (prog_info[2]<<5)+(prog_info[1]>>4)+1+prog_info[5]-prog_info[4], /*size*/
    envsize>>4,     /* environment size */
    P_SEG(dos_env), /* environment segment */
    P_OFF(dos_env), /* environment offset */
    P_SEG(cmdl),    /* command line segment */
    P_OFF(cmdl),    /* command line offset */
    P_SEG(pathname),/* path segment */
    P_OFF(pathname) /* path offset */
                 );

  /* doesn't return unless there's nasty problems */
  free(dos_env);  /* environment */
  return -1;
}



int _exec(prog,argv,envp,psearch)    /* process the arguments */
char *prog;
char *argv[];
char *envp;
int psearch;  /* should I search the path ? */
{
  extern int errno;
  char cmdl[129], tmp[256], pname[128];
  register char *cp;

  strcpy(tmp,prog);
  strcpy(pname,prog);
  if(_scan_path(pname,tmp,psearch)) return -1;  /* errno set by _scan_path */

  cmdl[1]=0;		/* build the command line */
  while(*++argv){
    strcat(cmdl+1," ");
    strcat(cmdl+1,*argv);
  }
  cmdl[0]=strlen(cmdl+1);
  strcat(cmdl+1,"\015");
  return doexec(tmp,cmdl,envp);  /* doesn't return if successful */
}

+ARCHIVE+ _exit.c       1574  4/24/87 12:05:44
/* _exit for DOS 2.0 and above
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTROY
#pragma REVISED "zap,20-nov-86,creation"
#pragma REVISED "zap,25-nov-86,different model i87rst() functions"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#pragma REVISED "zap,20-jan-87,declare _os_froot here instead of sbrk.c"
#pragma REVISED "zap,24-apr-87,stuff from exit"
#endif

#include <stdio.h>
#include <process.h>
#include <fileio3.h>

struct _tf_list{
  struct _tf_list *next;
  char name[L_tmpnam];
};
struct _tf_list _tf_root={NULL,""};

struct _os_free_item{
  struct _os_free_item far *next;
  unsigned blockmod;
} far *_os_froot=(void far *)0;

void _exit(code)
int code;
{
  struct _tf_list *_tf_next;
  int i;

  for(i=3;i<SYS_OPEN;++i){  /* close all the files */
    if(_iob[i]._base) fflush(&_iob[i]);
    if(_osfile[i] & (_IOREAD | _IOWRT | _IORW)) close(i);
  }
  if(_tf_root.name[0]){  /* remove all the temp files */
    _tf_next=&_tf_root;
    while(_tf_next){
      remove(_tf_next->name);
      _tf_next=_tf_next->next;
    }
  }

  while(_os_froot){
    _dosf49(_os_froot->blockmod);  /* free OS blocks */
    _os_froot=_os_froot->next;
  }

#ifdef _FLAGS_Al  /* restore emulator vectors */
#ifdef _FLAGS_Af
  _i87rstlf();
#else
  _i87rstln();
#endif          /* end _FLAGS_Af */
#else           /* near code */
#ifdef _FLAGS_Af
  _i87rstsf();
#else
  _i87rstsn();
#endif          /* end _FLAGS_Af */
#endif          /* end _FLAGS_Al */
  _quit(code);  /* 'bye */
}

+ARCHIVE+ _expand.c     2398 10/19/87 14:31:50
/* _expand - expand an allocated block without moving it
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,30-oct-86,creation"
#pragma REVISED "zap,31-oct-86,seems to work"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#pragma REVISED "zap,26-may-87,pointer manipulation"
#pragma REVISED "zap,11-sep-87,remove add_to_ptr()"
#pragma REVISED "ahm,19-oct-87,near: *p=NULL, np=ap+size+FHN_SIZE"
#endif

#include <malloc.h>
#include <_alloc.h>

#ifdef _FLAGS_Af
extern struct ffree_list_item *_fprimary_free_list;
#else
extern struct nfree_list_item *_nprimary_free_list;
#endif

void *_expand(ptr, size)
char *ptr;
unsigned size;
{

#ifdef _FLAGS_Af
  struct ffree_list_item far *p=NULL;
  struct ffree_list_item far *np;
  struct ffree_list_item far *ap;
  long apaddr;

  if(size>0xFFE8) return NULL;

  ap=(struct ffree_list_item *)((char *)abstoptr(ptrtoabs(ptr)-FHF_SIZE));
  _fmerge_free_lists();
  np=_fprimary_free_list;
  apaddr=ptrtoabs(ap);
  while(ptrtoabs(np)<apaddr){
    p=np;
    if(!(np=np->next)) return NULL;
  }
  if(apaddr+FHF_SIZE+ap->length!=ptrtoabs(np)) return NULL;
  if(p) p->next=np->next;
  else _fprimary_free_list=np->next;
  if((ap->length+=np->length+FHF_SIZE)<(long)size) return NULL;
  if(ap->length>(long)size+FHF_SIZE){
    np=abstoptr(ptrtoabs(ap)+size+FHF_SIZE);
    np->length=ap->length-size-FHF_SIZE;
    ap->length=(long)size;
    if(p){
      np->next=p->next;
      p->next=np;
    } else {
      np->next=_fprimary_free_list;
      _fprimary_free_list=np;
    }
  }

#else
  struct nfree_list_item *p=NULL,*np,*ap;

  if(size>0xFFE8) return NULL;

  ap=(struct nfree_list_item *)(ptr-FHN_SIZE);
  _nmerge_free_lists();
  np=_nprimary_free_list;
  while(np<ap){
    p=np;
    if(!(np=np->next)) return NULL;
  }
  if((char *)ap+FHN_SIZE+ap->length!=np) return NULL;
  if(p) p->next=np->next;
  else _nprimary_free_list=np->next;
  if((ap->length+=np->length+FHN_SIZE)<size) return NULL;
  if(ap->length>size+FHN_SIZE){
    np=(struct nfree_list_item *)((char *)ap+size+FHN_SIZE);
    np->length=ap->length-size-FHN_SIZE;
    ap->length=size;
    if(p){
      np->next=p->next;
      p->next=np;
    } else {
      np->next=_nprimary_free_list;
      _nprimary_free_list=np;
    }
  }

#endif

  return ptr;
}

+ARCHIVE+ _ffree.c      1670  9/11/87 17:56:40
/* _ffree - far memory freer-upper
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,10-sep-85,Complete rewrite! New scheme!"
#pragma REVISED "zap,14-oct-85,New header file, alloc.h"
#pragma REVISED "zap,20-oct-86,rewrite for near and far"
#pragma REVISED "zap,11-sep-87,remove add_to_ptr()"
#endif

#include <stdio.h>
#include <errno.h>
#include <signal.h>
#include <_alloc.h>

extern struct ffree_list_item far *_fprimary_free_list;
extern struct ffree_list_item far *_fsecondary_free_list;
extern int _fsecondary_list_count;

void _ffree(fptr)
char far *fptr;
{
  struct ffree_list_item far *free_ptr;
  struct ffree_list_item far *this_ptr;
  struct ffree_list_item far *last_ptr=(void far *)0;

  free_ptr=abstoptr(ptrtoabs(fptr)-FHF_SIZE);
  if(free_ptr->next!=ptrtoabs(free_ptr)){  /* invalid pointer */
    errno=EFREE;
    raise(SIGFREE);
    return;
  }

  this_ptr=_fsecondary_free_list;
  while(this_ptr && ptrtoabs(this_ptr)<free_ptr->next){
    last_ptr=this_ptr;
    this_ptr=this_ptr->next;
  }
  if(ptrtoabs(this_ptr)==free_ptr->next){  /* block already free */
    errno=EFREE;
    raise(SIGFREE);
    return;
  }
  if(!last_ptr){
    free_ptr->next=_fsecondary_free_list;
    _fsecondary_free_list=free_ptr;
    _fsecondary_list_count+=_fmerge_free_blocks(free_ptr);
  } else {
    if(free_ptr->next=this_ptr)
      _fsecondary_list_count+=_fmerge_free_blocks(free_ptr)-1;
    last_ptr->next=free_ptr;
    _fsecondary_list_count+=_fmerge_free_blocks(last_ptr);
  }
  if(_fsecondary_list_count==_FREE_LIST_SIZE) _fmerge_free_lists();
}
+ARCHIVE+ _filbuf.c     1441 11/10/87 16:49:12
/* _filbuf - fill an I/O buffer
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-jul-85,add this comment & copyright"
#pragma REVISED "zap,9-oct-85,add signals"
#pragma REVISED "zap,25-oct-85,add carriage return smarts"
#pragma REVISED "zap,25-oct-85,fix carriage return smarts"
#pragma REVISED "zap,22-may-86,new defines in fileio3.h"
#pragma REVISED "zap,10-nov-87,move in some EOF processing from read()"
#endif

#include <stdio.h>
#include <fileio3.h>
#include <errno.h>
#include <signal.h>
#include <malloc.h>

int _filbuf(s)
FILE *s;
{
  register fd;

  fd=s->_fd;
  if(!(s->_flag&(_IOREAD|_IOWRT|_IORW))){  /* if not open */
    errno=EBADF;
    raise(SIGREAD);
    return EOF;
  }
  if(!s->_base){  /* no gots buffer */
    if(!(s->_base=malloc(_piob[fd]._size))){
      errno=ENOMEM;
      raise(SIGALLOC);
      return EOF;
    }
  } else if(s->_cnt>0){  /* got buffer, got more chars */
    --s->_cnt;
    return *s->_ptr++;
  }
  _osfile[fd]&=~_IODIRTY;  /* because we're getting a new buffer */

  if(!(_osfile[fd]&_IOCDEV))
    if(_iob[fd]._flag&_IOEOF) return EOF;  /* antique ^Z garbage */

  if((s->_cnt=read(fd,s->_ptr=s->_base,_piob[fd]._size))<0) goto err;
  if(!s->_cnt) _iob[fd]._flag|=_IOEOF;
  else {
    _iob[fd]._flag&=~_IOEOF;
    s->_cnt--;
    return *s->_ptr++;
  }
err:
  return EOF;
}

+ARCHIVE+ _flsbuf.c     1416  1/09/87 23:43:42
/* yflsbuf.c - flush the buffer
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-jul-85,add this comment & copyright"
#pragma REVISED "zap,9-oct-85,add signals"
#pragma REVISED "zap,1-nov-85,problem with buffers and \n"
#pragma REVISED "zap,22-may-86,new defines in fileio3.h"
#pragma REVISED "zap,28-may-86,remove ASCII processing to write.c"
#pragma REVISED "zap,9-jan-87,write the proper amount"
#endif

#include <stdio.h>
#include <fileio3.h>
#include <errno.h>
#include <signal.h>
#include <malloc.h>

int _flsbuf(c,s)
unsigned char c;
FILE *s;
{
  register fd, count;

  fd=s->_fd;
  if(_piob[fd]._size<=1){  /* unbuffered */
    s->_cnt=0;
    if(write(fd,&c,1)!=1) goto err;
    return c;       /*** only buffered output beyond this point ***/
  }
  if(!(s->_base)){  /* if no gots buffer, get one */
    if(!(s->_base=malloc(_piob[fd]._size))){
      errno=ENOMEM;
      raise(SIGALLOC);
    }
  }
  if(_osfile[fd]&_IODIRTY){  /* if we already got it, write it */
    count=_piob[fd]._size-(s->_cnt+1);
    if(write(fd,s->_base,count)!=count){
      errno=EBADF;
      raise(SIGWRITE);
    }
  }
  _osfile[fd]|=_IODIRTY;  /* update the buffer */
  s->_cnt=_piob[fd]._size-1;
  s->_ptr=s->_base;
  *s->_ptr++=c;  /* how well we know operator binding! */
  return c;
err:
  return EOF;
}

+ARCHIVE+ _fmalloc.c    2626  9/11/87 17:57:50
/* _fmalloc - far memory allocator
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,10-sep-85,Complete rewrite! New scheme!"
#pragma REVISED "zap,14-oct-85,New header file, alloc.h"
#pragma REVISED "zap,20-oct-86,rename from malloc.c"
#pragma REVISED "zap,3-jun-87,make it more compilcated"
#pragma REVISED "zap,18-jun-87,ROMS"
#pragma REVISED "zap,11-sep-87,remove add_to_ptr()"
#endif

#include <stdio.h>
#include <_alloc.h>

extern void far *sbrk();
extern struct ffree_list_item far *_fprimary_free_list;
extern struct ffree_list_item far *_fsecondary_free_list;
extern int _fsecondary_list_count;
extern unsigned _amblksize;


void far *_fmalloc(requested_size)
unsigned requested_size;
{
  struct ffree_list_item far *malloc_ptr;
  struct ffree_list_item far *last_ptr;
  struct ffree_list_item far *mem_ptr;
  unsigned tmp;

  if(requested_size>0xFFE8) return (void far *)0;
  requested_size=(requested_size>MIN_FALLOC)
       ? (requested_size+1)&0xFFFE : MIN_FALLOC;

  malloc_ptr=_fsecondary_free_list;
  while(malloc_ptr!=(void far *)0){
    if(malloc_ptr->length==(long)requested_size){
      if(malloc_ptr==_fsecondary_free_list)
        _fsecondary_free_list=_fsecondary_free_list->next;
      else last_ptr->next=malloc_ptr->next;
      --_fsecondary_list_count;
      malloc_ptr->next=ptrtoabs(malloc_ptr);  /* ignore warnings this line */
      return abstoptr(ptrtoabs(malloc_ptr)+FHF_SIZE);
    } 
    last_ptr=malloc_ptr;
    malloc_ptr=malloc_ptr->next;
  }

again:
  if(_fsecondary_free_list) _fmerge_free_lists();
  if(_fprimary_free_list){
    if(!(last_ptr=_fmalloc_find(_fprimary_free_list,requested_size))){
      malloc_ptr=_fprimary_free_list;
      _fprimary_free_list=_fmalloc_take(malloc_ptr,requested_size);
    } else if(last_ptr->next){
      malloc_ptr=last_ptr->next;
      last_ptr->next=_fmalloc_take(malloc_ptr,requested_size);
    } else malloc_ptr=(void far *)0;
  } else malloc_ptr=(void far *)0;

#ifndef ROM_PROG
  if(malloc_ptr==(void far *)0){   /* call the O.S. */
    tmp = requested_size+FHF_SIZE < _amblksize 
                ? _amblksize : requested_size+FHF_SIZE;
    if(malloc_ptr=sbrk(tmp)){
      malloc_ptr->next=ptrtoabs(malloc_ptr);  /* ignore warning */
      malloc_ptr->length=tmp-FHF_SIZE;
      _ffree(malloc_ptr+1);
      goto again;
    } else return (void far *)0;
  }

#else
  if(malloc_ptr==(void far *)0){   /* give up */
    return (void far *)0;
  }
#endif

  return abstoptr(ptrtoabs(malloc_ptr)+FHF_SIZE);
}

+ARCHIVE+ _fmsize.c      528  9/11/87 17:58:38
/*  _fmsize.c - how big is that allocated far block
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,8-aug-86,new function"
#pragma REVISED "zap,21-oct-86,far"
#pragma REVISED "zap,11-sep-87,remove add_to_ptr()"
#endif

#include <_alloc.h>

unsigned _fmsize(cp)
char far *cp;
{
  struct ffree_list_item far *fp;

  fp=abstoptr(ptrtoabs(cp)-FHF_SIZE);
  if(fp->next!=ptrtoabs(fp)) return 0;  /* ignore warning */
  return (unsigned)fp->length;
}
+ARCHIVE+ _freect.c     1368 12/22/86 12:43:06
/* _freect - how many times can I allocate this much memory
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,31-oct-86,creation"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#endif

#include <malloc.h>
#include <_alloc.h>
#include <dos.h>

#ifdef _FLAGS_Af
extern struct ffree_list_item *_fprimary_free_list;
#else
extern struct nfree_list_item *_nprimary_free_list;
#endif


unsigned _freect(size)
unsigned size;
{

#ifdef _FLAGS_Af
  struct ffree_list_item far *p;
  register unsigned count=0,bsize;
  struct regval regs;

  regs.ax=0x4800;  /* forst look at memory */
  regs.bx=0xFFFF;
  if(!(sysint21(&regs,&regs)&1)) count=0;  /* this can't happen, honest */
  else count=((long)regs.bx<<4)/(size+FHF_SIZE);

  _fmerge_free_lists();  /* then peruse the free list */
  p=_fprimary_free_list;
  bsize=size+FHF_SIZE;
  while(p){
    if(p->length>=size){
       count++;
       count+=(p->length-size)/bsize;
    }
    p=p->next;
  }


#else
  struct nfree_list_item *p;
  register unsigned count=0,bsize;

  _nmerge_free_lists();  /* peruse the free list */
  p=_nprimary_free_list;
  bsize=size+FHN_SIZE;
  while(p){
    if(p->length>=size){
       count++;
       count+=(p->length-size)/bsize;
    }
    p=p->next;
  }

#endif

  return count;
}
+ARCHIVE+ _j0.c         1763 10/09/87 18:21:56
/* library function: Bessel Function - J0
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma CREATED "ahm,17-aug-87"
#endif

/*	function:	_j0(x) 
*		Calculate Bessel function Jo(X) for any real X.
*
* 	Note:	Algorithm taken from:
*		Numerical Recipes, Cambridge University Press; pg. 172-3.
*/

#include		<stdlib.h>
#include		<math.h>

#define		P1		1.0					/* Polynomial constants */
#define		P2    -1.098628627e-3
#define		P3    2.734510407e-5 
#define		P4    -2.073370639e-6 
#define		P5    2.093887211e-7 

#define		Q1    -1.562499995e-2 		/* Polynomial constants */
#define		Q2    1.430488765e-4 
#define		Q3    -6.911147651e-6 
#define		Q4    7.621095161e-7 
#define		Q5    -9.34945152e-8 

#define		R1    57568490574.0 		/* Polynomial constants */
#define		R2    -13362590354.0 
#define		R3    651619640.0 
#define		R4    -11214424.18 
#define		R5    77392.33017 
#define		R6    -184.9052456 

#define		S1    57568490411.0 		/* Polynomial constants */
#define		S2    1029532985.0 
#define		S3    9494680.718 
#define		S4    59272.64853 
#define		S5    267.8532712 
#define		S6    1.0

#define		CONST1		0.785398164
#define		CONST2		0.636619772


double _j0(x)
double x;
{
	double	abs_x,
				y,
				z,
				bessj0;

	abs_x = fabs(x);
	if (abs_x < 8){
		y = x*x;
		bessj0 = (R1 + y*(R2 + y*(R3 + y*(R4 + y*(R5 + y*R6)))))
					/(S1 + y*(S2 + y*(S3 + y*(S4 + y*(S5 + y*S6)))));
	}
 	else {
		y = square(8.0/abs_x);
		z = abs_x - CONST1;
		bessj0 = sqrt(CONST2/abs_x) *
					(cos(z) * (P1 + y*(P2 + y*(P3 + y*(P4 + y*P5)))) -
					 (8.0/abs_x) * sin(z) *
								       (Q1 + y*(Q2 + y*(Q3 + y*(Q4 + y*Q5)))) );
	}
  return bessj0;
}






+ARCHIVE+ _j1.c         1781 10/09/87 18:22:16
/* library function: Bessel Function - J0
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma CREATED "ahm,18-aug-87"
#endif

/*	function:	_j1(x) 
*		Calculate Bessel function J1(X) for any real X.
*
* 	Note:	Algorithm taken from:
*		Numerical Recipes, Cambridge University Press; pg. 173-4.
*/

#include		<stdlib.h>
#include		<math.h>

#define		P1		1.0					/* Polynomial constants */
#define		P2    1.83015e-3
#define		P3    -3.516396496e-5 
#define		P4    2.457520174e-6 
#define		P5    -2.40337019e-7 

#define		Q1    0.04687499995 		/* Polynomial constants */
#define		Q2    -2.002690873e-4 
#define		Q3    8.449199096e-6 
#define		Q4    -8.8228987e-7 
#define		Q5    1.05787412e-7 

#define		R1    72362614232.0 		/* Polynomial constants */
#define		R2    -7895059235.0 
#define		R3    242396853.1 
#define		R4    -2972611.439 
#define		R5    15704.48260
#define		R6    -30.16036606 

#define		S1    144725228442.0 		/* Polynomial constants */
#define		S2    2300535178.0 
#define		S3    18583304.74 
#define		S4    99447.43394
#define		S5    376.9991397 
#define		S6    1.0

#define		CONST1		2.356194491
#define		CONST2		0.636619772


double _j1(x)
double x;
{
	double	abs_x,
				y,
				z,
				bessj1;

	abs_x = fabs(x);
	if (abs_x < 8){
		y = x*x;
		bessj1 = x * (R1 + y*(R2 + y*(R3 + y*(R4 + y*(R5 + y*R6)))))
					/(S1 + y*(S2 + y*(S3 + y*(S4 + y*(S5 + y*S6)))));
	}
	else {
		y = square(8.0/abs_x);
		z = abs_x - CONST1;
		bessj1 = sqrt(CONST2/abs_x) *
					(cos(z) * (P1 + y*(P2 + y*(P3 + y*(P4 + y*P5)))) -
					 (8.0/abs_x) * sin(z) *
					 (Q1 + y*(Q2 + y*(Q3 + y*(Q4 + y*Q5)))) ) *
					(x > 0.0 ? 1.0 : -1.0);
		}
	  return bessj1;
}







+ARCHIVE+ _jn.c         1449 10/09/87 18:22:26
/* library function: Bessel Function - Jn
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma CREATED "ahm,18-aug-87"
#endif

/*	function:	_jn(x) 
*		Calculate Bessel function Jn(X) for any real X.
*
* 	Note:	Algorithm taken from:
*		Numerical Recipes, Cambridge University Press; pg. 175.
*/

#include		<stdlib.h>
#include		<math.h>

#define		BIGNO		1.0e10
#define		BIGNI		1.0e-10

double _jn(n,x)
int n;
double x;
{
	int	   i,
				j;
	double	y,
				sum,
			   jsum,
				temp,
				bessj,
				bessjm,
				bessjn;

/* calculate Bessel Function Yn											 */

	if (n == 0)
		return(j0(x));
	
	if (n == 1)
		return(j1(x));
	
	bessjm = j0(x);
	bessjn = j1(x);
	y = 2.0/x;

	if (x > n) {
	 	for (i=1;i<n;i++) {
	 		temp = i*y*bessjn - bessjm;
	 		bessjm = bessjn;
	 		bessjn = temp;
	 	}
	 }
	 else {
	 	j = 2 * floor((n + (floor(sqrt((double)(40*n)))))/2);
	 	bessjn = 0.0;
	 	jsum = 0.0;
	 	sum = 0.0;
	 	temp = 0.0;
	 	bessj = 1.0;
	 	for (i=j;i>=1;i--) {
	 		bessjm = i*y*bessj - temp;
	 		temp = bessj;
	 		bessj = bessjm;
	 		if (fabs(bessj) > BIGNO) {
	 			bessj *= BIGNI;
	 			temp *= BIGNI;
	 			bessjn *= BIGNI;
	 			sum *= BIGNI;
	 		}
	 		if (jsum != 0.0)
	 			sum += bessj;
	 		jsum = 1 - jsum;
	 		if (i == n)
	 			bessjn = temp;
	 	}
	 	sum = 2.0*sum - bessj;
	 	bessjn /= sum;
	 }

	return bessjn;
}




+ARCHIVE+ _main0.c      1979  8/03/87 15:51:40
/* _main_heap - Initialization of the near and far heaps
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,21-oct-86,creation"
#pragma REVISED "zap, 1-mar-87,pointers word aligned"
#pragma REVISED "gee,18-may-87,syntax not ANSI"
#pragma REVISED "zap,11-jun-87,ROMs"
#pragma REVISED "zap,22-jul-87,far heap size for DOS programs"
#endif

#include <_alloc.h>

struct ffree_list_item far *_fprimary_free_list=(void *)0; /* far free list */
struct nfree_list_item near *_nprimary_free_list=(void *)0;/*near free list */

#ifndef ROM_PROG
extern unsigned _heapmod;  /* segment pointer to this module */
extern unsigned _proglen;  /* current paragraph length of the program */
extern unsigned far *_pspseg;  /* PSP */
#endif


void _main0(nh_start, nh_size, fh_start, fh_size)
void near *nh_start;  /* beginning of the near heap */
unsigned nh_size;  /* size of the near heap */
void far *fh_start;  /* beginning of the far heap */
unsigned fh_size;  /* size of the far heap -- paragraphs */
{

  /* Make sure that both pointers are word aligned.
  */
  nh_start = (void near *)(((unsigned)nh_start+1) & -2);
  fh_start = (void far *)(((unsigned long)fh_start+1) & -2L);

  /* Set up the near heap.
  */
  _nprimary_free_list=(struct nfree_list_item near *)nh_start;
  _nprimary_free_list->next=(struct nfree_list_item near *)0;  /* NULL */
  _nprimary_free_list->length=nh_size-FHN_SIZE;

  /* Set up the far heap.
  */
  if(fh_start){
    _fprimary_free_list=fh_start;

#ifndef ROM_PROG
    if(_dosf4a(_proglen+fh_size, _heapmod)){
      bdos(9,"NO CORE$");
      exit(-1);
    }
    _proglen+=fh_size;
    _fprimary_free_list->length=(fh_size<<4)-sizeof(struct ffree_list_item);
    *(_pspseg+1)+=fh_size;

#else
    _fprimary_free_list->length=(fh_size<<4)-FHF_SIZE;
#endif
  
    _fprimary_free_list->next=(struct ffree_list_item far *)0;  /* NULL */
  }
}
+ARCHIVE+ _main1.c      2809  9/11/87 17:59:18
/* _main1() - File initializations
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma REVISED "gee,20-oct-86,begin"
#pragma REVISED "nlp,19-dec-86,_iob initialization"
#pragma REVISED "zap,21-jan-87,buffer for stdin now on heap"
#endif

#include <stdio.h>
#include <dos.h>
#include <fileio3.h>
#include <_alloc.h>

#define STDINFLGS  _IOREAD
#define STDOUTFLGS _IOWRT
#define STDERRFLGS _IONBF|_IOWRT
#define STDAUXFLGS _IONBF|_IORW
#define STDPRNFLGS _IOWRT

FILE _iob[SYS_OPEN] = {   		/* define the thing */
  {NULL,0,NULL,STDINFLGS,0},
  {NULL,0,NULL,STDOUTFLGS,1},
  {NULL,0,NULL,STDERRFLGS,2},
  {NULL,0,NULL,STDAUXFLGS,3},
  {NULL,0,NULL,STDPRNFLGS,4}
};

struct _piobuf _piob[SYS_OPEN] = {      /* define the other thing */
  {'c',BUFSIZ,0L},
  {'c',1,0L},
  {'c',1,0L},
  {'c',1,0L},
  {'c',1,0L}
};

int _osfile[SYS_OPEN] = {		/* dos file control stuff */
  _IOASCII|STDINFLGS,
  _IOASCII|STDOUTFLGS,
  _IOASCII|STDERRFLGS,
  STDAUXFLGS,
  STDPRNFLGS
};

#ifdef _FLAGS_Af
extern struct ffree_list_item *_fprimary_free_list;
#else
extern struct nfree_list_item *_nprimary_free_list;
#endif


void _main1()
{
  struct regval srv;
  register int j,k;
  char far *_main9(), far *cp;
  char *__bufin;

/* buffer for stdin
*/
#ifdef _FLAGS_Af
  __bufin=_fprimary_free_list+1;  /* ignore compiler warning */
  j=(int)_fprimary_free_list->length;
  _fprimary_free_list->length=BUFSIZ;
  _fprimary_free_list->next=ptrtoabs(_fprimary_free_list); /*ignore warning*/
  _fprimary_free_list=abstoptr(ptrtoabs(__bufin)+BUFSIZ);
  _fprimary_free_list->length=(long)(j-FHF_SIZE-BUFSIZ);
  _fprimary_free_list->next=NULL;
#else
  __bufin=_nprimary_free_list+1;  /* ignore compiler warning */
  j=_nprimary_free_list->length;
  _nprimary_free_list->length=BUFSIZ;
  _nprimary_free_list->next=(unsigned)_nprimary_free_list; /*ignore warning*/
  _nprimary_free_list=__bufin+BUFSIZ;  /* ignore compiler warning */
  _nprimary_free_list->length=(long)(j-FHN_SIZE-BUFSIZ);
  _nprimary_free_list->next=NULL;
#endif
  _iob[0]._ptr=__bufin;
  _iob[0]._base=__bufin;

/*	set up stdin, stdout, & stderr
*/
  for(j=0;j<5;++j){
    srv.ax=0x4400;
    srv.bx=j;
    if((~sysint21(&srv,&srv))&1){
      if(srv.dx&0x80){		/* is a character device ? */
        _osfile[j]|=_IOCDEV;			/* yes */
        if(srv.dx&1)_osfile[j]|=_IOCONSOLE;	/* its keyboard in */
      } else _piob[j]._size=BUFSIZ;
    }
    _iob[j]._flag=_osfile[j];
  }
  /* look for C_FILE_INFO  next byte is count, then bytes go to
   _osfile... (but ff's translate to zeros) */
  if(cp=_main9("C_FILE_INFO")){
    j= *cp++&0xff;
    for(k=0;k<j;){
      if((_osfile[k++]=*cp++)==0xff)_osfile[k-1]=0;
    }
  }
}

+ARCHIVE+ _main2.c      2806  9/11/87 17:59:52
/* _main2 - environment processing
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma REVISED "gee,20-nov-86,begin"
#pragma REVISED "zap,3-nov-86,castrated the b*st*rd"
#pragma REVISED "zap,8-nov-86,fleshed it out"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#pragma REVISED "nlp,27-jan-87,environ array built"
#pragma REVISED "zap,10-feb-87,ptr from PSP is far - fix for near data"
#pragma REVISED "zap,2-mar-87,assure heap word alignment"
#pragma REVISED "nlp,27-jul-87,cast on ptr subtract"
#pragma REVISED "zap,11-sep-87,remove add_to_ptr()"
#endif

#include <_alloc.h>

char **environ=(void *)0;

extern unsigned far *_pspseg;

#ifdef _FLAGS_Af
extern struct ffree_list_item far *_fprimary_free_list;
#else
extern struct nfree_list_item near *_nprimary_free_list;
#endif


int _main2()
{
  register unsigned length,elen=0;
  char *ptr, *ep, *cp;
  char far *fcp;
  int retval=-1;
  int i;

#ifdef _FLAGS_Af
  ep=ptr=_fprimary_free_list+1;
#else
  ep=ptr=_nprimary_free_list+1;
#endif

  /* point to environment strings */
  fcp=(char far *)((unsigned long)*(_pspseg+(0x2c/2))<<16);  /* ptr to env */

  /* copy environment into user's program space */
  while(*fcp){
    do{
      *ptr++=*fcp;
      elen++;
    } while(*fcp++);
  }
  *ptr++=0;
  elen++;

  /* check for NO87 */
  cp=ep;
  while(*cp){
    if(!strncmp(cp,"NO87",4)){
      retval=0;
      break;
    }
    cp+=strlen(cp)+1;
  }

  /* build environ[] pointer table (like argv[]) */
  if(P_OFF(ptr)&1) *ptr++=0;  /* assure word alignment */
  environ = ptr;
  for(i=0;*ep;(ep+=(strlen(ep)+1)),++i) {
    environ[i] = ep;
  }
  environ[i]=(char *)0;
  ptr = environ+(i+2);  /* add (i+2)*sizeof(char *) */

  /* adjust heap */
#ifdef _FLAGS_Af  /* ignore compiler warnings below */
  length=(unsigned)_fprimary_free_list->length
                                    -ptrdiff(ptr,_fprimary_free_list);
  length = (length+1) & (-2);   /* force even */
  _fprimary_free_list=ptr;
  _fprimary_free_list->next=(struct ffree_list_item *)0;
  _fprimary_free_list->length=(unsigned long)length;
  ptr=abstoptr(ptrtoabs(environ[0])-FHF_SIZE);
  ((struct ffree_list_item *)ptr)->next=ptrtoabs(ptr);
  ((struct ffree_list_item *)ptr)->length=(unsigned long)elen;
#else
  length=_nprimary_free_list->length-(unsigned)(ptr-(char *)_nprimary_free_list);
  length = (length+1) & (-2);   /* force even */
  _nprimary_free_list=ptr;
  _nprimary_free_list->next=(struct nfree_list_item *)0;
  _nprimary_free_list->length=length;
  ptr=environ[0]-FHN_SIZE;
  ((struct nfree_list_item *)ptr)->next=ptr;
  ((struct nfree_list_item *)ptr)->length=elen;
#endif

  return retval;  /* 0 to ignore 8087, -1 otherwise */
}

+ARCHIVE+ _main3.c      5852  7/27/87 21:02:24
/* _main3 - argument processing
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma REVISED "gee,20-nov-86,begin"
#pragma REVISED "zap,3-nov-86,hack, hack, hack"
#pragma REVISED "zap,8-nov-86,remove allocs and hack the free list directly"
#pragma REVISED "zap,8-nov-86,argv[0] for DOS 3+"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#pragma REVISED "nlp,21-jan-87,wildcard expansion"
#pragma REVISED "nlp,22-jan-87,double quote inside double quote"
#pragma REVISED "nlp,22-jan-87,stop scan when count exhausted"
#pragma REVISED "zap,4-mar-87,add argv[0]='c' for DOS 2"
#pragma REVISED "nlp,27-jul-87,cast on ptr subtract"
#endif

/* comment out the following line if you want wildcard expansion
   of filenames containing * and ? 
*/
/* #define EXPAND */

#include <malloc.h>
#include <string.h>
#include <ctype.h>
#include <_alloc.h>

short _argc=0;
char **_argv=(char *)0;

extern char far *_pspseg;
extern char *_environ;
extern char _osmajor;

#ifdef _FLAGS_Af
extern struct ffree_list_item far *_fprimary_free_list;
#else
extern struct nfree_list_item near *_nprimary_free_list;
#endif


#ifdef  EXPAND
/*      expand filenames into buffer
*/
struct ff_str { 
  char dummy[21];  /* reserved for dos */ 
  unsigned char attribute;  /* returned attribute */ 
  unsigned time; 
  unsigned date; 
  long size;      /* size of file */ 
  unsigned char fn[13];  /* string containing the filename */ 
}; 
#endif

void _main3()  /* build the arg lists */
{
  char far *cp;         /* command line */
  register tchar=0;     /* index for temp[] */
  char *ptr;   /* pointer into the heap */
  register int cmdl_len;
  char *ap;             /* arg ptr */
  unsigned length;

#ifdef _FLAGS_Af
  ptr=_fprimary_free_list+1;  /* ignore compiler warning */
#else
  ptr=_nprimary_free_list+1;  /* ignore compiler warning */
#endif
 
  if(_osmajor<3){   /** DOS 2 **/
    ptr[tchar++]='c';  /* argv[0] */
    ptr[tchar++]=0;
  } else {          /** DOS 3+ **/
    cp=(char far *)((unsigned long)*((int far *)_pspseg+(0x2c/2))<<16);
    while(*cp) while(*cp++) ;   /* neat, huh? */
    cp+=3;
    while(*cp) ptr[tchar++]=*cp++;  /* argv[0] */
    ptr[tchar++]=0;
  }

  cp=_pspseg+0x81;
  cmdl_len = _pspseg[0x80];

  while(*cp && cmdl_len>0) {
#ifdef  EXPAND
    int tidx = tchar;
#endif
   
   switch(*cp){
      case '\r':      /* end */
      case '\n':
        *cp=0;
        break;
      case 0:         /* skip these */
      case ' ':
      case '\t':
        ++cp;
        --cmdl_len;
        break;
      case '\"':       /* quoted strings here */
        ++cp;
        --cmdl_len;
        while(*cp && *cp!='\"' && (cmdl_len-- > 0)) {
          /* treate \" inside of a quoted literal as a single " */
          if(*cp=='\\' && cp[1]=='\"') {
            ++cp;                 
            --cmdl_len;
          }
          ptr[tchar++]=*cp++;
        }
        ptr[tchar++]=0;
        cp++;
        --cmdl_len;
        break;
      default:        /* remaining arguments */
        while(!isspace(*cp) && *cp && (cmdl_len-- > 0)) 
          ptr[tchar++]=*cp++;
        ptr[tchar++]=0;
#ifdef  EXPAND
        if(strchr(ptr+tidx,'*') || strchr(ptr+tidx,'?')) {
           struct regval srv, rrv;
           struct ff_str ff_area;    
           char filename[128], *pfilename;
           char filepath[128];
           char *cp, *lastp;
           
             strcpy(filename,ptr+tidx);

             /* filepath ends at the last "\ / or :" */
             strcpy(filepath,filename);
             lastp=(char *)0; 
             for(cp=filepath;*cp;++cp) {
               if(strchr(":\\/",*cp)) {
                 lastp = cp;  
               }
             }  
             if(lastp) lastp[1] = '\0';
             else filepath[0] = '\0';

             pfilename = filename;   
             srv.ds=P_SEG(pfilename); 
             srv.dx=P_OFF(pfilename);
             srv.cx=0;         /* mode 0 == regular files */
             bdos(0x1a,&ff_area);  /* set the transfer address */
           
             for(srv.ax = 0x4e00;!(sysint21(&srv,&rrv)&1);srv.ax = 0x4f00) {
               register int len;
           
               len = strlen(filepath)+strlen(ff_area.fn)+1;    
#ifdef _FLAGS_Af  /* ignore compiler warnings below */
               if(tidx+len >= (_fprimary_free_list->length-1024)) break;
#else
               if(tidx+len >= (_nprimary_free_list->length-1024)) break;
#endif
               strcat(strcpy(ptr+tidx,filepath),ff_area.fn);
               tidx += len;    
           }
           tchar = tidx;  /* new index in buffer */
        }
#endif
    }
  }

  ptr[tchar]=0;

  /* put argv just beyond the arg list itself */
  _argv = ptr+tchar+1;  

  /* initialize the argv array */
  for(_argc=0,ap=ptr;*ap;++_argc) {
   _argv[_argc] = ap;
   while(*ap++) ;               /* skip to next in list */
  }
  _argv[_argc]=(void *)0;

  /* set pointer to just beyond the argv[] array */
  ptr = 1 + ap + ((_argc+1) * (sizeof (char *)));
  if(P_OFF(ptr)&1) *ptr++=0;

#ifdef _FLAGS_Af  /* ignore compiler warnings below */
  length=(unsigned)_fprimary_free_list->length
                                    -ptrdiff(ptr,_fprimary_free_list);
  length = (length+1) & -2;	/* force size even */
  _fprimary_free_list=ptr;
  _fprimary_free_list->next=(struct ffree_list_item *)0;
  _fprimary_free_list->length=(unsigned long)length;
#else
  length=_nprimary_free_list->length-(unsigned)(ptr-(char *)_nprimary_free_list);
  length = (length+1) & -2;	/* force size even */
  _nprimary_free_list=ptr;
  _nprimary_free_list->next=(struct nfree_list_item *)0;
  _nprimary_free_list->length=length;
#endif
}

+ARCHIVE+ _main4.c       700  9/09/87 10:42:56
/* _main4() - revector ^C and NDP interrupts
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,18-nov-86,creation"
#pragma REVISED "zap,27-mar-87,int 2 patch"
#pragma REVISED "zap,9-sep-87,remove header files"
#endif

extern int _dosf25(int, void far *);
extern void far *_dosf35(int);

void far *_intndp=(void far *)0;  /* vector storage */
void far *_intctlc=(void far *)0;

extern void far _ndpint(void);
extern void far _ctlcint(void);

void _main4(yes87)
int yes87;
{
  _intctlc=_dosf35(0x23);  /* control C */
  _dosf25(0x23,_ctlcint);

  _intndp=_dosf35(2);  /* NDP */
  if(yes87) _dosf25(2,_ndpint);
}

+ARCHIVE+ _main9.c       457 12/22/86 12:41:40
/* _main9() - Search environment for string
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma REVISED "gee,20-nov-86,begin"
#endif

char far *_main9(string)
char *string;
{
  extern char far *_pspseg;
  char far *cp=_pspseg+0x81;
  char *tp;

  while(*cp){
    for(tp=string;*tp==*cp;++cp)if(!*tp++)return cp;
    while(*cp++);	/* skip to end of string */
  }
  return (char far *)0;
}


+ARCHIVE+ _mainlas.c     450 12/22/86 12:41:44
/* _mainlast - set up the program clock
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,2-nov-86,new function"
#endif

#include <time.h>
#include <dos.h>

struct tm _strt_time={0};

void _mainlast()
{
  struct regval regs;

  regs.ax=0x2C00;
  sysint21(&regs,&regs);
  _strt_time.tm_hour=regs.cx>>8;
  _strt_time.tm_min=regs.cx&0xFF;
  _strt_time.tm_sec=regs.dx>>8;
}
+ARCHIVE+ _msize.c       476  9/30/87 15:36:40
/*  _msize.c - how big is that allocated block
**  Copyright (c) 1986,1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,8-aug-86,new function"
#pragma REVISED "zap,21-oct-86,rewrite for near nad far"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#pragma REVISED "zap,move malloc.h"
#endif

unsigned _msize(cp)
char *cp;
{
#include <malloc.h>

#ifdef _FLAGS_Af
  return _fmsize(cp);
#else
  return _nmsize(cp);
#endif
}

+ARCHIVE+ _nfree.c      1600 12/24/86  9:56:50
/* _nfree - near memory freer-upper
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,10-sep-85,Complete rewrite! New scheme!"
#pragma REVISED "zap,14-oct-85,New header file, alloc.h"
#pragma REVISED "zap,20-oct-86,rewrite for near and far"
#endif

#include <stdio.h>
#include <errno.h>
#include <signal.h>
#include <_alloc.h>

extern struct nfree_list_item near *_nprimary_free_list;
extern struct nfree_list_item near *_nsecondary_free_list;
extern int _nsecondary_list_count;

void _nfree(fptr)
char near *fptr;
{
  struct nfree_list_item near *free_ptr;
  struct nfree_list_item near *this_ptr;
  struct nfree_list_item near *last_ptr=(struct nfree_list_item near *)0;

  free_ptr=fptr-FHN_SIZE;  /* ignore warning */
  if(free_ptr->next!=free_ptr){  /* invalid pointer */
    errno=EFREE;
    raise(SIGFREE);
    return;
  }

  this_ptr=_nsecondary_free_list;
  while(this_ptr && this_ptr<free_ptr){
    last_ptr=this_ptr;
    this_ptr=this_ptr->next;
  }
  if(this_ptr==free_ptr){  /* block already free */
    errno=EFREE;
    raise(SIGFREE);
    return;
  }
  if(!last_ptr){
    free_ptr->next=_nsecondary_free_list;
    _nsecondary_free_list=free_ptr;
    _nsecondary_list_count+=_nmerge_free_blocks(free_ptr);
  } else {
    if(free_ptr->next=this_ptr)
      _nsecondary_list_count+=_nmerge_free_blocks(free_ptr)-1;
    last_ptr->next=free_ptr;
    _nsecondary_list_count+=_nmerge_free_blocks(last_ptr);
  }
  if(_nsecondary_list_count==_FREE_LIST_SIZE) _nmerge_free_lists();
}
+ARCHIVE+ _nmalloc.c    1862  3/31/87 11:27:50
/* _nmalloc - near memory allocator
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,20-oct-86,New function"
#pragma REVISED "zap,23-feb-87,bad pointer increment"
#endif

#include <stdio.h>
#include <_alloc.h>

extern struct nfree_list_item near *_nprimary_free_list;
extern struct nfree_list_item near *_nsecondary_free_list;
extern int _nsecondary_list_count;

void near *_nmalloc(requested_size)
unsigned requested_size;
{
  struct nfree_list_item near *malloc_ptr;
  struct nfree_list_item near *last_ptr;
  struct nfree_list_item near *mem_ptr;

  if(requested_size>0xFFE8) return (void near *)NULL;
  requested_size=(requested_size>MIN_NALLOC)
       ? (requested_size+1)&0xFFFE : MIN_NALLOC;

  malloc_ptr=_nsecondary_free_list;
  while(malloc_ptr!=(void near *)NULL){
    if(malloc_ptr->length==requested_size){
      if(malloc_ptr==_nsecondary_free_list)
        _nsecondary_free_list=_nsecondary_free_list->next;
      else last_ptr->next=malloc_ptr->next;
      --_nsecondary_list_count;
      malloc_ptr->next=malloc_ptr;
      return malloc_ptr+1;  /* the size of the header */
    } 
    last_ptr=malloc_ptr;
    malloc_ptr=malloc_ptr->next;
  }

  if(_nsecondary_free_list) _nmerge_free_lists();
  if(_nprimary_free_list){
    if(!(last_ptr=_nmalloc_find(_nprimary_free_list,requested_size))){
      malloc_ptr=_nprimary_free_list;
      _nprimary_free_list=_nmalloc_take(malloc_ptr,requested_size);
    } else if(last_ptr->next!=(void near *)NULL){
      malloc_ptr=last_ptr->next;
      last_ptr->next=_nmalloc_take(malloc_ptr,requested_size);
    } else malloc_ptr=(void near *)NULL;
  } else malloc_ptr=(void near *)NULL;
  if(malloc_ptr==(void near *)NULL) return (void near *)NULL;

  return (void near *)(malloc_ptr+1);
}

+ARCHIVE+ _nmsize.c      436 12/22/86 12:41:50
/*  _nmsize.c - how big is that allocated near block
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,8-aug-86,new function"
#pragma REVISED "zap,21-oct-86,near"
#endif

#include <_alloc.h>

unsigned _nmsize(cp)
char near *cp;
{
  struct nfree_list_item near *np;

  np=cp;  /* ignore warning */
  np--;
  if(np->next!=np) return 0;
  return np->length;
}
+ARCHIVE+ _open.c       3493 11/23/87 16:49:46
/*  _open.c - core routine for creat, open, fopen, sopen
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,20-may-86,complete rewrite"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "gee,1-jan-87,modes"
#pragma REVISED "zap,24-mar-87,new header"
#pragma REVISED "zap,17-nov-87,add seek for append mode"
#endif

#include <fcntl.h>
#include <fileio3.h>
#include <dos.h>
#include <errno.h>

int _open(path, mode, share, permit)
unsigned char *path;
unsigned mode, share, permit;
{
  struct regval sregs,rregs,dtareg;
  register int handle=-1;
  extern int _psp;

  sregs.ds=P_SEG(path);
  sregs.dx=P_OFF(path);

  if(mode&O_CREAT){  		/* create a file */
    sregs.cx=(permit^0x100)>>8;
    if(mode&O_EXCL){  		/* don't create it if it already exists */
      sregs.ax=0x5B00;  		/* DOS 3 */
      if(!(sysint21(&sregs,&rregs)&1)) handle=rregs.ax;
      goto check_status;
    }
    dtareg.ax=0x1A00;		/* have to set dta for following */
    dtareg.ds=_psp;		/* out of harms way */
    dtareg.dx=0x80;		/* in prog segment prefix */
    sysint21(&dtareg,&dtareg);	/* set it */
    sregs.ax=0x4E00;		/* see if file exists */
    sregs.cx=0;			/* see only normal files */
    if(sysint21(&sregs,&rregs)&1){
      sregs.ax=0x3C00;
      sregs.cx=(permit^0x100)>>8;
      if(!(sysint21(&sregs,&rregs)&1)) handle=rregs.ax;
      goto check_status;
    }
  }
  if(mode&O_TRUNC){  		/* truncate an existing file */
    dtareg.ax=0x1A00;		/* have to set dta for following */
    dtareg.ds=_psp;		/* out of harms way */
    dtareg.dx=0x80;		/* in prog segment prefix */
    sysint21(&dtareg,&dtareg);	/* set it */
    sregs.ax=0x4E00;		/* see if file exists */
    sregs.cx=0;			/* see only normal files */
    if(!(sysint21(&sregs,&rregs)&1)){
      sregs.ax=0x3C00;
      sregs.cx=(permit^0x100)>>8;
      if(!(sysint21(&sregs,&rregs)&1)) handle=rregs.ax;
    }
    goto check_status;
  }
  sregs.ax=0x3D00;		/* just open it */
  sregs.ax|=mode&3;
  sregs.ax|=share;
  if(!(sysint21(&sregs,&rregs)&1)) handle=rregs.ax;

check_status:
  if(handle==-1) switch(rregs.ax){
    case 1: errno=EINVAL;
            break;
    case 2:
    case 3: errno=ENOENT;
            break;
    case 4: errno=EMFILE;
            break;
    case 5:
    case 12: errno=EACCES;
             break;
    case 80: errno=EEXIST;
             break;
    default: errno=EINVAL;
  } else {
    if(mode&O_TEXT) _osfile[handle]|=_IOASCII;
    if(mode&O_APPEND){
      struct regval srv;

      _osfile[handle]|=_IOAPPEND;
      srv.ax=0x4202;
      srv.bx=handle;
      srv.cx=0;
      srv.dx=0;
      if(sysint21(&srv,&srv)&1) errno=EACCES; /* should never happen */
    }
    sregs.ax=0x4400;
    sregs.bx=handle;
    if(sysint21(&sregs,&rregs)&1) errno=EACCES; /* should never happen */
    if(rregs.dx&0x80){
      _osfile[handle]|=_IOCDEV;
      if(rregs.dx&1) _osfile[handle]|=_IOCONSOLE;
      if(mode&O_TEXT){  /* character devices should be raw (unbuffered) */
        sregs.ax=0x4401;
        sregs.bx=handle;
        sregs.dx=(rregs.dx&0x00FF)|0x20; /* binary */
        if(sysint21(&sregs,&rregs)&1) errno=EACCES; /* should never happen */
      }
    }
    if(mode&O_RDWR) _osfile[handle]|=_IORW;
    else if(mode&O_WRONLY) _osfile[handle]|=_IOWRT;
    else _osfile[handle]|=_IOREAD;
  }
  _piob[handle]._foffset=0L;

  return handle;
}
+ARCHIVE+ _raise.c      1328 12/22/86 12:41:56
/* _raise - signal handling support routines
   CREATED for C86 v3.0 
   Copyright (c) 1985,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,9-25-85,New function"
#pragma REVISED "zap,10-9-85,four new signal handlers"
#pragma REVISED "zap,4-10-85,rename from _kill to _raise"
#endif

#include <errno.h>

int _sig_abrt_dfl(pid)  /* abort */
int pid;
{
  bdos(9,"PROCESS ABORTED$");
  _exit(1);
}

int _sig_fpe_dfl(pid)  /* floating point exception */
int pid;
{
  bdos(9,"FLOATING POINT EXCEPTION$");
  _exit(1);
}

int _sig_ill_dfl(pid)  /* illegal instruction */
int pid;
{
  bdos(9,"ILLEGAL INSTRUCTION$");
  _exit(1);
}

int _sig_int_dfl(pid)  /* ^C */
int pid;
{
  _exit(1);
}

int _sig_segv_dfl(pid)  /* bad data address */
int pid;
{
  errno=EDOM;
  return 0;
}

int _sig_term_dfl(pid)  /* terminate */
int pid;
{
  _exit(0);
}

int _sig_read_dfl(pid)
int pid;
{
  bdos(9,"READ$");
  _exit(1);
}

int _sig_write_dfl(pid)
int pid;
{
  bdos(9,"WRITE$");
  _exit(1);
}

int _sig_alloc_dfl(pid)
int pid;
{
  bdos(9,"ALLOC$");
  _exit(1);
}

int _sig_free_dfl(pid)
int pid;
{
  bdos(9,"FREE$");
  _exit(1);
}

int _sig_null(pid)  /* ignore signal */
int pid;
{
  /*** NULL FUNCTION ***/
  return 0;
}
+ARCHIVE+ _signal.c      319 12/22/86 12:41:58
/* _signal - signal handling initialization routines
** CREATED for C86 v3.0 
** Copyright (c) 1985,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#include <signal.h>

void _sigint2(pid)
int pid;
{
  (*_sig_eval[SIGFPE])(pid);
}

void _sigint23(pid)
int pid;
{
  (*_sig_eval[SIGINT])(pid);
}

+ARCHIVE+ _spawn.c      5160  7/28/87 16:57:54
/* spawn - all variations
** Copyright (C) 1986,87 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "nlp,02-jan-87,stab"
#pragma REVISED "nlp,08-jan-87,small model"
#pragma REVISED "nlp,27-jan-87,small model fixes, environ"
#pragma REVISED "nlp,28-jan-87,copy environment over, cheap thrills"
#pragma REVISED "nlp,29-jan-87,PROVISIONAL envseg ==0 for now"
#pragma REVISED "nlp,26-feb-87,call to loadexec now small compatible"
#pragma REVISED "zap,05-mar-87,buffers for FCBs; environment"
#pragma REVISED "zap,05-mar-87,rework path stuff, remove PROVISIONAL"
#pragma REVISED "zap,11-mar-87,split off user-level entry points"
#pragma REVISED "zap,16-mar-87,check for directory"
#pragma REVISED "zap,28-jul-87,clean up errno and return values"
#endif

#include <stdio.h>
#include <string.h>
#include <dos.h>
#include <errno.h>
#include <ctype.h>
#include <process.h>
#include <malloc.h>
#include <signal.h>
#include <stdlib.h>


/* Find the program and return it. Return zero on success.
*/
static int near _scan_path(pathstr,store,psearch)
char *pathstr,*store;
int psearch;
{
  register char *ep;
  struct regval s;

  if(!access(pathstr,0)){  /* first try the CWD... */
    s.ax=0x4300;
    s.ds=P_SEG(pathstr);
    s.dx=P_OFF(pathstr);
    if(!(sysint21(&s,&s)&1)){
      if(!(s.ax&0x10)){
        strcpy(store,pathstr);
        return 0;
      }
    }
  }

  /* ...then, if it's not a full path name... */
  if(!strchr(pathstr,':') && pathstr[0]!='\\' && psearch){
    if(ep=getenv("PATH")){  /* ...try the path... */
      strcpy(store,strtok(ep,";"));
      do {
        if(store[strlen(store)-1]!='\\') strcat(store,"\\");
        if(!access(strcat(store,pathstr),0)){
          s.ax=0x4300;
          s.ds=P_SEG(store);
          s.dx=P_OFF(store);
          if(!(sysint21(&s,&s)&1)) if(!(s.ax&0x10)) return 0;
        }
        ep=strtok(NULL,";");
        if(ep) strcpy(store,ep);
      } while(ep);
    }
  }
  if(!strchr(pathstr,'.')){  /* ...or maybe we should add an extention */
    return _scan_path(strcat(pathstr,".exe"),store,psearch);
  }
  return -1;  /* no go */
}


/* Attempt to spawn the process.
*/
static int near __dospawn(flags,pathname,cmdl,envp)
int flags;	/* ignore for now, no chaining */
char *pathname, *cmdl, **envp;
{
  struct pblock b, *pb = &b;
  extern int errno;
  register i, envsize;
  char *p=NULL, *cp;
  char fcb1[37],fcb2[37];

  /* build new, expensive environment */
  if(!envp) b.env=0;
  else {
    for(envsize=0,i=0;envp[i];++i) {  /* find out how much */
      envsize += (strlen(envp[i])+1);
    }
    envsize += strlen(pathname) + 8; /* add path name and pad chars to env */
    envsize += (16+1);

    if(!(p=malloc(envsize))) {    /* allocate memory */
      raise(SIGALLOC);
      return -1;
    }

    b.env=(P_SEG(p)+((P_OFF(p)>>4)+1));  /* set environment to b.env:0 */
    cp=p-(P_OFF(p)&0xf)+0x10;  /* copy it over into appropriate format */

    for(i=0;envp[i];++i){
      strcpy(cp,envp[i]);
      cp += (strlen(cp)+1);
    }
    *cp++=0;
    *cp++=1;
    *cp++=0;
    if(!strrchr(pathname,'\\')) strcpy(cp,pathname);
    else strcpy(cp,strrchr(pathname,'\\'));
  }

  b.com_line = cmdl;
  b.com_line[0]=strlen(cmdl+1); /* length */

  for(;*cmdl;++cmdl) {  /* skip argv[0] */
    if(strchr(" \t+/",*cmdl)) {    /* legal separators ? */
      ++cmdl;
      break;  
    }
  }

  b.fcb1=&fcb1[0];  /* set up the fcbs */
  b.fcb2=&fcb2[0];

  if(*cmdl) {  /* parse filenames into fcbs */
    struct regval srv;
    
    srv.ax = 0x2901;                    /* 1st fcb */
    srv.ds = P_SEG(cmdl);
    srv.si = P_OFF(cmdl);
    srv.es = P_SEG(b.fcb1);
    srv.di = P_OFF(b.fcb1);    
    if(!(sysint21(&srv,&srv)&1)) {      
       srv.ax = 0x2901;                 /* 2nd fcb */        
       srv.es = P_SEG(b.fcb2);
       srv.di = P_OFF(b.fcb2);    
       sysint21(&srv,&srv);
    }
  }

  /* load it */
  if(i = loadexec((char far *)pathname, (struct pblock far *)pb,0)){
    if(i==2) errno=ENOENT;  /* convert DOS error returns to errno values */
    else if(i==8) errno=ENOMEM;
    else if(i==11) errno=ENOEXEC;
    else errno=EMFILE;  /* as good a guess as any */
  }

  if(p) free(p);  /* environment */

  if(!i) {  /* return process return status */
    struct regval srv;
    srv.ax = 0x4d00;
    return (sysint21(&srv,&srv)&1) ? -1 : srv.ax;
  }
  return -1;
}



/* Process the arguments.
*/
int _spawn(flags,prog,argv,envp,psearch)
int flags;
char *prog;
char *argv[];
char *envp;
int psearch;  /* should I search the path ? */
{
  extern int errno;
  char cmdl[129];
  char tmp[256],pname[128];
  register char *cp;

  if(flags!=P_WAIT) {
    errno = EINVAL;
    return -1;
  }

  cmdl[1]=0;		/* build the command line */
  while(*++argv){
    strcat(cmdl+1," ");
    strcat(cmdl+1,*argv);
  }

  strcpy(tmp,prog);
  strcpy(pname,prog);
  if(_scan_path(pname,tmp,psearch)) return -1;  /* errno set by _scan_path */
  return __dospawn(flags,tmp,cmdl,envp);
}

+ARCHIVE+ _time.c       1681 12/22/86 12:42:04
/* _time - get actual time from operating system
** Gets time,date from system and records in struct type tm.
** also computes abs seconds from 01/01/70
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,4-nov-85,add header, copyright"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <time.h>

#define SECS 86400  
#define BASEYEAR 70

long _time(date)
struct tm *date;
{
  long abssec,julian,absdate;
  static unsigned char days[]={31,28,31,30,31,30,31,31,30,31,30,31};
  register int i,j=0;
  struct regval { unsigned int ax,bx,cx,dx,si,di,ds,es; } srv;

  srv.ax=0x2a00;
  if(sysint21(&srv,&srv)&1)return(-1);
  date->tm_year=srv.cx-1900;  /* year (less 1900) */
  date->tm_mday=srv.dx&0x00ff;  /* day  (1 - 31) */
  date->tm_mon=(srv.dx>>8)-1;  /* mon  (0 - 11) */
  date->tm_wday=srv.ax&0x00ff;  /* day in week (sun=0) */

  srv.ax=0x2c00;
  if(sysint21(&srv,&srv)&1)return(-1);
  date->tm_hour=srv.cx>>8;  /* hour */
  date->tm_min=srv.cx&0xff;  /* min */
  date->tm_sec=srv.dx>>8;  /* sec */
                                                /* Calculate Julian date */
  if(date->tm_year % 4==0) days[1]=29;  /* Check for leap year */
  for(i=0;i<date->tm_mon;j+=days[i++]);  /* Add up days before this mon */
  date->tm_yday=j+date->tm_mday-1;  /* Julian date - 1 */

   /* absdate = days since 12/31/69 */

  absdate=(((date->tm_year-BASEYEAR)+1)/4)
               +(date->tm_year-BASEYEAR)*365
               +date->tm_yday;

  abssec=absdate*SECS+(long)date->tm_hour*3600
   	        +(long)date->tm_min*60+(long)date->tm_sec;

  return abssec;
}
+ARCHIVE+ _tolower.c     322 12/22/86 12:42:08
/* _tolower - return lower case if c is upper, else undefined
** Copyright (c) 1984,85 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in, unsigned to int"
#endif

int _tolower(c)
int c;
{
  return c+'a'-'A';
}

 
+ARCHIVE+ _toupper.c     332 12/22/86 12:42:10
/* _toupper - return uppercase if it's a lower case, else undefined
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in, unsigned to int"
#endif

int _toupper(c)
int c;
{
   return c+'A'-'a';
}

 
+ARCHIVE+ _y0.c         1868 10/09/87 19:01:20
/* library function: Bessel Function - Y0
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma CREATED "ahm,18-aug-87"
#endif

/*	function:	_yo(x)
*		Calculate Bessel function Y0(X) for any real X.
*
* 	Note:	Algorithm taken from:
*		Numerical Recipes, Cambridge University Press; pg. 173.
*/

#include		<stdlib.h>
#include		<math.h>
#include		<_math.h>

#define		P1		1.0						/* Polynomial constants */
#define		P2    -1.098628627e-3
#define		P3    2.734510407e-5 
#define		P4    -2.073370639e-6 
#define		P5    2.093887211e-7 

#define		Q1    -1.562499995e-2 		/* Polynomial constants */
#define		Q2    1.430488765e-4 
#define		Q3    -6.911147651e-6 
#define		Q4    7.621095161e-7 
#define		Q5    -9.34945152e-8 

#define		R1    -2957821389.0	 		/* Polynomial constants */
#define		R2    7062834065.0 
#define		R3    -512359803.6 
#define		R4    10879881.29 
#define		R5    -86327.92757 
#define		R6    228.4622733 

#define		S1    40076544269.0 			/* Polynomial constants */
#define		S2    745249964.8
#define		S3    7189466.438 
#define		S4    47447.26470 
#define		S5    226.1030244 
#define		S6    1.0

#define		CONST1		0.785398164
#define		CONST2		0.636619772

extern double _fac;

double *_y0(x)
double x;
{
	double	y,
				z,
				*bessy0;
	struct exception exc;

  bessy0=&_fac;

	if (x < 8){
	     y = x*x;
		  z = *_j0(x);
		  z *= log(x);
		  _fac = (R1 + y*(R2 + y*(R3 + y*(R4 + y*(R5 + y*R6)))))
				     /(S1 + y*(S2 + y*(S3 + y*(S4 + y*(S5 + y*S6))))) +
				     CONST2 * z ;
  }
	else {
		y = square(8.0/x);
		z = x - CONST1;
		_fac = sqrt(CONST2/x) *
		  		   (sin(z) * (P1 + y*(P2 + y*(P3 + y*(P4 + y*P5)))) +
				   (8.0/x) * cos(z) *
							       (Q1 + y*(Q2 + y*(Q3 + y*(Q4 + y*Q5)))) );
  }
  return bessy0;
}







+ARCHIVE+ _y1.c         1971 11/11/87 16:09:16
/* library function: Bessel Function - Y1
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma CREATED "ahm,18-aug-87"
#pragma CREATED "ahm,11-nov-87,had wrong values of S*"
#endif

/* function:   _y1(x)
*  	Calculate Bessel function Y1(X) for any real X.
*
*  Note: Algorithm taken from:
*  	Numerical Recipes, Cambridge University Press; pg. 174.
*/

#include    <stdlib.h>
#include    <math.h>
#include    <_math.h>

#define  	P1		1.0					/* Polynomial constants */
#define		P2    1.83015e-3
#define		P3    -3.516396496e-5 
#define		P4    2.457520174e-6 
#define		P5    -2.40337019e-7 

#define		Q1    0.04687499995 		/* Polynomial constants */
#define		Q2    -2.002690873e-4 
#define		Q3    8.449199096e-6 
#define		Q4    -8.8228987e-7 
#define		Q5    1.05787412e-7 

#define		R1    -4.900604943e12	 		/* Polynomial constants */
#define		R2    1.275274390e12
#define		R3    -5.153438139e10
#define		R4    7.349264551e8
#define		R5    -4.237922726e6
#define		R6    8.511937936e3

#define		S1    2.499580570e13 			/* Polynomial constants */
#define		S2    4.244419664e11
#define		S3    3.733650367e9
#define		S4    2.245904002e7 
#define		S5    1.020426050e5
#define		S6    3.549632885e2
#define		S7    1.0

#define		CONST1		2.356194491
#define		CONST2		0.636619772

extern double _fac;

double *_y1(x)
double x;
{
	double	y,
				z,
				*bessy1;

  bessy1=&_fac;

	if (x < 8){
	     y = x*x;
		  z = *_j1(x);
		  z *= log(x);
		  z -= 1.0/x;
	     _fac = x * (R1 + y*(R2 + y*(R3 + y*(R4 + y*(R5 + y*R6)))))
				     /(S1 + y*(S2 + y*(S3 + y*(S4 + y*(S5 + y*(S6 + y*S7)))))) +
                CONST2 * z	;
  }
	else {
		y = square(8.0/x);
		z = x - CONST1;
		_fac = sqrt(CONST2/x) *
		  		   (sin(z) * (P1 + y*(P2 + y*(P3 + y*(P4 + y*P5)))) +
				   (8.0/x) * cos(z) *
							       (Q1 + y*(Q2 + y*(Q3 + y*(Q4 + y*Q5)))) );
  }
	return bessy1;
}
+ARCHIVE+ _yn.c          766 10/09/87 18:59:18
/* library function: Bessel Function - Yn
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma CREATED "ahm,18-aug-87"
#endif

/*	function:	_yn(n,x)
*		Calculate Bessel function Yn(X) for any integer n and any real X.
*
* 	Note:	Algorithm taken from:
*		Numerical Recipes, Cambridge University Press; pg. 174.
*/

#include		<stdlib.h>
#include		<math.h>
#include		<_math.h>

double *_yn(n,x)
int n;
double x;
{
	int	   i;
	double	temp,
				bessym,
				*bessyn;

	if(n==0) return _y0(x);
	if(n==1) return _y1(x);

	bessym = *_y0(x);
	bessyn = _y1(x);
	x = 2.0/x;
	for (i=1;i<n;i++) {
		temp = i*x* *bessyn - bessym;
		bessym = *bessyn;
		*bessyn = temp;
	}

	return bessyn;
}



+ARCHIVE+ abort.c        264  9/18/87 11:56:08
/* abort - terminate a process
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,18-nov-86,the original disappeared"
#endif

#include <signal.h>

void abort()
{
  raise(SIGABRT);
}

  
+ARCHIVE+ abs.c          265 12/29/86 19:28:26
/* abs - returns absolute value of an int
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,18-nov-86,the original disappeared"
#endif

int abs(x)
int x;
{
   return x>=0 ? x : -x;
}

  
+ARCHIVE+ abstoptr.c     454  2/06/87 11:25:56
/* abstoptr - convert an absolute address to a pointer
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,19-sep-85,add header, copyright notice, and small model"
#pragma REVISED "zap,15-oct-85,big model only!"
#pragma REVISERD "zap,6-feb-87,far"
#endif

void far *abstoptr(address)
unsigned long address;
{
  return (void far *)((address&0xfL)|((address&0xffff0)<<12L));
}
+ARCHIVE+ access.c       893  7/23/87 13:29:42
/* access.c - find a disk file's access mode
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-apr-86,creation"
#pragma REVISED "zap,10-dec-86,old style declaration"
#pragma REVISED "zap,23-jul-87,turn d: into d:\"
#endif

#include <dos.h>
#include <errno.h>

int access(path, mode)
char *path;
int mode;
{
  struct regval regs;
  char temp[4], *ptemp;

  regs.ax=0x4300;
  if(strlen(path)==2 && path[1]==':'){  /* a raw drive spec */
    temp[0]=path[0];
    temp[1]=':';
    temp[2]='\\';
    temp[3]=0;
    ptemp=temp;
  } else ptemp=path;
  regs.ds=P_SEG(ptemp);
  regs.dx=P_OFF(ptemp);
  if(sysint21(&regs,&regs)&1){
    if(regs.cx==5) errno=EACCES;
    else errno=ENOENT;
    return -1;
  }
  if(regs.cx&1 && (mode==2 || mode==6)){
    errno=EACCES;
    return -1;
  }
  return 0;
}
+ARCHIVE+ acos.c         981 10/09/87 14:59:50
/* acos - arc cosine shell
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-nov-86,separate files for asin and acos"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <errno.h>
#include <float.h>
#include <_math.h>

extern double _fac;

double *acos(x)
double x;
{
  register _temp;
  double *temp;
  struct exception exc;

  _clear87();
  errno=0;
  temp=_acos(x);
  if(errno){    /* EDOM */
    temp=&_fac;
    *temp=0.0;
    exc.type=DOMAIN;
    goto AC1;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
AC1:
    exc.name="acos";
    exc.arg1=x;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}

+ARCHIVE+ alloc.c        618  8/09/87 13:48:02
/* alloc - allocate memory, zero it, and signal if none
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,8-29-85,add header and copyright notice"
#pragma REVISED "nlp,27-feb-87,register + for size up even"
#endif

#include <stdio.h>
#include <errno.h>
#include <signal.h>
#include <malloc.h>

void *alloc(size)
register unsigned size;
{
  register unsigned char *cp;

  size = (size+1) & -2;
  if(cp=malloc(size)) memset(cp,0,size);
  else {
    errno=ENOMEM;
    raise(SIGALLOC);
    return(NULL);
  }
  return (void *)cp;
}
+ARCHIVE+ asctime.c     1527  9/21/87  9:15:12
/* asctime - Reads data in struct type tm (from _time()) & converts to  
**  ASCII 26-byte string in caller. Programmer provides receiving buffer.
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,4-nov-85,add header, copyright"
#pragma REVISED "zap,20-apr-87,remove sprintf(), do it right"
#pragma REVISED "nlp,31-aug-87,safer with strncat, strncpy"
#pragma REVISED "ahm,21-sep-87,removed spaces from Day and Mon tables"
#endif

#include <time.h>
#include <string.h>

static char *convert(i)
register int i;
{
  static char buf[5];
  register int index=4;

  buf[index--]=0;
  while(i){
    buf[index--] = i%10+'0';
    i/=10;
  }
  while(index>1) buf[index--]='0';
  return &buf[++index];
}

char *asctime(tm)
struct tm *tm;
{
  static char *daytable[]={"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
  static char *montable[]={"Jan","Feb","Mar","Apr","May","Jun","Jul",
			   "Aug","Sep","Oct","Nov","Dec"};
  static char timstr[26];

  strncpy(timstr,daytable[tm->tm_wday],4);
  strcat(timstr," ");
  strncat(timstr,montable[tm->tm_mon],3);
  strcat(timstr," ");
  strncat(timstr,convert(tm->tm_mday),2);
  strcat(timstr," ");
  strncat(timstr,convert(tm->tm_hour),2);
  strcat(timstr,":");
  strncat(timstr,convert(tm->tm_min),2);
  strcat(timstr,":");
  strncat(timstr,convert(tm->tm_sec),2);
  strcat(timstr," ");
  strncat(timstr,convert(tm->tm_year+1900),4);
  strcat(timstr,"\n");
  return timstr;
}
+ARCHIVE+ asin.c         963 10/09/87 15:14:18
/* asin - arc sine shell
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-nov-86,separate files for asin and acos"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <errno.h>
#include <float.h>
#include <_math.h>

extern double _fac;

double *asin(x)
double x;
{
  struct exception exc;
  register _temp;
  double *temp;

  _clear87();
  errno=0;
  temp=_asin(x);
  if(errno){
    temp=&_fac;
    *temp=0.0;
    exc.type=DOMAIN;
    goto AS1;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
AS1:
    exc.name="asin";
    exc.arg1=x;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}
+ARCHIVE+ atan.c        1512 10/09/87 16:02:46
/* atan and atan2 - arc tangent shells
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <float.h>
#include <errno.h>
#include <_math.h>

extern double _fac;

static double a[]={  /* return values for trivial cases in atan2() */
  0.0,
  0.523598775598298,
  1.570796326794896,
  1.047197551196597
};


double *atan(x)
double x;
{
  double *r, fabs();
  register _temp;
  struct exception exc;

  _clear87();
  r=_atan(x);
  if((_temp=_status87())&0x80){
    exc.name="atan";
    exc.arg1=x;
    exc.arg2=0;
    exc.retval=*r;
    exc.type=_err_map(_temp);
    if(matherr(&exc)) *r=exc.retval;
  }
  return r;
}


double *atan2(v,u)
double v,u;
{
  register int j,_temp;
  int *ip;
  double *r;
  struct exception exc;

  if(v==0.0){
    r=&_fac;
    *r=0.0;
    if(u==0.0){
      errno=EDOM;
      exc.type=DOMAIN;
      goto AT1;
    }
    return r;
  }
  errno=0;
  r=_atan(v/u);
  if(errno){
    exc.type=DOMAIN;
    goto AT1;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
AT1:
    exc.name="atan2";
    exc.arg1=v;
    exc.arg2=u;
    exc.retval=*r;
    if(matherr(&exc)) *r=exc.retval;
  }
  return r;
}

+ARCHIVE+ atexit.c       336  1/21/87 14:16:34
/* atexit - register routines for execution before termination of program
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "nlp,21-jan-87,created"
#endif

/* atexit - apply this function at exit
*/
int atexit(func)
void (*func)();
{

  return onexit(func);
}

+ARCHIVE+ atof.c         269 12/22/86 12:30:44
/* atof - ascii to double conversion
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,9-aug-85,new function"
#endif

#include <stdlib.h>

double atof(s)
char *s;
{
  return(strtod(s,0L));
}
+ARCHIVE+ atoi.c         542 12/22/86 12:30:46
/* atoi - convert ascii to integer (or long)
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,26-jul-85,add this comment and copyright"
#pragma REVISED "zap,4-jun-86,registers"
#endif

long atoi(s)
char *s;
{
  long j;
  register int sign;

  while(*s==' ' || *s=='\t')++s;	/* skip white space */
  sign=0;
  if(*s=='-')sign=1;
  else if(*s!='+')--s;
  ++s;						/* skip sign data */
  for(j=0;*s>='0' && *s<='9';)j=j*10+(*s++-'0');
  return sign?-j:j;
}
+ARCHIVE+ atol.c         275 12/22/86 12:30:46
/* atol - convert ascii to long int
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,9-aug-85,new function"
#endif

#include <stdlib.h>

long atol(s)
char *s;
{
  return strtol(s,(void *)0,10);
}
+ARCHIVE+ bsearch.c     1224 12/22/86 12:30:50
/*  bsearch.c - binary search
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
**
** Binary search routine -- searches a sorted array pointed to by base
** for a match of key.  compare is a user supplied function that compares
** two objects and returns 1 , 0 , -1 if ob1 is greater, less or equal
** to ob2.  Function also requires size of array and width of an element.
*/
#ifdef HISTORY
#pragma REVISED "zap,13-may-86,add header, copyright"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <stdio.h>

char *bsearch(key,base,num,width,compare)
char *key;  /* Search for */
char *base;  /* Search in   */
unsigned num,width;  /* Number & width of elements */
int (*compare)();  /* Pointer to compare function */
{
  register int mid,high;
  int low,ret;
  char *look_ptr;

  low=0;       /* Start and  */
  high=num-1;  /* End of search */
    
  while(low<=high){  
    mid=(high+low)/2;		    
    look_ptr=base+(width*mid); /* Mid point passed to comp */

    if((ret=(*compare)(key,look_ptr))<0) high=mid-1;
    else if(ret>0) low=mid+1;
    else return look_ptr;     /* Point to matching element */
  }
  return NULL;  /* Couldn't find a match */
}

+ARCHIVE+ calloc.c       708  2/27/87 14:10:48
/* calloc - allocate memory and clear it
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,8-29-85,add header and copyright notice"
#pragma REVISED "nlp,27-feb-87,ssize/size gyrations"
#endif

#include <malloc.h>

void *calloc(nelem, elsize)
unsigned nelem, elsize;
{
  register char *cp;
  register unsigned short ssize;   /* 'tis a 16 bit machine */
  unsigned long size;

  size=(unsigned long)nelem * (unsigned long)elsize;
  if(size>0xffe8) return (void *)0;

  ssize = ((unsigned short)size + 1) & -2;        /* force even, round up */
  if(cp=malloc(ssize)) {
    memset(cp,0,ssize);
  }
  return (void *)cp;
}
+ARCHIVE+ ceil.c         766 10/09/87 16:56:14
/* ceil - return ceiling
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,11-nov-86,8087"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <float.h>
#include <_math.h>

double *ceil(val)
double val;
{
  double *temp;
  register int _temp;
  struct exception exc;
  
  _clear87();
  temp=_ceil(val);
  if((_temp=_status87())&0x80){
    exc.name="ceil";
    exc.arg1=val;
    exc.arg2=0;
    exc.retval=*temp;
    exc.type=_err_map(_temp);
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}
 
+ARCHIVE+ chdir.c        690  7/23/87 13:49:28
/* chdir - change directory for dos 2.00+
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,22-oct-85, header, copyright, no check for old dos"
#pargma REVISED "zap,23-jul-87, handle a raw drive spec"
#endif

#include <dos.h>

int chdir(dir)
char *dir;
{
  struct regval srv;
  char temp[4], *ptemp;

  if(strlen(dir)==2 && dir[1]==':'){  /* a raw drive spec */
    temp[0]=dir[0];
    temp[1]=':';
    temp[2]='\\';
    temp[3]=0;
    ptemp=temp;
  } else ptemp=dir;
  srv.ds=P_SEG(ptemp);
  srv.dx=P_OFF(ptemp);
  srv.ax=0x3B00;
  return -(sysint21(&srv,&srv)&1);	/* return -1 on failure */
}
+ARCHIVE+ chmod.c        429 12/22/86 12:31:00
/* chmod.c - change the mode of a file
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,22-oct-85,header nad copyright"
#endif

#include <dos.h>

int chmod(name, mode)
char *name;
int mode;
{
  struct regval srv;

  srv.ax=0x4301;
  srv.cx=mode;
  srv.dx=P_OFF(name);
  srv.ds=P_SEG(name);
  if(sysint21(&srv,&srv)&1)return -1;
  return 0;
}
+ARCHIVE+ chsize.c      1329  8/09/87 13:48:28
/*  chsize.c - change the size of a file
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,28-apr-86,rewrite for v3"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <dos.h>
#include <stdio.h>
#include <errno.h>
#include <fileio3.h>

int chsize(fd, size)
int fd;
long size;
{
  extern long lseek(), ltell();
  struct regval regs;
  char dummy[512];
  register long end;

  regs.ax=0x4400;
  regs.bx=fd;
  if(sysint21(&regs,&regs)&1){
    errno=EBADF;  /* not open */
    return -1;
  }
  if(regs.dx&0x80){
    errno=EACCES;  /* character device */
    return -1;
  }
  if(!(_osfile[fd]&(_IOWRT|_IORW))){
    errno=EACCES;    /* no write permission */
    return -1;
  }

  if((end=lseek(fd,0L,2))>size){  /* truncate */
    lseek(fd,size,0);
    if(write(fd,dummy,0)<0){
      errno=EACCES;  /* can't write 0 bytes */
      return -1;
    }
  } else {                     /* or extend */
    memset(dummy,0,512);
    while(end>size+512){
      if(write(fd,dummy,512)<0){
        errno=ENOSPC;     /* out of disk space */
        return -1;
      }
      end-=512;
    }
    if(write(fd,dummy,(int)(size-end))<0){
      errno=ENOSPC;     /* out of disk space */
      return -1;
    }
  }
  return 0;
}
+ARCHIVE+ clearerr.c     389 10/22/87 16:40:06
/* clearerr - reset the error indication for a file
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-oct-85,rewrite for v3.0"
#pragma REVISED "zap,22-oct-87,also clear EOF flag"
#endif

#include <stdio.h>
#include <fileio3.h>

void clearerr(stream)
FILE *stream;
{
  stream->_flag&=~(_IOERR|_IOEOF);
}
+ARCHIVE+ clock.c        605 12/22/86 12:31:34
/* clock - return seconds since program start
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,4-nov-85,new function"
#endif

#include <time.h>
#include <dos.h>

extern struct tm _strt_time;

clock_t clock()
{
  clock_t res;
  struct regval regs;

  regs.ax=0x2C00;
  if(sysint21(&regs,&regs)&1) return (clock_t)-1;  /* I doubt it. */
  res=(regs.cx>>8)-_strt_time.tm_hour;
  if(res<0) res+=24;
  res*=60;
  res+=(regs.cx&0xFF)-_strt_time.tm_min;
  res*=60;
  res+=(regs.dx>>8)-_strt_time.tm_sec;
  return res;
}
+ARCHIVE+ close.c        508 12/22/86 12:31:36
/* close.c - close a file
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-jul-85,add this comment & copyright"
#pragma REVISEC "zap,23-may-86,add errno"
#endif

#include <stdio.h>
#include <dos.h>
#include <fileio3.h>
#include <errno.h>

int close(fd)
int fd;
{
  struct regval srv;

  srv.ax=0x3e00;
  srv.bx=fd;
  if(sysint21(&srv,&srv)&1){
    errno=EBADF;
    return -1;
  }
  _osfile[fd]=0;
  return 0;
}

+ARCHIVE+ cos.c          980 10/09/87 17:46:40
/* cos - cosine shell
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-nov-86,separate files for sin and cos"
#pragma REVISED "nlp,6-jul-87, return t"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <float.h>
#include <errno.h>
#include <_math.h>

extern double _fac;

double *cos(arg)
double arg;
{
  double *t;
  register _temp;
  struct exception exc;

  _clear87();
  errno=0;
  t=_cos(arg);
  if(errno){
    t=&_fac;
    *t=0;
    exc.type=DOMAIN;
    goto C1;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
C1:
    exc.name="cos";
    exc.arg1=arg;
    exc.arg2=0;
    exc.retval=*t;
    if(matherr(&exc)) *t=exc.retval;
  }
  return t;
}
+ARCHIVE+ cosh.c        1597 10/09/87 17:48:00
/* cosh - hyperbolic cosine
** algorithm is from Cody & Waite, p. 217
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,simplified,smaller,faster"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-nov-86,exp() to _exp()"
#pragma REVISED "nlp,04-feb-87,exc.name=cosh"
#pragma REVISED "zap,10-jul-87,_math.h"
#pragma REVISED "zap,9-oct-87,hack on overhead"
#endif

#include <math.h>
#include <float.h>
#include <_math.h>
#include <errno.h>

extern double _fac;

#define YBAR 704
#define WMAX 707
#define LNOFV    0.69316101074218750000
#define VOVER2_1 0.13830277879601902638e-4


/* This function computes cosh(x). Cosh(x) is defined to
   be (exp(x) + exp (-x)) / 2.0.
*/ 
double cosh(x)
double x;
{
  double z, w, result;
  register _temp;
  struct exception exc;

  _clear87();
  /* x = _fabs(x), because cosh(-x) = cosh(x) */
  (((unsigned short *)(&x))[3]) &= 0x7fff; /* 8 byte doubles, 8087 format */

  if(x>YBAR){
    w=x-LNOFV;
    if(w>WMAX){    /* the input number is too large  */
      errno=ERANGE;        
      result=HUGE_VAL;
      goto CH1;
    } else {
      z=*_exp(w);
      result=VOVER2_1*z;
    } 
  } else {
    z=*_exp(x);
    result=(z+(1.0/z))/2.0;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
CH1:
    exc.name="cosh";
    exc.arg1=x;
    exc.arg2=0;
    exc.retval=result;
    if(matherr(&exc)) result=exc.retval;
  }
  return result;
}

+ARCHIVE+ cotan.c        934 10/12/87 13:27:38
/* cotan.c - cotangent shell
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-nov-86,separate files for tan() and cotan()"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <float.h>
#include <errno.h>
#include <_math.h>

double *cotan(x)
double x;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  errno=0;
  temp=_cotan(x);
  if(errno){
    *temp=0.0;
    exc.type=DOMAIN;
    goto T1;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
T1:
    exc.name="cotan";
    exc.arg1=x;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}

+ARCHIVE+ creat.c        659  5/28/87  9:46:04
/* creat.c - create a new file, deleting any existing file
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,22-oct-85,call to v3.0 _open() with new arguments"
#pragma REVISED "zap,21-may-86,new v3 revs"
#pragma REVISED "zap,24-mar-87,new header"
#pragma REVISED "nlp,28-may-87, osmajor==2, use 0x100"
#endif


#include <fcntl.h>
#include <sys/stat.h>

extern unsigned _osmajor;
extern unsigned _umask;

int creat(filename, permit)
char *filename;
unsigned permit;
{

  return _open(filename,O_CREAT|O_BINARY|O_RDWR,0
		,((_osmajor==2) ? (S_IREAD) : (permit & (~_umask))));
}
+ARCHIVE+ ctime.c        365 12/22/86 12:31:28
/* ctime - convert calendar time to local time string
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,4-nov-85,new function"
#endif

#include <time.h>

extern char *asctime();
extern struct tm *localtime();

char *ctime(timer)
time_t *timer;
{
  return asctime(localtime(timer));
}
+ARCHIVE+ ctype.c       8057  1/02/87 14:10:54
/* ctype.c for C86 - define _ctype array.
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "gee,31-dec-86,Revised"
#endif

#define HEXIDECIMAL    0x80
#define SPACE          0x40
#define CONTROL        0x20
#define PUNCTUATOR     0x10
#define WHITESPACE     0x08
#define DIGIT          0x04
#define LOWERCASE      0x02
#define UPPERCASE      0x01

char _ctype[257] = {
    0,                              /* 0xffff  -1.     */
    CONTROL,                        /* 0x0      0.     */
    CONTROL,                        /* 0x1      1.     */
    CONTROL,                        /* 0x2      2.     */
    CONTROL,                        /* 0x3      3.     */
    CONTROL,                        /* 0x4      4.     */
    CONTROL,                        /* 0x5      5.     */
    CONTROL,                        /* 0x6      6.     */
    CONTROL,                        /* 0x7      7.     */
    CONTROL,                        /* 0x8      8.     */
    CONTROL|WHITESPACE,             /* 0x9      9.     */
    CONTROL|WHITESPACE,             /* 0xa     10.     */
    CONTROL|WHITESPACE,             /* 0xb     11.     */
    CONTROL|WHITESPACE,             /* 0xc     12.     */
    CONTROL|WHITESPACE,             /* 0xd     13.     */
    CONTROL,                        /* 0xe     14.     */
    CONTROL,                        /* 0xf     15.     */
    CONTROL,                        /* 0x10    16.     */
    CONTROL,                        /* 0x11    17.     */
    CONTROL,                        /* 0x12    18.     */
    CONTROL,                        /* 0x13    19.     */
    CONTROL,                        /* 0x14    20.     */
    CONTROL,                        /* 0x15    21.     */
    CONTROL,                        /* 0x16    22.     */
    CONTROL,                        /* 0x17    23.     */
    CONTROL,                        /* 0x18    24.     */
    CONTROL,                        /* 0x19    25.     */
    CONTROL,                        /* 0x1a    26.     */
    CONTROL,                        /* 0x1b    27.     */
    CONTROL,                        /* 0x1c    28.     */
    CONTROL,                        /* 0x1d    29.     */
    CONTROL,                        /* 0x1e    30.     */
    CONTROL,                        /* 0x1f    31.     */
    SPACE|WHITESPACE,               /* 0x20    32. ' ' */
    PUNCTUATOR,                     /* 0x21    33. '!' */
    PUNCTUATOR,                     /* 0x22    34. '"' */
    PUNCTUATOR,                     /* 0x23    35. '#' */
    PUNCTUATOR,                     /* 0x24    36. '$' */
    PUNCTUATOR,                     /* 0x25    37. '%' */
    PUNCTUATOR,                     /* 0x26    38. '&' */
    PUNCTUATOR,                     /* 0x27    39. ''' */
    PUNCTUATOR,                     /* 0x28    40. '(' */
    PUNCTUATOR,                     /* 0x29    41. ')' */
    PUNCTUATOR,                     /* 0x2a    42. '*' */
    PUNCTUATOR,                     /* 0x2b    43. '+' */
    PUNCTUATOR,                     /* 0x2c    44. ',' */
    PUNCTUATOR,                     /* 0x2d    45. '-' */
    PUNCTUATOR,                     /* 0x2e    46. '.' */
    PUNCTUATOR,                     /* 0x2f    47. '/' */
    HEXIDECIMAL|DIGIT,              /* 0x30    48. '0' */
    HEXIDECIMAL|DIGIT,              /* 0x31    49. '1' */
    HEXIDECIMAL|DIGIT,              /* 0x32    50. '2' */
    HEXIDECIMAL|DIGIT,              /* 0x33    51. '3' */
    HEXIDECIMAL|DIGIT,              /* 0x34    52. '4' */
    HEXIDECIMAL|DIGIT,              /* 0x35    53. '5' */
    HEXIDECIMAL|DIGIT,              /* 0x36    54. '6' */
    HEXIDECIMAL|DIGIT,              /* 0x37    55. '7' */
    HEXIDECIMAL|DIGIT,              /* 0x38    56. '8' */
    HEXIDECIMAL|DIGIT,              /* 0x39    57. '9' */
    PUNCTUATOR,                     /* 0x3a    58. ':' */
    PUNCTUATOR,                     /* 0x3b    59. ';' */
    PUNCTUATOR,                     /* 0x3c    60. '<' */
    PUNCTUATOR,                     /* 0x3d    61. '=' */
    PUNCTUATOR,                     /* 0x3e    62. '>' */
    PUNCTUATOR,                     /* 0x3f    63. '?' */
    PUNCTUATOR,                     /* 0x40    64. '@' */
    HEXIDECIMAL|UPPERCASE,          /* 0x41    65. 'A' */
    HEXIDECIMAL|UPPERCASE,          /* 0x42    66. 'B' */
    HEXIDECIMAL|UPPERCASE,          /* 0x43    67. 'C' */
    HEXIDECIMAL|UPPERCASE,          /* 0x44    68. 'D' */
    HEXIDECIMAL|UPPERCASE,          /* 0x45    69. 'E' */
    HEXIDECIMAL|UPPERCASE,          /* 0x46    70. 'F' */
    UPPERCASE,                      /* 0x47    71. 'G' */
    UPPERCASE,                      /* 0x48    72. 'H' */
    UPPERCASE,                      /* 0x49    73. 'I' */
    UPPERCASE,                      /* 0x4a    74. 'J' */
    UPPERCASE,                      /* 0x4b    75. 'K' */
    UPPERCASE,                      /* 0x4c    76. 'L' */
    UPPERCASE,                      /* 0x4d    77. 'M' */
    UPPERCASE,                      /* 0x4e    78. 'N' */
    UPPERCASE,                      /* 0x4f    79. 'O' */
    UPPERCASE,                      /* 0x50    80. 'P' */
    UPPERCASE,                      /* 0x51    81. 'Q' */
    UPPERCASE,                      /* 0x52    82. 'R' */
    UPPERCASE,                      /* 0x53    83. 'S' */
    UPPERCASE,                      /* 0x54    84. 'T' */
    UPPERCASE,                      /* 0x55    85. 'U' */
    UPPERCASE,                      /* 0x56    86. 'V' */
    UPPERCASE,                      /* 0x57    87. 'W' */
    UPPERCASE,                      /* 0x58    88. 'X' */
    UPPERCASE,                      /* 0x59    89. 'Y' */
    UPPERCASE,                      /* 0x5a    90. 'Z' */
    PUNCTUATOR,                     /* 0x5b    91. '[' */
    PUNCTUATOR,                     /* 0x5c    92. '\' */
    PUNCTUATOR,                     /* 0x5d    93. ']' */
    PUNCTUATOR,                     /* 0x5e    94. '^' */
    PUNCTUATOR,                     /* 0x5f    95. '_' */
    PUNCTUATOR,                     /* 0x60    96. '`' */
    HEXIDECIMAL|LOWERCASE,          /* 0x61    97. 'a' */
    HEXIDECIMAL|LOWERCASE,          /* 0x62    98. 'b' */
    HEXIDECIMAL|LOWERCASE,          /* 0x63    99. 'c' */
    HEXIDECIMAL|LOWERCASE,          /* 0x64   100. 'd' */
    HEXIDECIMAL|LOWERCASE,          /* 0x65   101. 'e' */
    HEXIDECIMAL|LOWERCASE,          /* 0x66   102. 'f' */
    LOWERCASE,                      /* 0x67   103. 'g' */
    LOWERCASE,                      /* 0x68   104. 'h' */
    LOWERCASE,                      /* 0x69   105. 'i' */
    LOWERCASE,                      /* 0x6a   106. 'j' */
    LOWERCASE,                      /* 0x6b   107. 'k' */
    LOWERCASE,                      /* 0x6c   108. 'l' */
    LOWERCASE,                      /* 0x6d   109. 'm' */
    LOWERCASE,                      /* 0x6e   110. 'n' */
    LOWERCASE,                      /* 0x6f   111. 'o' */
    LOWERCASE,                      /* 0x70   112. 'p' */
    LOWERCASE,                      /* 0x71   113. 'q' */
    LOWERCASE,                      /* 0x72   114. 'r' */
    LOWERCASE,                      /* 0x73   115. 's' */
    LOWERCASE,                      /* 0x74   116. 't' */
    LOWERCASE,                      /* 0x75   117. 'u' */
    LOWERCASE,                      /* 0x76   118. 'v' */
    LOWERCASE,                      /* 0x77   119. 'w' */
    LOWERCASE,                      /* 0x78   120. 'x' */
    LOWERCASE,                      /* 0x79   121. 'y' */
    LOWERCASE,                      /* 0x7a   122. 'z' */
    PUNCTUATOR,                     /* 0x7b   123. '{' */
    PUNCTUATOR,                     /* 0x7c   124. '|' */
    PUNCTUATOR,                     /* 0x7d   125. '}' */
    PUNCTUATOR,                     /* 0x7e   126. '~' */
    CONTROL,                        /* 0x7f   127.     */
};

+ARCHIVE+ difftime.c     361  3/18/87 16:38:04
/* difftime - get time difference in seconds
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,4-nov-85,new function"
#pragma REVISED "zap,18-mar-87,tested"
#endif

#include <time.h>

double difftime(time1,time2)
time_t time1,time2;
{
  return (double)((time1-time2)/CLK_TCK);
}
+ARCHIVE+ div.c          556 11/12/87 10:16:14
/*  div.c - strange division
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,7-may-86,new function"
#pragma REVISED "nlp,21-jan-87,new name,new members"
#pragma REVISED "zap,12-nov-87,return the struct, not a pointer"
#endif

#include <stdlib.h>
#include <errno.h>

div_t div(num, denom)
int num, denom;
{
  struct{int quot,rem;} z;

  if(denom==0){
    errno=EDOM;
    z.quot=0;
    z.rem=0;
  } else {
    z.rem=num%denom;
    z.quot=num/denom;
  }
  return z;
}
+ARCHIVE+ dosexter.c     681  1/02/87 16:47:18
/* dosexterr - get DOS extended error information
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,6-dec-85,new function"
#pragma REVISED "zap,25-apr-85,rename from dexterr()"
#pragma REVISED "zap,17-nov-86,argument"
#endif

#include <dos.h>
#include <errno.h>

int dosexterr(err)
struct derrbuf *err;
{
  struct regval reg;

  reg.ax=0x5900;
  reg.bx=0;
  if(sysint21(&reg,&reg)&0x0001){
    errno=0;  /* will never happen */
    return 0;
  }
  if(err){
    err->error=reg.ax;
    err->class=reg.bx>>8;
    err->action=reg.bx&0x00FF;
    err->locus=reg.cx>>8;
  }
  return reg.ax;
}
+ARCHIVE+ dup.c          697 12/22/86 12:31:42
/* dup - duplicate a file handle
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,6-dec-85,new function"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <stdio.h>
#include <fileio3.h>
#include <dos.h>
#include <errno.h>

int dup(fd)
int fd;
{
  struct regval reg;
  register int i;

  for(i=5;i<SYS_OPEN;++i) if(_iob[i]._flag) break;
  if(i>=SYS_OPEN){
    errno=EMFILE;
    return -1;
  }
  reg.ax=0x4500;
  reg.bx=fd;
  if(sysint21(&reg,&reg)&0x0001){
    errno=EBADF;
    return -1;
  }
  _osfile[reg.ax]=_osfile[fd];
  memcpy(&_iob[reg.ax],&_iob[fd],sizeof(FILE));
  return reg.ax;
}
+ARCHIVE+ dup2.c         733 12/24/86  9:58:26
/* dup2 - duplicate a file handle
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,6-dec-85,new function"
#pragma REVISED "zap,6-dec-85,rename from forcdup()"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "nlp,23-dec-86,remove register int i"
#endif

#include <stdio.h>
#include <fileio3.h>
#include <dos.h>
#include <errno.h>

int dup2(fd1, fd2)
int fd1, fd2;
{
  struct regval reg;

  if(_iob[fd2]._flag) close(fd2);
  reg.ax=0x4600;
  reg.bx=fd1;
  reg.cx=fd2;
  if(sysint21(&reg,&reg)&0x0001){
    errno=EBADF;
    return -1;
  }
  _osfile[fd2]=_osfile[fd1];
  memcpy(&_iob[fd2],&_iob[fd1],sizeof(FILE));
  return 0;
}

+ARCHIVE+ ecvt.c         813  7/16/87 16:02:10
/*  ecvt.c - float to ASCII
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-apr-86,new function"
#pragma REVISED "gee,13-aug-86,Added * to def of point and sign"
#pragma REVISED "nlp,16-jul-87,remove extra rubbish"
#endif

static char buf[315];

char *ecvt(value, digits, point, sign)
double value;
int digits, *point, *sign;
{
  char buffer[315], *p0, *p1;

  memset(buf,0,315);
  if(digits<=0){
    buf[0]=0;
    *point=0;
  } else {
    sprintf(buffer,"%+.*e",digits-1,value);
    *sign=(buffer[0]!='+');
    p0=buf;
    *p0++=buffer[1];
    p1=&buffer[3];
    while(*p1!='e'){
      *p0++=*p1++;
      --digits;
    }
    memset(p0,'0',digits-1);
    p1++;
    *point=(int)atoi(p1)+1;
  }
  return buf;
}
+ARCHIVE+ eof.c          406 12/22/86 12:31:48
/*  eof.c - is file at EOF
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,6-may-86,new function"
#endif

#include <dos.h>
#include <errno.h>

int eof(fd)
int fd;
{
  struct regval regs;

  regs.ax=0x4400;
  regs.bx=fd;
  if(sysint21(&regs,&regs)&1){
    errno=EBADF;
    return -1;
  }
  return (regs.dx&0x40) ? 1 : 0;
}
+ARCHIVE+ errno.c        169 12/22/86 12:31:48
/* define the error control field
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#define _REVISED "lpa,7-jun-85"

int errno=0;

 
+ARCHIVE+ execl.c        367  4/15/87 10:06:06
/* execl - list arguments
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-apr-87,creation"
#endif

#include <process.h>

extern int _exec(char *, char **, char *, int);


int execl(prog,args)
char *prog;
char *args;
{
  extern char **environ;

  return _exec(prog,&args,environ,0);
}
+ARCHIVE+ execle.c       468  4/15/87 10:06:30
/* execle - list arguments, environment processing
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-apr-87,creation"
#endif

#include <process.h>

extern int _exec(char *, char **, char *, int);


int execle(prog,args)
char *prog;
char *args;
{
  register char **pargs;

  /* make pargs point to envp */
  for(pargs=&args;*pargs;++pargs) ;
 
  return _exec(prog,&args,pargs[1],0);
}
+ARCHIVE+ execlp.c       386  4/15/87 10:06:44
/* execlp - list arguments, path processing
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-apr-87,creation"
#endif

#include <process.h>

extern int _exec(char *, char **, char *, int);


int execlp(prog,args)
char *prog;
char *args;
{
  extern char **environ;

  return _exec(prog,&args,environ,1);
}
+ARCHIVE+ execlpe.c      487  4/15/87 10:06:58
/* execlpe - list arguments, path processing, environment processing
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-apr-87,creation"
#endif

#include <process.h>

extern int _exec(char *, char **, char *, int);


int execlpe(prog,args)
char *prog;
char *args;
{
  register char **pargs;

  /* make pargs point to envp */
  for(pargs=&args;*pargs;++pargs) ;
 
  return _exec(prog,&args,pargs[1],1);
}
+ARCHIVE+ execv.c        363  4/15/87 10:07:14
/* execv - argument va_list
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-apr-87,creation"
#endif

#include <process.h>

extern int _exec(char *, char **, char *, int);


int execv(prog,argv)
char *prog, **argv;
{
  extern char **environ;

  return _exec(prog,argv,environ,0);
}
+ARCHIVE+ execve.c       383  4/15/87 10:07:38
/* execve - argument va_list, environment processing
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-apr-87,creation"
#endif

#include <process.h>

extern int _exec(char *, char **, char *, int);


int execve(prog,argv,envp)
char *prog;
char *argv[];
char *envp;
{
  return _exec(prog,argv,envp,0);
}
+ARCHIVE+ execvp.c       382  4/15/87 10:07:52
/* execvp - argument va_list, path processing
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-apr-87,creation"
#endif

#include <process.h>

extern int _exec(char *, char **, char *, int);


int execvp(prog,argv)
char *prog, **argv;
{
  extern char **environ;

  return _exec(prog,argv,environ,1);
}
+ARCHIVE+ execvpe.c      390  4/15/87 10:08:06
/* execvpe - argument va_list, environment processing, path processing
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-apr-87,creation"
#endif

#include <process.h>

extern int _exec(char *, char **, char *, int);


int execvpe(prog,argv,envp)
char *prog, **argv,**envp;
{
   return _exec(prog,argv,envp,1);
}
+ARCHIVE+ exit.c        1047  4/24/87 14:14:40
/* exit for DOS 2.0 and above
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTROY
#pragma REVISED "lpa,17-jun-85,created"
#pragma REVISED "lpa,18-jun-85,made this the exit routine, no nore _exit"
#pragma REVISED "zap,3-oct-85,add _exit; restore signal vectors (assembly)"
#pragma REVISED "zap,15-oct-85,add the 'onexit' functions"
#pragma REVISED "zap,17-oct-85,add OS free calls"
#pragma REVISED "zap,5-nov-85,conditionally compile OS free calls (big only)"
#pragms REVISED "zap,6-nov-85,close and delete temp files"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,20-nov-86,pulled in revectoring stuff; no more _exit"
#pragma REVISED "zap,4-feb-87,_tf_next becomes local"
#pragma REVISED "zap,24-apr-87,stuff to _exit"
#endif

#include <process.h>
#include <stdio.h>

void exit(code)
int code;
{
  register int i;

  _do_exit_func();  /* execute the "onexit" functions */
  for(i=0;i<3;++i) if(_iob[i]._base) fflush(&_iob[i]);
  _exit(code);  /* quit */
}

+ARCHIVE+ exit_tsr.c     472  8/03/87 14:15:54
/* exit_tsr.c - terminate and stay resident
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,22-oct-85,add header, copyright"
#pragma REVISED "zap,30-jun-87,rehack"
#pragma REVISED "zap,3-aug-87,save prog len in PSP"
#endif

#include <dos.h>

extern unsigned far *_pspseg;

void exit_tsr()
{
  struct regval srv;

  srv.ax=0x3100;
  srv.dx=_pspseg[1];
  sysint21(&srv,&srv);
}



+ARCHIVE+ exp.c          872 10/09/87 16:26:50
/* exp - exponential function chell
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <float.h>
#include <errno.h>
#include <_math.h>

double *exp(x)
double x;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  errno=0;
  temp=_exp(x);
  if(errno){
    *temp=0.0;
    exc.type=UNDERFLOW;
    goto E1;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
E1:
    exc.name="exp";
    exc.arg1=x;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}
+ARCHIVE+ fabs.c         333 12/22/86 12:31:54
/* fabs - return floating point absolute value
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,12-jun-85, 3.0,NTTM"
#endif

double fabs(x)
double x;
{
  (((unsigned short *)(&x))[3]) &= 0x7fff; /* 8 byte doubles, 8087 format */
  return x;
}



  

+ARCHIVE+ fclose.c       613  9/17/87 14:33:10
/* fclose - close a file
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-jul-85,add this comment & copyright"
#pragma REVISED "zap,15-dec-86,free buffer"
#pragma REVISED "zap,31-jul-87,zero the buffer pointer"
#pragma REVISED "zap,17-sep-87,zero the buffer pointer"
#endif

#include <stdio.h>
#include <fileio3.h>

int fclose(stream)
FILE *stream;
{
  fflush(stream);
  close(stream->_fd);
  if(stream->_base && !(stream->_flag&_IOMYBUF))  free(stream->_base);
  stream->_base=NULL;
  stream->_flag=0;
  return 0;
}

+ARCHIVE+ fcloseal.c     515 12/22/86 12:31:58
/* fclosall - fcloses all open files
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,6-dec-85,new function"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <stdio.h>
#include <fileio3.h>

int fcloseall()
{
  register int fd,count=0;

  for(fd=5;fd<SYS_OPEN;++fd){
    if(_iob[fd]._flag){
      if(fclose(&_iob[fd])!=EOF) ++count;
    } else if(_osfile[fd]){
      if(close(fd)) ++count;
    }
  }
  return count;
}
+ARCHIVE+ fcvt.c         832  7/16/87 16:03:06
/*  fcvt.c - float to ASCII
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-apr-86,new function"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "nlp,16-jul-87,remove rubbish"
#endif

static char buf[315];

char *fcvt(value,digits,point,sign)
double value;
int digits, *point, *sign;
{
  char buffer[315], *p0, *p1;

  if(value==0.0){
    *point=0;
    *buf=0;
  } else {
    sprintf(buffer,"%+.*f",digits,value);
    *sign=(buffer[0]=='+' ? 0 : 1);
    p0=buf;
    p1=buffer+1;
    *point=0;
    if(*p1!='0'){
      while(*p1!='.'){
        *p0++=*p1++;
        (*point)++;
      }
      ++p1;
    } else {
      while(*(++p1)=='0') ;
      while(*(++p1)=='0') --(*point);
    }
    strcpy(p0,p1);
  }
  return buf;
}
+ARCHIVE+ fdopen.c      1965 12/22/86 12:32:04
/*  fdopen.c - "I'll give you a fd, you give me a stream."
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,9-may-86,new function"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <stdio.h>
#include <fileio3.h>
#include <errno.h>

#define RWBITS _IOREAD|_IOWRT|_IORW
#define TRUE 1
#define FALSE 0

FILE *fdopen(fd, mode)
int fd;
char *mode;
{
  int iobs;          /* the _iob subscript */
  register int ascmode=TRUE;  /* ascii/binary mode; assume open ascii */
  int rwmode=0;      /* read/write/update flag */
  int first=0;       /* because of rw and wr stupidity */
  register unsigned mode_word;

  if(!(_osfile[fd]&(_IOREAD|_IOWRT|_IORW))) return NULL;

  for(iobs=0;iobs<SYS_OPEN;++iobs)  /* first find a slot for the file */
    if(!(_iob[iobs]._flag&(_IOREAD|_IOWRT|_IORW))) break;

  while(*mode){
    switch(*mode++){
      case 'b':
        ascmode=FALSE;      /* open in binary mode */
        continue;
      case 'r':
        if(!first) first=1; /* open not create */
        rwmode|=1;
        continue;
      case 'a':             /* a+ equ ar */
        if(!first) first=3; /* open at end, create if reqd */
      case 'w':             /* w+ equ wr */
        if(!first) first=2; /* create the file */
        rwmode|=2;
        continue;
      case '+':
        if(first){          /* allow read & write */
          rwmode|=3;
          continue;
        }
      default:              /* bad file mode */
        return NULL;
    }
  }

  mode_word=rwmode|(ascmode*_IOASCII);
  if((mode_word&RWBITS) != (_osfile[fd]&RWBITS))
    if(!(_osfile[fd]&_IORW)) return NULL;
  if(ascmode) _osfile[fd]|=_IOASCII;
  else _osfile[fd]&=~_IOASCII;

  _iob[iobs]._fd=fd;
  _iob[iobs]._cnt=0;
  _iob[iobs]._base=0;
  _iob[iobs]._flag=mode_word;
  _piob[iobs]._size=(_osfile[fd]&_IOCDEV)?1:BUFSIZ;
  return &_iob[iobs];
}
+ARCHIVE+ feof.c         366 12/22/86 12:32:06
/* feof - returns non-zero on eof of the named input stream, else zero
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-oct-85,rewrite for v3.0"
#endif

#include <stdio.h>
#undef feof
#include <fileio3.h>

int feof(stream)
FILE *stream;
{
  return stream->_flag&_IOEOF;
}


    
+ARCHIVE+ ferror.c       347 12/22/86 12:32:06
/* ferror - return non zero if error has occurred on file
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-oct-85,rewrite for v3.0"
#endif

#include <stdio.h>
#undef ferror
#include <fileio3.h>

int ferror(stream)
FILE *stream;
{
  return stream->_flag&_IOERR;
}
+ARCHIVE+ fflush.c       715  3/20/87 15:50:38
/* fflush - flush data from stream buffer
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-jul-85,add this comment & copyright"
#endif

#include <stdio.h>
#include <fileio3.h>
#include <errno.h>

int fflush(s)
FILE *s;
{
  if(!(s->_flag&(_IOREAD|_IOWRT|_IORW))){
    errno=EBADF;
    return EOF;
  }
  if(s->_base && s->_ptr!=s->_base && !(s->_flag&_IOREAD)){
    if(s->_cnt!=_piob[s->_fd]._size && _piob[s->_fd]._size>1
              && _osfile[s->_fd]&_IODIRTY){
      write(s->_fd,s->_base,_piob[s->_fd]._size-s->_cnt);
    }
    _osfile[s->_fd]&=~_IODIRTY;
    s->_ptr=s->_base;
    s->_cnt=0;
  }
  return 0;
}

+ARCHIVE+ fgetc.c        446 12/24/86  9:58:32
/* fgetc - get a character from the stream
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,new function"
#pragma REVISED "zap,25-oct-85,test for carriage return"
#pragma REVISED "zap,1-nov-85,look at character before decrementing count"
#pragma REVISED "gee,22-dec-86,use macro"
#endif

#include <stdio.h>

int fgetc(f)
FILE *f;
{
  return getc(f);
}

+ARCHIVE+ fgetchar.c     255  8/31/87 11:35:16
/* fgetchar -  read a character from stdin (function version)
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma CREATED "ahm,31-aug-87,new function"
#endif

int fgetchar()
{
	return getchar();
}


+ARCHIVE+ fgetpos.c      467  2/05/87 22:33:54
/*  fgetpos.c - get file position (stream)
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma REVISED "nlp,21-jan-87,created"
#pragma REVISED "gee,5-feb-87,define fpos_t"
#endif

#include <stdio.h>
#include <stddef.h>

/* fgetpos, get file position from stream, store in pos
*/

int fgetpos(stream, pos)
FILE *stream;
fpos_t *pos;
{

  if((*pos = ftell(stream)) == -1)return -1;
  return 0;
}

+ARCHIVE+ fgets.c        723  6/15/87 16:00:24
/* fgets - get a string froma a stream
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,add this comment and copyright"
#pragma REVISED "gee,01-aug-86,change c from char to int"
#pragma REVISED "gee,01-aug-86,add test for n > zero"
#pragma REVISED "nlp,15-jun-86, use getc()"
#endif
#include <stdio.h>
#include <fileio3.h>

char *fgets(s, n, f)
char *s;
int n;
FILE *f;
{
  register c;
  register char *cptr;

  for(cptr=s;n-- > 0;){
    if((c=getc(f))==EOF){
      if(s==cptr) return NULL;
      if(!errno) c=0;
      break;
    }
    *cptr++=c;
    if(c=='\n') break;
  }
  *cptr=0;
  return(c==EOF ? NULL : s);
}
+ARCHIVE+ filedir.c     1231 12/22/86 12:32:12
/* filedir.c - get file directory
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,22-oct-85,add header, copyright"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <stdio.h>
#include <dos.h>
#include <malloc.h>

struct ff_str { 
  char dummy[21];		/* reserved for dos */ 
  unsigned char attribute;	/* returned attribute */ 
  unsigned time; 
  unsigned date; 
  long size;			/* size of file */ 
  unsigned char fn[13];		/* string containing the filename */ 
}; 

char *filedir(filename, mode)
char *filename;
unsigned mode;
{
  struct regval srv;
  struct ff_str ff_area;    
  char *result=NULL;
  register int reslen=0; 

  srv.ds=P_SEG(filename); 
  srv.dx=P_OFF(filename);
  srv.cx=mode;         /* set search modes */
  bdos(0x1a,&ff_area);  /* set the transfer address */
  for(srv.ax=0x4e00;!(sysint21(&srv,&srv)&1);srv.ax=0x4f00){
    result=realloc(result,reslen+strlen(ff_area.fn)+1); 
    if(result==NULL) return NULL;  /* no memory left */ 
    strcpy(result+reslen,ff_area.fn); 
    reslen+=strlen(ff_area.fn)+1; 
  }
  *(result+reslen)=NUL;
  return result ? realloc(result,reslen+1) : NULL; 
} 

+ARCHIVE+ filelen.c      619  5/27/87 14:59:54
/* filelength - returns the length of an open file
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,6-dec-85,new function"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,27-may-87,declare ltell"
#endif

#include <stdio.h>
#include <errno.h>
#include <io.h>

long filelength(fd)
int fd;
{
  register long t1;
  long t2;

  t1=ltell(fd);
  if(lseek(fd,0L,SEEK_END)==-1){
    errno=EBADF;
    return 0L;
  }
  t2=ltell(fd);
  if(lseek(fd,t1,SEEK_SET)==-1){
    errno=EBADF;
    return 0L;
  }
  return t2;
}
+ARCHIVE+ fileno.c       374 12/22/86 12:32:16
/* return file descriptor of stream
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,22-oct-85,new file control structure"
#pragma REVISED "zap,6-dec-85,flush the buffer"
#endif

#include <stdio.h>
#undef fileno

int fileno(stream)
FILE *stream;
{
  fflush(stream);
  return stream->_fd;
}

+ARCHIVE+ floor.c        730 10/09/87 16:56:48
/* floor - return integer <= val
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <float.h>
#include <_math.h>

double *floor(val)
double val;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  temp=_floor(val);
  if((_temp=_status87())&0x80){
    exc.name="floor";
    exc.arg1=val;
    exc.arg2=0;
    exc.retval=*temp;
    exc.type=_err_map(_temp);
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}
+ARCHIVE+ flushall.c     397 12/22/86 12:32:20
/* flushall - fflushes all the I/O buffers
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,6-dec-85,new function"
#endif

#include <stdio.h>

int flushall()
{
  register int fd,count=0;

  for(fd=5;fd<SYS_OPEN;++fd){
    if(_iob[fd]._base){
      if(fflush(&_iob[fd])!=EOF) ++count;
    }
  }
  return count;
}
+ARCHIVE+ fmod.c        1325 11/20/87 17:54:36
/* fmod - floating point mod
** fmod(x,y) rets f, same sign as x, s.t. x == i*y + f and fabs(f) > fabs(y).
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,28-may-85,complete rewrite,NTTM"
#pragma REVISED "lpa,6-jun-85,used 0.0 assuming flost const folding,NTTM"
#pragma REVISED "lpa,12-jun-85,3.0, HISTORY in, ifdef _CII out"
#pragma REVISED "lpa,18-jun-85,ifdef _CII back in"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-jul-87,_math.h"
#pragma REVISED "ahm,24-sep-87,works for x/y == int(x/y) cases, safety feature"
#pragma REVISED "ahm,11-nov-87,safety case: works ok"
#pragma REVISED "ahm,20-nov-87,rewritten"
#endif

#include <float.h>
#include <math.h>
#include <_math.h>

extern int errno;

double fmod (x,y)
double x,y; 
{
  double d;
  register _temp,sign;
  struct exception exc;

  _clear87();
  if(y==0.0){
     d=0;
     errno=EDOM;
     exc.type=DOMAIN;
     goto bad;
     }
  if(x<0) sign=1;
  else sign=0;
  x=fabs(x);
  y=fabs(y);
  d=x-*_floor(x/y)*y;
  if(sign) d=-d;

  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
bad:
    exc.name="fmod";
    exc.arg1=x;
    exc.arg2=y;
    exc.retval=d;
    if(matherr(&exc)) d=exc.retval;
  }
  return d;
}
+ARCHIVE+ fopen.c       2498 11/25/87 17:53:20
/* fopen.c - open a stream
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,add this comment and copyright"
#pragma REVISED "zap,21-may-86,common conventions"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "gee,30-dec-86,truncate files opened in 'w' mode"
#pragma REVISED "zap,24-mar-87,new header"
#pragma REVISED "zap,27-may-87, prepend an underscore to modeparse"
#endif

#include <stdio.h>
#include <fileio3.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>

#define TRUE  1
#define FALSE 0

FILE *fopen(filename, openmode)
unsigned char *filename, *openmode;
{
  register int iobs, fd;
  unsigned mode;

  for(iobs=0;iobs<SYS_OPEN;++iobs)  /* first find a slot for the file */
    if(!(_iob[iobs]._flag&(_IOREAD|_IOWRT|_IORW))) break;
  if(iobs>=SYS_OPEN){
    errno=EMFILE;
    return NULL;
  }

  if((mode=_modeparse(openmode))==0xFFFF){
    errno=EINVAL;
    return NULL;
  }

  if((fd=_open(filename, mode, 0, S_IREAD|S_IWRITE))==-1) return NULL;
  if(mode&O_RDWR) _iob[iobs]._flag|=_IORW;
  else if(mode&O_WRONLY) _iob[iobs]._flag|=_IOWRT;
  else /* if(mode&O_RDONLY) */ _iob[iobs]._flag|=_IOREAD;
  _iob[iobs]._fd=fd;
  _iob[iobs]._cnt=0;
  _iob[iobs]._base=NULL;
  _piob[fd]._size=(_osfile[fd]&_IOCDEV)?1:BUFSIZ;

  return &_iob[iobs];
}


int _modeparse(openmode)
char *openmode;
{
  register unsigned mode=O_TEXT;
  register int state;

  switch(*openmode++){
    case 'r': mode|=O_RDONLY;
              state=0;
              break;
    case 'w': mode|=O_WRONLY|O_CREAT|O_TRUNC;
              state=1;
              break;
    case 'a': mode|=O_APPEND|O_WRONLY|O_CREAT;
              state=1;
              break;
    default:  return 0xFFFF;
  }
  while(*openmode){
    switch(*openmode++){
      case 'r':  if(!state) goto err;
                 mode&=~O_WRONLY;
                 mode|=O_RDWR;
                 break;
      case 'w':  if(state) goto err;
                 mode&=~O_RDONLY;
                 mode|=O_RDWR;
                 break;
      case '+':  mode&=~(O_RDONLY|O_WRONLY);
                 mode|=O_RDWR;
                 break;
      case 'b':  mode|=O_BINARY;
                 mode&=~O_TEXT;
                 break;
      case 't':  mode&=~O_BINARY;
                 mode|=O_TEXT;
                 break;
err:
      default:   return 0xFFFF;
    }
  }
  return mode;
}
+ARCHIVE+ fputc.c        396  1/02/87 16:49:06
/* fputc.c - put a character to the stream
** Copyright (c) 1984,85 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,new function"
#pragma REVISED "zap,1-nov-85,look at character before decrementing count"
#pragma REVISED "gee,22-dec-86,putc used"
#endif
#include <stdio.h>

int fputc(c, f)
int c;
FILE *f;
{
  return putc(c,f);
}

+ARCHIVE+ fputchar.c     264  8/31/87 12:20:34
/* fputchar -  write a character on stdio (function version)
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma CREATED "ahm,31-aug-87,new function"
#endif

int fputchar(c)
int c;
{
	return putchar(c);
}


+ARCHIVE+ fputs.c        417  6/15/87 16:41:16
/* fputs - put a string to the stream
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,new function"
#pragma REVISED "nlp,16-mar-87,register"
#pragma REVISED "nlp,15-jun-87,putc"
#endif
#include <stdio.h>

int fputs(s, f)
register char *s;
register FILE *f;
{
  while(*s) if(putc(*s++,f)==EOF) return(1);
  return(0);
}

+ARCHIVE+ fread.c        754  7/02/87  9:58:58
/* fread - read from a file
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,add this comment and copyright"
#pragma REVISED "nlp,15-jun-87, register temp"
#pragma REVISED "zap,2-jul-87,was returning EOF"
#endif
#include <stdio.h>

size_t fread(where, size, nitems, stream)
char *where;  /* where to put data */
size_t size;  /* size of one item in bytes */
size_t nitems;  /* number of items to read */
FILE *stream;  /* where to get it */
{
  register unsigned temp, j, count;
  
  for(count=0; count<nitems; ++count){
    for(j=0; j<size; ++j){
      if((temp=getc(stream))==EOF) goto done;
      *where++=temp;
    }
  }
done:
  return count;
}
+ARCHIVE+ free.c         516  8/12/87 10:42:22
/* free - memory freer-upper
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,10-sep-85,Complete rewrite! New scheme!"
#pragma REVISED "zap,14-oct-85,New header file, alloc.h"
#pragma REVISED "zap,20-oct-86,rewrite for near and far
#pragma REVISED "gee,20-dec-86,_FLAGS"
#pragma REVISED "zap,12-aug-87,remove include files"
#endif

void free(fptr)
void *fptr;
{
#ifdef _FLAGS_Af
  _ffree(fptr);
#else
  _nfree(fptr);
#endif
}

+ARCHIVE+ free_lst.c    1205 12/22/86 13:15:30
/* free_mem - return the largest free memory block
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-nov-85,creation"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,4-nov-86,near and far"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#endif

#include <stdio.h>
#include <malloc.h>
#include <_alloc.h>

#ifdef _FLAGS_Af

extern struct ffree_list_item *_fprimary_free_list;
extern struct ffree_list_item *_fsecondary_free_list;

unsigned long free_lst()
{
  register unsigned long max=0L;
  struct ffree_list_item *fptr;

  _fmerge_free_lists();
  if(fptr=_fprimary_free_list){
    do
      if(fptr->length>max) max=fptr->length;
    while((fptr=fptr->next)!=NULL);
  }

  return max;
}

#else

extern struct nfree_list_item *_nprimary_free_list;
extern struct nfree_list_item *_nsecondary_free_list;

unsigned long free_lst()
{
  register unsigned max=0;
  struct nfree_list_item *fptr;

  _nmerge_free_lists();
  if(fptr=_nprimary_free_list){
    do
      if(fptr->length>max) max=fptr->length;
    while((fptr=fptr->next)!=NULL);
  }

  return (unsigned long)max;
}

#endif
+ARCHIVE+ free_max.c     644 10/19/87 16:29:18
/* free_max - return size of largest allocatable block
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-nov-85,creation"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#pragma REVISED "ahm,19-oct-87,_FLAGS_As: free_max()=free_lst()"
#endif

#ifdef _FLAGS_Af

extern unsigned long free_mem();
extern unsigned long free_lst();

unsigned free_max()
{
  unsigned long m1,m2,max=0xFFE8;

  return (unsigned)(max<(m1=((m1=free_lst())>(m2=free_mem())?m1:m2))?max:m1);
}

#else

extern unsigned free_lst();

unsigned free_max()
{
  return free_lst();
}

#endif
+ARCHIVE+ free_mem.c     468 12/22/86 12:32:36
/* free_mem - return the largest chunk of free memory available
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-nov-85,creation"
#endif

#include <dos.h>
#include <_alloc.h>
#include <signal.h>

unsigned long free_mem()
{
  struct regval reg;

  reg.ax=0x4800;
  reg.bx=0xFFFF;
  if(!(sysint21(&reg,&reg)&0x0001)) raise(SIGALLOC);
  return ((unsigned long)reg.bx<<4)-FHF_SIZE;
}
+ARCHIVE+ freopen.c     1051  5/27/87 17:18:38
/* freopen - close the stream and attempt to open a new one.
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,16-aug-85,ignore fclose return status"
#pragma REVISED "zap,27-may-87,do it right"
#endif

#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <fileio3.h>
#include <errno.h>

extern int _modeparse(char *);

FILE *freopen(filename,type,stream)
char *filename,*type;
FILE *stream;
{
  unsigned mode;
  int fd;

  fclose(stream);

  if((mode=_modeparse(type))==-1){
    errno=EINVAL;
    return NULL;
  }
  if(mode&O_RDWR) stream->_flag|=_IORW;
  else if(mode&O_WRONLY) stream->_flag|=_IOWRT;
  else stream->_flag|=_IOREAD;
  stream->_cnt=0;
  stream->_base=NULL;

  if((fd=_open(filename, mode, 0, S_IREAD|S_IWRITE))==-1) return NULL;
  else if(fd!=stream->_fd){
    if(dup2(fd,stream->_fd)) return NULL;
    close(fd);
  }
  _piob[stream->_fd]._size=(_osfile[stream->_fd]&_IOCDEV)?1:BUFSIZ;

  return stream;
}

+ARCHIVE+ frexp.c        473 12/22/86 12:32:40
/* frexp - return exponent and fraction
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#endif

double frexp(val,ip)
double val;
int *ip;
{
  int *tip;

  if(val==0.0)*ip=0;
  else {
    tip=&val;
    *ip=((tip[3]>>4)&0x7ff)-0x3fe;  /* assumes 64-bit doubles */
    tip[3]=(tip[3]&0x800f)+0x3fe0;
  }
  return val;
}
+ARCHIVE+ fseek.c        953  9/10/87 18:09:44
/* fseek - move the file pointer
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,10-oct-85,rewrite the function in C"
#pragma REVISED "zap,25-oct-85,pure binary buffers"
#pragma REVISED "zap,22-may-86,new defines in fileio3.h, removed smarts"
#pragma REVISED "zap,10-sep-87,clear EOF"
#endif

#include <stdio.h>
#include <fileio3.h>
#include <dos.h>

int fseek(stream, offset, ptrname)
FILE *stream;
long offset;
int ptrname;
{
  struct regval reg;

  if(ptrname==SEEK_CUR){
    offset+=ftell(stream);
    ptrname=SEEK_SET;
  }
  fflush(stream);
  reg.ax=0x4200|ptrname;
  reg.bx=stream->_fd;
  reg.cx=(unsigned)(offset>>16);
  reg.dx=(unsigned)offset;
  if(sysint21(&reg,&reg)&0x0001) return -1;  /* carry flag - error */
  _piob[stream->_fd]._foffset=((long)reg.dx<<16)+reg.ax;
  stream->_cnt=0;
  _iob[stream->_fd]._flag&=~_IOEOF;
  return 0;
}
+ARCHIVE+ fsetpos.c      422  2/05/87 22:17:58
/*  fsetpos.c - set file position (stream)
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma REVISED "nlp,21-jan-87,created"
#pragma REVISED "gee,2-feb-87,stddef added"
#endif

#include <stdio.h>
#include <stddef.h>

/* fsetpos, set file position 
*/

int fsetpos(stream, pos)
FILE *stream;
fpos_t *pos;
{

   return fseek(stream,*pos,SEEK_SET);
}

+ARCHIVE+ fstat.c       1209  4/09/87 14:50:12
/* fstat.c - get a file's status
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-jul-86,new function"
#pragma REVISED "zap,24-mar-87,new header"
#pragma REVISED "zap,9-apr-87,call external routine for mod time"
#endif

#include <sys/stat.h>
#include <fcntl.h>
#include <fileio3.h>
#include <dos.h>
#include <errno.h>

extern long filelength();
extern time_t _cvt_time();

int fstat(fd, s)
int fd;
struct stat *s;
{
  struct regval regs;
  static int mon[12]={0,31,59,90,120,151,181,212,243,273,304,334};

  regs.ax=0x5700;
  regs.bx=fd;
  if(sysint21(&regs,&regs)&1){
    errno=EBADF;
    return -1;
  }
  s->st_atime=s->st_mtime=s->st_ctime=_cvt_time(regs.cx,regs.dx);

  if(_osfile[fd]&_IOCDEV){  /* character device */
    s->st_mode=S_IFCHR;
    s->st_size=1;
    s->st_dev=s->st_rdev=fd;
  } else {                  /* regular file */
    s->st_mode=S_IFREG;
    s->st_size=filelength(fd);
    s->st_dev=s->st_rdev=0;
  }
  if(_osfile[fd]&O_RDWR) s->st_mode|=S_IREAD|S_IWRITE;
  else if(_osfile[fd]&O_WRONLY) s->st_mode|=S_IWRITE;
  else s->st_mode|=S_IREAD;
  s->st_nlink=1;
  return 0;
}
+ARCHIVE+ ftell.c        943  5/19/87 12:40:42
/* ftell - get the file pointer
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-oct-85,rewrite the function in C"
#pragma REVISED "gee,20-dec-86,ascii stream changes"
#pragma REVISED "gee,31-dec-86,Happy new year"
#pragma REVISED "zap,6-may-87,missed by one byte"
#endif

#include <stdio.h>
#include <fileio3.h>

long ftell(stream)
FILE *stream;
{
  long offset;
  register int fd,j;
  char *cp;

  if(_osfile[fd=stream->_fd]&_IODIRTY){
    offset=_piob[fd]._foffset+(stream->_ptr-stream->_base);
    if(_osfile[fd]&_IOASCII){
      for(cp=stream->_base;cp<stream->_ptr;){
        if(*cp++ == '\n')++offset;
      }
    }
  } else {
    offset=_piob[fd]._foffset-stream->_cnt;
    if(_osfile[fd]&_IOASCII){
      for((j=stream->_cnt),(cp=stream->_ptr);--j>=0;){
        if(*cp++ == '\n')--offset;
      }
    }
  }
  return offset;
}
+ARCHIVE+ ftime.c       1072  9/30/87 11:43:38
/*  ftime.c - current time into the timeb struct
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,13-aug-86,new function"
#pragma REVISED "ahm,10-sep-87,t->millitm returns thousandth of a second"
#pragma REVISED "ahm,29-sep-87,tmp=regs.cx-1970 baseyear for function ftime"
#pragma REVISED "ahm,30-sep-87,t->time*=24, force precedence + and &"
#endif

#include <dos.h>
#include <sys/timeb.h>

extern long timezone;
extern int daylight;

void ftime(t)
struct timeb *t;
{
  struct regval regs;
  static int mon[12]={0,31,59,90,120,151,181,212,243,273,304,334};
  register tmp;

  regs.ax=0x2A00;
  sysint21(&regs,&regs);
  tmp=regs.cx-1970;
  t->time=tmp*365+(tmp+2)/4;
  tmp=regs.dx;
  t->time+=mon[(tmp>>8)-1]+(tmp&0xFF);
  t->time*=24;
  regs.ax=0x2C00;
  sysint21(&regs,&regs);
  tmp=regs.cx;
  tmp=((tmp>>8)*60+(tmp&0xFF));
  t->time*=3600;
  t->time+=(long)tmp*60+(regs.dx>>8);
  t->millitm=(regs.dx&0xFF)*10;
  t->timezone=(int)(timezone/60);
  t->dstflag=daylight;
}
+ARCHIVE+ ftoa.c         765  9/30/87 15:43:50
/* ftoa.c - convert double to ascii
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85"
#pragma REVISED "ahm,24-sep-87 rewritten"
#endif

ftoa(d,s,iplace,fplace)
double d;         /* value to convert */
unsigned char *s; /* the string to store result in */ 
unsigned iplace;  /* number of integer places */ 
unsigned fplace;  /* number of fractional places */ 
{
  register short exp;
  char *ptr,buf[50];
  unsigned ip=iplace;

  exp=_dtos(d,buf);
  ptr=buf;
  if(*ptr=='-') *s++=*ptr++;    
  while(iplace--) *s++=*ptr++;
  *s++='.';                     
  while(fplace--) *s++=*ptr++;
  *s++='E';                     
  itoa(exp-ip+1,s);
  return strlen(s);
}

+ARCHIVE+ fwrite.c       796 11/23/87 11:09:06
/* fwrite.c - write to a stream
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,16-oct-85,add header and copyright"
#pragma REVISED "zap,27-may-86,change putc to fputc"
#pragma REVISED "nlp,15-jun-87,putc"
#pragma REVISED "ahm,23-nov-87,return count, goto done"
#endif

#include <stdio.h>

size_t fwrite(where,size,nitems,stream)
register char *where;  /* where to get data */
size_t size;         /* size of one item in bytes */
size_t nitems;       /* number of items to write */
FILE *stream;          /* where to put it */
{
  register unsigned j,count;

  for(count=0;count<nitems;++count){
    for(j=0;j<size;++j){
      if(putc(*where++,stream)==EOF)goto done;
    }
  }
done:
  return count;
}
+ARCHIVE+ gcdir.c        929  5/11/87 20:44:50
/* gcdir.c - get current directory for dos 2.00
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,22-oct-85,add header, copyright"
#pragma REVISED "zap,6-feb-87,clean up compiler warnings"
#pragma REVISED "zap,22-apr-87,never worked"
#pragma REVISED "gee,5-may-87,removed register from current"
#endif

#include <dos.h>
#include <malloc.h>
#include <string.h>

char *gcdir(drive)
char *drive;
{
  struct regval srv;
  char *current;
  char temp[67];

  current=temp;
  srv.ds=P_SEG(current);
  srv.si=P_OFF(current)+3;
  if(drive[0] && drive[1]==':') srv.dx=(toupper(*drive)-'A')&0x0f;
  else srv.dx=bdos(0x19)&0xff;
  strcpy(temp," :\\");
  temp[0]=srv.dx+'A';
  srv.ax=0x4700;
  ++srv.dx;
  if(sysint21(&srv,&srv)&1) return 0;
  if(!(current=malloc(strlen(temp)+1))) return 0;
  strcpy(current,temp);
  return current;
}


+ARCHIVE+ gcvt.c         316 12/22/86 12:33:00
/*  gcvt.c - float to ASCII
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-apr-86,new function"
#endif

char *gcvt(value,digits,buffer)
double value;
int digits;
char *buffer;
{
  sprintf(buffer,"%.*g",digits,value);
  return buffer;
}
+ARCHIVE+ getc.c         277 12/22/86 12:33:02
/* getcget a character from the stream
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,new function"
#endif

getc(f)
char *f;  /* kluje - can't include stdio.h */
{
  return(fgetc(f));
}

+ARCHIVE+ getchar.c      291 12/22/86 12:33:06
/* getchar - get a character from stdin
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,add this comment and copyright"
#endif
#include <stdio.h>
#undef getchar

int getchar()
{
  return getc(stdin);
}
+ARCHIVE+ getcwd.c       736  7/07/87 15:33:32
/*  getcwd.c - gcdir()
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,14-may-86,new function"
#pragma REVISED "nlp,7-jul-87, don't depend on gcdir"
#endif

#include <stdio.h>  /* for NULL */
#include <dos.h>
#include <string.h>

extern char *malloc();

char *getcwd(path,n)
char *path;
int n;
{
  struct regval srv;
  char *current;
  char temp[128];

  current=temp;
  srv.ds=P_SEG(current);
  srv.si=P_OFF(current)+3;
  srv.dx=bdos(0x19)&0xff;

  strcpy(temp," :\\");
  temp[0]=srv.dx+'A';
  srv.ax=0x4700;
  ++srv.dx;
  if(sysint21(&srv,&srv)&1) return 0;

  if(path==NULL) path=malloc(n);
  strncpy(path,temp,n);
  return path;
}
+ARCHIVE+ getenv.c       891 11/02/87 16:09:22
/* getenv - return a copy of a string in the environment
** returns zero if not found
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,21-oct-85,add header and copyright"
#pragma REVISED "nlp,27-jan-86,use environ[] array - easy way"
#pragma REVISED "zap, 2-nov-87,add '=' so we don't match on a short name"
#endif

#include <dos.h>
#include <string.h>

static unsigned char rp[128];

char *getenv(string)
char *string;
{
extern char **environ;
register i, slen;

  strcpy(rp,string);
  strcat(rp,"=");        /* so we don't match "PAT" to "PATH" */
  slen = strlen(string);
  for(i=0;environ[i];++i) {
	 if(!strncmp(string,environ[i],slen)) {	
      char *result;

      if(result=strchr(environ[i],'=')) {
        return strcpy(rp,result+1);
      }
    }
  }
  return (char *)0;
}


+ARCHIVE+ getpid.c       228 12/22/86 12:33:16
/* getpid - return the process ID
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,6-dec-85,add header, copyright"
#endif

int getpid()
{
  return 0;
}
+ARCHIVE+ gets.c         531  3/16/87 19:03:30
/* gets - get a string froma a stream
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,add this comment and copyright"
#pragma REVISED "nlp,16-mar-87,c must be int"
#endif
#include <stdio.h>
#include <fileio3.h>

char *gets(s)
char *s;
{
  register char *cptr;
  register c;

  cptr=s;
  while((c=getchar())!='\n'){
    if(c==EOF){
      if(!errno)c=0;
      break;
    }
    *cptr++=c;
  }
  *cptr=0;
  return(c==EOF?NULL:s);
}
+ARCHIVE+ getw.c         421 12/22/86 12:33:22
/* getw.c - get a word from a file
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,22-oct-85,add header, copyright"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <stdio.h>
#include <fileio3.h>

getw(buf)
FILE *buf;
{
  register unsigned word;

  word=fgetc(buf);
  if(feof(buf))return EOF;
  return word|(fgetc(buf)<<8);
}
+ARCHIVE+ gmtime.c       749  5/20/87 12:44:34
/* gmtime - return Greenwich Mean Time
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,4-nov-85,new function"
#pragma REVISED "zap,6-dec-85,use environment variable TZ to make it work"
#pragma REVISED "zap,13-jan-86,corrections to TZ"
#pragma REVISED "zap,20-may-87,check timezone if no TZ in env"
#endif

#include <time.h>
#include <stdlib.h>

extern long timezone;

struct tm *gmtime(timer)
time_t *timer;
{
  register char *p;
  time_t t;

  t=*timer;
  if(p=getenv("TZ")){
    while(!isdigit(*p) && *p!='-') ++p;
    t += atoi(p)*3600*CLK_TCK; /* 3600 sec/hr and resolution of time_t */
  }
  else t+=(time_t)timezone;

  return localtime(&t);
}
+ARCHIVE+ halloc.c       637  6/02/87 16:17:10
/* halloc - huge memory allocator
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,20-oct-86,complete rewrite. call _fmalloc and _nmalloc"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#pragma REVISED "gee,10-jan-87,smaller"
#pragma REVISED "gee,1-jun-87, dosf48 declared"
#endif

#include <malloc.h>

extern far * _dosf48();

void huge *halloc(num_items, item_size)
long num_items;
unsigned item_size;
{
  unsigned long requested_size;

  requested_size=(unsigned long)num_items*item_size+15;
  return (void huge *)_dosf48((unsigned)(requested_size>>4));
}


+ARCHIVE+ hfree.c        409 10/22/87 15:03:38
/* hfree - huge memory freer-upper
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,21-oct-86,creation"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#pragma REVISED "nlp,9-jul-87,FP_SEG"
#pragma REVISED "zap,22-oct-87,dos.h for FP_SEG"
#endif

#include <dos.h>

void hfree(fptr)
void huge *fptr;
{

  _dosf49(FP_SEG(fptr) >> 4);
}


+ARCHIVE+ horse.c        541 12/22/86 12:33:34
/* horse.c - returns nostalgia
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,1-apr-86,creation"
#endif

char *horse()
{
  return "\tA horse is a horse, of course, of course\n\
\tAnd noone can talk to a horse, of course.\n\
\tThat is, of course, unless the horse\n\
\tIs the famous Mister Ed.\n\n\
\tGo right to the source and ask the horse.\n\
\tHe'll give you an answer that you'll endorse.\n\
\tHe's always on a steady course.\n\
\tTalk to Mister Ed!\n";
}

+ARCHIVE+ intrinit.c     472  8/12/87 10:22:16
/* INTRINIT: Interfacing routine for programs that do it the old way.
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#include <malloc.h>
#include <intr.h>

int intrinit(func,stack_size,vecno)
void (* func)();
unsigned int stack_size;
int vecno;
{
  char *stack_area;
 
  if(!(stack_area = malloc(stack_size+sizeof(struct intr_frame))))return -1;
  return intrset((void (far *)())func,stack_size,vecno,stack_area,stack_size);
}

+ARCHIVE+ intrrest.c     466  8/05/87 10:58:30
/* INTRREST: terminate interrupt handler established by intrinit
*   and reset previous handler.
*
*  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef	HISTORY
#pragma REVISED "nlp,5-aug-87,far *ip"
#endif

#include <intr.h>
#include <malloc.h>
  
void intrrest(vecno)
unsigned vecno;
{
  struct icb far *ip;
 
  ip = (struct icb far *)((char far *)_dosf35(vecno)-1);
  intrterm(vecno);
  free(ip->free_base);
}

+ARCHIVE+ intrset.c     1070  6/30/87 11:43:08
/* INTRSET: Initializes interrupt processing in C86PLUS run-time environment.
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#include <intr.h>

#define FAR_CALL 0x9A
 
int intrset(isr,frame_size,vecno,stack_base,stack_size)
void (far * isr)();	/* the c code to process the interrupt */
unsigned frame_size;	/* size for each invocation */
unsigned vecno;		/* the vector number to plug */
char *stack_base;	/* the area to use as stack */
unsigned stack_size;	/* size of memory allocated for "stack" */
{
  struct icb *p;
 
  if(stack_size<(sizeof(struct icb)+8))return -1;
  p = (struct icb *)(stack_base+stack_size-sizeof(struct icb));
  p->farcall_opcode = FAR_CALL;
  p->gateway = intrserv;
  p->frame_size = (frame_size+1) & (~2);	/* force it even */
  p->sub_sp = 6;
  p->new_isr = isr;
  p->old_isr = _dosf35(p->vecno = vecno);	/* get old vector */
  p->free_base=stack_base;		/* so we can free it */
  _dosf25(vecno, ((void(far *)()) ((char *)p+1)) );	/* and set new */
  return 0;	/* return success */
}

+ARCHIVE+ intrterm.c     327  4/12/87 15:23:46
/* INTRTERM: Terminate interrupt processing and restore vector
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
 
#include <intr.h>
 
void intrterm(vecno)
unsigned vecno;
{
  struct icb far *p;
 
  p = (struct icb far *)((char far *)_dosf35(vecno) - 1);
  _dosf25(vecno,p->old_isr);
}

+ARCHIVE+ isalnum.c      340 12/22/86 12:33:56
/* isalnum - return true if input character is alphabetic or a digit
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, unsigned out, ctype in"
#endif

isalnum(c)
int c;
{
  #include <ctype.h>
  return isalnum(c);
}
+ARCHIVE+ isalpha.c      331 12/22/86 12:33:58
/* isalpha - return true if input character is alphabetic
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, unsigned out, ctype in"
#endif

isalpha(c)
int c;
{
  #include <ctype.h>
  return isalpha(c);
}

+ARCHIVE+ isatty.c       358 12/22/86 12:34:02
/* isatty.c - is this a character device
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,28-apr-86,add header, copyright"
#endif

#include <dos.h>

int isatty(fd)
int fd;
{
  struct regval regs;

  regs.ax=0x4400;
  regs.bx=fd;
  sysint21(&regs,&regs);
  return regs.dx&0x80;
}
+ARCHIVE+ iscd.c         338 12/22/86 12:34:04
/* iscd - is this file (or device) a character device
** Copyright (c) 1984,85 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,9-dec-85,new function"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <fileio3.h>

int iscd(fd)
register int fd;
{
  return _osfile[fd]&_IOCDEV;
}
+ARCHIVE+ iscntrl.c      340 12/22/86 12:34:06
/* iscntrl - return true if input character is a a control character
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, unsigned out, ctype in"
#endif

iscntrl(c)
int c;
{
  #include <ctype.h>
  return iscntrl(c);
}
+ARCHIVE+ iscsym.c       337 12/22/86 12:34:08
/* is it a valid character for a c symbol ?
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,11-jun-85, 3.0, unsigned out, include ctype.h"
#endif
#include <ctype.h>

int iscsym(c)
int c;
{
  return isalnum(c)||c=='_';
}

  
+ARCHIVE+ iscsymf.c      351 12/22/86 12:34:10
/* is it a valid character for a c symbol's first letter ?
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,11-jun-85, 3.0, unsigned out, include ctype.h"
#endif
#include <ctype.h>

int iscsymf(c)
int c;
{
  return isalpha(c)||c=='_';
}


+ARCHIVE+ isdigit.c      329 12/22/86 12:34:12
/* isdigit - return true if input character is a digit
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, unsigned out, ctype in"
#endif

isdigit(c)
int c;
{
  #include <ctype.h>
  return isdigit(c);
}
 
+ARCHIVE+ isgraph.c      396 12/22/86 12:34:14
/* isgraph - is it a graphic character,  like isprint except false for space
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, unsigned out, ctype in"
#pragma REVISED "zap,15-nov-85, ctype out, conditional in"
#endif

isgraph(c)
int c;
{
  return c>040&&c<=0176;
}



+ARCHIVE+ islower.c      340 12/22/86 12:34:18
/* islower - return true if input character is lower case alphabetic
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, unsigned out, ctype in"
#endif

islower(c)
int c;
{
  #include <ctype.h>
  return islower(c);
}
+ARCHIVE+ isodigit.c     310 12/22/86 12:34:20
/* is it a valid octal character ? ('0'-'7')
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,11-jun-85, 3.0, unsigned out"
#endif

int isodigit(c)
register int c;
{
  return c>='0'&&c<='7';
}


  
+ARCHIVE+ isprint.c      331 12/22/86 12:34:22
/* isprint - return true if input character is printable
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, unsigned out, ctype in"
#endif

isprint(c)
int c;
{
  #include <ctype.h>
  return isprint(c);
}
 
+ARCHIVE+ ispunct.c      346 12/22/86 12:34:24
/* ispunct - return true if input character is not control or alphanumeric
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, unsigned out, ctype in"
#endif

ispunct(c)
int c;
{
  #include <ctype.h>
  return ispunct(c);
}
+ARCHIVE+ isspace.c      337 12/22/86 12:34:26
/* isspace - returns true if chararcter is a blank,tab or newline
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, unsigned out, ctype in"
#endif

isspace(c)
int c;
{
  #include <ctype.h>
  return isspace(c);
}
+ARCHIVE+ isupper.c      342 12/22/86 12:34:28
/* isupper.c - return true if input character is upper case alphabetic
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, unsigned out, ctype in"
#endif

isupper(c)
int c;
{
  #include <ctype.h>
  return isupper(c);
}
+ARCHIVE+ isxdigit.c     323 12/22/86 12:34:30
/* isxdigit - is it a hexadecimal character
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, unsigned out, ctype in"
#endif

isxdigit(c)
int c;
{
  #include <ctype.h>
  return isxdigit(c);
}



+ARCHIVE+ itoa.c         267 12/22/86 12:34:32
/* itoa - integer to ascii
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-oct-85,add header, copyright"
#endif

itoa(n,cp)
int n;
unsigned char *cp;
{
  return ltos((long)n,cp,-10);
}
+ARCHIVE+ itoh.c         280 12/22/86 12:34:36
/* itoh - integer to hex conversion
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-oct-85,add header, copyright"
#endif

itoh(n,cp)
unsigned n;
unsigned char *cp;
{
  return ltos((long)n,cp,16);
}
+ARCHIVE+ j0.c           662 10/09/87 16:58:12
/* library function: Bessel Function - J0
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma CREATED "ahm,17-aug-87"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include		<stdlib.h>
#include 	<_math.h>
#include 	<float.h>

double *j0(arg)
double arg;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  temp=_j0(arg);
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
    exc.name="j0";
    exc.arg1=arg;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}








+ARCHIVE+ j1.c           664 10/09/87 16:58:46
/* library function: Bessel Function - J0
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/

#ifdef HISTORY
#pragma CREATED "ahm,18-aug-87"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include		<stdlib.h>
#include		<_math.h>
#include 	<float.h>


double *j1(arg)
double arg;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  temp=_j1(arg);
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
    exc.name="j1";
    exc.arg1=arg;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}








+ARCHIVE+ jn.c           799 10/09/87 17:00:24
/* library function: Bessel Function - Jn
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma CREATED "ahm,18-aug-87"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <errno.h>
#include <float.h>
#include <_math.h>

extern double _fac;

double *jn(n,x)
int	n;
double x;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  if(x<=0.0 || n<0){
    errno=EDOM;
    temp=&_fac;
    *temp=0.0;
    exc.type=DOMAIN;
    goto SQ1;
  }

  temp=_jn(n,x);
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
SQ1:
    exc.name="jn";
    exc.arg1=n;
    exc.arg2=x;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }

  return temp;
}




+ARCHIVE+ kbhit.c        478  2/23/87 13:19:46
/*  kbhit.c - is there a char ready at stdin
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-may-86,new function"
#pragma REVISED "zap,23-feb-87,flush the buffer if it's got a char"
#endif

#include <dos.h>

int kbhit()
{
  struct regval reg;
  register i;

  reg.ax=0x0b00;
  sysint21(&reg,&reg);
  if((i=reg.ax)&0xff){
    reg.ax=0x0c00;
    sysint21(&reg,&reg);
  }
  return i&0xff;
}
+ARCHIVE+ labs.c         271 12/22/86 12:34:44
/* labs - returns absolute value of a long
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-oct-85,add header, copyright"
#endif

long int labs(x)
long int x;
{
   return x>=0L?x:-x;
}

  
+ARCHIVE+ ldexp.c        515 12/22/86 12:34:46
/* ldexp - rebuild a floating point number
   Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-oct-85,add header, copyright"
#endif

#include <errno.h>

double ldexp(val,exp)
double val;
int exp;
{
  int *ip;

  ip=&val;
  exp+=(ip[3]>>4)&0x3ff;
  if(exp<1)val=0.0;		/* it underflowed */
  else if(exp>0x7ff) {
    ip[3]|=0x7fff;
    ip[2]=ip[1]=ip[0]=-1;
    errno=ERANGE;
  } ip[3]=(ip[3]&0x800f)|(exp<<4);
  return val;
}
+ARCHIVE+ ldiv.c         554 11/12/87 10:16:38
/*  ldiv.c - strange division
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,7-may-86,new function"
#pragma REVISED "nlp,21-jan-87,use ldiv_t"
#pragma REVISED "zap,12-nov-87,return the struct, not a pointer"
#endif

#include <stdlib.h>
#include <errno.h>

ldiv_t ldiv(num, denom)
long num, denom;
{
  struct{long quot,rem;} z;

  if(denom==0L){
    z.quot=0L;
    z.rem=0L;
    errno=EDOM;
  } else {
    z.rem=num%denom;
    z.quot=num/denom;
  }
  return z;
}
+ARCHIVE+ lfind.c        567  9/03/87 10:22:40
/*  lfind.c - linear search
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,12-aug-86,new function"
#pragma REVISED "don,16-feb-87,return NULL if not found"
#pragma REVISED "gee,01-sep-87,was not ANSI syntax"
#endif

#include <stdio.h>	/* for NULL */

void *lfind(key, base, num, width, comp)
char *key, *base;
unsigned *num, width;
int (*comp)();
{
  register unsigned int i;

  for(i= *num;i--;){
    if(!(*comp)(key,base)) return base;
    base += width;
  }
  return NULL;
}
+ARCHIVE+ localtim.c    3601  4/08/87 17:07:16
/* localtime - convert a calendar time into a broken-down time
** Original tables copyright 1952 by Arthur A. Merrill
** Copyright (c) 1985,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,5-nov-85,new function"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "nlp,27-feb-87,day_of_week is a macro now"
#pragma REVISED "zap,8-apr-87,leap year screwup"
#endif

#include <time.h>
#include <dos.h>

                           /*  a b c d e f g h i j k l m n  */
static char week_day[12][14]={{1,2,3,4,5,6,0,1,2,3,4,5,6,0},  /* jan */
                              {4,5,6,0,1,2,3,4,5,6,0,1,2,3},  /* feb */
                              {4,5,6,0,1,2,3,5,6,0,1,2,3,4},  /* mar */
                              {0,1,2,3,4,5,6,1,2,3,4,5,6,0},  /* apr */
                              {2,3,4,5,6,0,1,3,4,5,6,0,1,2},  /* may */
                              {5,6,0,1,2,3,4,6,0,1,2,3,4,3},  /* jun */
                              {0,1,2,3,4,5,6,1,2,3,4,5,6,0},  /* jul */
                              {3,4,5,6,0,1,2,4,5,6,0,1,2,3},  /* aug */
                              {6,0,1,2,3,4,5,0,1,2,3,4,5,6},  /* sep */
                              {1,2,3,4,5,6,0,2,3,4,5,6,0,1},  /* oct */
                              {4,5,6,0,1,2,3,5,6,0,1,2,3,4},  /* nov */
                              {6,0,1,2,3,4,5,0,1,2,3,4,5,6}}; /* dec */
                        /*   0  1  2  3  4  5  6  7  8  9  */
static char year_type[160]={ 0, 1, 2, 3,11, 6, 0, 1, 9, 4,  /* 1900 */
                             5, 6, 7, 2, 3, 4,12, 0, 1, 2,  /* 1910 */
                            10, 5, 6, 0, 8, 6, 4, 5,13, 1,  /* 1920 */
                             2, 3,11, 6, 0, 1, 9, 4, 5, 6,  /* 1930 */
                             7, 2, 3, 4,12, 0, 1, 2,10, 5,  /* 1940 */
                             6, 0, 8, 3, 4, 5,13, 1, 2, 3,  /* 1950 */
                            11, 6, 0, 1, 9, 4, 5, 6, 7, 2,  /* 1960 */
                             3, 4,12, 0, 1, 2,10, 5, 6, 0,  /* 1970 */
                             8, 3, 4, 5,13, 1, 2, 3,11, 6,  /* 1980 */
                             0, 1, 9, 4, 5, 6, 7, 2, 3, 4,  /* 1990 */
                            12, 0, 1, 2,10, 5, 6, 0, 8, 3,  /* 2000 */
                             4, 5,13, 1, 2, 3,11, 6, 0, 1,  /* 2010 */
                             9, 4, 5, 6, 7, 2, 3, 4,12, 0,  /* 2020 */
                             1, 2,10, 5, 6, 0, 8, 3, 4, 5,  /* 2030 */
                            13, 1, 2, 3,11, 6, 0, 1, 9, 4,  /* 2040 */
                             5, 6, 7, 2, 3, 4,12, 0, 1, 2}; /* 2050 */

#define day_of_week(t) (week_day[t.tm_mon][year_type[t.tm_year]])

struct tm *localtime(timer)
time_t *timer;
{
  static struct tm t;
  static int month[12]={31,28,31,30,31,30,31,31,30,31,30,31};
  register int i;
  time_t tmr;

  tmr=*timer;
  t.tm_sec=tmr%60;
  tmr/=60;
  t.tm_min=tmr%60;
  tmr/=60;
  t.tm_hour=tmr%24;
  tmr/=24;
  t.tm_year=(tmr/(4*365+1))*4;
  for(tmr=tmr%(4*365+1); 1; ++t.tm_year){  /* perverse code */
    if(t.tm_year%4 || !(t.tm_year%100) && t.tm_year%400){  /* not leap year */
      if(tmr>365) tmr-=365;
      else break;
    } else {
      if(tmr>366) tmr-=366;
      else break;
    }
  }
  tmr--;
  if(!(t.tm_year%4 || !(t.tm_year%100) && t.tm_year%400)) month[1]=29;
  t.tm_yday=tmr;
  t.tm_mon=0;
  i=0;
  while(tmr>=month[i] && i<12){
    ++t.tm_mon;
    tmr-=month[i];
    ++i;
  }
  t.tm_mday=tmr+1;
  t.tm_wday=(day_of_week(t)+t.tm_mday-1)%7;
  t.tm_isdst=0;  /* are you kidding? */
  return &t;
}

+ARCHIVE+ locking.c     1479  3/12/87 14:37:52
/* locking - lock or unlock part of a file
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,1-jul-86,new function"
#endif

#include <dos.h>
#include <sys/locking.h>
#include <stdio.h>
#include <errno.h>

extern int _osmajor;

int locking(fd, mode, length)
int fd, mode;
long length;
{
  struct regval r1,r2;

  if(_osmajor<3) return 0;

  r1.ax=0x4201;  /* lseek */
  r1.bx=fd;
  r1.cx=0;
  r1.dx=0;
  if(sysint21(&r1,&r1)&1){  /* get the current offset */
    errno=EBADF;
    return -1;
  }
  r1.cx=r1.dx;
  r1.dx=r1.ax;
  r1.si=(unsigned)(length>>16);
  r1.di=(unsigned)length;
  if(mode==LK_UNLCK){  /* unlock stuff */
    r1.ax=0x5C01;
    if(sysint21(&r1,&r1)&1){
      if(r1.ax==1) errno=EINVAL;
      else if(r1.ax==6) errno=EBADF;
      else errno=EACCES;
      return -1;
    }
  } else {
    r1.ax=0x5C00;
    r2.ax=0x440B;  /* ioctl */
    if(mode==LK_LOCK) r2.bx=9;  /* 10 attempts */
    else if(mode==LK_NBLCK) r2.bx=0;  /* 1 attempt */
    else {
      errno=EINVAL;
      return -1;
    }
    r2.cx=1000;  /* timing between attempts */
    if(sysint21(&r2,&r2)&1){
      errno=EINVAL;
      return -1;
    }
    if(sysint21(&r1,&r1)&1){  /* lock it */
      if(r1.ax==1) errno=EINVAL;
      else if(r1.ax==6) errno=EBADF;
      else if(mode==LK_LOCK) errno=EDEADLOCK;
      else errno=EACCES;
      return -1;
    }
  }
  return 0;
}
+ARCHIVE+ log.c         1020 10/09/87 17:59:54
/* log.c - log base e
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-nov-86,separate files for log() and log10()"
#pragma REVISED "zap,24-aug-87,range error if arg == 0"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <_math.h>
#include <float.h>
#include <errno.h>
#include <stdlib.h>

double *log(val)
double val;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  errno=0;
  temp=_log(val);
  if(errno){
    *temp= -HUGE_VAL;
    exc.type=DOMAIN;
    goto L1;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
L1:
    exc.name="log";
    exc.arg1=val;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}

+ARCHIVE+ log10.c       1055 10/12/87 13:29:46
/* log10.c - log base 10
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-nov-86,separate files for log() and log10()"
#pragma REVISED "zap,24-aug-87,range error if arg == 0"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <float.h>
#include <errno.h>
#include <_math.h>
#include <stdlib.h>

double *log10(val)
double val;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  errno=0;
  temp=_log10(val);  /* *0.434294481903252 */
  if(errno){
    *temp= -HUGE_VAL;
    exc.type=DOMAIN;
    goto L10;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
L10:
    exc.name="log10";
    exc.arg1=val;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}
+ARCHIVE+ lower.c        358 12/22/86 12:35:04
/* lower - convert a string to lower case
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-oct-85,add header, copyright"
#endif

unsigned char *lower(cp)
unsigned char *cp;
{
  unsigned char *ct;

  for(ct=cp;*ct;++ct) if(*ct>='A' && *ct<='Z') *ct+=('a'-'A');
  return cp;
}
+ARCHIVE+ lsearch.c      592  9/03/87 10:28:36
/*  lsearch.c - linear search
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,12-aug-86,new function"
#pragma REVISED "gee,01-sep-87,add element if not found"
#endif

#include <stdio.h>

void *lsearch(key, base, num, width, comp)
char *key, *base;
unsigned *num, width;
int (*comp)();
{
  register unsigned int i;

  for(i= *num;i--;){
    if(!(*comp)(key,base)) return base;
    base+=width;
  }
  memcpy(base,key,width);	/* add the entry */
  ++*num;                  /* and count it */
  return NULL;
}
+ARCHIVE+ lseek.c        852  9/10/87 18:07:54
/* lseek.c - do a seek on a file
** Copyright (c) 1985,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,9-oct-85,add header and copyrignt, _opentab to _iob"
#pragma REVISED "zap,25-oct-85,assume no buffering"
#pragma REVISED "zap,22-may-86,new defines in fileio3.h"
#pragma REVISED "zap,10-sep-87,clear EOF"
#endif

#include <stdio.h>
#include <dos.h>
#include <fileio3.h>

long lseek(fd,offset,base)
int fd;				/* the file to seek */
long offset;		/* how far to move */
int base;			/* base to move from */
{
  struct regval reg;

  reg.ax=0x4200|base;
  reg.bx=fd;
  reg.cx=(unsigned)(offset>>16);
  reg.dx=(unsigned)offset;
  if(sysint21(&reg,&reg)&1) return -1L;  /* get the OS file offset */
  _iob[fd]._flag&=~_IOEOF;
  return _piob[fd]._foffset=((long)reg.dx<<16)+reg.ax;
}
+ARCHIVE+ ltell.c        380  1/02/87 10:41:52
/* ltell.c - return the current file position as a long
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-oct-85,add header, copyright"
#pragma REVISED "zap,22-may-86,new defines in fileio3.h"
#endif

#include <fileio3.h>
#include <io.h>

long ltell(fd)
int fd;
{

  return _piob[fd]._foffset;
}
+ARCHIVE+ ltoa.c         310 12/22/86 12:35:14
/* ltoa - long to ascii
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-jul-85,add this comment & copyright"
#pragma REVISED "zap,9-oct-85,add signals"
#endif

ltoa(n,cp)
long n;
unsigned char *cp;
{
  return ltos(n,cp,-10);
}
+ARCHIVE+ ltoh.c         291 12/22/86 12:35:18
/* ltoh - long integer to hex conversion
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,10-oct-85,add this comment & copyright"
#endif

ltoh(n,cp)
unsigned long n;
unsigned char *cp;
{
  return ltos(n,cp,16);
}
+ARCHIVE+ ltos.c         940  8/26/87 16:57:08
/* ltos - long to string
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,10-oct-85,add this comment & copyright"
#pragma REVISED "zap,4-jun-86,registers"
#endif

ltos(val,cp,base)
long val;			/* the number to convert */
unsigned char *cp;		/* the address of the string */
int base;			/* the conversion base */
{
  unsigned char tempc[34],*tcp;
  register int n=0;			/* number of characters in result */
  unsigned long uval;		/* unsigned value */
  static unsigned char dig[]={"0123456789ABCDEF"};

  *(tcp=tempc+33)=0;
  if(base<0){			/* needs signed conversion */
    if(val<0)n=1;
    else val=-val;
    do {*--tcp=dig[-(val%base)];} while((val/=-base));
    if(n)*--tcp='-';
  } else {				/* unsigned conversion */
    uval=val;
    do {*--tcp=dig[uval%base];} while(uval/=base);
  }
  n=tempc+33-tcp;
  memcpy(cp,tcp,n+1);
  return n;
}
+ARCHIVE+ makefcb.c     2617  8/14/87 17:53:14
/* makefcb - make a file control block
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,6-nov-85,add header, copyright"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "nlp,14-aug-87,wrong structure name"
#endif

/*	define the ms-dos file control block
*/

struct fcb_str{
  unsigned char fcb_dr;			/* drive specification */
  unsigned char fcb_fn[8];		/* the file name */
  unsigned char fcb_ft[3];		/* the file type */
  unsigned fcb_cb;			/* current block number */
  unsigned fcb_rs;			/* record size */
  unsigned long fcb_fs;			/* file size */
  unsigned fcb_fd;			/* file date */
  unsigned char fcb_dn[10];		/* ms-dos use */
  unsigned char fcb_cr;			/* current record */
  unsigned long fcb_rr;			/* random record number */
  unsigned char fcb_path[1];		/* path name if under 2.00 */
};

extern unsigned char *calloc();

struct fcb_str *makefcb(filename)
unsigned char *filename;
{
  register int u,j;
  struct fcb_str *fcb;
  unsigned char pathname[76],*cp,*pp;

  if(filename[1]==':'){
    u=toupper(*filename);
    if(u<'A' || u>'P')goto err01;
    filename+=2;
  } else u=(bdos(0x19)&0xff)+'A';	/* set default drive */

  strcpy(pathname," :");
  pathname[0]=u;		/* set the drive */
  for(pp=pathname+2;;filename=cp){
    for(cp=filename;*cp && *cp!='\\' && *cp!='/';++cp);
    if(!*cp)break;
    for(j=8,cp=filename;;){
      *pp=toupper(*cp++);
      if(*pp=='\\' || *pp=='/'){
        ++pp;
        break;
      }
      if(j)--j,++pp;
    }
    if(pp>pathname+67)goto err01;	/* too far up garden path */
  }
  if(pp>pathname+3)--pp;
  *pp=0;				/* end of path name */

  if(pp==pathname+2)pathname[0]=0;

  if(!(fcb=calloc(sizeof(struct fcb_str)+strlen(pathname),1)))
		goto err01;/* heap full */
  strcpy(fcb->fcb_path,pathname);

  fcb->fcb_dr=u-('A'-1);		/* set drive number */
  memset(fcb->fcb_fn,' ',11);			/* space fill fn and ft */
  if(_makefcb(fcb->fcb_fn,8,&filename)||_makefcb(fcb->fcb_ft,3,&filename))
    goto error;
  return fcb;					/* all ok */

error:
  free(fcb);
err01:
  return (struct fcb_str *)0;
}

/*	a service routine for makefcb
*/

_makefcb(outstr,outlen,filename)
unsigned char *outstr,**filename;
int outlen;
{
  unsigned char *cp;
  int u;

  for(cp=*filename;*cp;){		/* do file name */
    u=toupper(*cp++)&0x7f;
    if(u=='.')break;			/* that part done */
    if(u<0x21)return 1;			/* some protection */
    if(outlen){
      --outlen;
      *outstr++=u;
    }
  }
  *filename=cp;
  return 0;
}
+ARCHIVE+ makefnam.c    1422 12/24/86  9:58:58
/* makefnam - split up a file name (subroutine for makefnam)
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-oct-85,add header, copyright"
#pragma REVISED "zap,4-jun-86,registers"
#endif

static _makefn(source,dest)
unsigned char *source;
unsigned char *dest;
{
  register int j,k;
  unsigned char *strrchr();

  memset(dest,0,82);		/* clear result field */
  if(strlen(source)>1 && source[1]==':') for(j=0;j<2;) dest[j++]=*source++;
  j=3;
  while(strrchr(source,'\\')||strrchr(source,'/')){
    for(k=0;(*source!='\\')&&(*source!='/');++source)
		if(j<65 && k++<8)dest[j++]=*source;
    dest[j++] = (*source=='/') ? *source  : '\\';
    ++source;
  }
  for(j=67;*source && *source!='.';++source) if(j<75) dest[j++]=*source;
  for(j=76;*source;++source) if(j<80) dest[j++]=*source;
}

/*	make a file name using a template
*/

unsigned char *makefnam(rawfn,template,result)
unsigned char *rawfn;			/* the original file name */
unsigned char *template;		/* the template data */
unsigned char *result;			/* where to place the result */
{
  unsigned char et[82],er[82];

  _makefn(template,et);
  _makefn(rawfn,er);
  *result=0;			/* assure no data */
  strcat(result,er[0]?er:et);
  strcat(result,er[3]?er+3:et+3);
  strcat(result,er[67]?er+67:et+67);
  strcat(result,er[76]?er+76:et+76);
  return result;
}
+ARCHIVE+ malloc.c       512  8/14/87 10:37:54
/* malloc - memory allocator
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,20-oct-86,complete rewrite. call _fmalloc and _nmalloc"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#pragma REVISED "zap,12-aug-87,remove include files"
#endif

#include <malloc.h>
#undef malloc

void *malloc(requested_size)
unsigned requested_size;
{
#ifdef _FLAGS_Af
  return _fmalloc(requested_size);
#else
  return _nmalloc(requested_size);
#endif
}

+ARCHIVE+ matherr.c      470 12/22/86 12:35:28
/*  matherr.c - stub
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,17-may-86,gnu function"
#endif

struct exception{
  int type;         /* type of error - see get87sw() exception flags */
  char *name;    /* name of function which caused error, e.g.- "log" */
  double arg1,arg2,retval;   /* argument(s) and default return value */
};

int matherr(x)
struct exception *x;
{
  return 0;
}
+ARCHIVE+ memccpy.c      525  2/12/87 10:00:22
/* memccpy.c - copy characters from s2 to s1 until after c found or n exhausted
** returns: pointer to first character after c or NULL if c
**  not found in range
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-oct-85,add header, copyright"
#pragma REVISED "nlp,12-feb-87,register"
#endif

char *memccpy(s1, s2, c, n)
register char *s1, *s2;
register char c;
register int n;
{
  while(n-->0) if((*s1++=*s2++)==c) return s1;
  return 0;
}
+ARCHIVE+ memchr.c       393  2/12/87  9:29:48
/* memchr - locate a character in an array
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,9-aug-85,new function"
#pragma REVISED "nlp,12-feb-87,register"
#endif

char *memchr(s,c,n)
register char *s;
register int c;
register int n;
{
  while(n--){
    if(*s==c)return(s);
    ++s;
  }
  return (char *)0;
}
+ARCHIVE+ memcmp.c       509  2/12/87 10:00:46
/* memcmp.c - compares first n characters of arguments
   returns:
	-1	s1 < s2
	 0	s1 == s2
	+1	s2 > s2
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,26-jul-85,add this comment and copyright"
#pragma REVISED "nlp,12-feb-87,register"
#endif

int memcmp(s1,s2,n)
register unsigned char *s1,*s2;
register int n;
{
  for(;n;--n,++s1,++s2){
    if(*s1 == *s2)continue;
    return (*s1 < *s2) ? -1 : 1;
  }
  return 0;
}


+ARCHIVE+ memicmp.c      535  2/12/87 10:01:32
/*  memicmp.c - case-insentitive buffer comparison
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,--86,add header, copyright"
#pragma REVISED "nlp,12-feb-87,register"
#endif

int memicmp(buf1, buf2, count)
register char *buf1, *buf2;
register int count;
{
  while(count--){
    if(toupper(*buf1)!=toupper(*buf2)) break;
    buf1++;
    buf2++;
  }
  if(!isalpha(*buf1) || !isalpha(*buf2)) return *buf1-*buf2;
  return toupper(*buf1)-toupper(*buf2);
}

+ARCHIVE+ mkdir.c        465 12/22/86 12:35:48
/* mkdir - make a directory
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-oct-85,update to v3.0"
#endif

#include <dos.h>

mkdir(dir)
unsigned char *dir;
{
  struct regval srv;

  srv.ds=P_SEG(dir);
  srv.dx=P_OFF(dir);	/* address of drive and directory path names */
  srv.ax=0x3900; 	/* dos 2.0 MKDIR function call */
  if(sysint21(&srv,&srv)&1)return -1;
  return 0;
} 	
+ARCHIVE+ mktemp.c       894  7/09/87 17:15:34
/*  mktemp.c - make a temporary file name
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-may-86,new function"
#pragma REVISED "nlp,7-jul-87, use P_SEG, P_OFF"
#endif

#include <dos.h>
#include <stdio.h>  /* for NULL */

extern char *strstr();

char *mktemp(template)
char *template;
{
  struct regval reg;
  register char *p;

  if((p=strstr(template,"XXXXXX"))==NULL) return NULL;
  sprintf(p+1,"%05d",getpid());
  *p='0';

  reg.ax=0x4300;					/* see if file exists */
  reg.ds=P_SEG(template);
  reg.dx=P_OFF(template);
  if((sysint21(&reg,&reg)&1)) return template;	/* doesn't exist */


  for(*p='a'; *p<='z'; (*p)++){
    reg.ax=0x4300;
    reg.ds=P_SEG(template);
    reg.dx=P_OFF(template);
    if((sysint21(&reg,&reg)&1)) return template;	/* doesn't exist */
  }
  return NULL;
}
+ARCHIVE+ mktime.c      1426  8/28/87 14:05:40
/* mktime - converts the broken-down time, expressed as local time,
** into a calender time value with the same encoding as that of a value
** returned by time function. 
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma CREATED "ahm,25-aug-87,new function"
#pragma REVISED "ahm,28-aug-87, works under DOS and UNIX"
#endif

#include <time.h>
#include <sys/types.h>
#include <sys/utime.h>

time_t mktime(timeptr)
struct tm *timeptr; 
{
	int  days(), years, leap_years;
	time_t  sec, total_days;


	years = timeptr->tm_year;
	leap_years = (years+3)/4 + 1; /* total leap years before current year */
   timeptr->tm_yday = days(timeptr->tm_mon,
		                     timeptr->tm_mday,timeptr->tm_year);
   total_days = (years * 365L) + leap_years + timeptr->tm_yday;
	timeptr->tm_wday = (total_days-1) % 7;
	   /* day on Jan 1, 1900 was Monday = 1 */ 
   sec = ((((total_days*24 + timeptr->tm_hour) * 60L) +
		      timeptr->tm_min) *60L) + timeptr->tm_sec;
	
   return sec;
}

int days_in_month[12] = {31, 28, 31, 30, 31, 30,
	      	  	 31, 31, 30, 31, 30, 31};

int days(month, date, year)  /* calculate day of the year */
int month, date, year;
{
	int  i, yday=0;

	for(i=0;i<month;i++)
		yday += days_in_month[i];
	yday += date-1;			  /* complete days before date */
	if ((year%4==0)&&(month>1))  
	    yday += 1;
	return yday;
}
+ARCHIVE+ modf.c         745 10/09/87 16:28:54
/* modf - return the integer and fractional part of a number
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-oct-85,add header, copyright"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <float.h>
#include <_math.h>

double *modf(val, ivp)
double val;
double *ivp;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  temp=_modf(val,ivp);
  if((_temp=_status87())&0x80){
    exc.name="modf";
    exc.arg1=val;
    exc.arg2=*ivp;
    exc.retval=*temp;
    exc.type=_err_map(_temp);
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}
+ARCHIVE+ movblock.c     342  5/04/87 16:48:54
/* movblock.c - far memory copy
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,16-jul-86,rewrite from assembler"
#pragma REVISED "nlp,04-may-87,p2 is far, too"
#endif

void movblock(p1,p2,n)  
char far *p1, far *p2;  
int n;  
{
    while(n--) 
      *p2++=*p1++;
}
+ARCHIVE+ oldgets.c      461  6/08/87 10:45:56
/*	oldgets - get a string from stdin, dropping the newline, C86 fashion
** Copyright (C) 1987 Computer Innovations, Inc.  ALL RIGHTS RESERVED
*/

#include <stdio.h>

char *oldgets(line,maxline)
char *line;
int maxline;
{
  int j,cc;

  for(j=0;j<maxline-1;){
    cc=fgetc(stdin);
    if(cc=='\n')break;
    else if(cc==-1) {
      if(j==0) return NULL;
      else break;
    }
    line[j++]=cc;
  }
  line[j]=0;
  return j?line:NULL;
}
+ARCHIVE+ onexit.c       666 12/22/86 12:36:02
/* onexit - register routines for execution before termination of program
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-oct-85,rewrite for v3.0"
#pragma REVISED "zap,4-jun-86,registers"
#endif

static void (* _exit_func[32])()={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                         0,0,0,0,0,0,0,0,0,0,0,0};

int onexit(func)
int (* func)();
{
  register int i;

  for(i=0;_exit_func[i] && i<32;++i);
  if(i>=32) return 0;
  _exit_func[i]=func;
  return 1;
}

int _do_exit_func()
{
  register i=0;

  while(_exit_func[i] && i<=32) (*_exit_func[i++])();
}
+ARCHIVE+ open.c         508  5/28/87  9:46:26
/* open.c - do common open
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-jul-85,add this comment & copyright"
#pragma REVISED "nlp,28-may-87, use ternary"
#endif

#include <fcntl.h>
#include <sys/stat.h>

extern unsigned _osmajor;
extern unsigned _umask;

int open(path, mode, permit)
char *path;
unsigned mode, permit;
{

  return _open(path,mode,0
		,((_osmajor==2) ? (S_IREAD|S_IWRITE) : (permit&(~_umask))));
}
+ARCHIVE+ peek.c         250 12/22/86 12:36:10
/* peek.c - read a word anywhere in memory
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,16-jul-86,rewrite from assembler"
#endif

int peek(wp)  unsigned far *wp;  { return *wp; }
+ARCHIVE+ perror.c      1432 12/22/86 12:36:16
/* perror.c - print error message for error number
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-oct-85,new function"
#pragma REVISED "zap,7-nov-85,make _perrmess non-static for strerror()"
#pragma REVISED "zap,14-nov-85,two more messages"
#pragma REVISED "zap,19-may-86,new set of error messages"
#endif

#include <errno.h>
#include <stdio.h>

char *_perrmess[_NUM_ERR_NUMS+1]={
  " ",
  " ",
  "file or path not found ",
  " ",
  " ",
  " ",
  " ",
  "size of argument too large ",
  "file is not executable ",
  "invalid file descriptor ",
  " ",
  " ",
  "out of memory ",
  "file access denied ",
  " ",
  " ",
  " ",
  "file already exists ",
  "attempt to move a file to a different device ",
  " ",
  " ",
  " ",
  "invalid argument or operation ",
  " ",
  "too many open files ",
  " ",
  " ",
  " ",
  "device is full ",
  " ",
  " ",
  " ",
  " ",
  "argument out of range ",
  "result out of range ",
  " ",
  "locking violation ",
  "Bad signal vector ",
  "Bad free pointer ",
  "Illegal error number "};

perror(s)
char *s;
{
  char buff[256];

  buff[0]=0;
  if(errno<0 || errno>_NUM_ERR_NUMS) errno=_NUM_ERR_NUMS;  /* kluje */
  if(s!=NULL && *s!=0){
    strcat(buff,s);
    strcat(buff,": ");
  }
  strcat(buff,_perrmess[errno]);
  strcat(buff,"\r\n$");
  bdos(9,buff);
}
+ARCHIVE+ pokeb.c        260 12/22/86 12:36:18
/* pokeb.c - poke a byte
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,16-jul-86,rewrite from assembler"
#endif

int pokeb(cp, c)  char far *cp; char c;  { return *cp=c; }  /* cute, huh? */
+ARCHIVE+ pokew.c        261 12/22/86 12:36:20
/* pokew.c - poke a word
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,16-jul-86,rewrite from assembler"
#endif

int pokew(wp, w) int far *wp; int w; { return *wp=w; }  /* disgusting, no? */
+ARCHIVE+ pow.c          902 10/09/87 18:02:50
/* pow - returns x**y
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,11-nov-86,8087"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <float.h>
#include <errno.h>
#include <_math.h>

double *pow(x,y)
double x, y;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  errno=0;
  temp=_pow(x,y);
  if(errno){
    *temp=0.0;
    exc.type=DOMAIN;
    goto P1;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
P1:
    exc.name="pow";
    exc.arg1=x;
    exc.arg2=y;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}

+ARCHIVE+ ptrdiff.c      348 12/22/86 12:36:36
/* ptrdiff.c - get the difference between pointers
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-sep-86,new function"
#endif

#include <dos.h>

long ptrdiff(p1, p2)
void far *p1, *p2;
{
 return (((long)FP_SEG(p1)<<4)+FP_OFF(p1))-(((long)FP_SEG(p2)<<4)+FP_OFF(p2));
}

+ARCHIVE+ ptrtoabs.c     480  9/11/87 18:01:10
/* ptrtoabs - convert a pointer to an absolute address
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,19-sep-85,add header, copyright notice, and small model"
#pragma REVISED "zap,15-oct-85,far pointers only!"
#pragma REVISED "zap,11-dep-87,cast segment to long"
#endif

unsigned long ptrtoabs(offset,segment)
unsigned offset;
unsigned segment;
{
  return ((unsigned long)segment<<4L)+offset;
}
+ARCHIVE+ putc.c         335  2/06/87 10:21:44
/* putc - put a character to the stream
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,new function"
#pragma REVISED "zap,6-feb-87,include stdio.h"
#endif

#include <stdio.h>
#undef putc

putc(c,f)
char c;
FILE *f;
{
  return(fputc(c,f));
}
+ARCHIVE+ putchar.c      335  7/29/87 15:55:12
/* putchar - put a character to stdout
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,add this comment and copyright"
#pragma REVISED "zap,29-jul-87,typo"
#endif
#include <stdio.h>
#undef putchar

putchar(c)
char c;
{
  putc(c,stdout);
}

+ARCHIVE+ putenv.c      1811  1/29/87 10:57:40
/* putenv - update an environment string
** Copyright (c) 1985,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,12-nov-85,new function"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,8-nov-86,rewrite"
#pragma REVISED "nlp,27-jan-87,invalidated by _main2.c"	
#pragma REVISED "zap,28-jan-87,rewrite"
#pragma REVISED "zap,29-jan-87,common error tail"
#endif

#include <dos.h>
#include <string.h>
#include <malloc.h>
#include <signal.h>

extern char **environ;
static unsigned first=1;

int putenv(string)
char *string;
{
  register i,len;
  char **temp,*cp;

  if(first){  /* restructure the environment */
    for(i=0;environ[i];i++) ;  /* get the size */
    if(!(temp=calloc(i,sizeof(char *)))){  /* ignore compiler warning */
      goto woopsie;
    }
    for(i=0;environ[i];i++){
      if(!(temp[i]=malloc(strlen(environ[i])+1))) goto woopsie;
      strcpy(temp[i],environ[i]);
    }
    temp[i]=(char *)0;
    free(environ[0]);  /* free the old environment - it's built funny */
    environ=temp;
    first=0;
  }

  if((len=strcspn(string,"="))==strlen(string)) return -1;

      /* if it's already there, replace it */
  for(i=0;environ[i];i++){
    if(!strncmp(string,environ[i],len)){
      if(!(cp=malloc(strlen(string)+1))) goto woopsie;
      free(environ[i]);
      environ[i]=cp;
      strcpy(environ[i],string);
      return 0;
    }
  }
      /* otherwise, add it */
  if(!(temp=malloc((i+1)*sizeof(char *)))) goto woopsie;
  memcpy(temp,environ,(i+1)*sizeof(char *));
  free(environ);
  environ=temp;
  if(!(environ[i]=malloc(strlen(string)+1))) goto woopsie;
  environ[i+1]=(char *)0;
  strcpy(environ[i],string);
  return 0;

woopsie:
  raise(SIGALLOC);
  return -1;
}
+ARCHIVE+ puts.c         324  2/24/87 10:01:54
/* puts - put a string to the stream
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,new function"
#endif
#include <stdio.h>

puts(s)
char *s;
{
  if(fputs(s,stdout)) return 1;
  if(fputc('\n',stdout)==EOF) return 1;
  return 0;
}

+ARCHIVE+ putw.c         374  1/02/87 17:12:20
/* putw - put a word to a file
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-oct-85,add header, copyright"
#endif

#include <stdio.h>

int putw(w,buf)
int w;
FILE *buf;
{
  if(fputc(w,buf)==EOF) return EOF;	/* really error status */
  if(fputc(w>>8,buf)==EOF) return EOF;
  return w;
}
+ARCHIVE+ qsort.c       1587 12/22/86 12:37:04
/*	qsort - quicksort
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "7nov86,zap,add header, copyright"
#pragma REVISED "nlp,21-nov-86,register"
#endif

#include <search.h>

#define DEPTH 20		/* should be adequate for most sorts */

static swapbyte(a,b,count)
unsigned char *a,*b;
unsigned count;
{

  while(count--){
	 register temp;

    temp=*a;
    *a++=*b;
    *b++=temp;
  }
}

void qsort(base, n, width, cmpf)
unsigned char *base;  /* base of data */
unsigned int n;   /* number of items to sort */
unsigned width;   /* width of an element */
int (*cmpf)();    /* key comparison function */
{
  unsigned j, k, pivot, low[DEPTH], high[DEPTH];
  register count;

  if(n<2) return;  /* already sorted */
  count=1;			/* do initialisation */
  low[0]=0;
  high[0]=n-1;
  while(count--){
    pivot=low[count];
    j=pivot+1;
    n=k=high[count];
    while(j<k){
      while(j<k && (*cmpf)(base+j*width,base+pivot*width)<1) ++j;
      while(j<=k && (*cmpf)(base+pivot*width,base+k*width)<1) --k;
      if(j<k) swapbyte(base+(j++*width),base+(k--*width),width);
    }
    if((*cmpf)(base+pivot*width,base+k*width)>0)
    swapbyte(base+pivot*width,base+k*width,width);
    if(k>pivot) --k;
    if(k>pivot && n>j && (k-pivot < n-j)){
      swapbyte(&k,&n,2);
      swapbyte(&pivot,&j,2);
    }
    if(k>pivot){
      low[count]=pivot;
      high[count++]=k;
    }
    if(n>j){
      low[count]=j;
      high[count++]=n;
    }
    if(count>=DEPTH) abort();
  }
}
+ARCHIVE+ raise.c        398 12/22/86 12:37:08
/* raise - send a signal
** Copyright (c) 1985,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,9-25-85,New function"
#pragma REVISED "zap,4-10-85,rename from kill to raise"
#endif

#include <signal.h>
#include <errno.h>

int raise(sig)
int sig;  /* signal type */
{
  if(0<=sig && sig<=SIGSIZE) (*_sig_eval[sig])();
  else errno=ESIGNAL;
}
+ARCHIVE+ rand.c         455  8/12/87 15:38:50
/* rand - random number generator
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-oct-85,add copyright"
#pragma REVISED "zap,12-aug-87,get RAND_MAX from stdlib.h"
#endif

#include <stdlib.h>

static unsigned long next=1; 

int rand()
{
  next=next*1103515245+12345;
  return (unsigned)(next>>18) & RAND_MAX;
}

void srand(seed)
unsigned seed;
{
  next=seed;
}
+ARCHIVE+ read.c        2015 11/11/87 14:26:22
/* read.c - read from a file descriptor
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-apr-86,change kill to raise"
#pragma REVISED "zap,22-may-86,new defines in fileio3.h"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,5-feb-87,fill ascii buffers completely"
#pragma REVISED "zap,17-feb-87, ... except on a short read the first time"
#pragma REVISED "zap,25-feb-87,bad newline processing"
#pragma REVISED "zap,18-mar-87,return values; _dosf3f()"
#pragma REVISED "zap,19-may-87,ASCII ^Z processing"
#pragma REVISED "zap,10-sep-87,ASCII ^Z processing"
#pragma REVISED "zap,21-sep-87,typo"
#pragma REVISED "zap,22-oct-87,at ^Z EOF, return ptr diff, not return count"
#pragma REVISED "zap,23-oct-87,character device EOF"
#pragma REVISED "zap,10-nov-87,move some EOF processing to _filbuf()"
#pragma REVISED "zap,11-nov-87,another SIGREAD"
#endif

#include <stdio.h>
#include <dos.h>
#include <fileio3.h>
#include <errno.h>
#include <signal.h>

int read(fd,where,count)
int fd;
unsigned char *where;
int count;
{
  register int rcount,i;
  unsigned char *sp,*dp;

  if(fd<0 || fd>=SYS_OPEN){
    errno=EBADF;
    raise(SIGREAD);
    return EOF;
  }

  _osfile[fd]|=_IOTOUCHED;  /* for setvbuf */
  if((rcount=_dosf3f(fd,where,count))==EOF){  /* errno set bug _dosf3f() */
    raise(SIGREAD);
    return EOF;
  }
  if(!rcount) return 0;
  _piob[fd]._foffset+=rcount;  /* for fseek */

  if(_osfile[fd]&_IOASCII){  /* convert cr/lf pairs */
    sp=dp=where;
    for(i=rcount;i--;){
      if(*sp==26){               /* control-Z */
        if(sp==where) return 0;
        *dp=26;
        _piob[fd]._foffset--;
        if(!--rcount) return 0;
        return (int)((unsigned)dp-(unsigned)where);
      } else if(*sp=='\r'){
        ++sp;
        *dp++='\n';
      } else if(*sp=='\n'){
        sp++;
        --rcount;
      } else *dp++= *sp++;
    }
  }
  return rcount;
}
+ARCHIVE+ realloc.c     3839  9/11/87 17:55:08
/* realloc - memory reallocator
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,9-23-85,Complete rewrite! New scheme!"
#pragma REVISED "zap,10-14-85,New header file, alloc.h"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,4-nov-86,near and far"
#pragma REVISED "gee,20-dec-86,_FLAGS_Af added"
#pragma REVISED "zap,18-jun-87,ROMS
#pragma REVISED "zap,11-aug-87,split the whole file"
#pragma REVISED "zap,11-sep-87,remove add_to_ptr()"
#endif

#include <errno.h>
#include <signal.h>
#include <malloc.h>
#include <_alloc.h>

#ifdef _FLAGS_An
extern struct nfree_list_item *_nprimary_free_list;

void *realloc(bptr, requested_size)
char *bptr;
unsigned requested_size;
{
  struct nfree_list_item *block_ptr, *this_ptr, *last_ptr=NULL;
  register unsigned block_size, old_size;

  if(requested_size>0xFFE8) return NULL;
  requested_size=(requested_size>MIN_NALLOC)
               ? (requested_size+1)&0xFFFE : MIN_NALLOC;

  if(bptr){
    block_ptr=bptr-FHN_SIZE;
    if(block_ptr->next!=(void *)block_ptr){
      errno=EFREE;
      raise(SIGFREE);
      return(NULL);
    }
    old_size=(unsigned)block_ptr->length;
    _nfree(bptr);
  } else old_size=0;
  _nmerge_free_lists();

  if((last_ptr=_nmalloc_find(_nprimary_free_list,requested_size))==NULL){
    this_ptr=_nprimary_free_list;
    last_ptr=&_nprimary_free_list;  /* ignore compiler warning */
  } else this_ptr=last_ptr->next;

  if(this_ptr!=NULL){
    block_size=(requested_size>old_size) ? old_size : requested_size;
    memcpy((char *)this_ptr+FHN_SIZE,bptr,block_size);
    memset((char *)this_ptr+FHN_SIZE+block_size,0
          ,(requested_size>block_size) ? requested_size-block_size : 0);
    last_ptr->next=_nmalloc_take(this_ptr,requested_size);
  } else {
    return NULL;
  }

  return (void *)(this_ptr+1);
}


#else           /* far data */

#ifndef ROM_PROG
extern unsigned _amblksize;
#endif

extern struct ffree_list_item *_fprimary_free_list;

void *realloc(bptr, requested_size)
char *bptr;
unsigned requested_size;
{
  unsigned tmp;
  struct ffree_list_item *block_ptr, *this_ptr, *last_ptr=NULL;
  register unsigned block_size, old_size;

  if(requested_size>0xFFE8) return NULL;
  requested_size=(requested_size>MIN_FALLOC)
               ? (requested_size+1)&0xFFFE : MIN_FALLOC;

  if(bptr){
    block_ptr=abstoptr(ptrtoabs(bptr)-FHF_SIZE);
    if(block_ptr->next!=(void *)ptrtoabs(block_ptr)){
      errno=EFREE;
      raise(SIGFREE);
      return(NULL);
    }
    old_size=(unsigned)block_ptr->length;
    _ffree(bptr);
  } else old_size=0;

again:
  _fmerge_free_lists();

  if((last_ptr=_fmalloc_find(_fprimary_free_list,requested_size))==NULL){
    this_ptr=_fprimary_free_list;
    last_ptr=&_fprimary_free_list;  /* ignore compiler warning */
  } else this_ptr=last_ptr->next;

  if(this_ptr!=NULL){
    block_size=(requested_size>old_size) ? old_size : requested_size;
    memcpy(abstoptr(ptrtoabs(this_ptr)+FHF_SIZE),bptr,block_size);
    memset(abstoptr(ptrtoabs(this_ptr)+FHF_SIZE+block_size),0
          ,(requested_size>block_size) ? requested_size-block_size : 0);
    last_ptr->next=_fmalloc_take(this_ptr,requested_size);
  } else {
#ifndef ROM_PROG
    tmp= (requested_size+FHF_SIZE > _amblksize<<4)
            ? requested_size+FHF_SIZE : _amblksize<<4;
    if((this_ptr=sbrk(tmp))==NULL) return NULL;
    this_ptr->length=(long)tmp-FHF_SIZE;
    this_ptr->next=(void *)ptrtoabs(this_ptr);
    last_ptr=NULL;
    _ffree(this_ptr+1);  /* ignore compiler warning */
    goto again;
  }

  return (void *)abstoptr(ptrtoabs(this_ptr)+FHF_SIZE);

#else
  return (void *)0;   /* ROMmed programs have no sbrk() */
#endif
}

#endif

+ARCHIVE+ remove.c       431  3/03/87  9:23:42
/* remove - delete a file
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-oct-85,rewrite with dos.h, add copyright"
#endif

#include <dos.h>

int remove(filename)
char *filename;
{
  struct regval srv;

  srv.ax=0x4100;
  srv.dx=P_OFF(filename);
  srv.ds=P_SEG(filename);
  if(sysint21(&srv,&srv)&1) return -1;
  return 0;		/* success */
}

+ARCHIVE+ rename.c       565 12/22/86 12:37:22
/* rename - rename a file for dos 2.00
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-oct-85,add header, copyright"
#endif

#include <dos.h>

rename(filefrom,fileto)
unsigned char *filefrom,*fileto;
{ 
  struct regval srv;

  srv.ds=P_SEG(filefrom);
  srv.es=P_SEG(fileto);
  srv.ax=0x5600;	/* dos 2.0 function to rename file */
  srv.dx=P_OFF(filefrom);	/* old file name */
  srv.di=P_OFF(fileto);	/* new file name */
  if(sysint21(&srv,&srv)&1)return -1;
  return 0;
}

+ARCHIVE+ rewind.c       551  1/02/87 17:17:56
/* rewind - move the file pointer back to the start of the file
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-oct-85,rewrite the function in C"
#pragma REVISED "zap,20-dec-86,returns long"
#endif

#include <stdio.h>
#include <dos.h>
#include <fileio3.h>

void rewind(stream)
FILE *stream;
{
  struct regval reg;

  fflush(stream);
  reg.ax=0x4200;
  reg.bx=stream->_fd;
  reg.cx=0;
  reg.dx=0;
  sysint21(&reg,&reg);
  _piob[stream->_fd]._foffset=0L;
}

+ARCHIVE+ rmdir.c        447 12/22/86 12:37:30
/* rmdir - remove a directory
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-oct-85,add header, copyright"
#endif

#include <dos.h>

rmdir(dir)
char *dir;
{
  struct regval srv;

  srv.ds=P_SEG(dir);
  srv.dx=P_OFF(dir);		/* address of directory path */
  srv.ax=0x3A00;	/* dos 2.0 RMDIR function call */
  if(sysint21(&srv,&srv)&1)return -1;
  return 0;
}
+ARCHIVE+ rmtmp.c        481 12/22/86 13:16:44
/*  rmtmp.c - remove files created by tmpfile()
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,12-aug-86,new function"
#endif

#include <stdio.h>

struct _tf_list{
  struct _tf_list *next;
  char name[L_tmpnam];
};
extern struct _tf_list _tf_root;

int rmtmp()
{
  register int i=0;
  struct _tf_list *temp;

  for(temp=&_tf_root;temp!=NULL;temp=temp->next,i++) remove(temp->name);
  return i;
}
+ARCHIVE+ sbrk.c        2383  8/03/87 15:33:28
/* sbrk - get some memory from the system
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,23-aug-85,rewrite for new memory layout"
#pragma REVISED "zap,14-oct-85,differences between large and small model"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,20-oct-86,new DOS support routines, _amblksize"
#pragma REVISED "zap,20-oct-86,remove near data model; only far now"
#pragma REVISED "zap,20-jan-87,declare _os_froot in _exit.c"
#pragma REVISED "zap,23-feb-87,new module flakiness"
#pragma REVISED "zap,3-jun-87, rewrite -- maek it stupid"
#pragma REVISED "zap,3-aug-87,save prog len in PSP"
#endif

#include <dos.h>
#include <_alloc.h>

extern unsigned _proglen;  /* length of the program */
extern unsigned _heapmod;  /* module that we're presently allocating from */
extern unsigned far *_pspseg;  /* PSP */

extern char far *_dosf48();
struct _os_free_item{
  struct _os_free_item far *next;
  unsigned blockmod;
};
extern struct _os_free_item far *_os_froot;
static struct _os_free_item far *_os_fptr;

static rootmod=1;  /* Are we allocating out of the root DOS module? */


void far *sbrk(size)
unsigned size;			/* max allocation just less than 64K */
{
  char far *sb;
  register unsigned moreparas=0;

  if((size=(size+1)&0xfffe)>0xffe8) return (void far *)0;  /* too big */

  moreparas=size;
  if(size&0xF) moreparas += 0x10;
  moreparas >>= 4;

  if(!_dosf4a(_proglen+(moreparas),_heapmod)){   /* get more memory */
    sb=abstoptr(((unsigned long)_heapmod<<4) + ((unsigned long)_proglen<<4));
    _proglen += moreparas;
    if(rootmod) _pspseg[1]+=moreparas;
  }
  else {  /* try someplace else in memory */
    moreparas += 2;   /* need room for headers */
    if(sb=_dosf48(moreparas)){
      rootmod=0;
      _heapmod=FP_SEG(sb);  /* allocate from the new module */
      _proglen=moreparas;  /* paragraphs */
      if(_os_froot){
        _os_fptr=_os_froot;
        while(_os_fptr->next) _os_fptr=_os_fptr->next;
        _os_fptr->next=sb;
        _os_fptr=_os_fptr->next;
      } else {
        _os_froot=sb;
        _os_fptr=_os_froot;
      }
      _os_fptr->next=(void far *)0;
      _os_fptr->blockmod=_heapmod;
      sb = abstoptr(ptrtoabs(sb) + sizeof(struct _os_free_item));;
    }
  }
  return sb;
}
+ARCHIVE+ setbuf.c       391 12/22/86 12:37:36
/* setbuf - set up an I/O buffer to default
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,18-oct-85,new function"
#endif

#include <stdio.h>
#include <fileio3.h>

void setbuf(stream, buf)
FILE *stream;
char *buf;
{
  if(buf!=NULL) setvbuf(stream,buf,_IOFBF,BUFSIZ);
  else setvbuf(stream,NULL,_IONBF,0);
}
+ARCHIVE+ setlocal.c     752 10/30/87 14:44:46
/* setlocale.c - set one of these silly things
** Copyright (C) 1987 Computer Innovations, Inc.  ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,12-aug-87,creation"
#pragma REVISED "gee,30-oct-87,localblock is internal only"
#endif

#include <locale.h>

char *_localeblock[LC_MAX]={"C","C","C","C","C"};

char *setlocale(category, locale)
int category;
char *locale;
{
  register i;
  char *temp;

  if(category<0 || category>=LC_MAX) return (void *)0;

  if(category==LC_ALL){
    if(!locale)
      return (void *)0;
    temp=_localeblock[LC_ALL];
    for(i=0; i<LC_MAX; i++)
      _localeblock[i]=locale;
  } else {
    temp=_localeblock[category];
    _localeblock[category]=locale;
  }
  return temp;
}
+ARCHIVE+ setmem.c       370  3/06/87 18:41:24
/* setmem.c - set memory to a value 
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,16-jul-86,rewrite from assembler"
#pragma REVISED "nlp,27-feb-87,register"
#pragma REVISED "zap,06-mar-87,just call memset"
#endif

void setmem(cp, n, c)  
char *cp; 
int n; 
char c;  
{ 
  memset(cp,c,n); 
}
+ARCHIVE+ setmode.c      769  6/10/87 11:32:38
/*  setmode.c - change a file's newline processing
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,17-may-86,new function"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,24-mar-87,new header"
#pragma REVISED "zap,10-may-87,had it backwards"
#endif

#include <fcntl.h>
#include <fileio3.h>
#include <errno.h>

int setmode(fd,mode)
int fd, mode;
{
  register unsigned temp;

  if(fd<0 || fd>= SYS_OPEN){
    errno=EBADF;
    return -1;
  }
  temp=_osfile[fd];
  if(mode==O_BINARY) _osfile[fd]&=~_IOASCII;
  else if(mode==O_TEXT) _osfile[fd]|=_IOASCII;
  else {
    errno=EINVAL;
    return -1;
  }
  if(temp&_IOASCII) return O_TEXT;
  else return O_BINARY;
}
+ARCHIVE+ settrace.c     265  1/27/87 14:32:30
/* settrace - stack trace on exit
** Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED
*/
#ifdef HISTORY
#pragma REVISED "zap,27-jan-87,hacked it in"
#endif

extern int _exittbc;

void settrace(tval)
int tval;
{
  _exittbc=tval;
}


+ARCHIVE+ setvbuf.c     1062  7/17/87 10:53:16
/* setvbuf - set the size of an I/O buffer
** Copyright (c) 1985,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,17-oct-85,new function"
#pragma REVISED "zap,17-jul-87,limit size to 32k-1 (max for an int)"
#endif

#include <stdio.h>
#include <fileio3.h>

int setvbuf(stream,buf,type,size)
FILE *stream;
char *buf;
unsigned type;
int size;
{
  if(stream->_cnt || _osfile[stream->_fd]&_IOTOUCHED) return -1;
  if(type==_IOFBF){
    stream->_flag&=~_IOLBF&~_IONBF;
    stream->_flag|=_IOFBF;
    _piob[stream->_fd]._size=BUFSIZ;
  } else if(type==_IOLBF){
    stream->_flag&=~_IONBF&~_IOFBF;
    stream->_flag|=_IOLBF;
    _piob[stream->_fd]._size=BUFSIZ;
  } else if(type==_IONBF){
    stream->_flag&=~_IOFBF&~_IOLBF;
    stream->_flag|=_IONBF;
    _piob[stream->_fd]._size=1;
  } else return -1;
  if(buf){
    stream->_base=buf;
    stream->_flag|=_IOMYBUF;
  }
  if(size){
    if(size<0) size=0x7fff;  /* max for an int */
    _piob[stream->_fd]._size=size;
  }
  return 0;
}
+ARCHIVE+ signal.c      1543  5/28/87  9:55:56
/* signal - set response to a signal
** Copyright (c) 1985,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,9-25-85,New function"
#endif

#include <signal.h>
#include <errno.h>

/** Signal vector array: these are the routines which get
 ** executed when the raise() function is called.
 **/
void (*_sig_eval[SIGSIZE])()={
        _sig_abrt_dfl,
        _sig_ill_dfl,
        _sig_int_dfl,
        _sig_alloc_dfl,
        _sig_free_dfl,
        _sig_term_dfl,
        _sig_read_dfl,
        _sig_write_dfl,
        _sig_fpe_dfl,
        _sig_segv_dfl,
        _sig_null,
        _sig_null  };

/** Default signal processing routines.
 **/
void (*_sig_dfl[SIGSIZE])()={
        _sig_abrt_dfl,
        _sig_ill_dfl,
        _sig_int_dfl,
        _sig_alloc_dfl,
        _sig_free_dfl,
        _sig_term_dfl,
        _sig_read_dfl,
        _sig_write_dfl,
        _sig_fpe_dfl,
        _sig_segv_dfl,
        _sig_null,
        _sig_null  };


void (*signal(sig,func))()
int sig; /* signal type */
void (*func)(); /* response to signal */
{
  int (*f)()=SIG_IGN,(*ff)();

  (ff)=_sig_eval[sig];
  if(!func || sig<0 || sig>=SIGSIZE){
    errno=ESIGNAL;
    return SIG_ERR;
  }
  else if((func)==(f)) _sig_eval[sig]=_sig_null;
  else if((func)==SIG_DFL) _sig_eval[sig]=_sig_dfl[sig];
  else _sig_eval[sig]=(func);
  return (ff);
}
							
void _sig_err_dummy(){}  /* for macro definitions */
void _sig_dfl_dummy(){}
void _sig_ign_dummy(){}

+ARCHIVE+ sin.c          954 10/09/87 16:04:16
/* sin/cos routines
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-nov-86,separate files for sin and cos"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <float.h>
#include <errno.h>
#include <_math.h>

extern double _fac;

double *sin(arg)
double arg;
{
  register int _temp;
  double *temp;
  struct exception exc;

  _clear87();
  errno=0;
  temp=_sin(arg);
  if(errno){
    *temp=0.0;
    exc.type=DOMAIN;
    goto S1;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
S1:
    exc.name="sin";
    exc.arg1=arg;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}

+ARCHIVE+ sinh.c        2059 10/09/87 18:05:56
/* sinh - hyperbolic sin
** algorithm is from Cody & Waite, p. 217
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,28-may-85,cosmetic"
#pragma REVISED "lpa,6-jun-85,simplified,smaller"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-jul-87,call to _fabs() becomes fabs(), add _math.h"
#pragma REVISED "zap,9-oct-87,hack on overhead"
#endif

#include <math.h>
#include <_math.h>
#include <errno.h>

extern double _fac;

#define YBAR 704
#define WMAX 707
#define LNOFV    0.69316101074218750000
#define VOVER2_1 0.13830277879601902638e-4

/* EPS = 2 ** 26   */
#define EPS (1.0 / (16.0 * 16.0 * 16.0 * 16.0 * 16.0 * 64.0))

#define P0 -0.35181283430177117881e6
#define P1 -0.11563521196851768270e5
#define P2 -0.16375798202630751372e3
#define P3 -0.78966127417357099479e0
#define Q0 -0.21108770058106271242e7
#define Q1  0.36162723109421836460e5
#define Q2 -0.27773523119650701667e3

static double r(f) 
double f;
{
  double p,q;

  p=(((P3*f)+P2)*f+P1)*f+P0;
  q=((f+Q2)*f+Q1)*f+Q0;
  return f*(p/q);
}

/*  This function computes the sinh(x).
    sinh ( x ) is defined to be (exp(x) - exp(-x)) / 2.0.
    Also observe sinh(-x) = -sinh(x).
*/
double sinh(x)
double x;
{
  double w,y,z,result;
  register _temp;
  struct exception exc;

  _clear87();
  y=fabs(x);  
  if(y>1.0){
    if(y>YBAR){
      w=y-LNOFV;
      if(w>WMAX){
        errno=ERANGE;        
        result=HUGE_VAL;
        goto SH1;
      } else {
        z=*_exp(w);
        result=z+VOVER2_1*z;
      } 
    } else {
      z=*_exp(y);
      result=(z-(1/z))/2.0;
    }
    if(x<0.0) result=-result;
  } else if (y<EPS) result=x;
  else result=x+x*r(x*x);

  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
SH1:
    exc.name="sinh";
    exc.arg1=x;
    exc.arg2=0;
    exc.retval=result;
    if(matherr(&exc)) result=exc.retval;
  }
  return result;
}

+ARCHIVE+ sopen.c        437 12/22/86 12:38:06
/*  sopen.c - open a shared file
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,21-may-86,new function"
#endif

extern unsigned _osmajor;
extern unsigned _umask;

int sopen(path, mode, share, permit)
char *path;
unsigned mode, share, permit;
{
  if(_osmajor==2) return _open(path, mode, 0, 0x180);
  else return _open(path, mode, share, permit&(~_umask));
}
+ARCHIVE+ spawnl.c       394  3/16/87  9:58:48
/* spawnl - list arguments
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-mar-87,split"
#endif

#include <process.h>

extern int _spawn(int, char *, char **, char *, int);


int spawnl(flag,prog,args)
int flag;
char *prog;
char *args;
{
  extern char **environ;

  return _spawn(flag,prog,&args,environ,0);
}
+ARCHIVE+ spawnle.c      495  3/16/87  9:59:00
/* spawnle - list arguments, environment processing
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-mar-87,split"
#endif

#include <process.h>

extern int _spawn(int, char *, char **, char *, int);


int spawnle(flag,prog,args)
int flag;
char *prog;
char *args;
{
  register char **pargs;

  /* make pargs point to envp */
  for(pargs=&args;*pargs;++pargs) ;
 
  return _spawn(flag,prog,&args,pargs[1],0);
}
+ARCHIVE+ spawnlp.c      413  3/16/87  9:59:40
/* spawnlp - list arguments, path processing
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-mar-87,split"
#endif

#include <process.h>

extern int _spawn(int, char *, char **, char *, int);


int spawnlp(flag,prog,args)
int flag;
char *prog;
char *args;
{
  extern char **environ;

  return _spawn(flag,prog,&args,environ,1);
}
+ARCHIVE+ spawnlpe.c     514  3/16/87  9:59:54
/* spawnlpe - list arguments, path processing, environment processing
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-mar-87,split"
#endif

#include <process.h>

extern int _spawn(int, char *, char **, char *, int);


int spawnlpe(flag,prog,args)
int flag;
char *prog;
char *args;
{
  register char **pargs;

  /* make pargs point to envp */
  for(pargs=&args;*pargs;++pargs) ;
 
  return _spawn(flag,prog,&args,pargs[1],1);
}
+ARCHIVE+ spawnv.c       390  3/16/87 10:00:04
/* spawnv - argument va_list
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-mar-87,split"
#endif

#include <process.h>

extern int _spawn(int, char *, char **, char *, int);


int spawnv(flag,prog,argv)
int flag;
char *prog, **argv;
{
  extern char **environ;

  return _spawn(flag,prog,argv,environ,0);
}
+ARCHIVE+ spawnve.c      413  3/16/87 10:00:14
/* spawnve - argument va_list, environment processing
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-mar-87,split"
#endif

#include <process.h>

extern int _spawn(int, char *, char **, char *, int);


int spawnve(flags,prog,argv,envp)
int flags;
char *prog;
char *argv[];
char *envp;
{
  return _spawn(flags,prog,argv,envp,0);
}
+ARCHIVE+ spawnvp.c      409  3/16/87 10:00:24
/* spawnvp - argument va_list, path processing
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-mar-87,split"
#endif

#include <process.h>

extern int _spawn(int, char *, char **, char *, int);


int spawnvp(flag,prog,argv)
int flag;
char *prog, **argv;
{
  extern char **environ;

  return _spawn(flag,prog,argv,environ,1);
}
+ARCHIVE+ spawnvpe.c     417  3/16/87 10:00:34
/* spawnvpe - argument va_list, environment processing, path processing
** Copyright (C) 1987 Computer Innovations Inc. ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-mar-87,split"
#endif

#include <process.h>

extern int _spawn(int, char *, char **, char *, int);


int spawnvpe(flag,prog,argv,envp)
int flag;
char *prog, **argv,**envp;
{
   return _spawn(flag,prog,argv,envp,1);
}
+ARCHIVE+ sqrt.c         883 10/09/87 18:09:16
/* sqrt - square root, Newton Rapson
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <errno.h>
#include <float.h>
#include <_math.h>

double *sqrt(arg)
double arg;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  errno=0;
  temp=_sqrt(arg);
  if(errno){
    *temp=0.0;
    exc.type=DOMAIN;
    goto SQ1;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
SQ1:
    exc.name="sqrt";
    exc.arg1=arg;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}
+ARCHIVE+ square.c       655 10/09/87 16:52:44
/* square a number
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <_math.h>

double *square(d)
double d;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  temp=_square(d);
  if((_temp=_status87())&0x80){
    exc.name="square";
    exc.arg1=d;
    exc.arg2=0;
    exc.retval=*temp;
    exc.type=_err_map(_temp);
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}


 
+ARCHIVE+ stat.c        2389  7/07/87 15:10:14
/* stat - get file status info from system and load into struct type stat
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-oct-85,add header, copyright"
#pragma REVISED "had,14-nov-85,leap year,7f vs. 7,no chk CFLAG,pretty up"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,24-nov-86,major hack"
#pragma REVISED "zap,9-apr-87,colonel hack"
#pragma REVISED "nlp,7-jul-87,general hack"
#endif

#include <time.h>
#include <sys/stat.h>
#include <errno.h>
#include <dos.h>

/* converts integers from regvals containing time and date as found
   in directory entries to int values in struct tm.
   also computes julian date, and abs secs from 1/1/70.
*/
#define SECS 86400  
#define BASEYEAR 70

time_t _cvt_time(tm,dt)  /* date y:7,m:4,d:5  -  time h:5,m:6,s:5 */
unsigned int tm,dt;
{
  unsigned long rettim;
  static unsigned char days[]={31,28,31,30,31,30,31,31,30,31,30,31};
  register unsigned i,temp,j;

  i=dt>>9;
  temp=20*(365*4+1);  /* days from 1900 to 1980 */
  temp+=(i>>2)*(4*365+1);  /* get days since 1980 */
  i&=0x3;
  if(!i) days[1]=29;
  if(i--){
    temp+=366;  /* the first one has to be a leap year */
    while(i--) temp+=365;
  }
  j=((dt>>5)&0xF)-1;
  for(i=0; i<j; i++) temp+=days[i];
  temp+=dt&0x1F;  /* got the days */

  rettim=(long)temp*24+(tm>>11);  /* hours since 1900 */
  rettim*=60;
  rettim+=(tm>>5)&0x3F;  /* minutes */
  rettim*=60;
  rettim+=(tm<<1)&0x3F;  /* seconds */

  return (time_t)rettim;
}


int stat(filename,buf)
char *filename;
struct stat *buf;
{
  struct regval srv;
  struct ff_str ff;

  srv.ds=P_SEG(filename); 
  srv.dx=P_OFF(filename);
  srv.cx=0x7f;   /* set search modes to all */
  bdos(0x1a,&ff);  /* set the transfer address - ignore compiler warning */
  srv.ax=0x4e00;
  if(sysint21(&srv,&srv)&1){
    errno=ENOENT;
    return -1;
  }

  buf->st_size=ff.size;
  if(ff.attribute&0x10) buf->st_mode=S_IFDIR;  /* directory */
  else buf->st_mode=S_IFREG;  /* file */
  buf->st_atime=buf->st_ctime=buf->st_mtime=_cvt_time(ff.time,ff.date);
  if(filename[1]==':') buf->st_rdev=buf->st_dev=(filename[0]-'A')|0x30;
  else {
    srv.ax=0x1900;
    sysint21(&srv,&srv);
    buf->st_rdev=buf->st_dev=((srv.ax&0xff)-'A')|0x30;
  }
  buf->st_nlink=1;
  return 0; 
}

+ARCHIVE+ strchr.c       591 11/25/87 14:32:18
/* strchr - return a pointer to first occurrence of c in s
   or NULL if not found
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,10-jun-85,for 3.0, unsigned out"
#pragma REVISED "lpa,11-jun-85,added HISTORY"
#pragma REVISED "nlp,12-feb-87,register "
#pragma REVISED "zap,25-nov-87,terminating NUL is part of the string"
#endif
#include <stdio.h>

char *strchr(s,c)
register char *s;
register int c;
{
  do{
    if(*s==c) return s;
  } while(*s++);
  return NULL;
}

+ARCHIVE+ strcmpi.c      464  2/12/87  9:35:18
/* strcmpi - string compare, not case sensitive
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,7-nov-85,new function"
#pragma REVISED "zap,13-may-86,rewrite - copy from strcmp() and rename"
#pragma REVISED "nlp,12-feb-87,register"
#endif

int strcmpi(s1,s2)
register char *s1,*s2;
{
  for(;toupper(*s1)==toupper(*s2);s2++) if(!*s1++) return 0;
  return toupper(*s1)-toupper(*s2);
}
+ARCHIVE+ strcoll.c      318  8/12/87 14:40:16
/* strcoll.c
** Copyright (C) 1987 Computer Innovations, Inc.  ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,12-aug-87,creation"
#endif

#include <string.h>

size_t strcoll(to, maxsize, from)
char *to;
size_t maxsize;
char *from;
{
  strncpy(to, from, maxsize);
  return strlen(to);
}

+ARCHIVE+ strcspn.c      809  2/12/87  9:32:42
/* strcspn - Search s for first occurence in set of characters, skipping
**  over characters that are not in set. Return length of the longest
**  initial segment of s that consists of characters not found in set.
**  If no character appears in set, then the total length of s (not
**  counting NUL) is returned.
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,10-jun-85,for 3.0, unsigned out"
#pragma REVISED "lpa,11-jun-85,added HISTORY"
#pragma REVISED "zap,17-nov-86,ANSI"
#pragma REVISED "nlp,12-feb-87,register"
#endif
#include <string.h>

size_t strcspn(s,set)
char *s,*set;
{
  register char *cp;

  for(cp=s;*set && *cp && (strchr(set,*cp)==0);++cp) ;
  return (int)cp-(int)s;
}
+ARCHIVE+ strdup.c       491  2/12/87  9:40:20
/* strdup.c - malloc() and strcpy()
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-apr-86,new function"
#pragma REVISED "zap,29-aug-86,add headers and check for mallocation space"
#pragma REVISED "nlp,12-feb-87,rewrite"
#endif

#include <string.h>
#include <malloc.h>

char *strdup(s)
register char *s;
{
  register char *p;

  if(p=malloc(strlen(s)+1)) {
	 return strcpy(p,s);
  }
  return (char *)0;
}
+ARCHIVE+ strerror.c     540 12/22/86 12:38:44
/* strerror - construct an error message
   Copyright (c) 1984,85 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,7-nov-85,new function"
#endif

#include <errno.h>
#define STRERRLEN 100

extern char *_perrmess[];

char *strerror(s)
char *s;
{
  static char b[STRERRLEN];

  strncpy(b,s,STRERRLEN-strlen(_perrmess[errno])-2);  /* 2 for ": " */
  strcat(b,": ");
  strcat(b,_perrmess[errno]);
  b[strlen(b)-1]=0; /* overwrite the '$' (perror uses bdos) with a NUL */
  return b;
}
+ARCHIVE+ strftime.c   12675 11/25/87 15:04:20
/* strftime - places the characters into the array controlled by
**            format string, returns the number of characters placed
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma CREATED "ahm,25-nov-87"
#endif

#include <time.h>
#include <math.h>
#include <stdlib.h>

struct strf{
    char *a[7];       /* abbreviated weekday name */
    char *A[7];       /* full weekday name */
    char *b[12];      /* abbreviated month name */
    char *B[12];      /* full month name */
    char *dmark;      /* date mark */
    char *tmark;      /* time mark */
    char *p[2];       /* AM PM */
};

#define USA    0
#define NO_OF_COUNTRIES  1

int cntry=USA ;

struct strf country[NO_OF_COUNTRIES]={
   { {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"}, /* country[0]=USA */
     {"Sunday","Monday","Tuesday","Wednesday",
      "Thursday","Friday","Saturday"},
     {"Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"},
     {"January","February","March","April","May","June","July",
      "August","September","October","November","December"},
     "-",
     ":",
     {"AM","PM"}
   }
};

struct copy{
   char *s1;
   char *s2;
   size_t max;
};

size_t count=0;

size_t cat(x)  /* copy s2 at the end of s1 untill max is zero */
struct copy *x;
{
   (x->s1)+=strlen(x->s1);
   while (*(x->s2)) {
      if (!(x->max)) return 0; /* return, max=0 */
      *(x->s1)++=*(x->s2)++;
      count++;
      (x->max)--;
   }
   *(x->s1)=0;
   return 1;   /* return, max!=0 */
}

size_t strftime(s,max,format,tmptr)
char *s;                /* ch. array to hold time string */
size_t max;             /* max no. of ch's to be placed in array */
const char * format;    /* format string */
struct tm *tmptr;       /* time structure */
{
   div_t quorem;
   int temp,day;
   char buf[7],*cptr;
   struct copy x;

   count=0;
   *s=0;
   x.s1=s;
   if (max==0) return 0;
   else  x.max=max-1; /* -1 for NULL */
   while (*format) {
      if (x.max==0) return 0;
      if (*format!='%') {  /* ordinary ch. - copy it */
         *(x.s1)++=*format;
         *(x.s1)=0;
         count++;
         (x.max)--;
         }
      else {
         format++;
         switch(*format){
            case 'a':x.s2=country[cntry].a[tmptr->tm_wday];    /* abb. weekday name */
                     if(!(cat(&x))) return 0;
                     break;
            case 'A':x.s2=country[cntry].A[tmptr->tm_wday];    /* full weekday name */
                     if(!(cat(&x))) return 0;
                     break;
            case 'b':x.s2=country[cntry].b[tmptr->tm_mon];     /* abb. month name */
                     if(!(cat(&x))) return 0;
                     break;
            case 'B':x.s2=country[cntry].B[tmptr->tm_mon];     /* full month name */
                     if(!(cat(&x))) return 0;
                     break;
            case 'c':temp=itoa(tmptr->tm_mon+1,buf);  /* date & time */
                     if(temp<2) {                     /* date */
                        x.s2=" ";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     x.s2=country[cntry].dmark;
                     if(!(cat(&x))) return 0;
                     temp=itoa(tmptr->tm_mday,buf);
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     x.s2=country[cntry].dmark;
                     if(!(cat(&x))) return 0;
                     temp=itoa(tmptr->tm_year,buf);
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     x.s2="  ";
                     if(!(cat(&x))) return 0;
                     temp=itoa(tmptr->tm_hour,buf);         /* time */
                     if(temp<2) {
                        x.s2=" ";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     x.s2=country[cntry].tmark;
                     if(!(cat(&x))) return 0;
                     temp=itoa(tmptr->tm_min,buf);
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     x.s2=country[cntry].tmark;
                     if(!(cat(&x))) return 0;
                     temp=itoa(tmptr->tm_sec,buf);
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'd':temp=itoa(tmptr->tm_mday,buf);  /* day of month 01-31 */
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'H':temp=itoa(tmptr->tm_hour,buf);   /* hour 00-23 */
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'I':if((temp=tmptr->tm_hour)>12) temp-=12; /* hour 01-12 */
                     if (temp==0) temp=12;
                     temp=itoa(temp,buf);
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'j':temp=itoa(tmptr->tm_yday+1,buf);/* day of year 001-366 */
                     if(temp<2) {
                        x.s2="00";
                        if(!(cat(&x))) return 0;
                     }
                     else {
                        if(temp<3) {
                           x.s2="0";
                           if(!(cat(&x))) return 0;
                        }
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'm':temp=itoa(tmptr->tm_mon+1,buf);  /* month 01-12 */
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'M':temp=itoa(tmptr->tm_min,buf); /* minute 00-59 */
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'p':if (tmptr->tm_hour<12) {   /* AM or PM */
                        x.s2=country[cntry].p[0];
                        if(!(cat(&x))) return 0;
                     }
                     else {
                        x.s2=country[cntry].p[1];
                        if(!(cat(&x))) return 0;
                     }
                     break;
            case 'S':temp=itoa(tmptr->tm_sec,buf); /* seconds 00-59 */
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'U':quorem=div(tmptr->tm_yday+1,7);/* week of year 00-52 */
                     temp=quorem.quot;     /* Sunday as first day of week */
                     if (quorem.rem>(tmptr->tm_wday+1)) temp++;
                     temp=itoa(temp,buf);
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'w':itoa(tmptr->tm_wday,buf);  /* weekday 0-6 */ 
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'W':quorem=div(tmptr->tm_yday+1,7); /* week of year 00-52 */   
                     temp=quorem.quot;      /* Monday as first day of week */
                     day=tmptr->tm_wday-1;  /* Monday=0,... */
                     if(day<0) day=6;       /* Sunday=6 */
                     if (quorem.rem>(day+1)) temp++;
                     temp=itoa(temp,buf);
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'x':temp=itoa(tmptr->tm_mon+1,buf);  /* date */
                     if(temp<2) {
                        x.s2=" ";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     x.s2=country[cntry].dmark;
                     if(!(cat(&x))) return 0;
                     temp=itoa(tmptr->tm_mday,buf);
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     x.s2=country[cntry].dmark;
                     if(!(cat(&x))) return 0;
                     temp=itoa(tmptr->tm_year,buf);
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'X':temp=itoa(tmptr->tm_hour,buf);   /* time */
                     if(temp<2) {
                        x.s2=" ";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     x.s2=country[cntry].tmark;
                     if(!(cat(&x))) return 0;
                     temp=itoa(tmptr->tm_min,buf);
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     x.s2=country[cntry].tmark;
                     if(!(cat(&x))) return 0;
                     temp=itoa(tmptr->tm_sec,buf);
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'y':temp=itoa(tmptr->tm_year,buf);   /* year 00-99 */
                     if(temp<2) {
                        x.s2="0";
                        if(!(cat(&x))) return 0;
                     }
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'Y':itoa(tmptr->tm_year+1900,buf);   /* year with century */
                     x.s2=buf;
                     if(!(cat(&x))) return 0;
                     break;
            case 'Z':if(cptr=getenv("TZ=")){  /* timezone taken from TZ */ 
                        strncpy(buf,cptr,3);  /* DOS environment variable */
                        buf[3]=0;
                        x.s2=buf;
                        if(!(cat(&x))) return 0;
                     }
                     break;
            case '%':x.s2="%";                  /* % */
                     if(!(cat(&x))) return 0;
                     break;
            default : break;
            }
         }
      format++;
      }
done:
   return count;
}


+ARCHIVE+ stricmp.c      464  2/12/87  9:41:28
/* stricmp - string compare, not case sensitive
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,7-nov-85,new function"
#pragma REVISED "zap,13-may-86,rewrite - copy from strcmp() and rename"
#pragma REVISED "nlp,12-feb-87,register"
#endif

int stricmp(s1,s2)
register char *s1,*s2;
{
  for(;toupper(*s1)==toupper(*s2);s2++) if(!*s1++) return 0;
  return toupper(*s1)-toupper(*s2);
}
+ARCHIVE+ strlwr.c       398  2/12/87  9:46:48
/* strlwr.c - convert a string to lower case
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-apr-86,add header, copyright"
#pragma REVISED "nlp,12-feb-87,register"
#endif

unsigned char *strlwr(cp)
unsigned char *cp;
{
  register char *ct;

  for(ct=cp;*ct;++ct) if(*ct>='A' && *ct<='Z') *ct+=('a'-'A');
  return cp;
}
+ARCHIVE+ strncat.c      627  2/12/87 21:06:52
/* concatinate string t to string s, max n characters
   Copyright (c) 1984,85 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,10-jun-85,for 3.0, unsigned out"
#pragma REVISED "lpa,11-jun-85,added HISTORY"
#pragma REVISED "nlp,12-feb-87,register"
#pragma REVISED "gee,12-feb-87,ANSI standard"
#endif

char *strncat(s,t,n)
char *s,*t;
register unsigned n;
{
  register char *cp;

  if(n) {
    for(cp=s;*cp++;);   /* find end of string */
    for(--cp;(*cp++=*t++) && --n;); /* do the concatinate */
    if(!n)*cp=0;
  }
  return s;
}
+ARCHIVE+ strncmp.c      650  2/12/87  9:47:48
/* string compare up to n characters
   (remove the "unsigned" for signed collating set)
   Copyright (c) 1984,85 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,10-jun-85,for 3.0, unsigned out"
#pragma REVISED "lpa,10-jun-85,3.0, no more -1/0/1 returns"
#pragma REVISED "lpa,11-jun-85,added HISTORY"
#pragma REVISED "zap,13-may-86,changed assignment in second line to test"
#pragma REVISED "nlp,12-feb-87,register"
#endif

strncmp(s,t,n)
register char *s,*t;
register unsigned n;
{
  for(;n-- && (*s==*t);t++) if(!*s++) return 0;
  return n==-1 ? 0 : *s-*t;
}
+ARCHIVE+ strncpy.c      524  2/12/87  9:48:32
/* copy a string into a buffer n characters in length
   Copyright (c) 1984,85 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,10-jun-85,for 3.0, unsigned out"
#pragma REVISED "lpa,11-jun-85,added HISTORY"
#pragma REVISED "nlp,12-feb-87,register"
#endif

char *strncpy(to,from,n)
char *to;
register char *from;
register unsigned n;
{
  register char *cp;

  for(cp=to;n && (n--,(*cp++=*from++)););
  while(n--)*cp++=0;
  return to;
}
+ARCHIVE+ strnicmp.c     505  2/12/87  9:48:52
/* strnicmp - string compare with maximum length, not case sensitive
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,7-nov-85,new function"
#pragma REVISED "zap,2-jan-87,copy from strncmp()"
#pragma REVISED "nlp,12-feb-87,register"
#endif

int strnicmp(s1,s2,n)
register char *s1,*s2;
register int n;
{
  for(;n-- && (toupper(*s1)==toupper(*s2));s2++) if(!*s1++) return 0;
  return n==-1 ? 0 : toupper(*s1)-toupper(*s2);
}
+ARCHIVE+ strnset.c      375  2/12/87  9:50:22
/*  strnset.c - set a string to 'c'
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,13-may-86,new function"
#pragma REVISED "nlp,12-feb-87,register"
#endif

char *strnset(s,c,n)
char *s;
register int c;
register unsigned n;
{
  register char *p;

  p=s;
  while(n-- && *p) *p++=c;
  return s;
}
+ARCHIVE+ strpbrk.c      665  2/12/87  9:50:50
/* strpbrk - returns a pointer to the first occurrence in string s1
   of any character from string s2, or NULL if no character
   from s2 exists in s1
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,3-jun-85"
#pragma REVISED "lpa,7-jun-85,semi out after for stmt,BF"
#pragma REVISED "lpa,10-jun-85,for 3.0, unsigned out"
#pragma REVISED "lpa,11-jun-85,added HISTORY"
#pragma REVISED "nlp,12-feb-87,register"
#endif
#include <stdio.h>
#include <string.h>

char *strpbrk(s1,s2)
register char *s1,*s2;
{
  for(;*s1;++s1){
    if(strchr(s2,*s1))return s1;
  }
  return NULL;
}

+ARCHIVE+ strpos.c       622  2/12/87  9:52:50
/* strpos - return position of first c in s, or -1 if not found
   searching for a null character will return the position
   of the null character, not -1
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,10-jun-85,for 3.0, unsigned out"
#pragma REVISED "lpa,11-jun-85,added HISTORY"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "nlp,12-feb-87,register"
#endif

int strpos(s,c)
char *s;
register int c;
{
  register unsigned i;

  for(i=0;s[i] && s[i]!=c;i++);
  return (s[i]==c)?i:-1;
}


+ARCHIVE+ strpot.c       424 12/22/86 12:39:18
/* strpot.c - shuffle the contents of a string
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-apr-86,creation"
#pragma REVISED "zap,4-jun-86,registers"
#endif

char *strpot(s)
char *s;
{
  register int i,ii;
  char c;

  i=strlen(s)-1;
  while(i>0){
    ii=rand()%i;
    c=s[i];
    s[i]=s[ii];
    s[ii]=c;
    --i;
  }
  return s;
}
+ARCHIVE+ strrchr.c      585 11/25/87 14:31:22
/* strrchr - return a pointer to last occurrence of c in s
   or NULL if not found
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,10-jun-85,for 3.0, unsigned out"
#pragma REVISED "lpa,11-jun-85,added HISTORY"
#pragma REVISED "nlp,12-feb-87,register"
#pragma REVISED "zap,25-nov-87,terminating NUL is part of the string"
#endif
#include <stdio.h>

char *strrchr(s,c)
register char *s,c;
{
  char *cp=NULL;

  do{
    if(*s==c) cp=s;
  } while(*s++);
  return cp;
}
+ARCHIVE+ strrev.c       418 12/22/86 12:39:24
/* strrev.c - reverse the order of characters in a string
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-apr-86,new function"
#pragma REVISED "zap,4-jun-86,registers"
#endif

char *strrev(s)
char *s;
{
  register int i,j;
  char c;

  i=strlen(s)-1;
  for(j=0;j<i;j++,i--){
    c=s[i];
    s[i]=s[j];
    s[j]=c;
  }
  return s;
}
+ARCHIVE+ strrpos.c      494  2/12/87  9:54:20
/* return the position of the last occurence of c in s
   Copyright (c) 1984,85 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,10-jun-85,for 3.0, unsigned out"
#pragma REVISED "lpa,11-jun-85,added HISTORY"
#pragma REVISED "nlp,12-feb-87,register"
#endif

int strrpos(s,c)
char *s,c;
{
  register unsigned i,last;

  for(last= -1,i=0;s[i];i++){
    if(s[i]==c)last=i;
  }
  return s[i]==c ? i : last;
}

+ARCHIVE+ strset.c       335  2/12/87  9:54:44
/*  strset.c - set a string to a character
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,13-may-86,new function"
#pragma REVISED "nlp,12-feb-87,register"
#endif

char *strset(s,c)
char *s,c;
{
  register char *p;

  p=s;
  while(*p) *p++=c;
  return s;
}
+ARCHIVE+ strspn.c       637 12/22/86 12:39:32
/* strspn - search s for character not in set
   returns length of longest initial segment of s that consists
   of characters found in set.
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,3-jun-85"
#pragma REVISED "lpa,7-jun-85,BF"
#pragma REVISED "lpa,10-jun-85,for 3.0, unsigned out"
#pragma REVISED "lpa,11-jun-85,added HISTORY"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <string.h>

int strspn(s,set)
char *s,*set;
{
  register unsigned i;

  for(i=0;*set && s[i];i++){
    if(!strchr(set,s[i]))break;
  }    
  return i;
}

+ARCHIVE+ strstr.c       632 11/25/87 14:24:26
/* strstr - find first occurrence of s2 in s1
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,7-nov-85,new function"
#pragma REVISED "nlp,12-feb-87,register"
#pragma REVISED "zap,25-nov-87,check args for NULL"
#endif

#include <stdio.h>

char *strstr(s1,s2)
register char *s1;
char *s2;
{
  register char *s,*temp;

  if(s1==NULL || s2==NULL) return s1;
  s=s2;
  while(*s1!=0){
    if(*s1!=*s) ++s1;
    else {
      temp=s1;
      while(*s1++==*s++) if(*s==0) return temp;
      s1=temp+1;
      s=s2;
    }
  }
  return NULL;
}

+ARCHIVE+ strtod.c      2885  7/07/87 10:58:24
/* strtod - convert a string to a double
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,30-jul-85,new function"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-feb-87,original acquisition by scaler types"
#pragma REVISED "zap,7-jul-87,remove latest change"
#endif

#include <fileio3.h>
#include <ctype.h>
#include <math.h>
#include <limits.h>

#undef isspace
#undef isdigit

static unsigned int _ppowten[]={
	     0,     0,     0,0x3FF0,		/* 1e0 */
	0X0000,0X0000,0X0000,0X4024,		/* 1e1 */
	0X0000,0X0000,0X0000,0X4059,		/* 1e2 */
	0X0000,0X0000,0X8800,0X40C3,		/* 1e4 */
	0X0000,0X0000,0XD784,0X4197,		/* 1e8 */
	0X8000,0X37E0,0XC379,0X4341,		/* 1e16 */
	0X6E17,0XB505,0XB8B5,0X4693,		/* 1e32 */
	0XF9F6,0XE93F,0X4F03,0X4D38,		/* 1e64 */
	0X1D33,0XF930,0X7748,0X5A82,		/* 1e128 */
	0XBF3F,0X7F73,0X4FDD,0X7515		/* 1e256 */
};
static int _ppten[]={0,1,2,4,8,16,32,64,128,256,512};

static unsigned int _npowten[]={
	     0,     0,     0,0x3FF0,		/* 1e-0 */
	0X999A,0X9999,0X9999,0X3FB9,		/* 1e-1 */
	0X147B,0X47AE,0X7AE1,0X3F84,		/* 1e-2 */
	0X432D,0XEB1C,0X36E2,0X3F1A,		/* 1e-4 */
	0X8C3A,0XE230,0X798E,0X3E45,		/* 1e-8 */
	0X89BC,0X97D8,0XD2B2,0X3C9C,		/* 1e-16 */
	0XA732,0XD5A8,0XF623,0X3949,		/* 1e-32 */
	0XA73C,0X44F4,0X0FFD,0X32A5,		/* 1e-64 */
	0X979A,0XCF8C,0XBA08,0X255B,		/* 1e-128 */
	0X6F40,0X64AC,0X0628,0X0AC8		/* 1e-256 */
};
static int _npten[]={0,-1,-2,-4,-8,-16,-32,-64,-128,-256,-512};


double strtod(buf,end)
char *buf;
char **end;
{
  double d=0.0;
  register int exp=0,fcount=0;
  int i;
  unsigned temp=0,sign=0;  /* positive - my convention */
  static char *digitstring="1234567890";

  errno=0;
  while(isspace(*buf) || *buf=='\t')++buf;
  if(*buf=='-'){
    sign=1;
    ++buf;
  } else if(*buf=='+')++buf;
  while(*buf=='0') ++buf;
  i=(unsigned)strspn(buf,digitstring);
  while(isdigit(*buf)){
    d*=10.0;
    d+=(double)(*buf-'0');
    if(errno) break;
    ++buf;
  }

  if(*buf=='.'){
    ++buf;
    fcount=(unsigned)strspn(buf,digitstring);
    while(isdigit(*buf)){
      d*=10.0;
      d+=(double)(*buf-'0');
      ++buf;
    }
  }
  if(sign)d=-d;
  exp-=fcount;

  if(*buf=='e' || *buf=='E'){
    ++buf;
    sign=0;
    if(*buf=='-'){
      sign=1;
      ++buf;
    } else if(*buf=='+')++buf;
    fcount=0;
    while(isdigit(*buf)){
      fcount*=10;
      fcount+=(*buf-'0');
      ++buf;
    }
    if(sign)exp-=fcount;
    else exp+=fcount;
  }

  while(exp>0){
    for(i=0;_ppten[i]<=exp;++i);
    --i;
    d*=((double *)_ppowten)[i];
    exp-=_ppten[i];
  }
  while(exp<0){
    for(i=0;_npten[i]>=exp;++i);
    --i;
    d*=((double *)_npowten)[i];
    exp-=_npten[i];
  }

  if(end) *end=buf;
  if(errno==ERANGE) d=HUGE_VAL;
  return(d);
}
+ARCHIVE+ strtok.c       971  3/12/87 11:46:30
/* strtok - tokenize a given string
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85,complete rewrite"
#pragma REVISED "lpa,10-jun-85,for 3.0, unsigned out"
#pragma REVISED "lpa,11-jun-85,added HISTORY"
#pragma REVISED "nlp,12-feb-87,register"
#pragma REVISED "don,16-feb-87,return NULL"
#pragma REVISED "zap,06-mar-87,take out strpbrk() and strchr()"
#endif

#include <string.h>
#include <stdio.h>	/* for NULL */

static int ismember(c,s)
register char c,*s;
{
  while(*s){
    if(*s==c) return 1;
    s++;
  }
  return 0;
}

char *strtok(s1, s2)  
register char *s1, *s2;
{
  static char *tptr;

  if(!s1){
    if(!tptr) return NULL;
    s1=tptr;
  }
  while(ismember(*s1,s2)) s1++;  /* skip initial delimiters */
  tptr=s1;
  while(!ismember(*tptr,s2) && *tptr) tptr++;
  if(*tptr) *tptr++ = 0;
  else tptr=NULL;
  if(!*s1) return NULL;
  return s1;
}
+ARCHIVE+ strtol.c       794  1/21/87 13:54:52
/* strtol - convert a string to a long
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-jul-85,new function"
#pragma REVISED "nlp,21-jan-87,strtoul does the real work now"
#endif

#include <ctype.h>
#include <limits.h>
#include <errno.h>

long strtol(buf,end,base)
register char *buf;
char **end;
int base;
{
unsigned long strtoul();
long val;

  /* skip leading white space */
  while(isspace(*buf) || *buf=='\t') ++buf;

  if(*buf=='-'){
    val = -((long) strtoul(buf+1,end,base));
    return errno==ERANGE ? LONG_MIN : val;
  } else if(*buf=='+') {
    val = (long) strtoul(buf+1,end,base);
  } else {
    val = (long) strtoul(buf,end,base);
  }
  return errno==ERANGE ? LONG_MAX : val;
}
+ARCHIVE+ strtoul.c     1081  1/21/87 13:51:00

/* strtoul - convert a string to unsigned long
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "nlp,21-jan-87,strtoul does the real work now"
#pragma REVISED "nlp,21-jan-87,ULONG_MAX now"
#endif

#include <ctype.h>
#include <limits.h>
#include <errno.h>

/* convert string to unsigned long 
*/
unsigned long strtoul(buf,end,base)
register char *buf;
char **end;
int base;
{
  unsigned long el=0L;
  static char *convert="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  register int index;

  while(isspace(*buf) || *buf=='\t') ++buf;
  if(base==0){
    if(*buf=='0'){
      if(tolower(*(++buf))=='x'){
        base=16;
        ++buf;
      } else base=8;
    } else base=10;
  }
  else if(base<2 || base>36){
    errno=EDOM;
    goto done;
  }

  while(*buf){
    for(index=0;toupper(*buf)!=convert[index];++index)
      if(index==base) goto done;
    el*=base;
    el+=index;
    ++buf;
  }

done:
  if(end) *end=buf;
  if(errno==ERANGE) el=ULONG_MAX;
  return(el);
}



+ARCHIVE+ strupr.c       371  2/12/87  9:59:02
/* strupr.c - convert a string to upper case
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-apr-85,new function"
#pragma REVISED "nlp,12-feb-87,register"
#endif

char *strupr(cp)
char *cp;
{
  register char *ct;

  for(ct=cp;*ct;++ct) if(*ct>='a' && *ct<='z') *ct+=('A'-'a');
  return cp;
}
+ARCHIVE+ system.c      1140  2/27/87 15:10:16
/* system - run a program under the system function
	returns zero if succesful
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,31-oct-85,add header, copyright"
#pragma REVISED "jsc,27-oct-86,use far * / use getenv()"
#pragma REVISED "zap,20-feb-87,offset and segment for small model"
#endif

#include <dos.h>
extern char *getenv();

int system(prog)
unsigned char *prog;
{
  struct regval srv;
  struct pblock ctrl;

  char *ep, cline[128];

  if(strlen(prog) > 123) 
    return -1;	/* too  long to use */

  srv.ax = 0x3700;          /* get switchar */
  sysint21(&srv,&srv);
  cline[1] = srv.dx&0xff;

  srv.ax=0x4800;
  srv.bx=0xfff0;			/* look for a lot of memory */
  if((sysint21(&srv,&srv)&1) && srv.bx<(64*17))
    return -1;
  cline[0]=strlen(prog)+3;

  strcpy(cline+2,"C ");
  strcpy(cline+4,prog);
  strcat(cline,"\r");

  ctrl.env=0;
  ctrl.com_line=cline;
  if(ep=getenv("COMSPEC")){
    struct pblock *pb;

    pb=&ctrl;
    return loadexec((char far *)ep,(struct pblock far *)pb,0);
  } 
  return -1;
}


+ARCHIVE+ tan.c          928 10/09/87 16:18:36
/* tan.c - tan and cotan
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,6-jun-85,tabs out"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-nov-86,separate files for tan() and cotan()"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <float.h>
#include <errno.h>
#include <_math.h>

double *tan(x)
double x;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  errno=0;
  temp=_tan(x);
  if(errno){
    *temp=0.0;
    exc.type=DOMAIN;
    goto T1;
  }
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
T1:
    exc.name="tan";
    exc.arg1=x;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}
+ARCHIVE+ tanh.c        1745 10/09/87 17:22:28
/* tanh.c - hyperbolic tangent
** algorithm is from Cody & Waite, p. 239
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,28-may-85,cosmetic"
#pragma REVISED "lpa,6-jun-85,call fabs"
#pragma REVISED "lpa,12-jun-85, 3.0, HISTORY in"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-jul-87,_math.h"
#pragma REVISED "zap,9-oct-87,hack on overhead"
#endif

#include <math.h>
#include <_math.h>
#include <float.h>
#include <errno.h>

#define P0  (-0.16134119023996228053e4)
#define P1  (-0.99225929672236083313e2)
#define P2  (-0.96437492777225469787e0)
#define Q0  (0.48402357071988688686e4)
#define Q1  (0.22337720718962312926e4)
#define Q2  (0.11274474380534949335e3)

#define LN3_OVER2 0.54930614433405484570
#define XBIG 1.871497387511857e1     /* XBIG = (27*log(2)) */
#define EPS  (1.0 / 6.7108864000e7)  /* EPS  = 1 / (2 ** 26) */


static double rtanh(g) 
double g;
{ 
   double p,q;

   p=(P2*g+P1)*g+P0;
   q=((g+Q2)*g+Q1)*g+Q0;
   return (g*(p/q));
}

/* This function computes the hyberbolic tangent of x.
   The tanh(x) is defined as the following:  
   tanh(x) = 1 - (2 / (exp(2x) + 1)
*/
double tanh(x) 
double x;
{
  double f, result;
  register _temp;
  struct exception exc;

  _clear87();
  f=fabs(x);
  if(f>XBIG) result=1.0;
  else if(f>LN3_OVER2) result=1.0-2.0/(*_exp(2.0*f)+1.0);
  else if(f<EPS) result=f;
  else result=f+f*rtanh(f*f);
  if(x<0.0) result= -result;

  if((_temp=_status87())&0x80){
    exc.name="tanh";
    exc.arg1=x;
    exc.arg2=0;
    exc.retval=result;
    exc.type=_err_map(_temp);
    if(matherr(&exc)) result=exc.retval;
  }
  return (result);
}
+ARCHIVE+ tempnam.c      728  3/16/87 16:04:18
/* tempnam - create a unique temporary file name with path processing
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,16-mar-87,create"
#endif

#include <stdio.h>
#include <malloc.h>
#include <string.h>

char *tempnam(path, name)
char *path, *name;
{
  char *cp,*tp;

  if(cp=getenv("TMP")) path=cp;
  else if(path && !access(path,0)) ;
/*  else if(P_tmpdir) path=P_tmpdir; */
  else if(!access("\\tmp",0)) path="\\tmp";
  else return NULL;

  cp=malloc(strlen(path)+L_tmpnam+2);
  if(*path){
    strcpy(cp,path);
    strcat(cp,"\\");
  } else *cp=0;
  if(name) strcat(cp,name);
  strcat(cp,tp=tmpnam(NULL));
  free(tp);
  return cp;
}
+ARCHIVE+ time.c        1259  2/29/80 15:19:34
/* time - get current date and time from OS
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,4-nov-85,add header, copyright"
#pragma REVISED "zap,2-nov-86,combine time.c and _time.c"
#pragma REVISED "zap,8-apr-87,leap year screwup"
#endif

#include <time.h>
#include <dos.h>

time_t time(timer)
time_t *timer;
{
  static unsigned char days[]={31,28,31,30,31,30,31,31,30,31,30,31};
  struct regval regs;
  register int i;
  register unsigned temp;
  int j;
  long rettim;

  regs.ax=0x2a00;
  if(sysint21(&regs,&regs)&1) return (time_t)-1;
  temp=regs.cx-1900;
  i=temp/4;  /* leap days since 1/1/1900 - bug in 2000 A.D. */
  if(!(temp%4)) days[1]=29;  /* leap year - bug in 2000 A.D. */
  else i++;  /* another leap day */
  temp*=365;
  temp+=i;  /* days */
  j=(regs.dx>>8)-1;
  for(i=0;i<j;i++) temp+=days[i];
  temp+=regs.dx&0xFF;  /* days since 1900 */

  regs.ax=0x2c00;
  if(sysint21(&regs,&regs)&1) return -1;
  rettim=(long)temp*24+(regs.cx>>8);  /* hours since 1900 */
  rettim*=60;
  rettim+=regs.cx&0xFF;  /* minutes */
  rettim*=60;
  rettim+=regs.dx>>8;  /* seconds */

  if(timer) *timer=(time_t)rettim;
  return (time_t)rettim;
}
+ARCHIVE+ tmpfile.c      969  2/04/87 12:06:04
/* tmpfile - open a temporary file in binary update mode
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-oct-85,Creation"
#pragma REVISED "zap,7-nov-85,add temp file removal mechanism"
#pragma REVISED "jsc,27-oct-86,check malloc return value"
#pragma REVISED "zap,4-feb-87,_tf_next becomes local"
#endif

#include <stdio.h>
#include <malloc.h>

struct _tf_list{
  struct _tf_list *next;
  char name[L_tmpnam];
};
extern struct _tf_list _tf_root;

FILE *tmpfile()
{
  struct _tf_list *_tf_next;

  if(_tf_root.name[0]==0) return fopen(tmpnam(&_tf_root.name[0]),"w+b");
  else {
    _tf_next=&_tf_root;
    while(_tf_next->next) _tf_next=_tf_next->next;
    _tf_next->next = (struct _tf_list *)malloc(sizeof(struct _tf_list));
    if(_tf_next->next == NULL) return NULL;
    _tf_next->next->next=NULL;
    return fopen(tmpnam(&_tf_next->next->name[0]),"w+b");
  }
}
+ARCHIVE+ tmpnam.c       699  3/16/87 14:58:12
/* tmpnam - create a unique temporary file name
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-oct-85,new function"
#pragma REVISED "jsc,27-oct-86,honor C86TMP"
#pragma REVISED "zap,4-feb-87,backward ternary"
#pragma REVISED "zap,16-mar-87,simplify"
#endif

#include <stdio.h>
#include <malloc.h>

extern int _psp;    /* program segment prefix segment address */

/*    control variables
*/
static int filenumber = 0;      /* nth file so far */

/*  generate suitable temporary name
*/
char *tmpnam(s)
char *s;
{
  if(!s) s=malloc(L_tmpnam);
  sprintf(s,"~%x.%d",_psp,filenumber++);
  return s;
}


+ARCHIVE+ toascii.c      268 12/22/86 12:40:18
/* toascii - convert to ascii
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-oct-85,add header, copyright"
#endif

unsigned char toascii(c)
unsigned char c;
{
   return c&0x7f;
}


 
+ARCHIVE+ toint.c        401 12/22/86 12:40:20
/* toint - return weight of hexadecimal digit 0-15
**  or -1 if the character is not hexadecimal
** Copyright (c) 1984,85 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-oct-85,add header, copyright"
#endif

int toint(c)
unsigned char c;
{
  if(c>='0' && c<='9') return c-'0';
  if((c=toupper(c))>='A' && c<='F') return c-'A'+10;
  return -1;
}
+ARCHIVE+ tolower.c      349 12/22/86 12:40:24
/* tolower - convert character to lowercase if upper case
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, code changed, ctype in"
#endif
#include <ctype.h>

tolower(c)
int c;
{
  return (isupper(c) ? _tolower(c) : (c));
}
+ARCHIVE+ toupper.c      366  8/12/87 12:42:52
/* toupper.c - convert character to uppercase if lower case
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "lpa,7-jun-85"
#pragma REVISED "lpa,12-jun-85, 3.0, code changed, ctype in"
#endif
#include <ctype.h>

int toupper(c)
register int c;
{
  return (islower(c) ? _toupper(c) : (c));
}

+ARCHIVE+ tzset.c        654  5/20/87 12:44:10
/*  tzset.c - set the time zone variables from the environment
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,14-may-86,new function"
#pragma REVISED "zap,20-may-87,FMS !!"
#endif

#include <time.h>
#include <stdio.h>  /* for NULL */

int daylight=1;
long timezone=18000;
char *tzname[2]={"EST","DST"};

extern char *getenv();

void tzset()
{
  char *p;

  if((p=getenv("TZ"))==NULL) return;
  strncpy(tzname[0],p,3);
  while(!isdigit(*p)) p++;
  timezone=(long)atoi(p)*3600;
  p++;
  strncpy(tzname[1],p,3);
  if(*tzname[1]) daylight=1;
  else daylight=0;
}
+ARCHIVE+ ultoa.c        604 12/22/86 13:17:30
/*  ultoa.c - convert unsigned long to string
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,7-may-86,new function"
#endif

char *ultoa(value, buf, base)
unsigned long value;
char *buf;
unsigned base;
{
  static unsigned char *cbuf="0123456789abcdefghijklmnopqrstuvwxyz";
  unsigned char rbuf[34];
  register int i=33;

  if(base<2 || base>36) *buf=0;
  else {
    rbuf[i--]=0;
    while(value){
      rbuf[i--]=cbuf[(unsigned)(value%base)];
      value/=base;
    }
    strcpy(buf,&rbuf[i+1]);
  }
  return buf;
}
+ARCHIVE+ umask.c        340 12/22/86 12:40:34
/*  umask.c - set the file permission mask
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,21-may-86,new function"
#endif

unsigned _umask=0;

unsigned umask(permit)
unsigned permit;
{
  register unsigned temp;

  temp=_umask;
  _umask=permit;
  return temp;
}
+ARCHIVE+ ungetc.c       404  7/06/87 16:57:24
/* ungetc - unget a char from the input stream
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-jul-85,add this comment & copyright"
#pragma REVISED "nlp,6-jul-87, rewrite"
#endif

#include <stdio.h>

ungetc(cc,stream)
unsigned int cc;
register FILE *stream;
{

  stream->_cnt++;
  return *(--stream->_ptr)=cc;
}

+ARCHIVE+ unlink.c       300  3/03/87  9:25:34
/* unlink - delete a file the old fashioned way
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,3-mar-87,put this in the library"
#endif

#include <dos.h>

int unlink(filename)
char *filename;
{
  return remove(filename);
}

+ARCHIVE+ upper.c        360 12/22/86 12:40:40
/* upper.c - convert a string to upper case
   Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-oct-85,add header, copyright"
#endif

unsigned char *upper(cp)
unsigned char *cp;
{
  unsigned char *ct;

  for(ct=cp;*ct;++ct) if(*ct>='a' && *ct<='z') *ct+=('A'-'a');
  return cp;
}
+ARCHIVE+ utime.c       1273  6/02/87 16:43:54
/* utime - update file date and time
** Copyright (c) 1985,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,6-dec-85,new function"
#pragma REVISED "zap,5-may-86,change name from touch()"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,29-aug-86,do it right"
#pragma REVISED "zap,9-nov,86,second arg"
#pragma REVISED "zap,14-jan-87,swap bytes for time!=NULL"
#pragma REVISED "nlp,25-mar-87,open arguments updated"
#endif

#include <time.h>
#include <sys/utime.h>
#include <stdio.h>
#include <dos.h>
#include <sys/stat.h>
#include <fcntl.h>

int utime(filename,timer)
char *filename;
struct utimbuf *timer;
{
  register int fd;
  time_t temp;
  struct regval regs;
  struct tm *t;

  if((fd=open(filename, (O_RDWR | O_BINARY), (S_IREAD | S_IWRITE)))<0) 
    return -1;  /* open() sets errno */
  regs.bx=fd;
  if(!timer){  /* to current date and time */
    temp=time(NULL);
    t=localtime(&temp);
  }
  else t=localtime(&timer->modtime);  /* to specified date and time */
    
  regs.cx=(t->tm_sec>>1) | (t->tm_min<<5) | (t->tm_hour<<11);
  regs.dx=t->tm_mday | (t->tm_mon+1<<5) | (t->tm_year-80<<9);
  regs.ax=0x5701;
  sysint21(&regs,&regs);
  close(fd);
  return 0;
}
+ARCHIVE+ utoa.c         298 12/22/86 12:40:42
/* utoa - unsigned integer to ascii
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-oct-85,add header, copyright"
#endif

utoa(val,str)
unsigned val;
unsigned char *str;
{
  return ltos((unsigned long)val,str,10);
}
+ARCHIVE+ wqsort.c      1311 12/22/86 12:40:56
/* wqsort - Hoares quicksort algorithm
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-oct-85,add header, copyright"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#define DEPTH 20		/* should be adequate for most sorts */

wqsort(n,cmpf,xchgf,base)
unsigned int n;			/* number of items to sort */
int (*cmpf)();			/* key comparison function */
int (*xchgf)();			/* record exchange function */
unsigned char *base;		/* base of data */
{
  unsigned j,k;
  unsigned pivot,count,low[DEPTH],high[DEPTH];

  if(n<2)return;		/* already sorted */
  count=1;			/* do initialisation */
  low[0]=0;
  high[0]=n-1;
  while(count--){
    pivot=low[count];
    j=pivot+1;
    n=k=high[count];
    while(j<k){
      while(j<k && (*cmpf)(j,pivot,&base)<1)++j;
      while(j<=k && (*cmpf)(pivot,k,&base)<1)--k;
      if(j<k)(*xchgf)(j++,k--,&base);
    }
    if((*cmpf)(pivot,k,&base)>0)(*xchgf)(pivot,k,&base);
    if(k>pivot)--k;
    if(k>pivot && n>j && (k-pivot < n-j)){
      iswap(&k,&n);
      iswap(&pivot,&j);
    }
    if(k>pivot){
      low[count]=pivot;
      high[count++]=k;
    }
    if(n>j){
      low[count]=j;
      high[count++]=n;
    }
    if(count>=DEPTH)abort("wqsort failure");
  }
}
+ARCHIVE+ write.c       1762 11/17/87 16:00:32
/* write.c - write to a file
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,24-jul-85,add this comment & copyright"
#pragma REVISED "zap,9-oct-85,add signals"
#pragma REVISED "zap,17-oct-85,add 'touched' bit for setvbuf"
#pragma REVISED "zap,11-apr-86,change kill to raise"
#pragma REVISED "zap,22-may-86,new defines in fileio3.h"
#pragma REVISED "zap,28-may-86,ASCII processing"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,18-mar-87,_dosf40"
#pragma REVISED "zap,17-nov-87,remove seek for append mode (to _open)"
#endif

#include <stdio.h>
#include <dos.h>
#include <fileio3.h>
#include <errno.h>
#include <signal.h>

int write(fd,buffer,count)
register fd;
unsigned char *buffer;
{
  int res=0;   /* value to return to caller */

  if(fd<0 || fd>=SYS_OPEN){
    errno=EBADF;
    raise(SIGWRITE);
    return EOF;
  }
  _osfile[fd]|=_IOTOUCHED;  /* for setvbuf */

  if(_osfile[fd]&_IOASCII){
    char *sp, *ep;
    register unsigned nbytes;      /* no. bytes this call to _dosf40 */
    int xfer=0;                    /* actual no. transferred */

    ep=sp=buffer;
    while(count--) if(*ep++ == '\n'){
      *(ep-1)='\r';
      nbytes = ep - sp;
      if(_dosf40(fd,sp,nbytes)!=nbytes) goto err;
      res+= nbytes-1;
      xfer+= nbytes;  
      sp=ep-1;
      *sp='\n';
    }
    nbytes = ep - sp;
    if(_dosf40(fd,sp,nbytes)!=nbytes) goto err;
    res+=nbytes;
    _piob[fd]._foffset+=(xfer+nbytes);  /* for fseek */
  }             
  else {           /* binary */
    if(_dosf40(fd,buffer,res=count)!=count) goto err;
    _piob[fd]._foffset+=res;  /* for fseek */
  }
  return res;
err:
  return EOF;
}
+ARCHIVE+ y0.c           816 10/09/87 18:14:36
/* library function: Bessel Function - Y0
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma CREATED "ahm,18-aug-87"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <errno.h>
#include <float.h>
#include <_math.h>
#include <stdlib.h>

extern double _fac;

double *y0(arg)
double arg;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  if(arg<=0.0){
    errno=EDOM;
    temp=&_fac;
    *temp= -HUGE_VAL;
    exc.type=DOMAIN;
    goto SQ1;
  }
  temp=_y0(arg);
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
SQ1:
    exc.name="y0";
    exc.arg1=arg;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}





+ARCHIVE+ y1.c           820 10/09/87 18:14:44
/* library function: Bessel Function - Y1
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma CREATED "ahm,18-aug-87"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <errno.h>
#include <float.h>
#include <_math.h>
#include <stdlib.h>

extern double _fac;

double *y1(arg)
double arg;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  if(arg<=0.0){
    errno=EDOM;
    temp=&_fac;
    *temp= -HUGE_VAL;
    exc.type=DOMAIN;
    goto SQ1;
  }
  temp=_y1(arg);
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
SQ1:
    exc.name="y1";
    exc.arg1=arg;
    exc.arg2=0;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}







+ARCHIVE+ yn.c           819 10/09/87 18:14:54
/* library function: Bessel Function - Yn
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma CREATED "ahm,18-aug-87"
#pragma REVISED "zap,9-oct-87,hack on overhead, down and dirty"
#endif

#include <errno.h>
#include <float.h>
#include <_math.h>
#include <stdlib.h>

extern double _fac;

double *yn(n,x)
int	n;
double x;
{
  double *temp;
  register _temp;
  struct exception exc;

  _clear87();
  if(x<=0.0 || n<0){
    errno=EDOM;
    temp=&_fac;
    *temp= -HUGE_VAL;
    exc.type=DOMAIN;
    goto SQ1;
  }
  temp=_yn(n,x);
  if((_temp=_status87())&0x80){
    exc.type=_err_map(_temp);
SQ1:
    exc.name="yn";
    exc.arg1=n;
    exc.arg2=x;
    exc.retval=*temp;
    if(matherr(&exc)) *temp=exc.retval;
  }
  return temp;
}


+ARCHIVE+ zork.c         269 12/22/86 12:41:06
/* zork - returns the zork string
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,1-apr-86,creation"
#endif

char *zork()
{
  return "You are in a maze of twisty little passages, all alike.\n";
}

