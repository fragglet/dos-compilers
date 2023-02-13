+ARCHIVE+ _fprntxx.c    5075 11/17/87 14:02:48
/* _fprntxx - floating point support for _doprnt()
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,15-jan-87,creation - carved from _doprnt.c"
#pragma REVISED "zap,26-jan-87,models"
#pragma REVISED "zap,18-feb-87,make prototypes exact"
#pragma REVISED "nlp,26-feb-87,register"
#pragma REVISED "zap,7-jul-87,all models from one source file"
#pragma REVISED "zap,23-sep-87,dformat - bump exponent when rounding negs"
#pragma REVISED "ahm,23-oct-87,leftadj "
#pragma REVISED "ahm,9-nov-87,case 'g' & 'G' and alternate form - ok"
#pragma REVISED "ahm,17-nov-87,no printpad() required, register"
#endif

#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>

extern int _dtos(double, char *);
static char *_dformat(char *, char *, int, int *);

static char_count=0;


static void near printchar(c,s)
int c;
FILE *s;
{
  char_count++;
  putc(c,s);
}

/*
** Different names for different models -- good fun.
*/
#ifdef _FLAGS_As  /* small code */
#ifdef _FLAGS_An  /* near data */
int _fprntsn(
#else             /* far data */
int _fprntsf(
#endif

#else             /* large code */
#ifdef _FLAGS_An  /* near data */
int _fprntln(
#else             /* far data */
int _fprntlf(

#endif
#endif

     precisn, ap, format, width, alternate, csign, leftadj, padchar, stream)
unsigned precisn;  /* precision value */
va_list ap;        /* arg list */
char format;       /* control string */
unsigned width;    /* field width */
unsigned alternate;/* alternate form, yes or no */
char csign;        /* sign to be printed */
unsigned leftadj;  /* left or right justified in the field */
unsigned padchar;  /* pad character */
FILE *stream;      /* output stream */
{
  int exponent, gflag;
  register unsigned length;
  register int temp;
  char bcd_buf[350],*cp;
  int old_count;

  old_count=char_count;  /* reentrance */
  char_count=0;
  memset(bcd_buf,0,30);
  gflag=(format=='g') || (format=='G');

  exponent=_dtos(va_arg(ap,double),&bcd_buf[1]);
  cp=_dformat(&format,&bcd_buf[1],precisn,&exponent);
  if(*cp=='-'){
    cp++;
    csign='-';
  }

  if(format=='f'){
    if (gflag && (!alternate)) {
      if ((length=exponent+precisn)>0)  
         for(;*(cp+length)=='0'&& precisn;--precisn,--length);
    }
    length=(exponent>0?exponent:0)+1+precisn;  /* int + fract */
    if(csign) length++;                       /* sign */
    if(precisn || alternate) ++length;  /* decimal point */
    if(!leftadj) for(;width>length;length++) printchar(padchar,stream);
    if(csign) printchar(csign,stream);
    ++exponent;
    if(exponent<=0) printchar('0',stream);
    else for(;exponent;--exponent) printchar(*cp++,stream);

    if(alternate){
      if(!precisn) printchar('.',stream);
    }
    if(precisn){
      printchar('.',stream);
      while(exponent<0 && precisn){
        precisn--;
        exponent++;
        printchar('0',stream);
      }
      while(precisn--) printchar(*cp++,stream);
    }
    if(leftadj) for(;width>length;length++) printchar(padchar,stream);
  } else {           /* format is 'e' or 'E' */
    length=4;                  /* xExx */
    if(exponent<0) ++length;     /* exponent sign */
    length+=precisn;
    if(csign) ++length;                           /* sign */
    if(abs(exponent)>99) ++length;  /* 3-digit exp */
    if (gflag && (!alternate))  for(;*(cp+precisn)=='0' && precisn;--precisn,--length);
    if(precisn || alternate) ++length;  /* decimal point */
    if(!leftadj) for(;width>length;length++) printchar(padchar,stream);
    if(csign) printchar(csign,stream);

    printchar(*cp++,stream);
    if(alternate){
      if(!precisn) printchar('.',stream);
    }
    if(precisn)printchar('.',stream);
    else precisn=0;
    while(precisn--) printchar(*cp++,stream);
    printchar(format,stream);
    temp=itoa(exponent,bcd_buf);
    cp=bcd_buf;
    if(*cp=='-'){
      printchar(*cp++,stream);
      temp--;
    }
    if(temp<2) printchar('0',stream);
    while(*cp) printchar(*cp++,stream);
    if(leftadj) for(;width>length;length++) printchar(padchar,stream);
  }

  temp=char_count;
  char_count=old_count;  /* re-entrance */
  return temp;
}

static char *_dformat(cc,buff,prec,exp)
register char *cc;  /* conversion character */
char *buff;  /* BCD string buffer */
register int prec;  /* precision value */
int *exp;  /* exponent */
{
  int i;

  if(tolower(*cc)=='g'){
    if(*exp>=-4 && *exp<=prec) *cc='f';
    else if(isupper(*cc)) *cc='E';
    else *cc='e';
  }

  if(*cc=='f') prec+=*exp;
  prec++;

  if(*buff=='-') prec++;
  if (prec>=0) {
     i=buff[prec]+5;
     while(!isdigit(i) && prec>0){
        buff[prec]-=10;
        i=++buff[--prec];
     }
     if(!isdigit(i)){
       buff--;
       if(buff[1]=='-'+1){
         buff[1]='1';
         *buff='-';
       } else {
         buff[1]='0';
         *buff='1';
       }
       (*exp)++;
     }
  }

  return(buff);
}
+ARCHIVE+ _fscanxx.c    3058 11/17/87 11:56:06
/* _fscanxx - floating point support for _doscan()
** Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,16-jan-87,carved out of _doscan"
#pragma REVISED "zap,26-jan-87,models"
#pragma REVISED "zap,7-jul-87,all models from one source file"
#pragma REVISED "zap,22-oct-87,was reading an extra character"
#pragma REVISED "ahm,26-oct-87, do not unread_char, if EOF; char c changed to int c"
#pragma REVISED "ahm,27-oct-87, churn out white spaces in _doscan, not here"
#pragma REVISED "ahm,5-nov-87,was allowing first invalid character"
#pragma REVISED "ahm,17-nov-87,include float.h for FLT_MAX"
#endif

#define NUMFIELD_WIDTH 349

#include <stdio.h>
#include <float.h>
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

static int num_read=0;


static int near read_char(str)
FILE *str;
{
  ++num_read;
  return getc(str);
}

static void near unread_char(c,str)
int c;
FILE *str;
{
  --num_read;
  if (c!=EOF)  ungetc(c,str);
}


static int near _str_scan(c,b)
register int c;
register char *b;
{
  while(*b!=0){
    if(c==*b)return(1);
    ++b;
  }
  return(0);
}


/*
** Different names for different memory models -- good fun.
*/
#ifdef _FLAGS_As  /* small code */
#ifdef _FLAGS_An  /* near data */
int _fscansn(stream,longflg,ap,suppress)
#else             /* far data */
int _fscansf(stream,longflg,ap,suppress)
#endif

#else             /* large code */
#ifdef _FLAGS_An  /* near data */
int _fscanln(stream,longflg,ap,suppress)
#else             /* far data */
int _fscanlf(stream,longflg,ap,suppress)

#endif
#endif

register FILE *stream;
unsigned longflg;
va_list *ap;
unsigned suppress;
{
  register int c;
  int sign;
  char *bptr,buffer[350];
  float f;
  double d;

  num_read=0;

  c=read_char(stream);
  if(sign=(c=='-')) c=read_char(stream);
  bptr=buffer;
  while(isdigit(c)){
    *bptr++=c;
    c=read_char(stream);
  }
  if(c=='.'){
    *bptr++='.';
    c=read_char(stream);
    while(isdigit(c)){
      *bptr++=c;
      c=read_char(stream);
    }
  }
  if(c=='e' || c=='E'){
    *bptr++='e';
    if((c=read_char(stream))=='-') *bptr++='-';
    else unread_char(c,stream);
    c=read_char(stream);
    if (!isdigit(c)) {
       unread_char(c,stream);
       return 0;
    } else {
       while(isdigit(c)){
         *bptr++=c;
         c=read_char(stream);
       }
    } 
  }
  unread_char(c,stream);
  if(bptr==buffer) return 0;

  *bptr=0;
  bptr=va_arg(*ap,char *);
  if(!suppress){
    d=strtod(buffer,NULL);
    if(sign)d=-d;
    if(!longflg){
      if(d>FLT_MAX)d=FLT_MAX;
      f=(float)d;
      *((float *)bptr)=f;
    } else *((double *)bptr)=d;
  }

  return num_read;
}
