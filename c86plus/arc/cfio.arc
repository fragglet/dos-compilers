+ARCHIVE+ $main.asm     6385  9/29/87  9:36:14
; $main - This is the starting point for all c programs.
; Copyright (C) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED

; REVISED 17jun87 ZAP  Added ROM stuff.

	title	$main

BOOT_STRAP equ	1		;tell prologue this is $main

	include	prologue.ah

	public	__acrtused	;so this routine gets linked
__acrtused =	0ffffh		;any value will do

	SIZ_STK equ	16384	;bytes in the stack

NULL	segment
	dt	0
	db	'Copyright (C) 1986,87 Computer Innovations Inc.'
	db	0
NULL	ends

	extrn	_edata:byte	;defined for the startup module
	extrn	_end:byte
	extrn	__argc:word	;command line stuff
	EXTERN	__argv,dp
	EXTERN	_environ,dp

_DATA	segment
	assume	ds:DGROUP

; Program Segment Prefix pointer
	public	__pspseg, __pspadr, __psp
__pspseg	LABEL	dword	;32 bit pointer to the prog seg prefix
__pspadr	dw	0	;psp offset
__psp		dw	0	;psp segment

; Operating System stuff
	public	__osmajor, __osminor, __sysvers, __systype
__systype	dw	1	;o/s type (ms-dos)
__sysvers 	LABEL	word	;o/s version (low byte 0 if < dos 2.00 )
__osmajor	db	0	;DOS version number
__osminor	db	0

 	public	__proglen, __heapmod, __amblksize
__proglen dw	0		;length of program in paragraphs
__heapmod dw	0		;where heap comming from
__amblksize dw	2000h		;size of far heap chunks

; Numeric Data Processor
	public	ndphere
ndphere		dw	0	;Does the machine have a NDP?

; Stack and Data Segments
	public	__atopsp, __asizds, __dataseg
__atopsp	dw	0	;for near alloc purposes
__asizds	dw	0	;size of data seg in bytes
__dataseg	dw	0	;segment address of data seg

_DATA	ends

if SET_SSDS eq FALSE
	NEARHEAP segment
		near_heap db	16 dup (?)
	NEARHEAP ends
endif

STACK	segment
	db	SIZ_STK dup (?)
STACK	ends

	EXTERN	_main,cp
	EXTERN	__main0,cp

	EXTERN	__main1,cp
        EXTERN	__main2,cp
	EXTERN  __main3,cp
	EXTERN  __main4,cp
	EXTERN	__mainlast,cp
	EXTERN	_exit,cp
        EXTERN  __control87,cp

if FAR_CODE eq TRUE
       	if FAR_DATA eq TRUE
       		EXTERN  __main5lf,cp
        else
       		EXTERN	__main5ln,cp
        endif				; FAR_DATA
else
       	if FAR_DATA eq TRUE
               	EXTERN	__main5sf,cp
       	else
       		EXTERN  __main5sn,cp
        endif				; FAR_DATA
endif				; FAR_CODE



_TEXT	segment
	assume	cs:_TEXT,ds:DGROUP

	public	$main
$main	proc	far
	jmp	short begin

begin:
	cld				;initial setup
	mov	dx,DGROUP		;make data addressable
	mov	ds,dx
	fninit

; check the operating system version

	mov	DGROUP:__psp,es  	;save psp segment...
	mov	DGROUP:__heapmod,es	;...and heap module
	mov	ah,30h			;check DOS version
	int	21h
	mov	word ptr __osmajor,ax	;save for user
	cmp	al,2			;DOS 2 or later only
	jae	isdos2			;its a winner
	mov	dx,offset usedos2
	push	ds			;sorry you loose
	push	cs
	pop	ds
	mov	ah,9			;tell them
	int	21h
	pop	ds
	jmp	dword ptr DGROUP:__pspadr	;and die
usedos2	db	13,'DOS 2+ Needed',10,'$'
isdos2:

; set up the stack (SS and SP)

if SET_SSDS eq TRUE
	mov	bx,es:2			;end of memory
	sub	bx,dx			;less DGROUP
	cmp	bx,1000h		;limit is 64K
	jb	do_set
	mov	bx,1000h		;its the limit
do_set:	cli				;don't interrupt me
	add	sp,offset DGROUP:_end-2	;and adjust the sp
	jnc	set_ss
	sub	sp,offset DGROUP:_end-2	;did not make it
	sti
	mov	dx,offset nostack
die:	mov	ah,9			;rude message and die
	push	cs
	pop	ds
	int	21h
	mov	ax,4cffh		;terminate
	int	21h
nostack	db	13,'Stack  Overflow',10,'$'
set_ss:	mov	ss,dx			;set the stack to ds
	and	sp,0fffeh		;force sp even
	sti				;interrupts back on
	mov	__atopsp,sp		;save sp value
	mov	ax,bx			;get size of data seg
	mov	cl,4
	shl	ax,cl
	dec	ax			;less 1 so no overflow
	mov	DGROUP:__asizds,ax	;save for paying public
	add	bx,dx			;last para in prog
endif

if SET_SSDS eq FALSE
        mov     DGROUP:__asizds,0ffffh  ;say VERY large
	mov	bx,sp			;see how much we are using
	mov	cl,4
	shr	bx,cl			;in paragraphs
	mov	cx,ss			;go via a temp
	add	bx,cx			;absolutely
	inc	bx			;don't forget last paragraph
endif

; return unused memory to system

	mov	es:2,bx			;save in PSP
	mov	cx,es			;go via a temp
	sub	bx,cx			;actual # of para in image
	mov	DGROUP:__proglen,bx	;length of the program
	mov	ah,4ah
	int	21h			;free unused memory

; zero the uninitialized data areas

	mov	es,dx			;set to DGROUP
	xor	ax,ax			;set static area to zero
	mov	cx,offset dgroup:_end	;end of area to zap
	mov	di,offset dgroup:_edata	;beginning of area

	sub	cx,di			;# of bytes to zero
	rep	stosb			;and zap it to zero

	mov	dx, ds
	mov	DGROUP:__dataseg, dx	; near data segment

; call the C routines _main?() to do other initialization

	mov	bp,ax			;zap bp as marker

	mov	dx,sp
	add	dx, 2
if FAR_DATA eq TRUE
	mov	ax, DGROUP:__amblksize
	mov	cl, 4
	shr	ax, cl
else
	mov	ax, 1
endif
	push	ax			;size of the far heap
	mov	ax,DGROUP:__psp
	add	ax,DGROUP:__proglen
	push	ax			;far heap segment
	xor	ax,ax
	push	ax			;far heap offset
if SET_SSDS eq TRUE
	mov	ax, DGROUP:__asizds
	sub	ax,dx
	push	ax			;near heap size
	push	dx			;near heap address
else
	mov	ax, 16			;size of near heap
	push	ax
	mov	ax, offset DGROUP:near_heap	;kluje it out
	push	ax
endif

	call	__main0			;initialize heap
	add	sp,10
	fnstcw	DGROUP:ndphere		;for 8087 auto-detect
	call	__main1			;do file initializations
	and	DGROUP:ndphere, 0FF3Fh	;difference between PC and AT
	cmp	DGROUP:ndphere, 033Fh
	je	fpok			;AT funny business
	mov	DGROUP:ndphere, 0	;no coprocessor
fpok:
	call	__main2			;process environment stuff
	and	DGROUP:ndphere, ax	;ignore 8087 if "NO87" in environment
	call	__main3			;build command line stuff
	push	DGROUP:ndphere
	call	__main4			;save and set ^C and NDP interrupts

if FAR_CODE eq TRUE		; init the 8087 or emulator
if FAR_DATA eq TRUE
	call	__main5lf
else
	call	__main5ln
endif				; FAR_DATA
else
if FAR_DATA eq TRUE
	call	__main5sf
else
	call	__main5sn
endif				; FAR_DATA
endif				; FAR_CODE

nocwset:
	call	__mainlast		;set up program clock
	if	FAR_DATA eq TRUE
	push	word ptr DGROUP:_environ+2
	endif
	push	word ptr DGROUP:_environ
	if	FAR_DATA eq TRUE
	push	word ptr DGROUP:__argv+2
	endif
	push	word ptr DGROUP:__argv
	push	word ptr DGROUP:__argc

	call	_main			;do the real thing
	push	ax			;set the terminal value
NOGOOD:
	call	_exit			;and quietly exit

FUN_END	$main
	end	$main

+ARCHIVE+ _doprnt.c     9255 10/27/87 15:43:06
/* _doprnt - Format data under control of a format string.
** Copyright (c) 1985,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,17-jun-85,renamed from _fmtout,add ANSI flags"
#pragma REVISED "zap,19-aug-85,shaken out fairly well"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "zap,2-nov-86,%D, %p"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#pragma REVISED "nlp,08-jan-87,static fcns"
#pragma REVISED "zap,15-jan-87,split out floating point"
#pragma REVISED "zap,21-jan-87,fix return value"
#pragma REVISED "zap,26-jan-87,floating point support models"
#pragma REVISED "nlp,26-feb-87,more registers"
#pragma REVISED "zap,30-apr-87,forgot to update arg ptr for floats"
#pragma REVISED "nlp,15-jun-87,use static FILE *str, _inttohex is near"
#pragma REVISED "nlp,15-jun-87,no more strcpy, changed while() structure"
#pragma REVISED "zap,7-jul-87,mumble bloody floats"
#pragma REVISED "zap,17-jul-87,near and far pointers"
#pragma REVISED "nlp,12-aug-87,longflg follies"
#pragma REVISED "nlp,26-aug-87,wrong union choice in assignment, line 264"
#pragma REVISED "zap,24-sep-87,field width for %c"
#pragma REVISED "ahm,15-oct-87, accept flags in format string in any order"
#pragma REVISED "gee,27-oct-87, csign converted to int"
#endif

#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>
#include <malloc.h>

/*
** To revert to the old C86 spec, comment out the definition of _ANSI.
*/

#define _ANSI
#define _C86EXTEND

#ifdef _FLAGS_As
#ifdef _FLAGS_An
#define FLOAT_PRINT_FUNC _fprntsn

#else
#define FLOAT_PRINT_FUNC _fprntsf

#endif
#else
#ifdef _FLAGS_An
#define FLOAT_PRINT_FUNC _fprntln

#else
#define FLOAT_PRINT_FUNC _fprntlf

#endif
#endif

int FLOAT_PRINT_FUNC(unsigned, va_list, char, unsigned, unsigned
             , char, unsigned, unsigned, FILE *);

static void near _inttohex(i,buf)
unsigned  i;
char  *buf;
{
  static char conv[]={'0','1','2','3','4','5','6','7',
                      '8','9','A','B','C','D','E','F'};
  register unsigned mask=0xF000;
  register int shft=12;

  while(mask){
    *buf=conv[(i&mask)>>shft];
    mask>>=4;
    shft-=4;
    buf++;
  }
  *buf=0;
}

static int char_count=0;
static FILE *str=NULL;

static void near printchar(c)
int c;
{
  ++char_count;
  putc(c,str);
}


int _doprnt(format,args,stream)
register char  *format;
va_list  *args;
FILE  *stream;
{
  va_list  ap;
  register int base, temp;
  int exponent;
  unsigned leftadj,padchar,width,precflg,precisn,longflg,length,alternate;
  char  *cp,prefix[5],_buf[30];
  int csign=0;
  union {
    long tlong;
    unsigned long tulong;
  }lw;
#ifdef _FLAGS_Af
  unsigned longptrflg=1;  /* default data pointers are far */
#else
  unsigned longptrflg=0;  /* near */
#endif

#ifdef _ANSI
  unsigned hexupper;
#endif

  /* re-entrant now */
  FILE *oldstream = str;
  int old_count = char_count;

  str = stream;
  char_count=0;

  ap=*args;
  alternate=0;
  memset(prefix,0,5);
  memset(_buf,0,30);

  while(*format){
    if(*format!='%') printchar(*format++);  /* normal characters */

    else {           /* conversion spec */

#ifdef _ANSI
         hexupper=0;
#endif

       alternate=0;
       leftadj=0; 

       while (*++format=='-'||*format=='+'||*format=='#'||isspace(*format)) {
         switch(*format) {
            case '-': leftadj = '-'; break;        /* left justify */
            case '+': csign = '+'; break;          /* print sign */
            case ' ': if(!csign) csign=' '; break; /* prepend a space */
            case '#': alternate = '#'; break;      /* alt form */
            default : break;
         }
       }

      if(*format=='0'){  /* alternate pad character */
        padchar='0';
        ++format;
      }
      else padchar=' ';

      if(*format=='*'){
        width=va_arg(ap,int);  /* width is an argument */
        ++format;
      }
      else {                 /* set the field width */
        for(width=0; isdigit(*format); )
           width=width*10+(*format++-'0');
		}
      if(precflg=(*format=='.')){  /* precision? */
        ++format;
        if(*format=='-') ++format;
        if(*format=='*'){
          precisn=abs(va_arg(ap,int));  /* precisn is an argument */
          ++format;
        }
        else
          for(precisn=0; isdigit(*format); )
            precisn=precisn*10+(*format++-'0');
      }
      else precisn=0;

		if(*format=='l') {
		  longflg=longptrflg=1;	/* long */
		  ++format;
      }
		else if(*format=='L') {	/* extra long */
	     longflg=2;
		  longptrflg=1;
		  ++format;
      }
      else if(*format=='h'){
        ++format;
        longptrflg=longflg=0;
      }
		else {
  		  longflg=0;
		}

      cp=_buf;
      switch(*format){
        case 'e':
        case 'E':
        case 'f':
        case 'g':
        case 'G':
          if(!precflg) precisn=6;  /* default */
          char_count+=FLOAT_PRINT_FUNC(precisn, ap, *format, width
                  ,alternate ,csign, leftadj, padchar, stream);
          ap+=sizeof(double);
          break;
#ifdef _C86EXTEND
        case 'B':
          longflg=1;
        case 'b':
          base=2;
          goto nosign;
        case 'O':
          longflg=1;
#endif
        case 'o':
          if(alternate) {
				prefix[0]='0'; prefix[1]='\0';
			 }
          base=8;
          goto nosign;
#ifdef _C86EXTEND
        case 'U':
          longflg=1;
#endif
        case 'u':
          base=10;
          goto nosign;
        case 'X':
#ifdef _ANSI
          hexupper=1;
#else
          longflg=1;
#endif
        case 'x':
          if(alternate) {
				prefix[0]='0'; prefix[1]='x'; prefix[2]='\0';
			 }
          base=16;
          goto nosign;
        case 'D':
          longflg=1;
        case 'd':
        case 'i':
          base=-10;
          goto nosign;
        case 'p':
          if(longptrflg){
            if(width>9 && leftadj) for(;width>9;width--) printchar(' ');
            _inttohex(va_arg(ap,int),&_buf[0]);
            _inttohex(va_arg(ap,int),&_buf[6]);
            cp=&_buf[6];
            while(*cp) printchar(*cp++);
            printchar(':');
            cp=&_buf[0];
            while(*cp) printchar(*cp++);
            for(;width>9;width--) printchar(' ');
            break;
          }
          else {
            base=16;
            longflg=0;
          }

nosign:
          cp=prefix;
          if(base<0){ /* signed conversion */
            if(longflg)lw.tlong=va_arg(ap,long);
            else lw.tlong=(long)va_arg(ap,int);
            if(csign && lw.tlong>=0) *cp++=csign;
            else if(lw.tlong<0){
              *cp++='-';
              lw.tlong=-(lw.tlong);
            }
          } else { /* unsigned conversion */
            if(longflg)lw.tulong=va_arg(ap,unsigned long);
            else lw.tulong=(unsigned long)va_arg(ap,unsigned);
            if(alternate)while(*cp)cp++;
          }
          *cp=0;
          ltos(lw.tlong,_buf,base);
          length=strlen(_buf);
          if(precflg && length<precisn) precisn-=length;
          else precisn=0;
          temp=strlen(prefix);
          if(width){
            if(width>length+precisn){
              width-=length+precisn;
              if(width>temp) width-=temp;
              else width=0;
            } else width=0;
          }
          cp=prefix;
          if(!leftadj){
            if(padchar=='0'){
              for(;temp;--temp) printchar(*cp++);
              for(;width;--width) printchar('0');
            } else {
              for(;width;--width) printchar(' ');
              for(;temp;--temp) printchar(*cp++);
            }
          } else for(;temp;--temp) printchar(*cp++);
          cp=_buf;
          for(;precisn;--precisn) printchar('0');
#ifdef _ANSI
          if(hexupper)for(;length;--length) printchar(*cp++);
          else for(;length;--length) printchar(tolower(*cp++));
#else
          for(;length;--length) printchar(*cp++);
#endif
          for(;width;--width) printchar(' ');
          break;
        case 's':
          length=strlen(cp=va_arg(ap,char *));
          if(precflg){
            if(length>precisn) length=precisn;
          }
          if(width){
            if(width>length){
              width-=length;
              if(!leftadj) for(;width;width--) printchar(' ');
            } else width=0;
          }
          while(length--) printchar(*cp++);
          while(width--) printchar(' ');
          break;
        case 'c':
          if(!leftadj && width) while(width-->1) printchar(padchar);
          printchar(va_arg(ap,int));
          if(leftadj && width) while(width-->1) printchar(padchar);
          break;
        case 'n':
          *(va_arg(ap,int *))=char_count;
          break;
        default:
          printchar(*format);
          break;
      }			/* end switch */
      ++format;
    } /* end else */
  }  /* end while */

  temp=char_count;

  /* pop em */
  char_count=old_count;
  str = oldstream;

  return temp;
}


+ARCHIVE+ _doscan.c    11365 10/28/87 15:37:22
/* format data into memory - used by scanf et al
** Copyright (c) 1985,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-jul-85,complete rewrite of yfmtin.c"
#pragma REVISED "zap,19-aug-85,shaken out fairly well"
#pragma REVISED "zap,9-dec-86,mumble whitespace"
#pragma REVISED "nlp,12-dec-86,static fcn"
#pragma REVISED "gee,20-dec-86,_FLAGS"
#pragma REVISED "nlp,08-jan-87,register int c, EOF test %s"
#pragma REVISED "jew,12-JAN-87,fix exhausted field count action"
#pragma REVISED "zap,16-jan-87,cut out floats"
#pragma REVISED "zap,26-jan-87,floating point support models"
#pragma REVISED "nlp,26-feb-87,registers"
#pragma REVISED "nlp,15-jun-87,make re-entrant + use static stream"
#pragma REVISED "zap,16-jul-87,wig out if nothing was converted"
#pragma REVISED "zap,17-jul-87,near and far pointers"
#pragma REVISED "nlp,12-aug-87,longflg problems with f.p."
#pragma REVISED "ahm,22-oct-87,assignment suppression for cases 's', 'c', 'p', 'n' & '['"
#pragma REVISED "ahm,23-oct-87,do not unread_char, if EOF"
#pragma REVISED "ahm,26-oct-87,case 'd': nondigit following sign is illegal"
#pragma REVISED "ahm,27-oct-87,case '%[^...]': add EOF to the list of terminators"
#pragma REVISED "ahm,27-oct-87, return EOF if EOF & no conversion is done"
#pragma REVISED "ahm,27-oct-87, case '[': corrected"
#pragma REVISED "ahm,27-oct-87, case 'f': churn out white spaces & check for EOF"
#endif

/*
** Remove the definition _ANSI to revert to the old C86 extentions.
*/

#define _ANSI
#define NUMFIELD_WIDTH 349

#include <stdio.h>
#include <ctype.h>
#include <stdarg.h>
#include <stdlib.h>

#define iswhite(c)		(isspace(c) || c=='\t')

#define _IIC_BIN 0  /* indices for integer conversion tables */
#define _IIC_OCT 1
#define _IIC_UNS 2    /* unsigned decimal */
#define _IIC_DEC 3
#define _IIC_HEX 4
#define _IIC_INT 5    /* %i conversion */


#ifdef _FLAGS_As
#ifdef _FLAGS_An
#define FLOAT_SCAN_FUNC _fscansn

#else
#define FLOAT_SCAN_FUNC _fscansf

#endif
#else
#ifdef _FLAGS_An
#define FLOAT_SCAN_FUNC _fscanln

#else
#define FLOAT_SCAN_FUNC _fscanlf

#endif
#endif

int FLOAT_SCAN_FUNC(FILE *, unsigned, va_list *, unsigned);

static int num_read=0;
static FILE *str = NULL;

static int near read_char()
{
  ++num_read;
  return getc(str);
}

static void near unread_char(c)
int c;
{
  --num_read;
  if (c!=EOF) ungetc(c,str);
}


static int near _str_scan(c,b)
register int c;
register char *b;
{
  while(*b!=0){
    if((char)c==*b)return(1);
    ++b;
  }
  return(0);
}


int _doscan(format,args,stream)
char *format;
va_list *args;
FILE *stream;
{
  static char *int_digits[]={
    "01",
    "01234567",
    "0123456789",
    "+-0123456789",
    "0123456789abcdefABCDEF",
    "+-0123456789",
  };
  static dptr_inc[]={0,0,0,2,0,-1};
  int dgt_index;
  long el;
  union{
    char far *p;
    unsigned pp[2];
  }ptr;
  int num_conv=0;  /* number of conversions made */
  unsigned shortflg,longflg,width,suppress,sign,base,invert;
  char buffer[350],*bptr,*dptr;
  register int c;
  va_list ap;
#ifdef _FLAGS_Af
  unsigned longptrflg=1;  /* default data pointer size is far */
#else
  unsigned longptrflg=0;  /* near */
#endif

  /* make re-entrant */
  int old_num_read = num_read;
  FILE *old_stream = str;

  num_read=0;
  str=stream;

  c=read_char();
  if(c == EOF) return EOF;
  unread_char(c);

  ap=*args;
  while(*format){
    shortflg=longflg=width=suppress=sign=0;
    while(*format!='%'){
      if(iswhite(*format)){
        c=' ';  /* macro problems */
        while(iswhite(c)) c=read_char();
        unread_char(c);
        while(iswhite(*format))++format;
      } else if(*format++!=(c=read_char())){
        unread_char(c);
        goto wig_out;
      }
    }
    ++format;
    if(*format=='*'){
      suppress=1;
      ++format;
    }
    while(isdigit(*format))width=width*10+(*format++-'0');
    if(*format=='h'){
      shortflg=1;
      longptrflg=0;
      ++format;
    }
	 if(*format=='L') {
      if(shortflg) goto wig_out;
      longptrflg=longflg=2;	/* long double */
      ++format;
    }
    else if(*format=='l'){
      if(shortflg) goto wig_out;
      longptrflg=longflg=1;  /* regular double */
      ++format;
    }
    switch(*format)
    {
#ifndef _ANSI
      case 'B':
        longflg=1;
      case 'b':
        base=2;
        dptr=int_digits[dgt_index=_IIC_BIN];
        goto decimal;
      case 'D':
        longflg=1;
#endif
      case 'd':
        base=10;
        dptr=int_digits[dgt_index=_IIC_DEC];
        goto decimal;
      case 'i':
        base=0;
        dptr=int_digits[dgt_index=_IIC_INT];
        goto decimal;
#ifndef _ANSI
      case 'O':
        longflg=1;
#endif
      case 'o':
        base=8;
        dptr=int_digits[dgt_index=_IIC_OCT];
        goto decimal;
#ifndef _ANSI
      case 'U':
        longflg=1;
#endif
      case 'u':
        base=10;
        dptr=int_digits[dgt_index=_IIC_UNS];
        goto decimal;
      case 'X':
      case 'x':
        base=16;
        dptr=int_digits[dgt_index=_IIC_HEX];
        /* Note fall through... */

decimal:
        if(!width)width=NUMFIELD_WIDTH;
        do{
          c=read_char();  /* dump whitespace */
        } while(iswhite(c));
        if (c==EOF && !num_conv)  return EOF;
        bptr=buffer;
        if(width && _str_scan(c,dptr)){
          *bptr++=c;
          if(base==0){
            if(c=='0'){
              if(toupper(c=read_char())=='X'){
                dptr=int_digits[_IIC_HEX];
                *bptr++=c;
                c=read_char();
              } else dptr=int_digits[_IIC_OCT];
            } else {
              dptr=int_digits[_IIC_UNS];
              c=read_char();
            }
          } else {
            dptr+=dptr_inc[dgt_index];
            c=read_char();
          }
          --width;
          if (((*(bptr-1)=='+')||(*(bptr-1)=='-'))&&(!_str_scan(c,dptr))) { /* Invalid char after '-' or '+' */
             unread_char(c);
             goto wig_out;
          }
          for(;width && _str_scan(c,dptr);--width){
            *bptr++=c;
            c=read_char();
          }
        }
        /* At this point, we either read the wrong type of character,
        or we've read too many of the right kind.  IN EITHER CASE,
        we should put it back where it belongs: */
        unread_char(c);	   /* no "if(width)" */
        *bptr=0;
        if(!buffer[0]) goto wig_out;  /* nothing converted */
        el=strtol(buffer,NULL,base);
        if(!suppress){
          if(longflg){
            bptr=va_arg(ap,char *);
            *((long *)bptr)=el;
          } else {
            bptr=va_arg(ap,char *);
            *((unsigned *)bptr)=(unsigned)el;
          }
          ++num_conv;
        }
        break;

      case 's':
        if(!suppress) bptr=va_arg(ap,char *);
        if(!width) width=0x7FFF;
        do{
          c=read_char();  /* dump whitespace */
        } while(iswhite(c));
        if (c==EOF && !num_conv)  return EOF;
        if(c == EOF) goto wig_out; /* don't bump num_conv if EOF in white space */
        while(width && (!iswhite(c)) && (c!=EOF)){
          if(!suppress) *bptr++=c;
          --width;
          c=read_char();
        }
        if(!suppress){
          *bptr=0;
          ++num_conv;
        }
		  if(c == EOF) goto wig_out;
        unread_char(c);
        break;

      case 'c':
        if (!suppress) bptr=va_arg(ap,char *);
        if(!width) width=1;
        if ( (c=read_char())==EOF && !num_conv) return EOF;
        while(width){
          if(!suppress) *bptr++=c;
          c=read_char();
          --width;
        }
        unread_char(c);
        if(!suppress) ++num_conv;
        break;

      case 'E':
      case 'F':
#ifndef   _ANSI
        longflg=i;
#else
        longflg=1;
#endif
		  goto do_efg;
      case 'e':
      case 'f':
      case 'g':
do_efg:			
        do{
             c=read_char(stream);  /* dump whitespace */
           } while(iswhite(c));
        unread_char(c);
        if (c==EOF && !num_conv) return EOF;
        if(!(c=FLOAT_SCAN_FUNC(stream, longflg, &ap, suppress))) goto wig_out;
        num_read+=c;
        num_conv++;
        break;

      case 'p':
        do{
          c=read_char();  /* dump whitespace */
        } while(iswhite(c));
        if (c==EOF && !num_conv) return EOF;
        if(longptrflg){
          width=4;
          bptr=buffer;
          *bptr++='0';
          while(width && isxdigit(c)){
            *bptr++=c;
            --width;
            c=read_char();
          }
          *bptr=0;
          ptr.pp[0]=(unsigned)strtol(buffer,NULL,16);
          if(c!=':') goto wig_out;
          width=4;
          bptr=buffer;
          *bptr++='0';
          c=read_char();
          while(width && isxdigit(c)){
            *bptr++=c;
            --width;
            c=read_char();
          }
          *bptr=0;
          unread_char(c);
          if(!buffer[0]) goto wig_out;
          ptr.pp[1]=(unsigned)strtol(buffer,NULL,16);
          if(!suppress) bptr=(char *)va_arg(ap,char **);
          if(!suppress){
            *((char **)bptr)=ptr.p;
            ++num_conv;
          }
        }
        else {
          unread_char(c);
          width=4;
          bptr=buffer;
          *bptr++='0';
          while(width && isxdigit(c=read_char())){
            *bptr++=c;
            width--;
          }
          if(!buffer[0]) goto wig_out;
          *bptr=0;
          if(!suppress) bptr=va_arg(ap,char **);
          if(!suppress){
            *((void **)bptr)=(void *)strtol(buffer,NULL,16);
            ++num_conv;
          }
        }
        break;

      case 'n':
        if(!suppress) bptr=(char *)va_arg(ap,int *);
        if(!suppress){
          *((int *)bptr)=num_read;
          ++num_conv;
        }
        break;

      case '[':
        c=read_char();
        if (c==EOF && !num_conv) return EOF;
        unread_char(c);
        bptr=buffer;
        if(*(++format)=='^'){
          invert=1;
          *bptr++ = EOF;         /* add EOF to the list of terminators */
          ++format;
        } else invert=0;
        while(*format!=']') *bptr++=*format++;
        *bptr=0;
        if(!width)width=0x7FFF;
        if(!suppress) bptr=va_arg(ap,char *);
        if(invert!=_str_scan((c=read_char()),buffer)) unread_char(c);
        else goto wig_out;    /* no match character found */
        while(width && invert!=_str_scan((c=read_char()),buffer)){
          if(!suppress)*bptr++=c;
          --width;
        }
        unread_char(c);
        *bptr=0;
        if(!suppress) ++num_conv;
        break;
      case '%':
        do{
          c=read_char();  /* dump whitespace */
        } while(iswhite(c));
        if (c==EOF && !num_conv) return EOF;
        if(c!='%') goto wig_out;
        ++num_conv;
        break;
      default:
        goto wig_out;
    }
    ++format;
  }
wig_out:

  /* pop em */
  num_read = old_num_read;
  str = old_stream;

  return(num_conv);
}





+ARCHIVE+ _fpc.asm      9020 10/20/87 16:40:56
;
;  msc/compatible -FPc support package
;  Copyright (C) 1987 Computer Innovations, Inc. ALL RIGHTS RESERVED
;
;  NO NEED TO SHIP SOURCE
;

include prologue.ah


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fldd
	fld	qword ptr [bx]		; fld qword under ds
	fwait
	ret
FUN_END  __fldd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __flds
	fld	dword ptr [bx]		; fld dword under ds
	fwait
	ret
FUN_END  __flds


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fldl
	fild	dword ptr [bx]		; fild dword under ds
	fwait
	ret
FUN_END  __fldl


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fldw
	fild	word ptr [bx]		; fild word under ds
	fwait
	ret
FUN_END  __fldw


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __eldd
	fld	qword ptr es:[bx]	; fld qword under es
	fwait
	ret
FUN_END  __eldd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __elds
	fld	dword ptr es:[bx]	; fld dword under es
	fwait
	ret
FUN_END  __elds


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __eldl
	fild	dword ptr es:[bx]	; fild dword under es
	fwait
	ret
FUN_END  __eldl


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __eldw
	fild	word ptr es:[bx]	; fild word under es
	fwait
	ret
FUN_END  __eldw


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __sldd
	fld	qword ptr es:[bx]	; fld qword under es
	fwait
	ret
FUN_END  __sldd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __slds
	fld	dword ptr es:[bx]	; fld dword under es
	fwait
	ret
FUN_END  __slds


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __sldl
	fild	dword ptr ss:[bx]	; fild dword under ss
	fwait
	ret
FUN_END  __sldl


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __sldw
	fild	word ptr es:[bx]	; fild word under es
	fwait
	ret
FUN_END  __sldw


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fstdp
	fstp	qword ptr [bx]		; fstp qword under ds
	fwait
	ret
FUN_END  __fstdp


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fstd
	fst	qword ptr [bx]		; fst qword under ds
	fwait
	ret
FUN_END  __fstd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fstsp
	fstp	dword ptr [bx]		; fstp dword under ds
	fwait
	ret
FUN_END  __fstsp


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fsts
	fst	dword ptr [bx]		; fst dword under ds
	fwait
	ret
FUN_END  __fsts


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __estdp
	fstp	qword ptr es:[bx]	; fstp qword under es
	fwait
	ret
FUN_END  __estdp


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __estd
	fst	qword ptr es:[bx]	; fst qword under es
	fwait
	ret
FUN_END  __estd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __ests
	fst	dword ptr es:[bx]	; fst dword under es
	fwait
	ret
FUN_END  __ests


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __estsp
	fstp	dword ptr es:[bx]	; fstp dword under es
	fwait
	ret
FUN_END  __estsp


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __sstdp
	fstp	qword ptr ss:[bx]	; fstp qword under ss
	fwait
	ret
FUN_END  __sstdp


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __sstd
	fst	qword ptr ss:[bx]	; fst qword under ss
	fwait
	ret
FUN_END  __sstd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __ssts
	fst	dword ptr ss:[bx]	; fst dword under ss
	fwait
	ret
FUN_END  __ssts


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __sstsp
	fstp	dword ptr ss:[bx]	; fstp dword under ss
	fwait
	ret
FUN_END  __sstsp


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __faddd
	fadd	qword ptr [bx]		; fadd qword under ds
	fwait
	ret
FUN_END  __faddd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fadds
	fadd	dword ptr [bx]		; fadd dword under ds
	fwait
	ret
FUN_END  __fadds


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __eaddd
	fadd	qword ptr es:[bx]	; fadd qword under es
	fwait
	ret
FUN_END  __eaddd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __eadds
	fadd	dword ptr es:[bx]	; fadd dword under es
	fwait
	ret
FUN_END  __eadds


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __saddd
	fadd	qword ptr ss:[bx]	; fadd qword under ss
	fwait
	ret
FUN_END  __saddd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __sadds
	fadd	dword ptr ss:[bx]	; fadd dword under ss
	fwait
	ret
FUN_END  __sadds


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fsubd
	fsub	qword ptr [bx]		; fsub qword under ds
	fwait
	ret
FUN_END  __fsubd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fsubdr
	fsubr	qword ptr [bx]		; fsubr qword under ds
	fwait
	ret
FUN_END  __fsubdr


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fsubs
	fsub	dword ptr [bx]		; fsub dword under ds
	fwait
	ret
FUN_END  __fsubs


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fsubsr
	fsubr	dword ptr [bx]		; fsubr dword under ds
	fwait
	ret
FUN_END  __fsubsr


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __esubd
	fsub	qword ptr es:[bx]	; fsub qword under es
	fwait
	ret
FUN_END  __esubd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __esubdr
	fsubr	qword ptr es:[bx]	; fsubr qword under es
	fwait
	ret
FUN_END  __esubdr


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __esubs
	fsub	dword ptr es:[bx]	; fsub dword under es
	fwait
	ret
FUN_END  __esubs


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __esubsr
	fsubr	dword ptr es:[bx]	; fsubr dword under es
	fwait
	ret
FUN_END  __esubsr


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __ssubd
	fsub	qword ptr ss:[bx]	; fsub qword under ss
	fwait
	ret
FUN_END  __ssubd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __ssubdr
	fsubr	qword ptr ss:[bx]	; fsubr qword under ss
	fwait
	ret
FUN_END  __ssubdr


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __ssubs
	fsub	dword ptr ss:[bx]	; fsub dword under ss
	fwait
	ret
FUN_END  __ssubs


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __ssubsr
	fsubr	dword ptr ss:[bx]	; fsubr dword under ss
	fwait
	ret
FUN_END  __ssubsr


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fmuld
	fmul	qword ptr [bx]		; fmul qword under ds
	fwait
	ret
FUN_END  __fmuld

	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fmuls
	fmul	dword ptr [bx]		; fmul dword under ds
	fwait
	ret
FUN_END  __fmuls


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __emuld
	fmul	qword ptr es:[bx]	; fmul qword under es
	fwait
	ret
FUN_END  __emuld


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __emuls
	fmul	dword ptr es:[bx]	; fmul dword under es
	fwait
	ret
FUN_END  __emuls


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __smuld
	fmul	qword ptr ss:[bx]	; fmul qword under ss
	fwait
	ret
FUN_END  __smuld


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __smuls
	fmul	dword ptr ss:[bx]	; fmul dword under ss
	fwait
	ret
FUN_END  __smuls


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fdivd
	fdiv	qword ptr [bx]		; fdiv qword under ds
	fwait
	ret
FUN_END  __fdivd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fdivdr
	fdivr	qword ptr [bx]		; fdivr qword under ds
	fwait
	ret
FUN_END  __fdivdr


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fdivs
	fdiv	dword ptr [bx]		; fiv dword under ds
	fwait
	ret
FUN_END  __fdivs


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fdivsr
	fdivr	dword ptr [bx]		; fdivr dword under ds
	fwait
	ret
FUN_END  __fdivsr


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __edivd
	fdiv	qword ptr es:[bx]	; fdiv qword under es
	fwait
	ret
FUN_END  __edivd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __edivdr
	fdivr	qword ptr es:[bx]	; fdivr qword under es
	fwait
	ret
FUN_END  __edivdr


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __edivs
	fdiv	dword ptr es:[bx]	; fdiv dword under es
	fwait
	ret
FUN_END  __edivs


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __edivsr
	fdivr	dword ptr es:[bx]	; fdivr dword under es
	fwait
	ret
FUN_END  __edivsr


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __sdivd
	fdiv	qword ptr ss:[bx]	; fdiv qword under ss
	fwait
	ret
FUN_END  __sdivd


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __sdivdr
	fdivr	qword ptr ss:[bx]	; fdivr qword under ss
	fwait
	ret
FUN_END  __sdivdr


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __sdivs
	fdiv	dword ptr ss:[bx]	; fdiv dword under ss
	fwait
	ret
FUN_END  __sdivs


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __sdivsr
	fdivr	dword ptr ss:[bx]	; fdivr dword under ss
	fwait
	ret
FUN_END  __sdivsr


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fchs
	fchs
	fwait
	ret
FUN_END  __fchs


	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fadd
	faddp	st(1),st
	fwait
	ret
FUN_END  __fadd

	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fsub
	fsubp	st(1),st
	fwait
	ret
FUN_END  __fsub

	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fsubr
	fsubrp	st(1),st
	fwait
	ret
FUN_END  __fsubr

	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fmul
	fmulp	st(1),st
	fwait
	ret
FUN_END  __fmul

	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fdiv
	fdivp	st(1),st
	fwait
	ret
FUN_END  __fdiv

	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fdivr
	fdivrp	st(1),st
	fwait
	ret
FUN_END  __fdivr

	_TEXT	segment
	assume	cs:_TEXT
FUN_PROC __fdup
	fld	st(0)
	fwait
	ret
FUN_END  __fdup

end

+ARCHIVE+ _ldiv.asm      884 10/20/87 14:20:20
; _ldiv.asm - MSC compatible long divide entry point
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.

	title	__ldiv

	include	prologue.ah

public	__ldiv
public	__aldiv

_TEXT	segment
assume	cs:_TEXT,ds:DGROUP

if FAR_CODE eq TRUE

extrn	__aFldiv:far
__ldiv	proc	far
	jmp 	__aFldiv
__ldiv	endp

	if FAR_DATA eq TRUE

extrn	__aFFaldiv:far
__aldiv	proc	far
	jmp	__aFFaldiv
__aldiv endp

	else	;FAR_DATA

extrn	__aFNaldiv:far
__aldiv	proc	far
	jmp	__aFNaldiv
__aldiv	endp

	endif	;FAR_DATA

else	;FAR_CODE

extrn	__aNldiv:near
__ldiv	proc	near
	jmp	__aNldiv
__ldiv	endp

	if FAR_DATA eq TRUE

extrn	__aNFaldiv:near
__aldiv	proc	near
	jmp	__aNFaldiv
__aldiv endp

	else	;FAR_DATA

extrn	__aNNaldiv:near
__aldiv	proc	near
	jmp	__aNNaldiv
__aldiv	endp

	endif	;FAR_DATA

endif	;FAR_CODE

_TEXT	ends
	end


+ARCHIVE+ _lmul.asm      886 10/20/87 14:20:06
; _lmul.asm - MSC compatible long multiply entry point
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.

	title	__lmul

	include	prologue.ah

public	__lmul
public	__almul

_TEXT	segment
assume	cs:_TEXT,ds:DGROUP

if FAR_CODE eq TRUE

extrn	__aFlmul:far
__lmul	proc	far
	jmp 	__aFlmul
__lmul	endp

	if FAR_DATA eq TRUE

extrn	__aFFalmul:far
__almul	proc	far
	jmp	__aFFalmul
__almul endp

	else	;FAR_DATA

extrn	__aFNalmul:far
__almul	proc	far
	jmp	__aFNalmul
__almul	endp

	endif	;FAR_DATA

else	;FAR_CODE

extrn	__aNlmul:near
__lmul	proc	near
	jmp	__aNlmul
__lmul	endp

	if FAR_DATA eq TRUE

extrn	__aNFalmul:near
__almul	proc	near
	jmp	__aNFalmul
__almul endp

	else	;FAR_DATA

extrn	__aNNalmul:near
__almul	proc	near
	jmp	__aNNalmul
__almul	endp

	endif	;FAR_DATA

endif	;FAR_CODE

_TEXT	ends
	end


+ARCHIVE+ _lrem.asm      891 10/20/87 14:21:04
; _lrem.asm - MSC compatible long modulo divide entry point
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.

	title	__lrem

	include	prologue.ah

public	__lrem
public	__alrem

_TEXT	segment
assume	cs:_TEXT,ds:DGROUP

if FAR_CODE eq TRUE

extrn	__aFlrem:far
__lrem	proc	far
	jmp 	__aFlrem
__lrem	endp

	if FAR_DATA eq TRUE

extrn	__aFFalrem:far
__alrem	proc	far
	jmp	__aFFalrem
__alrem endp

	else	;FAR_DATA

extrn	__aFNalrem:far
__alrem	proc	far
	jmp	__aFNalrem
__alrem	endp

	endif	;FAR_DATA

else	;FAR_CODE

extrn	__aNlrem:near
__lrem	proc	near
	jmp	__aNlrem
__lrem	endp

	if FAR_DATA eq TRUE

extrn	__aNFalrem:near
__alrem	proc	near
	jmp	__aNFalrem
__alrem endp

	else	;FAR_DATA

extrn	__aNNalrem:near
__alrem	proc	near
	jmp	__aNNalrem
__alrem	endp

	endif	;FAR_DATA

endif	;FAR_CODE

_TEXT	ends
	end


+ARCHIVE+ _lshl.asm      888 10/20/87 14:21:44
; _lshl.asm - MSC compatible long shift left entry point
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.

	title	__lshl

	include	prologue.ah

public	__lshl
public	__alshl

_TEXT	segment
assume	cs:_TEXT,ds:DGROUP

if FAR_CODE eq TRUE

extrn	__aFlshl:far
__lshl	proc	far
	jmp 	__aFlshl
__lshl	endp

	if FAR_DATA eq TRUE

extrn	__aFFalshl:far
__alshl	proc	far
	jmp	__aFFalshl
__alshl endp

	else	;FAR_DATA

extrn	__aFNalshl:far
__alshl	proc	far
	jmp	__aFNalshl
__alshl	endp

	endif	;FAR_DATA

else	;FAR_CODE

extrn	__aNlshl:near
__lshl	proc	near
	jmp	__aNlshl
__lshl	endp

	if FAR_DATA eq TRUE

extrn	__aNFalshl:near
__alshl	proc	near
	jmp	__aNFalshl
__alshl endp

	else	;FAR_DATA

extrn	__aNNalshl:near
__alshl	proc	near
	jmp	__aNNalshl
__alshl	endp

	endif	;FAR_DATA

endif	;FAR_CODE

_TEXT	ends
	end


+ARCHIVE+ _lshr.asm      889 10/20/87 14:22:22
; _lshr.asm - MSC compatible long shift right entry point
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.

	title	__lshr

	include	prologue.ah

public	__lshr
public	__alshr

_TEXT	segment
assume	cs:_TEXT,ds:DGROUP

if FAR_CODE eq TRUE

extrn	__aFlshr:far
__lshr	proc	far
	jmp 	__aFlshr
__lshr	endp

	if FAR_DATA eq TRUE

extrn	__aFFalshr:far
__alshr	proc	far
	jmp	__aFFalshr
__alshr endp

	else	;FAR_DATA

extrn	__aFNalshr:far
__alshr	proc	far
	jmp	__aFNalshr
__alshr	endp

	endif	;FAR_DATA

else	;FAR_CODE

extrn	__aNlshr:near
__lshr	proc	near
	jmp	__aNlshr
__lshr	endp

	if FAR_DATA eq TRUE

extrn	__aNFalshr:near
__alshr	proc	near
	jmp	__aNFalshr
__alshr endp

	else	;FAR_DATA

extrn	__aNNalshr:near
__alshr	proc	near
	jmp	__aNNalshr
__alshr	endp

	endif	;FAR_DATA

endif	;FAR_CODE

_TEXT	ends
	end


+ARCHIVE+ cabs.c         737 10/09/87 17:44:24
/*  cabs.c - absolute value of a complex number
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,28-apr-86,new function"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,9-oct-87,hack on overhead"
#endif

#include <float.h>
#include <math.h>
#include <_math.h>

double cabs(z)
struct complex z;
{
  extern double cabsres;
  register int _temp;
  struct exception exc;

  _clear87();
  _cabs(z.x, z.y);
  if((_temp=status87())&0x80){
    exc.name="cabs";
    exc.arg1=z.x;
    exc.arg2=z.y;
    exc.retval=cabsres;
    _temp&=0x2F;
    exc.type=_err_map(_temp);
    if(matherr(&exc)) cabsres=exc.retval;
  }
  return cabsres;
}
+ARCHIVE+ cgets.c        369 12/22/86 12:30:58
/*  cgets.c - console string input
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,14-may-86,new function"
#pragma REVISED "nlp,21-nov-86,use bdos"
#endif

#include <dos.h>

char *cgets(buffer)
char *buffer;
{

  bdos(0x0a,buffer);
  *(buffer+2+(unsigned)buffer[1])=0;
  return buffer+2;
}
+ARCHIVE+ cprintf.c      587  2/25/87 17:39:08
/*  cprintf.c - printf to the console
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-may-86,new function"
#pragma REVISED "zap,4-jun-86,registers"
#pragma REVISED "nlp,21-nov-86,use bdos(2)"
#endif

#include <stdarg.h>

int cprintf(format)
char *format;
{
  va_list ap;
  char buffer[512];
  register int i;
  register char *cp;

  va_start(ap,format);
  i=vsprintf(buffer,format,ap);
  va_end(ap);
  for(cp = buffer; *cp; ++cp) { 
	if(*cp == '\n')bdos(2,'\r');
	bdos(2,*cp);
  }
  return i;
}
+ARCHIVE+ cputs.c        506  2/06/87 11:33:24
/*  cputs.c - console string output
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-may-86,new function"
#pragma REVISED "nlp,21-nov-86,use bdos(2)"
#pragma REVISED "zap,6-feb-87,use bdos(6)"
#endif

#include <dos.h>

void cputs(buffer)
char *buffer;
{
  register char *cp;

  for(cp=buffer;*cp;++cp) {
	 if(*cp == '\n') bdos(6,'\r');  /* ignore compiler warning */
	 bdos(6,*cp);  /* ignore compiler warning */
  }
}
+ARCHIVE+ fprintf.c      573 12/22/86 13:15:24
/* fprintf - formatted print to a stream
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#define REVISED "zap,2-jul-85,_doprnt() replaces _fmtout(), add ANSI flags"
#pragma REVISED "zap,25-jul-85,add this comment and copyright"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <stdio.h>
#include <stdarg.h>

int fprintf(stream, control)
FILE *stream;
char *control;
{
  va_list  args;
  register int i;

  va_start(args,control);
  i=_doprnt(control,&args,stream);
  va_end(args);
  return i;
}
+ARCHIVE+ fscanf.c       523 12/22/86 12:32:42
/* fscanf - read input from a file under format conversion
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-jul-85,rewrite to run with _doscan and stdarg.h"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <stdio.h>
#include <stdarg.h>

fscanf(stream,format)
FILE *stream;
unsigned char *format;
{
  register int i;
  va_list args;

  va_start(args,format);
  i=_doscan(format,&args,stream);
  va_end(args);
  return(i);
}
+ARCHIVE+ getch.c        319 12/22/86 12:33:04
/*  getch.c - read a char from the console
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-may-86,new function"
#endif

#include <dos.h>

int getch()
{
  struct regval reg;

  reg.ax=0x0800;
  sysint21(&reg,&reg);
  return reg.ax&0xff;
}
+ARCHIVE+ getche.c       321 12/22/86 12:33:08
/*  getche.c - read a char from the console
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-may-86,new function"
#endif

#include <dos.h>

int getche()
{
  struct regval reg;

  reg.ax=0x0700;
  sysint21(&reg,&reg);
  return reg.ax&0xff;
}
+ARCHIVE+ hypot.c        737 10/09/87 17:43:00
/*  hypot.c - get the hypotenuse
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,28-apr-86,new function"
#pragma REVISED "zap,10-sep-86,matherr()"
#pragma REVISED "zap,10-jul-87,_math.h"
#pragma REVISED "zap,9-oct-87,hack on overhead"
#endif

#include <float.h>
#include <math.h>
#include <_math.h>

extern double cabsres;

double hypot(x, y)
double x, y;
{
  register _temp;
  struct exception exc;
  
  _clear87();
  _cabs(x,y);

  if((_temp=_status87())&0x80){
    exc.name="hypot";
    exc.arg1=x;
    exc.arg2=y;
    exc.retval=cabsres;
    exc.type=_err_map(_temp);
    if(matherr(&exc)) cabsres=exc.retval;
  }
  return cabsres;
}
+ARCHIVE+ inp.c          221 12/22/86 12:33:42
/*  inp.c - inportb
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-apr-86,new function"
#endif

inp(port)
int port;
{
  return inportb(port);
}
+ARCHIVE+ int86.c        710  6/19/87  9:47:56
/*  int86.c - sysint()
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,14-may-86,new function"
#pragma REVISED "zap,19-jun-87,struct defs from dos.h"
#endif

#include <dos.h>

int int86(vec, inreg, outreg)
int vec;
union REGS *inreg, *outreg;
{
  struct regval regs;

  regs.ax=inreg->x.ax;
  regs.bx=inreg->x.bx;
  regs.cx=inreg->x.cx;
  regs.dx=inreg->x.dx;
  regs.si=inreg->x.si;
  regs.di=inreg->x.di;
  outreg->x.cflag=sysint(vec, &regs, &regs);
  outreg->x.ax=regs.ax;
  outreg->x.bx=regs.bx;
  outreg->x.cx=regs.cx;
  outreg->x.dx=regs.dx;
  outreg->x.si=regs.si;
  outreg->x.di=regs.di;
  return regs.ax;
}
+ARCHIVE+ int86x.c       783  6/19/87  9:49:32
/*  int86x.c - sysint()
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,14-may-86,new function"
#pragma REVISED "zap,19-jun-87,struct defs from dos.h"
#endif

#include <dos.h>

int int86x(vec, inreg, outreg, sreg)
int vec;
union REGS *inreg, *outreg;
struct SREGS *sreg;
{
  struct regval regs;

  regs.ax=inreg->x.ax;
  regs.bx=inreg->x.bx;
  regs.cx=inreg->x.cx;
  regs.dx=inreg->x.dx;
  regs.si=inreg->x.si;
  regs.di=inreg->x.di;
  regs.es=sreg->es;
  regs.ds=sreg->ds;
  outreg->x.cflag=sysint(vec, &regs, &regs);
  outreg->x.ax=regs.ax;
  outreg->x.bx=regs.bx;
  outreg->x.cx=regs.cx;
  outreg->x.dx=regs.dx;
  outreg->x.si=regs.si;
  outreg->x.di=regs.di;
  return regs.ax;
}

+ARCHIVE+ intdos.c       698  6/19/87  9:50:28
/*  intdos.c - sysint21()
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,14-may-86,new function"
#pragma REVISED "zap,19-jun-87,struct defs from dos.h"
#endif

#include <dos.h>

int intdos(inreg, outreg)
union REGS *inreg, *outreg;
{
  struct regval regs;

  regs.ax=inreg->x.ax;
  regs.bx=inreg->x.bx;
  regs.cx=inreg->x.cx;
  regs.dx=inreg->x.dx;
  regs.si=inreg->x.si;
  regs.di=inreg->x.di;
  outreg->x.cflag=sysint21(&regs, &regs);
  outreg->x.ax=regs.ax;
  outreg->x.bx=regs.bx;
  outreg->x.cx=regs.cx;
  outreg->x.dx=regs.dx;
  outreg->x.si=regs.si;
  outreg->x.di=regs.di;
  return regs.ax;
}

+ARCHIVE+ intdosx.c      769  6/19/87  9:51:38
/*  intdosx.c - sysint21()
**  Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,14-may-86,new function"
#pragma REVISED "zap,19-jun-87,struct defs from dos.h"
#endif

#include <dos.h>

int intdosx(inreg, outreg, sreg)
union REGS *inreg, *outreg;
struct SREGS *sreg;
{
  struct regval regs;

  regs.ax=inreg->x.ax;
  regs.bx=inreg->x.bx;
  regs.cx=inreg->x.cx;
  regs.dx=inreg->x.dx;
  regs.si=inreg->x.si;
  regs.di=inreg->x.di;
  regs.es=sreg->es;
  regs.ds=sreg->ds;
  outreg->x.cflag=sysint21(&regs, &regs);
  outreg->x.ax=regs.ax;
  outreg->x.bx=regs.bx;
  outreg->x.cx=regs.cx;
  outreg->x.dx=regs.dx;
  outreg->x.si=regs.si;
  outreg->x.di=regs.di;
  return regs.ax;
}

+ARCHIVE+ movedata.c     296 12/22/86 12:35:58
/*  movedata.c - movblock()
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-apr-86,new function"
#endif

movedata(sseg,soff,dseg,doff,count)
unsigned sseg,soff,dseg,doff,count;
{
  movblock(soff,sseg,doff,dseg,count);
}
+ARCHIVE+ outp.c         247 12/22/86 12:36:06
/*  outp.c - outportb()
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-apr-86,new function"
#endif

outp(port,value)
int port, value;
{
  return outportb(port, value);
}
+ARCHIVE+ printf.c       588 12/22/86 12:36:28
/* printf - print to standard output
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,add this comment and copyright"
#pragma REVISED "zap,17-jun-85,_doprnt() replaces _fmtout(), add ANSI flags"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <stdio.h>
#include <stdarg.h>

int printf(control)
unsigned char *control;		/* the format control string */
{
  va_list  args;
  register int i;

  va_start(args,control);
  i=_doprnt(control,&args,stdout);
  va_end(args);
  return i;
}
+ARCHIVE+ putch.c        313 12/22/86 12:36:44
/*  putch.c - write a char to the console
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-may-86,new function"
#endif

#include <dos.h>

putch(c)
int c;
{
  struct regval reg;

  reg.ax=0x0200;
  reg.dx=c;
  sysint21(&reg,&reg);
}
+ARCHIVE+ scanf.c        494 12/22/86 12:37:34
/* scanf - read input under format control from stdin
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-jul-85,rewrite to run with _doscan and stdarg.h"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <stdio.h>
#include <stdarg.h>

scanf(format)
unsigned char *format;
{
  va_list args;
  register int i;

  va_start(args,format);
  i=_doscan(format,&args,stdin);
  va_end(args);
  return(i);
}
+ARCHIVE+ sprintf.c      801 10/22/87 16:38:28
/* sprintf - formatted print to memory
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,2-jul-85,_doprnt() replaces _fmtout(), add ANSI flags"
#pragma REVISED "zap,25-jul-85,add this comment and copyright"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <stdio.h>
#include <stdarg.h>
#include <fileio3.h>

sprintf(string,format)
char *string;
char *format;  /* the format control string */
{
  va_list  args;
  FILE file;
  register int i;

  file._ptr=string;
  file._base=string;
  file._cnt=0x7fff;		/* reset the length */
  file._flag=_IOWRT;
  file._fd=1;
  va_start(args,format);
  i=_doprnt(format,&args,&file);
  va_end(args);
  string[i]=NUL;  /* terminate the buffer */
  return i;
}
+ARCHIVE+ sscanf.c       747 12/22/86 12:38:22
/* sscanf - read a formatted string in memory
** Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,25-jul-85,add this comment and copyright"
#pragma REVISED "zap,31-oct-85,new FILE definition"
#pragma REVISED "zap,4-jun-86,registers"
#endif

#include <stdio.h>
#include <stdarg.h>
#include <fileio3.h>

int sscanf(string,format)
unsigned char *string;		/* source of data */
unsigned char *format;		/* control string */
{
  va_list  args;
  FILE file;
  register int i;

  file._ptr=string;
  file._base=string;
  file._cnt=0x7FFF;
  file._flag=_IOREAD;
  file._fd=0;
  va_start(args,format);
  i=_doscan(format,&args,&file);
  va_end(args);
  return i;
}
+ARCHIVE+ swab.asm       547 12/22/86 12:19:00
; swab.asm - copy while swapping bytes.
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah

FUN_BEG _swab,0,<si,di>
FUN_ARG src,dp
FUN_ARG dest,dp
FUN_ARG n,word

if FAR_DATA eq TRUE
	push	ds
	les	si, src[bp]
	lds	di, dest[bp]
	mov	cx, n[bp]
else
	mov	ax, ds
	mov	es, ax
	mov	si, src[bp]
	mov	di, dest[bp]
	mov	cx, n[bp]
endif

	shr	cx, 1
LOOP:
	mov	ax, es:[si]
	mov	bh, al
	mov	bl, ah
	mov	ds:[di], bx
	add	si, 2
	add	di, 2
	loop	LOOP

FUN_LEAVE <si,di>
FUN_END _swab
end
+ARCHIVE+ tell.c         244 12/22/86 12:40:10
/*  tell.c - ltell()
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,29-apr-86,new function"
#endif

long tell(fd)
int fd;
{
  extern long ltell();
  return ltell(fd);
}
+ARCHIVE+ vfprintf.c     386 12/22/86 12:40:46
/* vfprintf - Formatted output from a va_list to a file.
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,5-dec-86,creation - true function"
#endif

#include <stdio.h>
#include <stdarg.h>

int vfprintf(stream,format,args)
FILE  *stream;
char  *format;
va_list  args;
{
  return _doprnt(format,&args,stream);
}
+ARCHIVE+ vprintf.c      352 10/29/87 10:14:28
/* vprintf - Formatted output from a va_list.
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,22-oct-87,creation - true function"
#endif

#include <stdio.h>
#include <stdarg.h>

int vprintf(format,args)
char  *format;
va_list  args;
{
  return _doprnt(format,&args,stdout);
}
+ARCHIVE+ vsprintf.c     786 10/22/87 16:38:04
/* vsprintf - print to memory
** Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#define REVISED "zap,22-jul-85,new function"
#pragma REVISED "zap,25-jul-85,add this comment and copyright"
#pragma REVISED "zap,31-oct-85,new FILE definition"
#pragma REVISED "zap,22-oct-87,add NUL to end of string"
#endif
#include <stdio.h>
#include <stdarg.h>
#include <fileio3.h>

int vsprintf(s,format,arg)
char *s;  /* destination pointer */
char *format;  /* format control string */
va_list arg;
{
  FILE file;
  register int i;

  file._ptr=s;
  file._base=s;
  file._cnt=0x7fff;		/* reset the length */
  file._flag=_IOWRT;
  file._fd=1;
  i=_doprnt(format,&arg,&file);
  s[i]=NUL;  /* only one 'L' !!! */
  return i;
}
