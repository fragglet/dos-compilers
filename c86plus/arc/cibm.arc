+ARCHIVE+ com_getc.asm   443  2/09/87 15:45:34
; com_getc - wait until a char is ready and read it
; Comyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

EXTERN _com_rdy,cp

FUN_BEG _com_getc,0,<si,di>
FUN_ARG channel,2
not_ready:
	push	channel[bp]	; push comm number
	call	_com_rdy
	add	sp,2
	or	ax,ax
	jz	not_ready	; not yet
ready:
	mov	dx,channel[bp]
	mov	ax,0200h
	int	14h
	xor	ah,ah
FUN_LEAVE <si,di>
FUN_END _com_getc

end

+ARCHIVE+ com_putc.asm   405  2/09/87 14:34:30
; com_putc - send a character to the communications channel
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _com_putc,0,<si,di>
FUN_ARG channel,2
FUN_ARG char,2
	mov	dx, channel[bp]	; get comm channel number
	mov	ax, char[bp]	; get character
	mov	ah, 1		; request transmit
	int	14h		; xmit it!
FUN_LEAVE <si,di>
FUN_END _com_putc

end


+ARCHIVE+ com_rdy.asm    355  2/09/87 14:34:46
; com_rdy - is there a character ready?
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _com_rdy,0,<si,di>
FUN_ARG channel,2
	mov	dx,channel[bp]
	mov	ax,0300h
	int	14h
	test	ah,1
	jz	not_ready
	mov	ax,1
FUN_LEAVE <si,di>

not_ready:
	xor	ax,ax
FUN_LEAVE <si,di>
FUN_END _com_rdy

end
+ARCHIVE+ com_rst.c      768  2/25/87 17:34:00
/*  comyrst.c - set communication parameters for channel
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-apr-86,add header, copyright"
#endif

unsigned int com_rst(channel,baudrate,parity,stopbits,wordlen)
unsigned int channel;	/* 0 = COM1, 1 = COM2 */
unsigned int baudrate;	/* 7 = 9600 baud */
unsigned int parity;	/* 0 = no parity */
unsigned int stopbits;	/* 0 = 1 stop bit */
unsigned int wordlen;	/* 3 = 8 bits */
{
  struct { unsigned int ax,bx,cx,dx,si,di,ds,es; }  srv;

  srv.ax = ((baudrate & 0x7) << 5) | 
	      ((parity & 0x3) << 3) | 
	      ((stopbits & 0x1) << 2) |
	      (wordlen & 0x3);
  srv.dx = channel;
  sysint(0x14,&srv,&srv);
  return srv.ax;
}




+ARCHIVE+ com_stat.asm   284  2/09/87 14:34:58
; com_stat - return communication line status
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _com_stat,0,<si,di>
FUN_ARG channel,2
	mov	dx, channel[bp]
	mov	ax, 0300h
	int	14h
FUN_LEAVE <si,di>
FUN_END _com_stat

end

+ARCHIVE+ crt_cls.asm    447  7/06/87 14:01:28
; crt_cls - clear screen for IBMPC standard monitor
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

EXTERN  _crt_home,cp

FUN_BEG _crt_cls,0,<>
	mov	ax,0f00h
	push	bp
	int	010h
	pop	bp
	mov	bh,07
	cmp	al,03
	jle	bh_set
	cmp	al,07
	je	bh_set
	xor	bh,bh
bh_set: mov	ax,0600h
	xor	cx,cx
	mov	dx,184FH
	push	bp
	int	010h
	pop	bp
	call	_crt_home
FUN_LEAVE <>
FUN_END _crt_cls

end
+ARCHIVE+ crt_gmod.asm   256  7/06/87 14:01:48
; crt_gmod - get crt mode
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _crt_gmod,0,<si,di>
	mov	ax, 0f00h
	push	bp
	int	10h
	pop	bp
	xor	ah,ah
FUN_LEAVE <si,di>
FUN_END _crt_gmod

end


+ARCHIVE+ crt_grcp.asm   337  7/06/87 14:02:58
; crt_grcp - Obtains present cursor position & returns it in ax -
;  Row in ah, col in al
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _crt_grcp,0,<si,di>
	mov	ax, 0300h
	xor	bx, bx
	push	bp
	int	10h
	pop	bp
	mov     ax, dx
FUN_LEAVE <si,di>
FUN_END _crt_grcp

end

+ARCHIVE+ crt_home.asm   278  7/06/87 14:03:22
; crt_home - position cursor to 1,1
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _crt_home,0,<si,di>
	mov	ax, 0200h
	xor	bx, bx
	xor	dx, dx
	push	bp
	int	10h
	pop	bp
FUN_LEAVE <si,di>
FUN_END _crt_home

end

+ARCHIVE+ crt_line.c    1415 10/21/87 14:55:38
/* crtyline.c - draw a line in graphics mode on color monitor
** Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-apr-86,add header, copyright"
#pragma REVISED "zap,15-oct-87,remove iswap()"
#endif

void crt_line(x1, y1, x2, y2, color)
int x1, y1, x2, y2, color;
{
  struct regval{int ax,bx,cx,dx,si,di,ds,es;}srv,rrv;
  int dx;
  int dy;
  int xinc;
  int yinc;
  int tv;
  int sflag;
  int a;
  int b;

  srv.ax=0x0C00|(color&0xf);	/* set to write dot and set color */ 
  dx=x2-x1;	/* delta x and direction increment */
  xinc=1;
  if(dx<0){
    xinc=-1;	/* negative increment */
    dx=x1-x2;	/* make delta x positive */
  }
  dy=y2-y1;	/* delta y and direction increment */
  yinc=1;
  if(dy<0){
    yinc=-1;	/* negative increment */
    dy=y1-y2;	/* make delta y positive */
  }
  sflag=0;
  if(dy>dx){
    sflag=1;
    a=dy;
    dy=dx;
    dx=a;
  }
  srv.cx=x1;	/* coordinates of first point */
  srv.dx=y1;
  tv=(dy<<1)-dx;	/* test variable for the move */
  a=dy<<1;		/* factor to add after each horizontal move */
  b=(dy-dx)<<1;		/* factor to add after each vertical move */
  for(dx++;dx;dx--){
    sysint(0x10,&srv,&rrv);
    if(tv<0)tv+=a;
    else{
      tv+=b;
      if(sflag)srv.cx+=xinc;
      else srv.dx+=yinc;
    }
    if(sflag)srv.dx+=yinc;
    else srv.cx+=xinc;
  }
}

+ARCHIVE+ crt_mode.asm   304  7/06/87 14:03:44
; crt_mode - set the crt_mode
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _crt_mode,0,<si,di>
FUN_ARG mode,2
	mov	ax, mode[bp]
;	and	ax, 7	; not with extended card
	push	bp
	int	10h	
	pop	bp
FUN_LEAVE <si,di>
FUN_END _crt_mode

end

+ARCHIVE+ crt_putc.asm   638  7/06/87 14:04:06
; crt_putc - Writes character to screen at current cursor position
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

; Some attributes that work for IBM/PC(mono):
; 0  -  Blank           ||  1  -  Underline          ||    2 - Normal 
; 10 -	 HIgh intensity	|| 25  -  High int/underline ||  112 - Reverse video
; 129 - Underline/blink 			

include prologue.ah

FUN_BEG _crt_putc,0,<si,di>
FUN_ARG character,2
FUN_ARG attribute,2
	mov	ah, 09h
	mov	al, character[bp]
	mov	bl, attribute[bp]
        xor     bh, bh 
	mov     cx, 1 
	push	bp
	int	10h
	pop	bp
FUN_LEAVE <si,di>
FUN_END _crt_putc

end
+ARCHIVE+ crt_rdot.asm   414  7/06/87 14:04:30
; crt_rdot - read a dot on the graphics monitor and return color
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _crt_rdot,0,<si,di>
FUN_ARG row,2
FUN_ARG col,2
        mov     ah, 13
        mov     cx, col[bp]
        mov     dx, row[bp]
	push	bp
        int     10h
	pop	bp
        xor     ah, ah
FUN_LEAVE <si,di>
FUN_END _crt_rdot

end


+ARCHIVE+ crt_roll.c     456 12/22/86 12:31:26
/* crtyroll.c - scroll an area of the screen n lines
** Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-apr-86,add header, copyright"
#endif

crt_roll(top, bot, lef, rit, n)
int top, bot, lef, rit, n;
{
  struct { int ax,bx,cx,dx,si,di,ds,es; } srv;

  srv.cx=(top<<8)+lef;
  srv.dx=(bot<<8)+rit;
  srv.ax=(n<0) ? 0x700-n : 0x600+n ;
  srv.bx=0x700;
  sysint(0x10,&srv,&srv);
}
+ARCHIVE+ crt_srcp.asm   386  7/06/87 14:04:48
; crt_srcp - set cursor to row, column and page
; Copyright (C) 1987 Ci\omputer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _crt_srcp,0,<si,di>
FUN_ARG row,2
FUN_ARG column,2
FUN_ARG page,2
	mov	ax, 0200h
	mov	dh, row[bp]
	mov	dl, column[bp]
	mov	bh, page[bp]
	xor	bl, bl
	push	bp
	int	10h
	pop	bp
FUN_LEAVE <si,di>
FUN_END _crt_srcp

end

+ARCHIVE+ crt_wdot.asm   431  7/06/87 14:05:08
; crt_wdot - write a dot to the graphics monitor
; Copyright (C) 1987 Computer Innovations, Inc,  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _crt_wdot,0,<si,di>
FUN_ARG row,2
FUN_ARG column,2
FUN_ARG color,2
        mov     ah, 12
        mov     al, color[bp]
        mov     cx, column[bp]
        mov     dx, row[bp]
	push	bp
        int     10H
	pop	bp
FUN_LEAVE <si,di>
FUN_END _crt_wdot

end



+ARCHIVE+ key_getc.asm   278  7/06/87 14:07:00
; key_getc - wait for a key to be pressed and return it
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _key_getc,0,<si,di>
	xor	ah, ah		; ah <- 0
	int	16h		; read keyboard
FUN_LEAVE <si,di>
FUN_END _key_getc

end

+ARCHIVE+ key_scan.asm   349  2/09/87 14:46:24
; key_scan - scan keyboard
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _key_scan,0,<si,di>
	mov	ah, 1
	int	16h 		; scan keyboard
	jz	none_there	; no character available
FUN_LEAVE <si,di>

none_there:
	mov	ax, 0ffffh	; return EOF
FUN_LEAVE <si,di>
FUN_END _key_scan

end




+ARCHIVE+ key_shft.asm   323  2/09/87 14:47:56
; key_shft - wait for a key to be pressed and return it
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _key_shft,0,<si,di>
	mov	ah, 2		; get shift status
	int	16h		; read keyboard
	xor	ah,ah		; clear high byte
FUN_LEAVE <si,di>
FUN_END _key_shft

end




+ARCHIVE+ prt_busy.c     350  5/27/87 22:53:48
/*  prtybusy.c - returns 1 if the printer is busy, 0 if not
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-apr-86,add header, copyright"
#pragma REVISED "nlp,27-may-87,==0, not != 0"
#endif

prt_busy(printer)
int printer;
{
  return ((prt_stat(printer)&0x80) == 0);
}


+ARCHIVE+ prt_err.c      527 12/22/86 12:36:34
/*  prtyerr.c - is there a printer error ? 
**    return 1 if Timeout, i/o error, out of paper, 0 otherwise
**  Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
*/
#ifdef HISTORY
#pragma REVISED "zap,11-apr-86,add header, copyright"
#endif

prt_err(printer)
int printer;
{
  int stat;

  stat = prt_stat(printer);

  if((stat & 0x10) == 0)  /* not selected */
    return 1;

  if(stat & 0x29) 	/* timeout, i/o error, or paper out set */ 
    return 1;

  return 0;		/* okay */
}




+ARCHIVE+ prt_putc.asm   443  2/09/87 14:54:22
; prt_putc - print the character to the printer
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _prt_putc,0,<si,di>
FUN_ARG printer,2
FUN_ARG char,2
	mov	ax, char[bp]	; get character to print
	xor	ah, ah		; print character request
	mov	dx, printer[bp]	; get printer to use
	int	17h		; line printer interrupt
	mov	al, ah
	xor	ah, ah
FUN_LEAVE <si,di>
FUN_END _prt_putc

end

+ARCHIVE+ prt_rst.asm    383  2/09/87 14:56:06
; prt_rst - reset printer port
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _prt_rst,0,<si,di>
FUN_ARG printer,2
	mov	ah, 1		; reset printer port
	mov	dx,printer[bp]	; get printer to use
	int	17h		; line printer interrupt
	mov	al, ah		; put printer status in AL
	xor	ah, ah
FUN_LEAVE <si,di>
FUN_END _prt_rst

end
+ARCHIVE+ prt_scr.asm    230  2/09/87 14:58:20
; prt_scr - print screen to printer
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _prt_scr,0,<si,di>
	int	05h	; print screen
FUN_LEAVE <si,di>
FUN_END _prt_scr

end

+ARCHIVE+ prt_stat.asm   386  2/09/87 15:00:08
; prt_stat - return printer status
; Copyright (C) 1987 Computer Innovations, Inc  ALL RIGHTS RESERVED

include prologue.ah

FUN_BEG _prt_stat,2,<si,di>
FUN_ARG printer,2
	mov	ah, 2		; get printer status
	mov	dx,printer[bp]	; get printer to use
	int	17h		; line printer interrupt
	mov	al, ah		; move status into al
	xor	ah, ah
FUN_LEAVE <si,di>
FUN_END _prt_stat

end

