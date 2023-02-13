+ARCHIVE+ 87_arc.asm    2810  8/06/87 10:56:46
; 87_arc - inverse trig function support
; Copyright (c) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	$87_pi_2,byte	; Pi / 2
EXTERN	$87_pi_4,byte	; Pi / 4

pi_div_2	equ	qword ptr DGROUP:$87_pi_2
pi_div_4	equ	qword ptr DGROUP:$87_pi_4


_TEXT segment
	assume cs:_TEXT, ds:DGROUP
if FAR_CODE eq TRUE
$87_arc4	proc far		; X > Y 
else
$87_arc4	proc near
endif
	push	bp
	mov	bp, sp
	sub	sp, 2

	fld	st(1)			; Get Y on top of stack
	ftst				; Compare Y with zero
	fstsw	word ptr -2[bp]		; Store flags in memory variable
	fstp	st(0)			; Pop Y off of stack
	fwait 
	test	byte ptr -1[bp],41h	; Is X > Y > 0?
	fwait 
	jz	not_a_zero		; Yes, then calc ARCTAN

	fstp	st(0)			; No, then pop X and Y
	fstp	st(0)			; off stack.
	fldz				; Push a proper Zero onto 8087 stack
	jmp	done_arc4
not_a_zero:
	fpatan				; Calculate ARCTAN (Y/X)
done_arc4:
	fwait 

	mov	sp, bp
	pop	bp
	ret
$87_arc4	endp


if FAR_CODE eq TRUE
$87_arc3	proc far
else
$87_arc3	proc near
endif
	push	bp
	mov	bp, sp
	sub	sp, 2

	fcom				; Compare X to Y
	fstsw	word ptr -2[bp]		; Store Flags
	fwait
	test	byte ptr -1[bp],1	; Is X < Y?
	jz	test_for_equal		; No, then check for X = Y
	fxch				; Switch X & Y
	call	$87_arc4		; Check for  (x=0) or (y=0)
	fsubr	pi_div_2		; Pi/2 - ARCTAN
	fwait 
	jmp 	done_arc3
test_for_equal:
	test	byte ptr -1[bp],040h	; Is X = Y?
	jnz	around			; yes
	call	$87_arc4		; No.
	jmp	done_arc3
around:
	fstp	st(0)			; Pop X off stack
	fstp	st(0)			; Pop Y off stack
	fld	pi_div_4		; Load Pi/4 on 8087 stack top
	fwait 

done_arc3:
	mov	sp, bp
	pop	bp
	ret
$87_arc3 endp


if FAR_CODE eq TRUE
$87_arc2	proc far
else
$87_arc2	proc near
endif
	push	bp
	mov	bp, sp
	sub	sp, 2

	ftst				; Is X < 0?
	fstsw	word ptr -2[bp]
	fwait
	test	byte ptr -1[bp],1	; If zero bit is set, then X < 0
	jz	x_is_pos		; X is positive
	fchs				; Force X positive
	call	$87_arc3			; Check for Y > X
	fldpi				; Load Pi
	fsubrp	st(1),st		; Pi - ARCTAN
	fwait 
	jmp	done_arc2
x_is_pos:
	call	$87_arc3		; Check for Y > X

done_arc2:
	mov	sp, bp
	pop	bp
	ret
$87_arc2	endp

_TEXT ends



FUN_BEG $87_arc_y_x,2,<ds>
	fld	st(1)			; Load Y
	ftst				; Compare Y to zero
	fstsw	word ptr -2[bp]		; Store result in status word
	fstp	st(0)			; Pop Y off of stack
	fwait 
	test	byte ptr -1[bp],1	; If zeroth bit set then
					; Y is negative
	jz	y_is_positive		; Y is positive

	fxch				; Load Y
	fchs				; -  Y
	fxch				; Load X
	fchs				; - X
	call	$87_arc2		; Test for Cosine troubles
	fldpi				; Load Pi
	faddp	st(1),st		; Add Pi to ARCTAN
	fwait 
	jmp	done_arc1
y_is_positive:
	call	$87_arc2		; Test for Cosine troubles
done_arc1:
	fwait
FUN_LEAVE <ds>
FUN_END $87_arc_y_x

end

+ARCHIVE+ 87_data.asm   2295  8/05/87 13:47:06
; 87_data - floating point support (data)
; Copyright (c) 1986 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

_DATA segment
	assume ds:DGROUP

	public	$87_pi_2, $87_pi_4, $87_lrg_num, $87_max_rad
	public	$87_half, $87_sqrt_2
	public	$87_lrg_exp

;	The values for Pi/2 and Pi/4 are static for reasons of speed.
;	The necessity of dividing or scaling Pi to these useful values
;	was determined to take too long when the data space taken up was
;	miniscule.

$87_pi_2		label	qword		; Pi / 2
	db	018h,02dh,044h,054h,0fbh,021h,0f9h,03fh
$87_pi_4		label	qword		; Pi / 4
	db	018h,02dh,044h,054h,0fbh,021h,0e9h,03fh

;	$87_LRG_NUM is the largest number that can be stored in double
;	precision format for both negative and positive numbers.	
;									
;	$87_MAX_RAD is the largest radian value that can be reduced by	
;	FPREM to under Pi/4 with one pass. Thus it becomes the maximum  
;	radian value to pass to TAN, COTAN, SINe, and COSine.		

$87_lrg_num	label	qword		; 2**1022	- Very large number
	db	00h,00h,00h,00h,00h,00h,0e0h,07fh
$87_max_rad	label	qword		; 1.0e18	- Maximum Radian value
	db	00h,00h,00h,00h,065h,0cdh,0ddh,041h

; one plus and one minus epsilon are not used currently
;	$87_ONE_PLS is short for One-plus-epsilon. $87_ONE_MIN is short for 
;	One-minus-epsilon. Epsilon = 1 - (sqrt(2) / 2), or approximately
;	0.29. The log functions can be less than accurate when the	
;	argument is very close to one (1). By using FYL2XP1, the result 
;	is more accurate when the argument is between 0.71 and 1.29.	

;$87_one_pls	label	qword		; 1.29		- For log functions
;	db	0a2h,070h,03dh,0ah,0d7h,0a3h,0f4h,03fh
;$87_one_min	label	qword		; 0.71		- For log functions
;	db	0b8h,01eh,085h,0ebh,051h,0b8h,0e6h,03fh

;	$87_HALF and $87_SQRT_2 are used by the exponential functions for
;	calculating the limits of arguments for the 8087 instruction	 
;	F2MX1. $87_SQRT_2 is the 80 bit, temporary real representation	 
;	of the square root of two.					 

$87_half	label	qword		; 0.5		- For EXP and POW
	db	00h,00h,00h,00h,00h,00h,0e0h,03fh
$87_sqrt_2	label	tbyte		; SQRT(2)	- Temporary Real
	db	084h,064h,0deh,0f9h,033h
	db	0f3h,04h,0b5h,0ffh,03fh

$87_lrg_exp	dw	1023	; Largest possible exponent

_DATA ends

end

+ARCHIVE+ 87_fac.asm     321  8/07/87 17:56:22
; 87_fac - definition of the floating accumulator
; Copyright (c) 1987 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

_DATA segment
	assume ds:DGROUP

	public	__fac
	__fac	dt	?	; standard return location for doubles

	public	__ndpsw
	__ndpsw	dw	?	; place to FSTSW to
_DATA ends

end
+ARCHIVE+ 87_y2x.asm    3439  8/05/87 15:05:22
; 87_y2x - y to the x
; Copyright (c) 1986, 1987 Computer Innovations, Inc, ALL RIGHTS RESERVED

	include prologue.ah

EXTERN	_errno,word		; Storage for error variable
EXTERN	$87_lrg_num,byte	; 2**1022 - Very large number
EXTERN	$87_half,byte		; 0.5	  - For EXP and POW
EXTERN	$87_sqrt_2,byte		; SQRT(2) - Temporary Real
EXTERN	$87_lrg_exp,word	; Largest possible exponent

large_num	equ	qword ptr DGROUP:$87_lrg_num
half		equ	qword ptr DGROUP:$87_half
sqrt_2		equ	tbyte ptr DGROUP:$87_sqrt_2
ERANGE		equ	34


_TEXT segment
	assume cs:_TEXT, ds:DGROUP
if FAR_CODE eq TRUE
two_2_the_x	proc far
else
two_2_the_x	proc near
endif
	push	bp
	mov	bp, sp
	sub	sp, 2

	fld	st(0)			; Push a Copy onto 8087 stack
	fstcw	word ptr -2[bp]		; store control word
	fwait
	mov	ax,-2[bp]
	or	byte ptr -1[bp],0ch	; force any rounding to chop
	fldcw	word ptr -2[bp]		; Load in modified control word
	frndint				; Chop off fraction
	mov	-2[bp],ax 
	fldcw	word ptr -2[bp]		; Load in original control word
	fsub	st(1),st		; Convert ST(1) to fraction only
	fxch				; Switch places with st(0)
	fld	half			; Load 0.5
	fcom	st(1)			; Compare with ST(1)
	fstsw	word ptr -2[bp]		; Save flags for perusal
	fwait
	test	byte ptr -1[bp],41h	; Is the fraction larger than 0.5?
	jz	dont_sub		; No.
	test	byte ptr -1[bp],40h	; Is the fraction equal to 0.5?
	jnz	exactly_sqrt_2		; Yes, then don't subtract 0.5
	fsub	st(1),st		; Else, subtract 0.5 from fraction
dont_sub:
	fstp	st(0)			; Pop off 0.5
	f2xm1				; Calc (2^X)-1
	fld1				; Add one to result
	faddp	st(1),st
	test	byte ptr -1[bp],1	; Was this originally > 0.5?
	jz	dont_mul		; No.
	fld	sqrt_2			; Yes, then multiply result by
	fmulp	st(1),st		; SQRT(2)
	jmp	short dont_mul		; Skip around special code for
					; exactly square root of 2
exactly_sqrt_2:
	fstp	st(0)			; Pop off 0.5
	fstp	st(0)			; Pop off fraction
	fld	sqrt_2			; Load square root of two as result

dont_mul:
	fxch				; Must check scale factor for a zero
	ftst
	fstsw	word ptr -2[bp]
	fxch				; Switch them back.
	fwait 
	test	byte ptr -1[bp],40h	; If scale factor equals zero,
	jnz	dont_scale
	fscale				; Scale fraction up to correct value

dont_scale:
	fstp	st(1)			; Pop off stack leaving result at top

	mov	sp, bp
	pop	bp
	ret
two_2_the_x	endp



if FAR_CODE eq TRUE
set_exp	proc far
else
set_exp	proc near
endif
	push	bp
	mov	bp, sp
	sub	sp, 2

	fld	st(0)		; Load working copy of exponent
	ficomp	DGROUP:$87_lrg_exp  ; Compare exponent to maximum exponent
	fstsw	word ptr -2[bp] 
	fwait
	test	byte ptr -1[bp],1 ; Is ST < $87_lrg_exp?
	jnz	exp_is_ok	; Yes, then exponent is within range

	mov	DGROUP:_errno,ERANGE	; No, then set error word
	fstp	st(0)		; pop off 8087 stack
	fld	large_num	; Load in near Infinity
	jmp	done_set

exp_is_ok:
	call	two_2_the_x	; Final calculation

done_set:
	fwait 
	mov	sp, bp
	pop	bp
	ret
set_exp	endp

_TEXT ends



FUN_BEG $87_y2x,2,<ds>
	fmulp	st(1),st	; Multiply X by log base 2 of Y
	ftst			; Check for x < 0
	fstsw	word ptr -2[bp]	; Store 8087 flags
	fwait
	test	byte ptr -1[bp],1 ; Is X negative?
	jz	x_not_neg	; No.

	fchs			; Yes, then make positive
	call	set_exp		; Calculate exponent
	fld1			; Load a one for inverting result
	fdivrp	st(1),st	; 1 / (y^x)
	jmp	done

x_not_neg:
	call	set_exp		; Calculate (y^x)
done:
	fwait 
FUN_LEAVE <ds>
FUN_END $87_y2x

end
+ARCHIVE+ 87sincos.asm  2420  8/05/87 13:45:02
; 87sincos - support for trig functions
; Copyright (c) 1986, 1987 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	$87_pi_4,qword	; Pi / 4

pi_div_4	equ	DGROUP:$87_pi_4

FUN_BEG $87_sin_cos,2,<ds>	; Co-tangent, Cosine, and Sine.
				; Enter routine with radian
				; at top of 8087 stack.
	fld	DGROUP:$87_pi_4		; Push pi/4 onto stack as modulus.
	fld	st(1)			; Get copy of radian value to tos.
	fprem				; Set radian to zeroth octant.
	fstsw	word ptr -2[bp]		; Get the last three bits of quotient.
	fwait				; Wait till 8087 has stored status
	mov	ax,-2[bp]		; Must shift around some bits to get
	and	ah,43h			; an integer value result.
	ror	ah,1			; Move C0 to bit 7 position.
	shr	ax,1			; Get C1 out of AH.
	mov	cl,4
	shr	ah,cl			; Move C3 to bit 0 in AH.
	shr	ax,1			; Bump C3 out of AH.
	shr	ah,1			; Move C0 to bit 0 position.
	shl	ax,1			; Push C3 and C1 back into
	shl	ax,1			; AH.
	test	ah,1			; Odd octants get subtracted by 
					; PI/4.
	jz	normal_fptan		; If not then don't subtract from
					; Pi/4.
cos_to_sin:
	fsubr	pi_div_4		; Subtract stack top from Pi/4.
normal_fptan:
	ftst				; Must see if radian = 0.0
	fstsw	word ptr -2[bp]		;
	fwait
	test	byte ptr -1[bp],40h	; If bit is set, then zero.
	jz	compute_tangent
	fstp	st(0)			; Pop off stack
	fldz				; Load a zero (sine)
	fld1				; Load a one (cosine)
	jmp	short skip_fptan
compute_tangent:
	fptan				; Compute the tangent (sin/cos)
skip_fptan:
	cmp	ah,1			; Do the SINE and COSINE values
	je	switch_sine_cos		; require switching for correct
	cmp	ah,2			; trigonometric identities?
	je	switch_sine_cos		; Only Octants 1,2,5,and 6
	cmp	ah,5			; require this switch.
	je	switch_sine_cos
	cmp	ah,6
	jne	no_switch		; If no switch is required, then leave
switch_sine_cos:
	fxch				; Sine and cosine switch places
no_switch:
	cmp	ah,4			; Will the SINE value be negative?
	jb	no_change_sine_sign	; Yes, but the Cosine is not.
change_sine_sign:
	fld	st(1)			; Get a copy of the SINE.
	fchs				; Make this negative.
	fstp	st(2)			; Store back for the real SINE.
no_change_sine_sign:
	cmp	ah,2			; Is the cosine negative?
	jb	no_change_cosine_sign	; No.
	cmp	ah,5
	ja	no_change_cosine_sign	; No.
change_cosine_sign:
	fchs
no_change_cosine_sign:
	fwait 
FUN_LEAVE <ds>				; Cosine is on top of stack, ST(0),
FUN_END $87_sin_cos			; Sine is at ST(1).

end
+ARCHIVE+ _acos.asm     1164 10/09/87 15:00:28
; __acos - arc cosine guts
; Copyright (C) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED

EDOM		equ	33
ERANGE		equ	34
	
include prologue.ah

EXTERN	__fac,dp
EXTERN	$87_arc_y_x,cp
EXTERN	_errno,word

FUN_BEG __acos,0,<ds>
	fld	qword ptr ARG_BASE[bp]	; Load in cosine
	sub	sp,2
	fld	st(0)			; Push a copy onto 8087 stack
	fabs				; Compare with zero
	fld1				; Load a one
	fcomp				; Is arg < 1.0?
	fstsw	word ptr -2[bp]		; Save 8087 flags
	fwait
	test	byte ptr -1[bp],1
	jz	ok_to_calc_arccos	; Yes.
	mov	DGROUP:_errno,EDOM	; No, then set errno
	fstp	st(0)			; Pop stack
	fstp	st(0)
	fldz				; Load a zero
	jmp	short _acos_done

ok_to_calc_arccos:
	fmul	st,st(0)		; Square cosine value
	fld1				; Load one for trig identity
	fsubrp	st(1),st(0)		; 1 - (cos^2) = sin^2
	fsqrt				; Sine at top of stack
	fxch				; Switch sine and cosine so that
					; cosine is at top of 8087 stack
	call	$87_arc_y_x		; Calculate ARCTAN(sin/cos)

_acos_done:
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __acos
end
+ARCHIVE+ _asin.asm     1658 10/09/87 15:54:32
; __asin - arc sine guts
; Copyright (C) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED

EDOM		equ	33
ERANGE		equ	34

include prologue.ah

EXTERN	__fac,dp
EXTERN	$87_arc_y_x,cp
EXTERN	_errno,word	; Storage for error variable


_TEXT segment
	assume cs:_TEXT,ds:DGROUP
if FAR_CODE eq TRUE
__arc_sine	proc far
else
__arc_sine	proc near
endif
	push	bp
	mov	bp, sp
	sub	sp, 2

	fld1				; Load a one for test
	fcomp				; Compare sine with one.
	fstsw	word ptr -2[bp]		; Save flags
	fwait
	test	byte ptr -1[bp],1	; Is arg > 1.0?
	jz	no_sine_err		; No.
	mov	DGROUP:_errno,EDOM	; Yes, set error flag
	fstp	st(0)			; Pop arg off 8087 stack
	fldz				; Load a zero
	jmp	done_arc_sine

no_sine_err:
	fld	st(0)			; Duplicate arg	
	fmul	st,st(0)		; Square the sine
	fld1				; Load a one
	fsubrp	st(1),st(0)		; 1 - (sin^2) = cos^2
	fsqrt				; Cosine at top of 8087 stack
	call	$87_arc_y_x		; Calculate ARCTAN(sin/cos)
done_arc_sine:
	fwait

	mov	sp, bp
	pop	bp
	ret
FUN_END __arc_sine


FUN_BEG __asin,0,<ds>
	fld	qword ptr ARG_BASE[bp]	; Load sine
	sub	sp,2
	ftst				; Compare with zero
	fstsw	word ptr -2[bp]		; Save flags in 8088 memory
	fwait				
	test	byte ptr -1[bp],1	; Is Sine negative (< 0)?
	jz	sine_is_pos		; No.
	fchs				; Change to positive
	call	__arc_sine		; Calculate Arc_sine
	fchs			; Convert result to negative
	jmp	short _asin_done

sine_is_pos:
	call	__arc_sine	; Calculate Arc_sine

_asin_done:
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __asin

end
+ARCHIVE+ _atan.asm     1534  8/05/87 17:07:54
; atan and atan2 - arc tangent guts
; Copyright (c) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED
;
;	__atan2(y,x) returns as follows: 
; 
;       0.0 		if y==0.0 && x==0.0 
;       pi/2		if x==0.0 && y>0.0 
;       -pi.2		if x==0.0 && y<0.0 
;       arctan(y/x) 	else 

include prologue.ah

EXTERN	$87_arc_y_x,cp
EXTERN	__fac,dp


_TEXT segment
	assume cs:_TEXT, ds:DGROUP
if FAR_CODE eq TRUE
atan2a	proc far
else
atan2a	proc near
endif
	push	bp
	mov	sp, bp
	sub	sp, 2

	ftst	 
	fstsw	word ptr -2[bp] 
	fwait 
	test	byte ptr -1[bp],1 
	jz	xpos    	       	; atan2(v/u) = pi - atan2(v/-u), u<0 
	fchs 
        call	$87_arc_y_x
	fldpi	 
	fsubrp	st(1),st(0) 
	mov	sp, bp
	pop	bp
	ret

xpos: 
	call	$87_arc_y_x
	mov	sp, bp
	pop	bp
	ret
FUN_END atan2a


FUN_BEG __atan,2,<ds>
	fld	qword ptr ARG_BASE[bp]	; Load Double precision Tangent
	ftst				; Compare with zero
	fstsw	word ptr -2[bp]		; Save Flags for use by 8088
	fwait
	test	byte ptr -1[bp],1	; Is Tangent > 0?
	jz	positive_tan		; Yes, then skip
	fchs				; No, then make positive
	fld1				; Load a one for cosine
	call	$87_arc_y_x		; Calculate ARCTAN (tan/1)
	fchs				; Convert to negative
	jmp	short __atan_done

positive_tan:
	fld1				; Load in a 1 for cosine value
	call	$87_arc_y_x		; Calculate ARCTAN(tan/1)

__atan_done:
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __atan

end
+ARCHIVE+ _cabs.asm      443  8/05/87 17:08:10
; _cabs.asm - Take the absolute value of a complex number.
; Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.

.8087
include prologue.ah

_DATA	segment
 	cabsres	dd	0
_DATA	ends

public cabsres

FUN_BEG __cabs,0,<ds>
	fld	dword ptr ARG_BASE+8[bp]
	fld	st(0)
	fmul
	fld	dword ptr ARG_BASE+16[bp]
	fld	st(0)
	fmul
	fadd
	fsqrt
	fstp	dword ptr DGROUP:cabsres
	fwait
FUN_LEAVE <ds>
FUN_END __cabs
end
+ARCHIVE+ _ceil.asm      719  8/05/87 17:08:22
; _ceil - ceiling function guts
; Copyright (c) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	__fac,dp

FUN_BEG __ceil,2,<ds>
	fld	qword ptr ARG_BASE[bp]	; Load in argument
	fstcw	word ptr -2[bp]		; store control word
	fwait
	mov	ax,-2[bp]		; store working copy
	or	byte ptr -1[bp],08h	; force rounding to next greatest int
	fldcw	word ptr -2[bp]		; Load in modified control word
	frndint				; Chop off fraction
	mov	-2[bp],ax 
	fldcw	word ptr -2[bp]		; Load in original control word
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __ceil

end
+ARCHIVE+ _chkstk.asm   1278  1/07/87 19:39:08
; _chkstk - default stack checking for c86plus
; Copyright (C) 1986, Computer Innovations Inc, ALL RIGHTS RESERVED
	title	_chkstk

	include	prologue.ah

EXTERN	_end,word
EXTERN	__exit,cp

_DATA	segment
	public	STKHQQ
if	SET_SSDS eq TRUE
STKHQQ	dw	OFFSET DGROUP:_end+256	;for interrupt service
else
STKHQQ	dw	256			;for interrupt service
endif
_DATA	ends

_TEXT	segment
	assume	cs:_TEXT,ds:DGROUP,es:DGROUP

nostack	db	13,'Stack Overflow',10,'$'

	public	__chkstk
if	FAR_CODE eq TRUE
__chkstk proc	far
	pop	bx		;get return address
else
__chkstk proc	near
endif
	pop	cx		;other part of return address
	cli			;lock it up
	sub	sp,ax		;adjust stack
	jb	nogo		;stack underflow
if SET_DS eq TRUE
	assume	es:DGROUP
	mov	dx,DGROUP
	mov	es,dx
	cmp	sp,es:STKHQQ	;logical underflow ?
	assume	es:nothing
else
	cmp	sp,DGROUP:STKHQQ ;logical underflow ?
endif
	jb	nogo		;too bad
	sti			;back to normal
	push	cx		;painful return logic
if	FAR_CODE eq TRUE
	push	bx
endif
	ret

;	the program is going byebye

nogo:
	add	sp,ax		;set stack back
	sti
	mov	dx,offset nostack
	mov	ah,9			;rude message and die
	push	ds
	push	cs
	pop	ds
	int	21h
	pop	ds
	mov	al,0ffh			;terminal status
	push	ax
	call	__exit

FUN_END __chkstk
	end

+ARCHIVE+ _clear87.asm   261 12/22/86 12:18:22
; _clear87.asm - Clear the 8087 exception flags.
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah
.8087

FUN_BEG __clear87,2,<>
	fstsw	-2[bp]
	fwait
	fclex
	mov	ax, -2[bp]
FUN_LEAVE <>
FUN_END __clear87
end
+ARCHIVE+ _cos.asm      1671  8/05/87 17:08:44
; cos - cosine guts
; Copyright (c) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	$87_sin_cos,cp
EXTERN	__fac,dp
EXTERN	_errno,word		; Storage for error variable
EXTERN	$87_max_rad,byte	; 1.0e18 - Maximum Radian value

max_rads equ qword ptr DGROUP:$87_max_rad
EDOM	equ	33

_TEXT segment
	assume cs:_TEXT, ds:DGROUP
if FAR_CODE eq TRUE
co_sinner	proc far
else
co_sinner	proc near
endif
	push	bp
	mov	bp, sp
	sub	sp, 2

	fcom	max_rads		; Is radian greater than Maximum
	fstsw	word ptr -2[bp]		; Check status word
	fwait
	test	byte ptr -1[bp],1h	; If bit 0 in AH is set,
	jnz	rad_cosine_ok		; then good radian on stack
	jmp	trig_error		; Else, set trig error

rad_cosine_ok:
	call	$87_sin_cos		; get y,x
	fxch				; exchange y,x
	fmul	st(0),st		; square x
	fld	st(1)			; get y
	fmul	st(0),st		; square y
	faddp	st(1),st		; sum squares
	fsqrt				; now we have hypotenuse
	fdivr	st,st(1)		; compute x/h
	fstp	st(3)			; clean up stack and
	fstp	st(0)			; leave x/h on tos
	fstp	st(0)
	mov	sp, bp
	pop	bp
	ret

trig_error:
	mov	DGROUP:_errno,EDOM	; Set error variable
	fstp	st(0)			;  pop stack
	fldz				; Load 8087 stack top with Zero
	mov	sp, bp
	pop	bp
	ret
FUN_END co_sinner


FUN_BEG __cos,0,<ds>
	fld	qword ptr ARG_BASE[bp]	; Push radian onto 8087 stack.
	fabs				; cos(-x) = cos(x)
	call	co_sinner		; A radian of either positive
					; or negative value will produce
					; the same cosine.
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __cos

end
+ARCHIVE+ _cotan.asm    2070 10/09/87 16:12:40
; _cotan - cotangent guts
; Copyright (c) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	$87_sin_cos,cp
EXTERN	__fac,dp
EXTERN	_errno,word		; Storage for error variable
EXTERN	$87_lrg_num,qword	; 2**1022 - Very large number
EXTERN 	$87_max_rad,qword	; 1.0e18 - Largest allowable radian

EDOM		equ	33
ERANGE		equ	34

_TEXT segment
assume cs:_TEXT, ds:DGROUP

if FAR_CODE eq TRUE
co_tanner proc far
else
co_tanner proc near
endif
	push	bp
	mov	bp, sp
	fcom	DGROUP:$87_max_rad	; Is radian greater than Maximum
	fstsw	word ptr -2[bp]		; Check status word
	fwait
	test	byte ptr -1[bp],1h	; If bit 0 in AH is not set,
	jz	trig_error		; then bad radian on stack
					; Else,
	call	$87_sin_cos		; Get the COSINE and SINE.
	fxch				; Switch Sine and cosine on stack
	ftst				; Check for a zero Sine value
	fstsw	word ptr -2[bp]
	fwait
	test	byte ptr -1[bp],40h	; Is this a zero?
	jz	good_cotan		; No, then don't set large_num
	fstp	st(0)			; Yes, then pop off stack
	fld	DGROUP:$87_lrg_num	; Load extremely large number
	mov	_errno,erange		; Set error variable
	fxch				; Switch large number with one
good_cotan:
	fdivp	st(1),st		; Divide the Cosine by the Sine.
	fstp	st(1)			; pop stack
	ret

trig_error:
	mov	_errno,EDOM		; Set error variable
	fstp	st(0)
	fldz				; Load 8087 stack top with Zero
	ret
co_tanner endp

_TEXT ends


FUN_BEG __cotan,2,<ds>
	fld	qword ptr ARG_BASE[bp]	; Get the radian value to convert.
	ftst				; Is this negative?
	fstsw	word ptr -2[bp]
	fwait
	test	byte ptr -1[bp],1	; the radian is negative.
	jz	pos_cotan		; Must be a positive.
	fchs				; Change sign for $87_sin_cos routine.
	call	co_tanner		; Find the co_tangent.
	fchs				; Change the sign of the result.
	jmp	short _cotan_done

pos_cotan:
	call	co_tanner	; Find normal co-tangent.

_cotan_done:
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __cotan

	end

+ARCHIVE+ _doexec.asm   5102 10/29/87 15:32:48
; _doexec.asm - load and run another program
; Copyright (C) 1987  Computer Innovations Inc,  ALL RIGHTS RESERVED.

include prologue.ah

EXTERN  __quit,cp
EXTERN  _main,cp
EXTERN  __psp,word

_DATA segment
        assume ds:DGROUP
	slime	label	dword
	slimeoff	dw	0
	slimeseg	dw	0
_DATA ends


FUN_BEG  __doexec,2,<si,di,ds>

FUN_ARG newCSoffset,2
FUN_ARG newIP,2
FUN_ARG newSP,2
FUN_ARG newSSoffset,2
FUN_ARG memsize,2	; memory necessary (paragraphs) for the new program
FUN_ARG envsize,2	; environment size in paragraphs
FUN_ARG envseg,2	; environment
FUN_ARG envoff,2
FUN_ARG cmdseg,2	; command line
FUN_ARG cmdoff,2
FUN_ARG pathseg,2	; path
FUN_ARG pathoff,2

FUN_AUTO temp,2

	mov	ah, 48h		; Make sure of DOS memory integrity.
	mov	bx, 0FFFFh
	int	21h
	cmp	al, 7
	jnc	dos_ok
	call	__quit		; can't do anything but crap out
dos_ok:
	mov	ax, __psp	; Expand program to the max.
	dec	ax
	mov	es, ax
	mov	bx, es:[3]
	mov	temp[bp], bx
	inc	ax
	mov	es, ax
	mov	bx, 0FFFFh
	mov	ah, 4Ah
	int	21h
	mov	ah, 4Ah
	int	21h

	mov	ah, 52h		; magic function
	int	21h
	mov	dx, es:[bx-2]	; aieee!!
	mov	bx, __psp

free_again:
	mov	es, dx		; Free the machine.
	inc	dx
	cmp	es:[1], bx
	jne	free_next
	cmp	bx, dx
	je	free_next
	mov	cx, es
	mov	es, dx
	mov	ah, 49h
	int	21h
	mov	es, cx
free_next:
	cmp	byte ptr es:[0], 5Ah
	je	free_done
	add	dx, es:[3]
	jmp	short free_again
free_done:

	mov	ah, 48h
	mov	bx, envsize[bp]
	int	21h		; get memory for environment
	jnc	got_env_space
	mov	ax, __psp
	dec	ax		; Store the environment.
	mov	es, ax
	mov	bx, es:[3]
	inc	ax
	mov	es, ax
	dec	bx
	dec	bx
	sub	bx, envsize[bp]
	mov	ah, 4Ah
	int	21h		; free memory for the environment (plus end)
	mov	ah, 48h
	mov	bx, envsize[bp]
	int	21h		; get memory for environment
	jnc	got_env_space
	jmp	no_env
got_env_space:
	mov	es, ax		; dest seg
	xor	di, di
	mov	ax, envseg[bp]
	push	ds
	mov	ds, ax
	mov	si, envoff[bp]
	mov	cx, envsize[bp]
	shl	cx, 1
	shl	cx, 1
	shl	cx, 1
	rep	movsw		; got the environment
	mov	envseg[bp], es	; save it
	pop	ds

	mov	dx, offset end_slime	; Load the slime code.
	sub	dx, offset start_slime
	mov	cl, 4
	shr	dx, cl
	inc	dx
	mov	bx, dx
	mov	ah, 48h
	int	21h
	jnc	got_slime_space
	mov	ax, __psp
	dec	ax
	mov	es, ax
	mov	bx, es:[3]
	sub	bx, dx
	dec	bx		; header
	inc	ax
	mov	es, ax
	mov	ah, 4Ah
	int	21h		; make room for the slime code
	mov	bx, dx
	mov	ah, 48h
	int	21h
	jc	no_slime
got_slime_space:
	mov	es, ax
	mov	DGROUP:slimeseg, ax	; for the far jump
	xor	di, di
	push	ds
	push	cs
	pop	ds
	mov	si, offset start_slime
	mov	cx, dx
	shl	cx, 1
	shl	cx, 1
	shl	cx, 1
	rep	movsw
	pop	ds

	mov	bx, __psp
	dec	bx
	mov	es, bx
	mov	bx, es:[3]
	cmp	bx, memsize[bp]
	jae	mem_size_ok

	mov	ax, DGROUP:slimeseg
	mov	es, ax
	mov	ah, 49h
	int	21h
no_slime:
	mov	ax, envseg[bp]
	mov	es, ax
	mov	ah, 49h
	int	21h
no_env:
	mov	bx, temp[bp]
	mov	ah, 4Ah
	int	21h
	mov	ax, 12		; return ENOMEM
FUN_LEAVE <si,di,ds>
mem_size_ok:

	mov	ax, __psp	; Set the command line.
	mov	es, ax
	mov	di, 80h
	mov	dx, di		; for later
	push	ds
	mov	ds, cmdseg[bp]
	mov	si, cmdoff[bp]
	mov	cl, [si]
	xor	ch, ch
	add	cx, 2
	rep	movsb
	mov	ds, ax
	mov	ah, 1Ah
	int	21h		; set the DTA
	pop	ds

	push	ds		; FCBs
	mov	ax, __psp
	mov	es, ax
	mov	cx, envseg[bp]	; Set the environment as long as I'm here.
	mov	es:[2Ch], cx
	mov	di, 5Ch
	mov	ds, ax
	mov	si, 80h
	cmp	byte ptr [si], 0
	je	cmd_zip
	inc	si
cmd_zip:
	mov	ax, 2901h
	int	21h
	mov	di, 6Ch
	mov	ax, 2901h
	int	21h
	pop	ds

	mov	cx, DGROUP:slimeseg	; set up slime stack
	push	cx
	mov	es, cx
	mov	si, offset end_slime
	sub	si, offset start_slime
	dec	si
	dec	si
	mov	ax, DGROUP:__psp
	add	ax, newCSoffset[bp]
	add	ax, 10h
	mov	es:[si], ax
	dec	si
	dec	si
	mov	cx, newIP[bp]
	mov	word ptr es:[si], cx
	dec	si
	dec	si
	mov	cx, newSP[bp]
	mov	word ptr es:[si], cx
	dec	si
	dec	si
	mov	ax, DGROUP:__psp
	mov	cx, newSSoffset[bp]
	add	cx, 10h
	add	cx, ax
	mov	es:[si], cx
	dec	si
	dec	si
	mov	es:[si], ax
	dec	si
	dec	si
	mov	cx, pathseg[bp]
	mov	word ptr es:[si], cx
	pop	cx

if FAR_CODE eq FALSE
	push	cs		; set up parameter block
	pop	es
else
	mov	bx, seg _main
	mov	es, bx
endif
	mov	bx, offset _main
	mov	ax, DGROUP:__psp
	add	ax, 10h		; no explanation
	mov	word ptr es:[bx], ax
	mov	word ptr es:2[bx], ax
	xor	di, di		; pointer to program name
	mov	ax, envseg[bp]
	push	ds
	mov	ds, ax
	cmp	word ptr [di], 0
	je	null_env
env_next:
	inc	di
	cmp	word ptr [di], 0
	jne	env_next
null_env:
	pop	ds

	mov	dx, pathoff[bp]
	sti
	mov	ss, cx
	mov	sp, si
	cli
	mov	ax, 4B03h
	jmp	dword ptr slime		; CHARGE !!!

start_slime:
	pop	ds			; pathseg
	int	21h
	pop	ax
	mov	es, ax
	mov	ds, ax
	pop	ax
	pop	cx
	pop	dx
	pop	bx
	sti
	mov	ss, ax
	mov	sp, cx
	cli
	push	bx
	push	dx
	db	0CBh
	dw	16 dup (0) ; OS
	dw	0	; path seg
	dw	0	; PSP
	dw	0	; SS
	dw	0	; SP
	dw	0	; IP
	dw	0	; CS
end_slime:

FUN_END  __doexec
end

+ARCHIVE+ _dosf25.asm    383  2/27/87 13:48:10
; __dosf25 - revector an interrupt
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah

FUN_BEG __dosf25,0,<>
FUN_ARG vec,2
FUN_ARG vecoff,2
FUN_ARG	vecseg,2

	push	ds
	mov	al, vec[bp]
	mov	ah, 25h
	mov	dx, vecoff[bp]
	mov	ds, vecseg[bp]
	int	21h
	pop	ds
	jnc	done
	xor	ax, ax
done:
FUN_LEAVE <>
FUN_END __dosf25

end


+ARCHIVE+ _dosf35.asm    342  2/27/87 13:40:44
; __dosf35 - get the contents of an interrupt vector
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah

FUN_BEG __dosf35,0,<>
FUN_ARG vec,2
	mov	al, vec[bp]
	mov	ah, 35h
	int	21h
	mov	dx, es
	mov	ax, bx
	jnc	done
	xor 	ax, ax
	mov	dx, ax
done:
FUN_LEAVE <>
FUN_END __dosf35

end


+ARCHIVE+ _dosf3f.asm    808 11/11/87 14:34:06
; _dosf3f - read from a handle
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.

; 11nov87 zap	Add some errno stuff.

include prologue.ah

EXTERN _errno,word

if FAR_DATA eq FALSE
EXTERN __dataseg,word
endif

FUN_BEG __dosf3f,0,<>
FUN_ARG fd,2
FUN_ARG where,dp
FUN_ARG	count,2

	push	ds
	mov	ax, 3f00h
	mov	bx, fd[bp]
        mov     cx, count[bp]
if FAR_DATA eq TRUE
        lds     dx, where[bp]
else
	mov	dx, where[bp]
	mov	ds, dgroup:__dataseg
endif
	int	21h
	pop	ds
	jnc	done
	cmp	ax, 5
	jne	BAD_HANDLE
	mov	ax, 13
	mov	DGROUP:_errno, ax	;EACCES -- file access denied
	mov	ax, -1			;EOF
	jmp	short done
BAD_HANDLE:
	mov	ax, 9
	mov	DGROUP:_errno, ax	;EBADF -- invalid file descriptor
	mov	ax, -1
done:
FUN_LEAVE <>
FUN_END __dosf3f

end

+ARCHIVE+ _dosf40.asm    523  3/18/87 17:30:26
; _dosf40 - write
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah

if FAR_DATA eq FALSE
EXTERN __dataseg,word
endif

FUN_BEG __dosf40,0,<>
FUN_ARG fd,2
FUN_ARG buffer,dp
FUN_ARG	count,2

	push	ds
	mov	ax, 4000h
	mov	bx, fd[bp]
        mov     cx, count[bp]
if FAR_DATA eq TRUE
        lds     dx, buffer[bp]
else
	mov	dx, buffer[bp]
	mov	ds, dgroup:__dataseg
endif
	int	21h
	pop	ds
	jnc	done
	mov	ax, -1
done:
FUN_LEAVE <>
FUN_END __dosf40

end


+ARCHIVE+ _dosf48.asm    396  2/23/87 13:11:28
; _dosf48.asm - Executes a DOS function 48h call (allocate some memory).
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah

FUN_BEG __dosf48,0,<>
FUN_ARG paras,2
	mov	ax, 4800h
	mov	bx, word ptr paras[bp]
	int	21h
	jnc	good
	xor	ax, ax
	mov	dx, ax
	jmp	short done
good:
	mov	dx, ax
	xor	ax, ax
done:
FUN_LEAVE <>
FUN_END __dosf48
end

+ARCHIVE+ _dosf49.asm    330 12/22/86 12:28:36
; _dosf49.asm - Executes a DOS function 49 call (frees OS-allocated memory).
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.

	include prologue.ah

FUN_BEG __dosf49,0,<>
FUN_ARG where,2			;segment to be freed
	mov	ax, 4900h
	mov	es,word ptr where[bp]
	int	21h
FUN_LEAVE <>
FUN_END __dosf49
	end

+ARCHIVE+ _dosf4a.asm    432 12/22/86 12:28:16
; _dosf4a.asm - Executes a DOS function 4A call (increase the module size).
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.

	include prologue.ah

;	call:	dosf4a(newsize,block)

FUN_BEG __dosf4a,0,<>
FUN_ARG	newsize,2
FUN_ARG	block,2
	mov	ax, 4A00h
	les	bx, dword ptr newsize[bp]	;cheat
	int	21h
	jc	done		;failed, ax is non-zero
	xor	ax,ax		;did it
done:
FUN_LEAVE <>
FUN_END __dosf4a
	end

+ARCHIVE+ _dtobcd.asm    904  8/05/87 16:43:16
; _dtobcd.asm - Convert double to BCD (ASCII) using 8087
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.

include	prologue.ah

.8087

EXTERN __fac,dp

FUN_BEG __dtobcd,10,<si,di,ds>
FUN_ARG d_val,8
FUN_ARG buffer_off,2
FUN_ARG buffer_bas,2
FUN_AUTO work_c,10

	cld
	fld	qword ptr d_val[bp]
	fbstp	tbyte ptr dgroup:__fac
	fwait
	mov	si, 9+offset dgroup:__fac ; to end of value (MSW)
	mov	di, buffer_off[bp]	; address of destination buffer
if FAR_DATA eq TRUE
	mov	es, buffer_bas[bp]
else
	mov	ax, ds
	mov	es, ax
endif
	xor	bx, bx			; number of bytes in return string
	mov	cx, 9
BCD4:	dec	si
	mov	al, [si]
	mov	ah, al
	and	ah, 0Fh
	shr	al, 1
	shr	al, 1
	shr	al, 1
	shr	al, 1
	add	ah, 30h			; ASCII '0'
	add	al, 30h
	stosw
	add	bx, 2
	loop	BCD4

_DTOBCD_DONE:
	xor	al, al
	stosb
	mov	ax, bx

FUN_LEAVE <si,di,ds>
FUN_END __dtobcd
end

+ARCHIVE+ _exp.asm       494  8/05/87 17:09:26
; _exp - exponential function guts
; Copyright (c) 1986 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	$87_y2x,cp
EXTERN	__fac,dp

FUN_BEG __exp,0,<ds>
	fld	qword ptr ARG_BASE[bp]	; Load argument into 8087
	fldl2e				; Load log base 2 of 'e'
	call	$87_y2x			; Calculate y^X
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __exp

end
+ARCHIVE+ _fcmp.asm      500  8/05/87 14:04:06
; _fcmp - set cpu flags for floating point comparison
; Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED

	title	_fcmp

	include	prologue.ah

FUN_BEG	__fcmp,2,<>
FUN_AUTO stat,2			;the place to store 8087 status
	fcompp			;compare the values
	fstsw	stat[bp]	;get flags to ax
	fwait
	mov	ah,stat+1[bp]
	mov	al,ah
	shl	ah,1
	shr	al,1
	rcr	ah,1
	shl	al,1
	shl	al,1
	and	al,80h
	xor	ah,al
	xor	ah,80h
	sahf			;set the flags
FUN_LEAVE <>
FUN_END	__fcmp
	end

+ARCHIVE+ _floor.asm     727  8/05/87 17:09:36
; _floor - floor function guts
; Copyright (c) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	__fac,dp

FUN_BEG __floor,2,<ds>
	fld	qword ptr ARG_BASE[bp]	; Load in the argument
	fstcw	word ptr -2[bp]		; Store control word
	fwait 
	mov	ax,-2[bp]		; store working copy 
	or	byte ptr -1[bp],04h	; force rounding to next least int
	fldcw	word ptr -2[bp]		; Load in modified control word
	frndint				; Chop off fraction
	mov	-2[bp],ax 
	fldcw	word ptr -2[bp]		; Load in original control word
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __floor

end


+ARCHIVE+ _fpreset.asm   311 12/22/86 12:18:48
; _fpreset.asm - reset the 8087.
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah
.8087

public __fpreset

_TEXT segment
assume cs:_TEXT

if FAR_CODE eq TRUE
__fpreset proc far
else
__fpreset proc near
endif
	finit
	ret
__fpreset endp
_TEXT ends
end
+ARCHIVE+ _ftol.asm      473  7/31/87 14:51:46
; _ftol - convert double to long
; Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED

	title	_ftol

	include	prologue.ah

FUN_BEG	__ftol,6,<>
FUN_AUTO value,4
FUN_AUTO cwrd,2
	fstcw	word ptr cwrd[bp]
	fwait
	mov	ax, cwrd[bp]
	or	word ptr cwrd[bp], 0C00h
	fldcw	word ptr cwrd[bp]
	fistp	dword ptr value[bp]
	fwait
	mov	cwrd[bp], ax
	fldcw	word ptr cwrd[bp]
	mov	ax, value[bp]
	mov	dx, value+2[bp]
FUN_LEAVE <>
FUN_END	__ftol
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


+ARCHIVE+ _log.asm      1357 10/09/87 16:23:18
; log and log10 - guts of these functions
; Copyright (c) 1986, 1987 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	__fac,dp
EXTERN	_errno,word
EXTERN	$87_lrg_num,qword	; 2**1022 - Very large number

EDOM		equ	33

_TEXT segment
	assume cs:_TEXT, ds:DGROUP
if FAR_CODE eq TRUE
$87_calc_log	proc far
else
$87_calc_log	proc near
endif
	fld	qword ptr ARG_BASE[bp]	; Argment now on top of 8087 stack
	ftst				; Check for a negative argument
	fstsw	word ptr -2[bp]
	fwait
					; Only positive, non-zero arguments
					; are allowed.
	test	byte ptr -1[bp],41h	; Is this a positive argument?
	jz	arg_is_positive		; Yes, then check for close to one.
	mov	DGROUP:_errno,EDOM	; No, then set error flag
	fstp	st(0)			; Pop arg off stack
	fstp	st(0)			; pop stack
	fld	DGROUP:$87_lrg_num	; Load a large number on stack
	fchs				; Change to negative value
	jmp	short _log_done

arg_is_positive:
	fyl2x				; Calculate log value

_log_done:
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END $87_calc_log


FUN_BEG __log,2,<ds>
	fldln2				; log to base e
	jmp	$87_calc_log
FUN_END __log

FUN_BEG __log10,2,<ds>
	fldlg2				; log to base 10
	jmp 	$87_calc_log
FUN_END __log10

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


+ARCHIVE+ _modf.asm     1101  9/23/87 17:16:54
; _modf - get integer and fraction
; Copyright (c) 1986 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	__fac,dp

FUN_BEG __modf,2,<ds>

if FAR_DATA eq TRUE
	les	bx,dword ptr ARG_BASE+8[bp]
else
	mov	bx,ARG_BASE+8[bp]	; BX gets address of double variable
endif

	fld	qword ptr ARG_BASE[bp]	; Load 8087 with Source argument
	fld	st(0)			; Copy and push onto 8087 stack
	fstcw	word ptr -2[bp]		; Store control word
	fwait
	mov	ax,-2[bp]		; store working copy
	or	byte ptr -1[bp],0ch
					; Force any rounding to chop
	fldcw	word ptr -2[bp]		; Load in modified control word
	frndint				; Chop off fraction
	mov	-2[bp],ax
	fldcw	word ptr -2[bp]		; Load in original control word
	fsub	st(1),st		; arg - int = fraction

if FAR_DATA eq TRUE
	fstp	qword ptr es:[bx]
else
	fstp	qword ptr [bx]		; Store integer part
endif

	fabs				; Force fractional part to positive
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __modf

end
+ARCHIVE+ _pow.asm      2524 10/09/87 16:32:42
; _pow - power function guts
; Copyright (c) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	$87_y2x,cp
EXTERN	__fac,dp
EXTERN	_errno,word

EDOM		equ	33

FUN_BEG __pow,10,<ds>
	fld	qword ptr ARG_BASE+8[bp]; Load X
					; one double
	ftst				; Test X for zero value
	fstsw	word ptr -2[bp]
	fwait
	test	byte ptr -1[bp],40h	; is x == zero ?
	jz	do_not_default		; No, then don't return a one
	fstp	st(0)			; Yes, then load a one at the
	fld1				; 8087 stack top, then return
	jmp	_pow_done

do_not_default:
	fld	qword ptr ARG_BASE[bp]	; Load Y
	ftst				; Check for a negative Y value
	fstsw	word ptr -2[bp]
	fwait
	test	byte ptr -1[bp],41h	; If not zero then negative
	jz	base_is_pos		; Y is positive
	test	byte ptr -1[bp],01h	; Y is either zero or negative
	jnz	base_is_neg		; Y is negative
base_is_zero:
	fxch				; Test for X zero or negative
	ftst
	fstsw	word ptr -2[bp]
	fwait
	fstp	st(0)   		; get rid of X,Y 
	fstp	st(0) 
	fldz				; Answer is zero no matter what
	test	byte ptr -1[bp],41h	; If X is positive, then no ERROR
	jz	no_zero_error		; X is positive
	mov	DGROUP:_errno,EDOM	; X is negative, forcing an error
no_zero_error:
	jmp	short _pow_done

base_is_pos:
	fld1				; Convert Y to log base 2
	fxch
	fyl2x				; Top of stack now has log base 2 of Y
	call	$87_y2x			; Calculate Y^x
	jmp	short _pow_done

base_is_neg:				; Special processing if Y is negative
	fld	st(1)
	fld	st(0)			; Load two copies of xponent
	frndint				; Change stack top to integer
	fcomp	st(1)			; Was X an integer value?
	fstsw	word ptr -2[bp]
	fistp	qword ptr -10[bp]	; Pop extra X off 8087 stack
					; While storing as integer X
	test	byte ptr -1[bp],40h	; Test for X = integer(X)
	jnz	x_is_integer		; X is an integer
	fstp	st(0)			; Pop another off stack
	fstp	st(0)			; and another 
	mov	DGROUP:_errno,EDOM	; Set error variable
	fldz
	jmp	short _pow_done

x_is_integer:
	fchs				; Change Y to positive
	fld1				; Load a one for log base 2 of Y
	fxch
	fyl2x
	test	byte ptr -10[bp],01h	; Check if exponent even
	jz	x_is_even		; Yes.
	call	$87_y2x			; Calculate correct y^X
	fchs				; Since X was odd and neg
					; Change sign of result to negative
	jmp	short _pow_done

x_is_even:
	call	$87_y2x		; Calculate Y^X for positive Y

_pow_done:
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __pow

end
+ARCHIVE+ _quit.asm     1702  2/27/87 14:42:14
; _quit - emergency exit for quick bomb
; Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah

EXTERN  __intctlc,dword
EXTERN  __intndp,dword
EXTERN  __dosf25,cp
EXTERN  __dosf35,cp


_DATA	segment
	public	__exittbc
	db	0ah,0dh
__exittbc	db	0,0,0,0
if	FAR_CODE eq TRUE
	db	':0000'
endif
	db	'$'
_DATA	ends

;	convert word to hex

_TEXT segment
assume cs:_TEXT, ds:DGROUP

wtoh	proc near
	mov	si,4		;digits per word
wtoh01:
	mov	al,dl		;get a digit
	mov	cl,4
	shr	dx,cl		;strip the digit
	and	al,0fh		;keep low nibble
	add	al,090h
	daa
	adc	al,040h
	daa
	dec	si		;count the digit
	mov	[bx+si],al	;store the digit
	jnz	wtoh01
	ret
wtoh	endp
_TEXT ends

FUN_BEG __quit,0,<ds>
FUN_ARG errcode,2
	les	dx, DGROUP:__intndp	; restore interrupt vector 2
	push	es
	push	dx
	mov	ax, 2
	push	ax
	call	__dosf25
	add	sp, 6
	les	dx, DGROUP:__intctlc	; restore interrupt vector 2
	push	es
	push	dx
	mov	ax, 23h
	push	ax
	call	__dosf25
	add	sp, 6
	mov	ax, errcode[bp]

	mov	bx,word ptr DGROUP:__exittbc	;get trace back control byte
	or	bl,bl
	jz	tb_none		;traceback is off
	js	tb_go		;do it
	or	al,al		;any error returned
	jz	tb_none		;nope
tb_go:
	push	ax		;save the exit value
tb_loop:
if	FAR_CODE eq TRUE
	mov	dx,errcode-4[bP]	;get the offset
	lea	bx,DGROUP:__exittbc+5
	call	wtoh
endif
	mov	dx,errcode-2[bp]
	lea	bx,DGROUP:__exittbc
	call	wtoh
	lea	dx,DGROUP:__exittbc-2
	mov	ah,9
	int	21h
	or	bp,bp
	jz	tb_done
	cmp	[bp],bp
	jbe	tb_done
	mov	bp,[bp]		;up the stack
	jmp	short tb_loop

tb_done:
	pop	ax		;restore ax
tb_none:
	mov	ah, 4Ch
	int	21h		; 'bye
FUN_END __quit

	end


+ARCHIVE+ _sigint.asm   1444  5/19/87 16:05:42
; _sigint - the interrupt hanlders for the signal interrupts
; Copyright (C) 1986,87 Computer Innovations, Inc. ALL RIGHTS RESERVED.

include prologue.ah

EXTERN	__sig_eval,cp
extrn   __intndp:far

public __ndpint,__ctlcint

_TEXT segment
assume cs:_TEXT,ds:DGROUP

__ndpint proc far			; (*_sig_eval[SIGFPE])();
        sub     sp,4
        push    bp
        mov     bp, sp
        fstsw   word ptr 2[bp]
	push	ds
        push    ax
	mov	ax, DGROUP
	mov	ds, ax
        test    word ptr 2[bp], 80h
        jz      not87
if FAR_CODE eq TRUE
	call	dword ptr DGROUP:32[__sig_eval]
else
	call	word ptr 16[__sig_eval]
endif
        fnclex
        pop     ax
	pop	ds
        mov     sp, bp
        pop     bp
        add     sp,4
	iret
not87:
        mov     ax,word ptr __intndp    
        mov     word ptr 2[bp],ax
        mov     ax,word ptr __intndp+2
        mov     word ptr 4[bp],ax
        pop     ax
	pop	ds
        mov     sp, bp
        pop     bp
        ret
__ndpint endp

__ctlcint proc far			; (*_sig_eval[SIGINT])();
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	ds
	push	es
        mov	ax, DGROUP
        mov	ds, ax
if FAR_CODE eq TRUE
        call    dword ptr DGROUP:8[__sig_eval]
else
        call    word ptr DGROUP:4[__sig_eval]
endif
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	iret
__ctlcint endp

_TEXT ends
end
+ARCHIVE+ _sin.asm      1836  8/05/87 17:10:52
; _sin - sine function guts
; Copyright (c) 1986 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	$87_sin_cos,cp
EXTERN	__fac,dp
EXTERN	_errno,word		; Storage for error variable
EXTERN	$87_max_rad,qword	; 1.0e18 - Maximum Radian value

EDOM		equ	33

_TEXT segment
	assume cs:_TEXT, ds:DGROUP
if FAR_CODE eq TRUE
sinner	proc far
else
sinner	proc near
endif
	push	bp
	mov	bp, sp
	sub	sp, 2

	fcom	DGROUP:$87_max_rad	; Is radian greater than Maximum
	fstsw	word ptr -2[bp]		; Check status word
	fwait
	test	byte ptr -1[bp],1h	; If bit 0 is set,
	jnz	rad_sine_ok		; then good radian on stack
	jmp	trig_error		; Else, set trig error

rad_sine_ok:
	call	$87_sin_cos		; get y,x
	fmul	st(0),st		; square x
	fld	st(1)			; get y
	fmul	st(0),st		; square y
	faddp	st(1),st		; sum squares
	fsqrt				; now we have hypotenuse
	fdivr	st,st(1)		; compute y/h
	fstp	st(3)			; clean up stack and
	fstp	st(0)			; leave y/h on tos
	fstp	st(0)
done_sinner:
	mov	sp, bp
	pop	bp
	ret

trig_error:
	mov	DGROUP:_errno,EDOM	; Set error variable
	fstp	st(0)			;  pop stack
	fldz				; Load 8087 stack top with Zero
	jmp	done_sinner
FUN_END sinner


FUN_BEG __sin,2,<ds>
	fld	qword ptr ARG_BASE[bp]	; Load radian onto 8087 stack.
	ftst				; check for negative radian.
	fstsw	word ptr -2[bp]		; Store result in memory
	fwait
	test	byte ptr -1[bp],1	; is this negative ? 
	jz	pos_sin			; Not.
	fchs				; Is, then make positive for sin_cos.
	call	sinner			; Ask 8087 for Sine.
	fchs				; change the Sine's sign.
	jmp	short _sin_done

pos_sin:
	call	sinner			; Do a normal radian.

_sin_done:
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __sin

end
+ARCHIVE+ _sqrt.asm      912  8/05/87 17:11:00
; _sqrt - square root routine guts
; Copyright (c) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	__fac,dp
EXTERN	_errno,word	; Storage for error variable

EDOM		equ	33

FUN_BEG __sqrt,2,<ds>
	fld	qword ptr ARG_BASE[bp]	; Load in the argument.
	ftst				; Is argument negative?
	fstsw	word ptr -2[bp]		; Check status word
	fwait
	test	byte ptr -1[bp],1h	; If bit 0 in AH is not set,
	jz	sqrt_arg_ok		; then good argument on stack
	jmp	trig_error		; Else, set trig error
sqrt_arg_ok:
	fsqrt				; 8087 xsquare root.
	jmp	short _sqrt_done

trig_error:
	mov	DGROUP:_errno,EDOM	; Set error variable
	fstp	st(0)			; pop
	fldz				; Load 8087 stack top with Zero

_sqrt_done:
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __sqrt

end
+ARCHIVE+ _square.asm    442  8/14/87 10:55:32
; _square - square guts
; Copyright (c) 1986 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	__fac,qword

FUN_BEG __square,0,<ds>
	fld	qword ptr ARG_BASE[bp]	; Load in the arg to square.
	fmul	st,st(0)		; Square the value.
	fstp	qword ptr DGROUP:__fac	; get the answer
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __square

end
+ARCHIVE+ _tan.asm      2098 10/09/87 15:58:08
; _tan - tangent guts
; Copyright (c) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	$87_sin_cos,cp
EXTERN	__fac,dp
EXTERN	_errno,word		; Storage for error variable
EXTERN	$87_lrg_num,qword	; 2**1022 - Very large number
EXTERN	$87_max_rad,qword	; 1.0e18 - Largest allowable radian

EDOM		equ	33
ERANGE		equ	34


_TEXT segment
	assume cs:_TEXT, ds:DGROUP
if FAR_CODE eq TRUE
tanner	proc far
else
tanner	proc near
endif
	push	bp
	mov	bp, sp
	sub	sp, 2

	fcom	DGROUP:$87_max_rad	; Is radian greater than Maximum
	fstsw	word ptr -2[bp]		; Check status word
	fwait
	test	byte ptr -1[bp],1h	; If bit 0 in AH is not set,
	jz	trig_error		; then bad radian on stack
					; Else,
	call	$87_sin_cos		; Get Cosine and sine on 8087 stack.
	ftst				; Check for a zero cosine value
	fstsw	word ptr -2[bp]
	fwait
	test	byte ptr -1[bp],40h	; Is this a zero?
	jz	good_tan		; No, then don't set large_num
	fstp	st(0)			; Yes, then pop off stack
	fld	DGROUP:$87_lrg_num	; Load extremely large number
	mov	DGROUP:_errno,ERANGE	; Set error variable
	fxch				; Switch large number with one
good_tan:
	fdivp	st(1),st		; Divide Sine by the Cosine.
	fstp	st(2)
	fstp	st(0)			; keep tos and pop
	mov	sp, bp
	pop	bp
	ret

trig_error:
	mov	DGROUP:_errno,EDOM	; Set error variable
	fstp	st(0)			;  pop stack
	fldz				; Load 8087 stack top with Zero
	mov	sp, bp
	pop	bp
	ret
FUN_END tanner


FUN_BEG __tan,2,<ds>
	fld	qword ptr ARG_BASE[bp]  ; Get the radian off stack.
	ftst				; Is it a negative?
	fstsw	word ptr -2[bp]		; Get the flags.
	fwait
	test	byte ptr -1[bp],1	; Not zero if negative.
	jz	pos_tan			; Must be positive.
	fchs				; Force positive, will reverse later.

	call	tanner			; Get tangent from 8087.
	fchs				; Must reverse sign change.
	jmp	short _tan_done

pos_tan:
	call	tanner			; Get a normal tangent.

_tan_done:
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END __tan

end
+ARCHIVE+ alloca.asm     767  9/30/87 10:31:12
; alloca - allocate a buffer on the stack
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.

;REVISED "ahm 30-sep-87 jumps to offset in bx instead of [bx]"

	include prologue.ah

_TEXT	segment
	assume	cs:_TEXT,ds:DGROUP

FUN_PROC _alloca
	pop	dx		;get return offset
	if	FAR_CODE eq TRUE
	pop	cx		;save the segment too
	endif
	pop	ax		;get the requested size
	inc	ax		;force it even
	and	al,0feh
	mov	bx,sp		;get the stack offset
	sub	sp,ax		;set the stack
	mov	ax,sp		;get the return address
	push	ss:2[bx]	;save register variables
	push	ss:[bx]
if	FAR_CODE eq TRUE
	push	cx
	push	dx
	mov	dx,ss		;have to return the segment too
	ret			;go back
else
	mov	bx,dx
	jmp	bx		;go back quick 
endif
FUN_END _alloca

end

+ARCHIVE+ bdos.asm       423  5/04/87 15:49:26
; bdos - call bios for simple services
; Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
	title	_bdos

	include	prologue.ah

FUN_BEG	_bdos,0,<si,di>
FUN_ARG	opcode,2
FUN_ARG pointer,dp
	mov	ah,opcode[bp]
if	FAR_DATA eq TRUE
	push	ds
	lds	dx,dword ptr pointer[bp]
else
	mov	dx,pointer[bp]
endif
	int	21h
if	FAR_DATA eq TRUE
	pop	ds
endif
FUN_LEAVE	<di,si>
FUN_END	_bdos
	end

+ARCHIVE+ cli.asm        296 11/25/87 16:08:56
; cli: Disables processor interrupt facility.
; Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
 
	include	prologue.ah
 
_TEXT	segment
	assume cs:_TEXT

public _cli

if FAR_CODE eq TRUE
_cli	proc far
else
_cli	proc near
endif
	cli
	ret
FUN_END _cli
	end

+ARCHIVE+ cswitch.asm   1351  9/12/87 16:18:02
; Copyright (c) 1986 Computer Innovations, Inc, ALL RIGHTS RESERVED
;
;	character switch (signed)
;
;	entry
;	value in al
;	pointer to switch table in ds:bx 
;	exit
;	jump address in bx

;	calling sequence 
;	mov	al,value		;lsw of value
;	mov	bx,word ptr xxx		;address of table
;	jmp	bx			;dispatch to code

;	table format
;	dw	number of entries * size of entry
;	db	entry 1
;	db	entry 2
;	.
;	.
;	.
;	dw	offset address for entry 1
;	dw	offset address for entry 2
;	dw	offset for default (after switch if none)

	include prologue.ah

FUN_BEG cswitch,0,<si,di>
	mov	si,bx		;match old entry logic
	xor	cx,cx		;zero lower limit
	mov	di,[si]		;get upper limit
	add	si,2		;could be done in table creation
	or	di,di		;no entries ?
	jz	default		;get out fast
again0:	dec	di		;byte offset to last entry
again:	cmp	cx,di		;any candidates left ?
	jg	default		;nope take default
	mov	bx,cx		;get mid point
	add	bx,di
	shr	bx,1		
	cmp	al,[si+bx]
	jl	low
	je	equal
high:	mov	cx,bx		;reset limit
	inc	cx		;but higher
	jmp	short again
low:	mov	di,bx
        or      di,di
	jnz	again0
default:mov	bx,[si-2]	;take the default
equal:	shl	bx,1
	add	bx,[si-2]	;get table address
	inc	bx		;force table to be even
	and	bx,0fffeh
	mov	bx,[bx+si]	;get the offset (+si - jsc)
FUN_LEAVE	<si,di>
FUN_END cswitch
	end

+ARCHIVE+ ctl87.asm      433 12/22/86 12:19:12
; _control87.asm - Get or set the 8087 control word.
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah
.8087

FUN_BEG __control87,2,<>
FUN_ARG new,2
FUN_ARG mask,2
	fstcw	-2[bp]
	fwait
	mov	ax, -2[bp]
	mov	dx, mask[bp]
	or	dx, dx
	jz	L0
	mov	bx, new[bp]
	and	bx, dx
	not	dx
	and	dx, ax
	or	dx, bx
	mov	-2[bp], dx
	fldcw	-2[bp]
L0:
FUN_LEAVE <>
FUN_END __control87
end
+ARCHIVE+ ctype.asm     1084  8/05/87 15:00:30
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
  
	title	ctype
	subttl	Compiled by C86PLUS Version 1.08 (May 1987)
	name	ctype

include prologue.ah

	public	__ctype
	public	__ctype_

_DATA	segment word public 'DATA'	; 0101h
	assume	ds:dgroup
__ctype	label	byte
__ctype_ label	byte
	db	   0,  32,  32,  32,  32,  32,  32,  32
	db	  32,  32,  40,  40,  40,  40,  40,  32
	db	  32,  32,  32,  32,  32,  32,  32,  32
	db	  32,  32,  32,  32,  32,  32,  32,  32
	db	  32,  72,  16,  16,  16,  16,  16,  16
	db	  16,  16,  16,  16,  16,  16,  16,  16
	db	  16, 132, 132, 132, 132, 132, 132, 132
	db	 132, 132, 132,  16,  16,  16,  16,  16
	db	  16,  16, 129, 129, 129, 129, 129, 129
	db	   1,   1,   1,   1,   1,   1,   1,   1
	db	   1,   1,   1,   1,   1,   1,   1,   1
	db	   1,   1,   1,   1,  16,  16,  16,  16
	db	  16,  16, 130, 130, 130, 130, 130, 130
	db	   2,   2,   2,   2,   2,   2,   2,   2
	db	   2,   2,   2,   2,   2,   2,   2,   2
	db	   2,   2,   2,   2,  16,  16,  16,  16
	db	  32
	db	128 dup (0)
_DATA	ends

	end
+ARCHIVE+ eoi.asm        358  2/02/87 12:51:08
; _eoi: Places the interrupt controller back in service.  Should be
;       called only at the end of routines that service a HARDWARE
;       interrupt!
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
 
	include	prologue.ah
 
_TEXT	segment
	assume cs:_TEXT
FUN_PROC _eoi
	mov	al,020h
	out	020h,al
	ret
FUN_END _eoi
	end

+ARCHIVE+ exp10.asm      520  8/05/87 17:05:44
; _exp10 - ten to the argument - where is this called?
; Copyright (c) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	$87_y2x,cp
EXTERN	__fac,dp

FUN_BEG _exp10,0,<ds>
	fld	qword ptr ARG_BASE[bp]	; Load argument into 8087
	fldl2t				; Load log base 2 of 10
	call	$87_y2x			; Calculate y^X

	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END _exp10

end
+ARCHIVE+ fix87s.asm     596  8/05/87 13:54:54
; fix87s.asm - fixup values for FP opcodes, software '87
; Copyright (C) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
;
; 1dec86 zap  New values.

include prologue.ah

	public	FIARQQ
	public	FICRQQ
	public	FIDRQQ
	public	FIERQQ
	public	FISRQQ
	public	FIWRQQ
	public	FJARQQ
	public	FJCRQQ
	public	FJSRQQ
	public	__fltused

	FIARQQ	equ	0FE32h
	FICRQQ	equ	 0E32h
	FIDRQQ	equ	 5C32h	; normal mung value
	FIERQQ	equ	 1632h
	FISRQQ	equ	 0632h
	FIWRQQ	equ	0A23Dh	; solitary FWAIT
	FJARQQ	equ	 4000h
	FJCRQQ	equ	0C000h
	FJSRQQ	equ	 8000h

	__fltused	equ	 9876h

end
+ARCHIVE+ free_stk.asm   395  1/05/87 16:54:16
; free_stk - how much room left on the stack
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah

ife FAR_DATA
	EXTERN _stack,word
endif

FUN_BEG _free_stk,0,<> 

if FAR_DATA
	mov	ax, sp
else
	mov	bx, seg DGROUP:_stack
	mov	dx, ds
	sub	bx, dx
	mov	cx, 4
	shl	bx, cl
	mov	ax, sp
	sub	ax, bx
endif

FUN_LEAVE <>
FUN_END _free_stk
end
+ARCHIVE+ frexp.asm      710  9/23/87 17:19:18
; frexp - split a double
; Copyright (c) 1986,87 Computer Innovations, Inc ALL RIGHTS RESERVED

include prologue.ah

EXTERN	__fac,dp

FUN_BEG _frexp,0,<ds>
if FAR_DATA eq TRUE
	les	bx, dword ptr ARG_BASE+8[bp]
else
	mov	bx, ARG_BASE+8[bp]	; BX points to integer variable
endif
	fld	qword ptr ARG_BASE[bp]	; Load 8087 with argument
	fxtract				; Mantissa on top of stack
	fxch				; Exponent on top
if FAR_DATA eq TRUE
	fistp	word ptr es:[bx]
else
	fistp	word ptr [bx]		; Store Integer exponent
endif
	fwait

	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END _frexp

end
+ARCHIVE+ inportb.asm    325 12/22/86 12:18:28
; inportb - read an 8 bit value from a port
; Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.

include	prologue.ah

FUN_BEG _inportb,0,<>
FUN_ARG port,2
	mov	dx, port[bp]	;get the port number
	in	al, dx		;get a byte value
	xor	ah, ah		;zero the top byte
FUN_LEAVE <>
FUN_END _inportb
end
+ARCHIVE+ inportw.asm    280 12/22/86 12:18:30
; inportw - read a 16 bit value from a port
; Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.

include	prologue.ah

FUN_BEG _inportw,0,<>
	mov	dx, ARG_BASE[bp]	;get the port number
	in	ax, dx		;get a byte value
FUN_LEAVE <>
FUN_END _inportw
end
+ARCHIVE+ introld.asm   1805  8/05/87 13:55:36
; INTROLD: Passes control to the the entry point that was most
; recently re-vectored via intr_set().
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.
 
	include prologue.ah
	include intr.ah
 
FUN_BEG	_introld,0,<si,di>
FUN_ARG	if_ptr,4
		push	ds		; Gear up for REP MOVSW.
		push	es
		lds	si,if_ptr[bp]	; Get addressability to i_f.
		les	di,[si].icb_ptr	; And also to ICB.
		pushf			; Construct bogus interrupt
		push	cs		; return address.
		pushi	<offset _TEXT:oldint2>
		mov	ax,[si].if_f	; Load flags at interrupt time
		and	ah,0FCh		; Mask IF & TF!
		push	ax		; Ok, that's ready to ship.
		push	word ptr es:[di].old_isr+2
		push	word ptr es:[di].old_isr
		mov	cx,ss
		mov	es,cx
		sub	sp,20
		mov	di,sp
		mov	cx,10
		rep	movsw		; Get copy of all registers
		pop	es		; And load 'em up!
		pop	ds
		popa
		iret			; We're off to old_isr!
oldint2	label	word
		pushf			; We're back.  Save every-
		pusha			; thing we can get our hands
		push	ds		; on!
		push	es		; Ok, breathe...
COMMENT * Now some of the less couth interrupt routines even
alter BP!  So we cannot rely on it being intact.  The only thing
at this point that we can trust is SP.  Because we know what SP
is, and what BP used to be, we can calculate the span between them
and use this result (30 in this case) as an addition constant to
all [BP] references.
*
		mov	bp,sp		; 30 off, remember!
		les	di,if_ptr+30[bp] ; ES:DI instead of DS:SI
		mov	si,sp		; this time because we're
		mov	cx,ss		; going the other way.
		mov	ds,cx
		mov	cx,10
		rep	movsw
		add	sp,20
		pop	es:[di].if_f-20
		; Anyone who cannot fully explain that line of code
		; need not apply!
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	bp		; Rather anticlimatic, huh?
		ret
FUN_END	_introld
		end
+ARCHIVE+ intrserv.asm  1664  5/29/87 15:58:16
; _intrserv: Service routine for interrupts revectored via intrset()
; Copyright (c) 1986,87 by Computer Innovations. Inc.  All rights reserved.

	include prologue.ah

;	offsets to information in control block

icb_off	        equ	22	;offset to return address on stack
frame_size	equ     0
sub_sp		equ     2
new_isr		equ     4
old_isr		equ     8
vecno		equ     -6
 
	public	_intrserv
_TEXT	segment
	assume	cs:_text,ds:nothing
 
_intrserv	proc	far
        sub     sp,2            		;leave a slot
	pusha                   		;save all the registers
	push	ds
	push	es
	mov	bp,sp           		;make stack addressable
	lds	si,dword ptr icb_off[bp]	;get parameter address
	mov	bx,si				;calculate sp value
	sub	bx,sub_sp[si]           	;starting offset of stack
	mov	ax,frame_size[si]       	;get size of stack
	add	sub_sp[si],ax   		;"Allocate" user stack
	mov	dx,ss				;save old ss
	mov	cx,sp				;save old sp
	mov	ax,ds				;set the stack segment
	mov	ss,ax
	mov	sp,bx				;and the stack pointer
	push	dx              		;address of register block
	push	cx				;also old ss:sp
	mov	ax,ds
	mov	es,ax
	mov	ax,DGROUP			;set ds correctly
	mov	ds,ax
if	FAR_CODE eq TRUE
	call	dword ptr es:new_isr[si]
else
	call	word ptr es:new_isr[si]
endif
	pop	cx				;Recover original stack.
	pop	dx
	mov	ss,dx
	mov	sp,cx
	lds	si,dword ptr icb_off[bp]	;get parameter address
	mov	ax,frame_size[si]
	sub	sub_sp[si],ax			;deallocate user stack
	pop	es				;Recover segment registers
	pop	ds
	popa					;Recover everything else
	add	sp,6				;dump the rubbish
	iret	    				;Instead return to interruptee.
_intrserv	endp
_TEXT	ends
	end

+ARCHIVE+ iswap.asm      589 10/15/87  9:46:48
; iswap - exchange two integers
; Copyright (C) 1987 Computer Innovations Inc,  ALL RIGHTS RESERVED.

include	prologue.ah

FUN_BEG _iswap,0,<si,di>
FUN_ARG dst,dp
FUN_ARG src,dp

if FAR_DATA eq TRUE
	push	ds
	lds	si, dword ptr src[bp]
	les	di, dword ptr dst[bp]
else
	mov	ax,ds		;ensure that extra seg is correct
	mov	es,ax
	mov	si,src[bp]	;the source address
	mov	di,dst[bp]	;the destination address
endif
	cli
	mov	ax, ds:[si]
	mov	bx, es:[di]
	mov	es:[di], ax
	mov	ds:[si], bx
	sti
if FAR_DATA eq TRUE
	pop	ds
endif
FUN_LEAVE <si,di>
FUN_END _iswap

end
+ARCHIVE+ ldexp.asm     1610  8/05/87 17:06:32
; ldexp - build a double
; Copyright (c) 1986,87 Computer Innovations, Inc, ALL RIGHTS RESERVED

include prologue.ah

EXTERN	__fac,dp
EXTERN	_errno,word		; Storage for error variable
EXTERN	$87_lrg_num,byte	; 2**1022 - Very large number
EXTERN	$87_lrg_exp,word	; Largest possible exponent

large_num	equ	qword ptr DGROUP:$87_lrg_num
ERANGE		equ	34

FUN_BEG _ldexp,2,<ds>
	fld	qword ptr ARG_BASE[bp]	; Load mantissa into 8087
	fxtract				; Convert to integer and significand
	fxch				; put integer on stack top
	fiadd	word ptr ARG_BASE+8[bp]	; Add integer exponential value
	fild	DGROUP:$87_lrg_exp	; Load in maximum exponent
	fchs				; Make it negative
	fcom	st(1)			; Test for exp < -1023
	fstsw	word ptr -2[bp]
	fwait
	test	byte ptr -1[bp],1h	; If zero, then underflow
	jz	under_flow		; Error, will set to zero
	fchs				; change max-exp to positive
	fcom	st(1)
	fstsw	word ptr -2[bp]		; Check now for overflow condtions
	fwait
	test	byte ptr -1[bp],1h	; If not zero, then overflow
	jnz	over_flow		; Exponent is too high
	fstp	st(0)			; pop off maximum exponent
	fxch				; Switch valid exponent with mantissa
	fscale				; Convert to a valid number
	fstp	st(1)			; Save on top of stack
	jmp	short _ldexp_done

under_flow:
	fldz				; Return with zero
	jmp	short _ldexp_done

over_flow:
	fld	large_num		; Load with near Infinity
	mov	DGROUP:_errno,erange	; Set error word

_ldexp_done:
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END _ldexp

end
+ARCHIVE+ ldivide.asm   2979  9/16/87 10:02:54
; ldivide.asm - long integer division functions
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
;
;  10sep87 ahm  rewritten, faster
;  15sep87 ahm  routines divided in ludiv, ludivide, lsdiv and lsdivide

;	old entry points:
;                        for successful compilation of old code
;
;	ludiv - long unsigned divide
;	lsdiv - long signed divide

;
;	conventions:
;
;       for a / b
;
;	push a
;	push b
;	call ludiv
;	result in dxax
;
	include prologue.ah




;	new entry points:
;
;	ludivide - long unsigned divide
;	lsdivide - long signed divide

;
;	conventions:
;
;       for a / b
;
;	a in dxax
;	b in bxcx
;	call ludivide
;	result in dxax
;


_TEXT segment
assume	cs:_TEXT,ds:DGROUP


FUN_PROC ludivide
        xchg    bx, cx
	jcxz	quickdiv
        push    bp 
        mov     bp,sp
        push    dx                              ;xx
        push    ax                              ;yy
        push    di
        push    si
        mov     si,cx
        mov     ax,dx
        xor     dx,dx
	div 	cx				;q1=xx/zz
	mov	di, ax
	push	ax
	mul	cx				;ccdd=q1*zz
	xchg	ax, di
	xchg	si, dx				;sidi=ccdd
	mul	bx               		;ww dxax=aabb=q1*ww
	add	dx, di				;dd+aa
	adc	si, 0
	cmp	si, 1
	jge	oneless
	sub	word ptr -4[bp],ax              ;yy
	sbb	word ptr -2[bp],dx              ;xx
	jns	ok
oneless:
	pop	ax
	sub	ax, 1
	xor	dx, dx
	jmp	endudiv
ok:
	pop	ax
	xor	dx, dx
endudiv:
        pop     si
        pop     di
        mov     sp, bp
        pop     bp
        ret     
quickdiv:
        or      dx,dx
        jz      quickquick
        xchg    dx,ax
        mov     cx,dx
        xor     dx,dx
      	div	bx
	xchg	cx,ax
quickquick:
	div	bx
	mov	dx,cx
        ret
FUN_END ludivide


_TEXT segment
assume	cs:_TEXT,ds:DGROUP


FUN_PROC lsdivide
	test	dx,8000h
	jz	posnum
	neg	dx		;num is -ve 
	neg	ax
	sbb	dx,0
	test	bx,8000h
	jz	negdiv		;-/+
	neg	bx		;-/-
	neg	cx
	sbb	bx,0
	jmp	posdiv
negdiv:				;-ve div result
	call	ludivide
	neg	dx
	neg	ax
	sbb	dx,0
        ret     
posnum:	
	test	bx,8000h
	jz	posdiv		;+/+
	neg	bx		;+/-
	neg	cx
	sbb	bx,0
	jmp	negdiv
posdiv:				;+ve div result
	call	ludivide
        ret     
FUN_END lsdivide

FUN_BEG ludiv,0,<>
FUN_ARG divisor,4
FUN_ARG dividend,4
	mov	ax,word ptr dividend[bp]        ;yy
	mov	dx,word ptr dividend+2[bp]      ;xx
	mov	bx,word ptr divisor+2[bp]       ;zz
	mov	cx,word ptr divisor[bp]         ;ww
        call    ludivide
        mov     sp, bp
        pop     bp
        ret     8
FUN_END ludiv


FUN_BEG lsdiv,0,<>
FUN_ARG divisor,4
FUN_ARG dividend,4
	mov	ax,word ptr dividend[bp]        ;yy
	mov	dx,word ptr dividend+2[bp]      ;xx
	mov	bx,word ptr divisor+2[bp]       ;zz
	mov	cx,word ptr divisor[bp]         ;ww
        call    lsdivide
        mov     sp, bp
        pop     bp
        ret     8
FUN_END lsdiv


end

+ARCHIVE+ lmodulo.asm   3335  9/16/87 10:02:38
; lmodulo.asm - long integer remainder functions
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
;
;  09sep87 ahm  rewritten mod functions, no longer depend upon ldiv
;  15sep87 ahm  routines divided in lumod, lumodulo, lsmod and lsmodulo

;	old entry points:
;                       for successful compilation of old code 
;
;	lumod - long unsigned modulus
; 	lsmod - long signed modulus

;
;	conventions:
;
;       for a % b
;
;	push a
;	push b
;	call lumod
;	result in dxax


	include prologue.ah



;	new entry points:
;
;	lumodulo - long unsigned modulus
; 	lsmodulo - long signed modulus

;
;	conventions:
;
;       for a % b
;
;	a in dxax
;	b in bxcx
;	call lumodulo
;	result in dxax
;


_TEXT segment
assume	cs:_TEXT,ds:DGROUP

FUN_PROC lumodulo
        xchg    bx, cx				
	jcxz	quickmod
        push    bp 
        mov     bp,sp
        push    dx                              ;xx
        push    ax                              ;yy
        push    bx                              ;ww
        push    cx                              ;zz
        push    di
        push    si
        mov     si,cx
        mov     ax,dx
        xor     dx,dx
	div 	cx				;q1=xx/zz
	mov	di, ax
	mul	cx				;ccdd=q1*zz
	xchg	ax, di
	xchg	si, dx				;sidi=ccdd
	mul	bx              		;ww dxax=aabb=q1*ww
	add	dx, di				;dd+aa
	adc	si, 0
	mov	cx, ax
	mov	bx, dx
	mov	dx,word ptr -2[bp]	        ;xx
	mov	ax,word ptr -4[bp]	        ;yy
	cmp	si, 1
	jge	adjust
	sub	ax, cx
	sbb	dx, bx
	jns	endumod
	neg	dx
	neg	ax
	sbb	dx,0
	mov	cx, ax
	mov	bx, dx
	mov	ax, word ptr -6[bp]     	;ww
	mov	dx, word ptr -8[bp]      	;zz
	sub	ax, cx
	sub	dx, bx
	jmp	endumod
adjust:
	sub	ax, cx
	sbb	dx, bx
	add	ax, word ptr -6[bp]     	;ww
	adc	dx, word ptr -8[bp]      	;zz
endumod:
        pop     si
        pop     di
        mov     sp, bp
        pop     bp
        ret     
quickmod:
        or      dx,dx
        jz      quickquick
        xchg    dx,ax
        mov     cx,dx
        xor     dx,dx
	div	bx	
	mov	ax,cx
quickquick:
	div	bx
	mov 	ax, dx
	xor 	dx, dx
        ret     
FUN_END lumodulo


_TEXT segment
assume	cs:_TEXT,ds:DGROUP

FUN_PROC  lsmodulo
	test	dx,8000h
	jz	posnum
	neg	dx		;num is -ve 
	neg	ax
	sbb	dx,0
	test	bx,8000h
	jz	negmod		;-/+
	neg	bx		;-/-
	neg	cx
	sbb	bx,0
negmod:				;-ve mod result
	call	lumodulo
	neg	dx
	neg	ax
	sbb	dx,0
        ret     
posnum:	
	test	bx,8000h
	jz	posmod		;+/+
	neg	bx		;+/-
	neg	cx
	sbb	bx,0
posmod:				;+ve mod result
	call	lumodulo
        ret     
FUN_END lsmodulo

FUN_BEG lumod,0,<>
FUN_ARG divisor,4
FUN_ARG dividend,4
	mov	ax,word ptr dividend[bp]        ;yy
	mov	dx,word ptr dividend+2[bp]      ;xx
	mov	bx,word ptr divisor+2[bp]       ;zz
	mov	cx,word ptr divisor[bp]         ;ww
        call    lumodulo
        mov     sp, bp
        pop     bp
        ret     8
FUN_END lumod


FUN_BEG lsmod,0,<>
FUN_ARG divisor,4
FUN_ARG dividend,4
	mov	ax,word ptr dividend[bp]        ;yy
	mov	dx,word ptr dividend+2[bp]      ;xx
	mov	bx,word ptr divisor+2[bp]       ;zz
	mov	cx,word ptr divisor[bp]         ;ww
        call    lsmodulo
        mov     sp, bp
        pop     bp
        ret     8
FUN_END lsmod

end

+ARCHIVE+ loadexec.asm  2050  6/04/87 10:51:14
; loadexec.asm - load or execute a program (according to microsoft)
; Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.

; 12-dec-86,zap,save DS
; 27-feb-87,zap,interrupt vectors

include	prologue.ah

EXTERN  ndphere,word
EXTERN	__intctlc,dword
EXTERN	__intndp,dword
EXTERN  __ctlcint,far
EXTERN  __ndpint,far
EXTERN  __dosf25,cp

; loadexec(char far *file,struct control far *cont,int al_code);

_DATA	segment
savess	dw	0
savesp	dw	0
_DATA	ends

FUN_BEG _loadexec,0,<si,di,ds>

FUN_ARG filename,4 ; a1
FUN_ARG param,4    ; a2
FUN_ARG funcode,2  ; a3
	mov	ax, DGROUP:ndphere
	or	ax, ax
	jz	dontbother
	les	dx, DGROUP:__intndp	; restore interrupt vector 2
	push	es
	push	dx
	mov	ax, 2
	push	ax
	call	__dosf25
	add	sp, 6
dontbother:
	les	dx, DGROUP:__intctlc	; restore interrupt vector 23
	push	es
	push	dx
	mov	ax, 23h
	push	ax
	call	__dosf25
	add	sp, 6

if SET_DS eq TRUE
	mov	dx,DGROUP
	mov	es,dx
else
	push	ds
	pop	es
endif
	lds	dx,dword ptr filename[bp]	;get file name string
        push    bp
	push	word ptr es:30h			;save words corrupted by MS
	push	word ptr es:2eh
	cli
assume es:DGROUP
	mov	es:savess,ss			;save the stack
	mov	es:savesp,sp			;and the stack pointer
assume es:NOTHING
	sti
	les	bx,dword ptr param[bp]		;parameter block
	mov	al,funcode[bp]			;and sub function code
	mov	ah,4bh
	int	21h			;away we go....
	jc	fail			;did not make it
	xor	ax,ax			;say successful
fail:
	mov	dx,dgroup		;restore segments
	mov	ds,dx			;data segment
	mov	ss,dgroup:savess	;restore the stack
	mov	sp,dgroup:savesp
	pop	ds:2eh
	pop	ds:30h
        pop     bp

        push    ax
	mov	ax, seg __ctlcint
	push	ax
	mov	ax, offset __ctlcint
	push	ax
	mov	ax, 23h
	push	ax
	call	__dosf25
	add	sp, 6
	mov	ax, DGROUP:ndphere
	or	ax, ax
	jz	outahere
	mov	ax, seg __ndpint
	push	ax
	mov	ax, offset __ndpint
	push	ax
	mov	ax, 2
	push	ax
	call	__dosf25
	add	sp, 6
outahere:
        pop     ax
FUN_LEAVE <si,di,ds>
FUN_END _loadexec
end
+ARCHIVE+ longjmp.asm   1394 12/28/86  0:01:06
; longjmp - restore the environment saved by setjmp
; Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.

; 11-dec-86,zap,si and di, check return value
; 27-dec-86,gee,all models supported

include	prologue.ah

	_REGSP  equ 0   ;buffer indeces
	_REGBP  equ 2
	_RETOFF equ 4
	_RETSEG equ 6
	_REGSI  equ 8
	_REGDI  equ 10
	_REGDS  equ 12

;	entry	1, address of environment
;		2, value to return after restoration

public _longjmp

_TEXT segment
assume cs:_TEXT,ds:DGROUP

if      FAR_CODE eq TRUE
_longjmp proc   far
        add     sp,4                    ;dump return address
else
_longjmp proc   near
        add     sp,2                    ;dump return address
endif
if      FAR_DATA eq TRUE
        pop     bx                      ;get the environment offset
        pop     ds                      ;and the segment
        mov     ax,4[bp]                ;and the return value
else
        pop     bx                      ;get environment pointer
endif
        pop     ax                      ;get the return value
	mov	sp,_REGSP[bx]		;get the sp value
	mov	bp,_REGBP[bx]
if      FAR_CODE eq TRUE
	push	_RETSEG[bx]		;push the restart address
endif
	push	_RETOFF[bx]
	mov	si,_REGSI[bx]
	mov	di,_REGDI[bx]
if      FAR_DATA eq TRUE
	mov	ds,_REGDS[bx]
endif
	or	ax,ax
	jnz	away
	inc	ax
away:	ret
FUN_END _longjmp
end
+ARCHIVE+ lswitch.asm   1374  5/11/87 22:24:42
; Copyright (c) 1986 Computer Innovations, Inc, ALL RIGHTS RESERVED
;
;	entry
;	value in ax,dx
;	pointer to switch table in bx
;	exit
;	jump address in bx

;	calling sequence
;	mov	ax,value	;lsw of value
;	mov	dx,value+2	;msw of value
;	mov	bx,word ptr xxx	;address of table
;	jmp	[bx]		;dispatch to code

;	table format
;	dw	number of entries * size of entry
;	dd	entry 1
;	dd	entry 2
;	.
;	.
;	.
;	dw	offset for default (after switch if none)
;	dw	offset address for entry 1
;	dw	offset address for entry 2

	include	prologue.ah

FUN_BEG	lswitch,0,<si,di>
	mov	si,bx		;match entry conditions
	xor	cx,cx		;zero lower limit
	mov	di,[si]		;get upper limit
	add	si,2		;could be done in table creation
	or	di,di		;no entries ?
	jz	default		;get out fast
	sub	di,4		;byte offset to last entry
again:	cmp	cx,di		;any candidates left ?
	jg	default		;nope take default
	mov	bx,cx		;get mid point
	add	bx,di
	ror	bx,1		;keep the CARRY for BIG tables
	and	bl,0fch		;force even mod 4
	cmp	dx,2[si+bx]
	jl	low
	jg	high
	cmp	dx,[si+bx]
	jb	low
	je	equal
high:	mov	cx,bx		;reset limit
	add	cx,4		;but higher
	jmp	short again
low:	mov	di,bx
	sub	di,4
	jmp	short again
default:mov	bx,0ffffh	;take the default
equal:	shr	bx,1
	add	bx,[si-2]	;get table address
	mov	bx,[bx]	;get the offset
FUN_LEAVE	<si,di>
FUN_END	lswitch
	end

+ARCHIVE+ memcpy.asm     878 11/25/87 14:19:44
; movcpy - copy a block of memory
; Copyright (C) 1987 Computer Innovations Inc,  ALL RIGHTS RESERVED.

include	prologue.ah

FUN_BEG _memcpy,0,<si,di>
FUN_ARG dst,dp
FUN_ARG src,dp
FUN_ARG count,2

	mov	cx, count[bp]	;the number of bytes to move
        or      cx, cx
        jz      dontbother

if FAR_DATA eq TRUE
	push	ds
	lds	si, dword ptr src[bp]
	les	di, dword ptr dst[bp]
else
	mov	ax,ds		;ensure that extra seg is correct
	mov	es,ax
	mov	si,src[bp];	;the source address
	mov	di,dst[bp]	;the destination address
endif
        shr     cx, 1
	jz	nowords
        rep     movsw		;do the move
nowords:
        jnc     done
        movsb
done:
if FAR_DATA eq TRUE
	pop	ds
endif

dontbother:
if FAR_DATA eq TRUE
	mov	dx, word ptr dst+2[bp]	;return the pointer
endif
	mov	ax, word ptr dst[bp]

FUN_LEAVE <si,di>
FUN_END _memcpy

end
+ARCHIVE+ memset.asm     803  8/15/87 16:44:54
; memset - sets the first n characters in s to c
;   returns s
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.

; 06mar87 zap  Rewrite in assembler.

; char *memset(char *s, char c, int n)

include prologue.ah

FUN_BEG _memset,0,<di>
FUN_ARG s,dp
FUN_ARG c,2
FUN_ARG n,2

if FAR_DATA eq TRUE
        les     di, s[bp]
else
        mov     di, ds
        mov     es, di
        mov     di, s[bp]
endif
        mov     bx, di          ; save for return
        mov     ax, c[bp]
        mov     cx, n[bp]
        mov     ah, al
        shr     cx, 1
	jz	nowords
        rep     stosw
nowords:
        jnc     even
        stosb
even:
        mov     ax, bx
if FAR_DATA eq TRUE
        mov     dx, es
endif

FUN_LEAVE <di>
FUN_END _memset

end
+ARCHIVE+ movmem.asm    2369  7/31/87 13:37:42
; movmem - move a block of memory
; Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.

; contains MEMMOVE, MEMMOV, MOVMEM

include	prologue.ah

; entry	1,the destination address
;   2,the source address
;   3,the number of bytes to move

FUN_BEG _memmove,0,<si,di>

if FAR_DATA eq TRUE
@ptrlen	=	4
else	
@ptrlen	=	2
endif
a2	=	ARG_BASE
a1	=	a2+@ptrlen
a3	=	a1+@ptrlen

start:
	mov	cx,a3[bp]	;the number of bytes to move
        jcxz    dontbother

if FAR_DATA eq TRUE
	push	ds

	mov	si,word ptr a1[bp]
	mov	ax,word ptr a1+2[bp]
	mov	dx,si			; make it canonical
	shr	dx,1
	shr	dx,1
	shr	dx,1
	shr	dx,1
	add	ax,dx
	and	si,0fh
	mov	ds,ax

	mov	di,word ptr a2[bp]
	mov	bx,word ptr a2+2[bp]
	mov	dx,di
	shr	dx,1
	shr	dx,1
	shr	dx,1
	shr	dx,1
	add	bx,dx
	and	di,0fh
	mov	es,bx

else
	mov	ax,ds		;ensure that extra seg is correct
	mov	es,ax
	mov	si,a1[bp];	;the source address
	mov	di,a2[bp]	;the destination address
endif
if FAR_DATA eq TRUE
	cmp	ax,bx
	jb	movmem01
	ja	movmem00
endif
	cmp	si,di		;which way to do the move ?
	jb	movmem01	;do it in reverse order
movmem00:
	cld
	jmp	short movmem02	;must be this
movmem01:
	add	si,cx		;point to other end of string
	dec	si
	add	di,cx
	dec	di
	std			;backwards in memory
movmem02:
        rep     movsb		;do the move
done:
if FAR_DATA eq TRUE
	pop	ds
endif

dontbother:
	cld			;more DOS bugs
FUN_LEAVE <si,di>
FUN_END _memmove


FUN_BEG _memmov,0,<si,di>

if FAR_DATA eq TRUE
@ptrlen	=	4
else	
@ptrlen	=	2
endif
a1	=	ARG_BASE
a2	=	a1+@ptrlen
a3	=	a2+@ptrlen

        mov     ax, a1[bp]
        mov     cx, a2[bp]
        mov     a1[bp], cx
        mov     a2[bp], ax
if FAR_DATA eq TRUE
        mov     bx, a1+2[bp]
        mov     dx, a2+2[bp]
        mov     a1+2[bp], dx
        mov     a2+2[bp], bx
endif
        jmp     start
FUN_END _memmov

FUN_BEG _movmem,0,<si,di>

if FAR_DATA eq TRUE
@ptrlen	=	4
else	
@ptrlen	=	2
endif
a1	=	ARG_BASE
a2	=	a1+@ptrlen
a3	=	a2+@ptrlen

        mov     ax, a1[bp]
        mov     cx, a2[bp]
        mov     a1[bp], cx
        mov     a2[bp], ax
if FAR_DATA eq TRUE
        mov     bx, a1+2[bp]
        mov     dx, a2+2[bp]
        mov     a1+2[bp], dx
        mov     a2+2[bp], bx
endif
        jmp     start
FUN_END _movmem

end
+ARCHIVE+ n87init.asm   3279  7/15/87 10:57:26
; n87initl.asm - error handling routines for nofloat floats
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.

; REVISED "zap,12-jan-87,for real"
; REVISED "zap,34-feb-87,combine the models into one file
; REVISED "zap,15-jul-87,change to _DATA segment"

include prologue.ah

_DATA	segment
	assume ds:DGROUP
	fp_int_vecs	dw	24 dup (0)	; save int 34 thru 3E vectors
_DATA	ends

if FAR_CODE eq TRUE
	extrn	_bdos:far
	extrn	__exit:far

	if FAR_DATA eq TRUE
		public __main5lf, __i87rstlf
	else
		public __main5ln, __i87rstln
	endif
else
	extrn	_bdos:near
	extrn	__exit:near

	if FAR_DATA eq TRUE
		public __main5sf, __i87rstsf
	else
		public __main5sn, __i87rstsn
	endif
endif

_DATA segment
assume ds:DGROUP

mess_3E	db	0ah,0dh,'INTERRUPT 3E$'
mess_fp	db	0ah,0dh,'Floating point not loaded.$'
_DATA ends


_TEXT segment
assume cs:_TEXT, ds:DGROUP

if FAR_CODE eq TRUE
 if FAR_DATA eq TRUE
  __main5lf	proc far
 else
  __main5ln	proc far
 endif
else
 if FAR_DATA eq TRUE
  __main5sf	proc near
 else
  __main5sn	proc near
 endif
endif
	push	bp
	mov	bp, sp
	push	di
	push	ds
if FAR_CODE eq TRUE
if FAR_DATA eq TRUE
	mov	ax, DGROUP
	mov	ds, ax
endif
endif

	mov	di, offset fp_int_vecs	; save the interrupt vectors...
	mov	ax, seg fp_int_vecs
	mov	ds, ax
	mov	cx, 12		; int 34h through 3Fh
	mov	ax, 3534h
st_vec:	int	21h
	mov	ds:[di], bx
	add	di, 2

	mov	ds:[di], es
	add	di, 2
	inc	ax
	loop	st_vec

	pop	ds
	push	ds

	mov	dx, offset fp_int	; ... and load up the emulator's
	mov	ax, seg fp_int
	mov	ds, ax
	mov	cx, 0ah		; int 34h through 3Dh
	mov	ax, 2534h
ld_vec:	int	21h
	inc	ax
	loop	ld_vec

	mov	dx, offset int_3E		; INT 3E
	mov	bx, seg int_3E
	mov	ds, bx
	int	21h
	inc	ax

        xor     ax, ax
	pop	ds
	pop	di
	mov	sp, bp
	pop	bp
	ret
if FAR_CODE eq TRUE
 if FAR_DATA eq TRUE
  __main5lf	endp
 else
  __main5ln	endp
 endif
else
 if FAR_DATA eq TRUE
  __main5sf	endp
 else
  __main5sn	endp
 endif
endif


if FAR_CODE eq TRUE
 if FAR_DATA eq TRUE
  __i87rstlf	proc far
 else
  __i87rstln	proc far
 endif
else
 if FAR_DATA eq TRUE
  __i87rstsf	proc near
 else
  __i87rstsn	proc near
 endif
endif
	push	bp
	mov	bp, sp
	push	di
	push	ds
if FAR_CODE eq TRUE
if FAR_DATA eq TRUE
	mov	ax, DGROUP
	mov	ds, ax
endif
endif

	mov	di, offset fp_int_vecs
	mov	ax, seg fp_int_vecs
	mov	es, ax
	mov	ax, 2534h
	mov	cx, 12
vrst:	mov	dx, es:[di]
	add	di, 2
	mov	ds, es:[di]
	add	di, 2
	int	21h
	inc	ax
	loop	vrst

	pop	ds
	pop	di
	mov	sp, bp
	pop	bp
	ret
if FAR_CODE eq TRUE
 if FAR_DATA eq TRUE
  __i87rstlf	endp
 else
  __i87rstln	endp
 endif
else
 if FAR_DATA eq TRUE
  __i87rstsf	endp
 else
  __i87rstsn	endp
 endif
endif


fp_int	proc	far		; ititial emulator entry point
	mov	ax, seg mess_fp
	push	ax
	mov	ax, offset mess_fp
	push	ax
	mov	ax, 9
	push	ax
	call	_bdos
	mov	ax, 0FFh
	push	ax
	call	__exit		; doesn't return
fp_int	endp


int_3E	proc	far		; interrupt 3Eh - function unknown
	mov	ax, seg mess_3E
	push	ax
	mov	ax, offset mess_3E
	push	ax
	mov	ax, 9
	push	ax
	call	_bdos
	mov	ax, 0FFh
	push	ax
	call	__exit		; doesn't return
int_3E	endp


_TEXT	ends
end

+ARCHIVE+ outportb.asm   378 12/22/86 12:19:04
; outportb - write an 8 bit value to port
; Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.

include	prologue.ah

FUN_BEG _outportb,0,<>
FUN_ARG port,2
FUN_ARG value,2
	mov	dx,port[bp]	;get the port number
	mov	ax,value[bp]	;get the value to output
	xor	ah,ah		;zero the top byte
	out	dx,al		;put it out
FUN_LEAVE <>
FUN_END _outportb
end
+ARCHIVE+ outportw.asm   347 12/22/86 12:18:48
; outportw - write an 16 bit value to port
; Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.

include	prologue.ah

FUN_BEG _outportw,0,<>
FUN_ARG port,2
FUN_ARG value,2
	mov	dx,port[bp]	;get the port number
	mov	ax,value[bp]	;get the value to output
	out	dx,ax		;put it out
FUN_LEAVE <>
FUN_END _outportw
end
+ARCHIVE+ segread.asm    897  3/20/87 14:06:22
; segread - read the segment registers
; Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.

include	prologue.ah

; entry	1, the address of a 4 word structure to hold the seg values
;
; the format of the region is
; struct regs {
; 	unsigned cs;
; 	unsigned ss;
; 	unsigned ds;
; 	unsigned es;
; };

FUN_BEG _segread,0
FUN_ARG result,dp

if FAR_DATA eq TRUE
	mov	ax,ds			;save the ds value
	lds	bx,dword ptr result[bp] ;get the address of save area
	mov	4[bx],ax		;the ds value
else
	mov	bx,word ptr result[bp]
	mov	4[bx],ds		;the ds value
endif
if FAR_CODE eq TRUE
	mov	dx,result-2[bp]	        ;get callers cs value
	mov	[bx],dx			;set the cs value
else
        mov     [bx],cs                 ;set the cs value
endif
	mov	2[bx],ss
	mov	6[bx],es
if FAR_DATA eq TRUE
	mov	ds,ax			;restore ds
endif
	FUN_LEAVE 
FUN_END _segread
end

+ARCHIVE+ setjmp.asm    1518 10/22/87 15:45:46
; setjmp.asm - save the environment for later restoration by longjmp
; Copyright (c) 1984,85,86,87 Computer Innovations Inc, ALL RIGHTS RESERVED.

; 11-dec-86,zap,save si & di
; 27-dec-86,gee,cover all models
; 22-oct-87,zap,return location for small code"

include	prologue.ah

	_REGSP   equ 0   ;buffer indeces
	_REGBP   equ 2
	_RETOFF  equ 4
	_RETSEG  equ 6
	_REGSI   equ 8
	_REGDI   equ 10
	_REGDS   equ 12

; entry	1, address of a buffer to save the environment
; exit	ax contains zero

public	_setjmp

_TEXT segment
assume cs:_TEXT,ds:DGROUP

if      FAR_CODE eq TRUE
_setjmp	proc	far
	pop	ax		;offset
	pop	dx		;segment 
else
_setjmp proc    near
        pop     ax              ;offset
endif
if      FAR_DATA eq TRUE
	pop	bx		;environment offset 
        mov     cx,ds           ;save ds for exit
	pop	ds		;environment segment 
	sub	sp,4		;to the right place 
else
	pop	bx		;environment offset 
	sub	sp,2		;to the right place 
endif
	mov	_REGSP[bx],sp   ;save the sp
	mov	_REGBP[bx],bp   ;and bp
	mov	_RETOFF[bx],ax  ;return offset
if      FAR_CODE eq TRUE
	mov	_RETSEG[bx],dx  ;return segment
endif
	mov	_REGSI[bx],si   ;register variables 
	mov	_REGDI[bx],di
if      FAR_DATA eq TRUE
	mov	_REGDS[bx],cx   ;saved ds value
	mov	ds,cx		;restore ds
endif
if      FAR_CODE eq TRUE
	push	dx
	push	ax
else
	mov	dx,ax
endif
	xor	ax,ax		;return a zero
if      FAR_CODE eq TRUE
	ret
else
	jmp	dx		;and we are done
endif
_setjmp	endp
_TEXT ends
end

+ARCHIVE+ square.asm     499  8/05/87 17:07:02
; square - square number
; Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah

EXTERN	__fac,dp

FUN_BEG	_square,0,<ds>	; quick 8087 squaring function.
FUN_ARG	val,8
	fld	qword ptr val[bp]	; load in the arg to square.
	fmul	st,st(0)		; square the value.
	fstp	qword ptr DGROUP:__fac	; get the answer 
	mov	ax, offset DGROUP:__fac
if FAR_DATA eq TRUE
	mov	dx, seg DGROUP:__fac
endif
	fwait
FUN_LEAVE <ds>
FUN_END	_square
	end








+ARCHIVE+ sswitch.asm   1400  5/11/87 22:25:20
; Copyright (c) 1986 Computer Innovations, Inc, ALL RIGHTS RESERVED
;
;	sswitch: switch short integer value (binary search)
;

;	entry
;	value in ax
;	pointer to switch table in ds:bx
;	exit
;	jump address in bx

;	calling sequence
;	mov	ax,value		;lsw of value
;	mov	bx,word ptr xxx	;address of table
;	jmp	bx			;dispatch to code

;	table format
;	dw	number of entries 
;	dw	entry 1
;	dw	entry 2
;	.
;	.
;	.
;	dw	offset address for entry 1
;	dw	offset address for entry 2
;	dw	offset for default (after switch if none)
;

	include prologue.ah

FUN_BEG sswitch,0,<si,di>
	mov	si,bx
	xor	cx,cx		;zero lower limit
	mov	di,[si]	;get upper limit
	add	si,2		;could be done in table creation
	or	di,di		;no entries ?
	jz	default		;get out fast
	add	di,di		; entries are short	- jsc
again0:	sub	di,2		;byte offset to last entry
again:	cmp	cx,di		;any candidates left ?
	jg	default		;nope take default
	mov	bx,cx		;get mid point
	add	bx,di
	shr	bx,1
	and	bl,0feh		;force to word offset
	cmp	ax,[si+bx]
	jl	low
	je	equal
high:	mov	cx,bx		;reset limit
	add	cx,2		;but higher
	jmp	short again
low:	mov	di,bx
	or	di,di
	jnz	again0
default:mov	bx,[si-2]	; length of table
	shl	bx,1		; scale it
equal:	add	bx,[si-2]	;get table address
	add	bx,[si-2]	; word table -jsc
	mov	bx,[bx+si]	; get the offset (+si jsc)
FUN_LEAVE	<si,di>
FUN_END	sswitch
	end

+ARCHIVE+ stackava.asm   308  9/24/87 16:06:36
; stackavail - how much room left on the stack
; Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah

EXTERN _end,byte

FUN_BEG _stackavail,0,<ds>
	mov	ax, sp
if SET_SSDS eq TRUE
	sub	ax, offset DGROUP:_end
endif
	FUN_LEAVE <ds>
FUN_END _stackavail
end

+ARCHIVE+ stat87.asm     247 12/22/86 12:18:58
; stat87.asm - Get the 8087 status word.
; Copyright (c) 1986 Computer Innovations Inc, ALL RIGHTS RESERVED.

include prologue.ah
.8087

FUN_BEG __status87,2,<>
	fstsw	-2[bp]
	fwait
	mov	ax, -2[bp]
FUN_LEAVE <>
FUN_END __status87
end
+ARCHIVE+ sti.asm        299 11/25/87 16:09:36
; sti: Enables processor interrupt facility.
; Copyright (c) 1986,87 Computer Innovations Inc, ALL RIGHTS RESERVED.
 
  	include	prologue.ah
 
_TEXT	segment
  	assume cs:_TEXT

public _sti

if FAR_CODE eq TRUE
_sti	proc far
else
_sti	proc near
endif
	sti
	ret
FUN_END _sti
	end

+ARCHIVE+ strcat.asm    1213  3/23/87 13:17:10
; strcat - concatinate two strings
; Copyright (C) 1987 Computer Innovations, Inc.  ALL RIGHTS RESERVED

include	prologue.ah

FUN_BEG _strcat,0,<si,di>
FUN_ARG dest,dp			; 1, the destination address
FUN_ARG src,dp			; 2, the source address

	cld			;set in the direction of up
if FAR_DATA eq TRUE
	push	ds		;save it
	les	di,dword ptr src[bp]	;get source address
	lds	si,dword ptr src[bp]	;for later
else
	mov	di,ds
	mov	es,di
	mov	di,src[bp]	;get source address
	mov	si,di		;for later
endif
	xor	ax,ax		;get the length of string
	xor	cx,cx		;set the counter
	dec	cx		;to 64k
	repnz	scasb		;till zero
	not	cx		;number of bytes to move
	mov	dx,cx		;save for later

if FAR_DATA eq TRUE
	les	di,dword ptr dest[bp]	;get destination address
else
	mov	di,dest[bp]	;get destination address
endif
	xor	cx,cx		;set the counter
	dec	cx		;to 64k
	repnz	scasb		;till zero
	dec	di		;over-write the zero

	mov	cx,dx		;restore count

	test	cl,1		;odd number to move ?
	jz	nope
	lodsb
	stosb			;doit
nope:
	shr	cx,1
	rep	movsw		;move them
	mov	ax,dest[bp]	;return dest address
if FAR_DATA eq TRUE
	mov	dx,es
	pop	ds		;restore ds
endif

FUN_LEAVE <si,di>
FUN_END _strcat

end
+ARCHIVE+ strcmp.asm    1089  3/25/87 21:30:28
; strcmp - compare 2 strings
; Copyright (C) 1987 Computer Innovations, Inc.  ALL RIGHTS RESERVED

include	prologue.ah

FUN_BEG _strcmp,0,<si,di>
FUN_ARG s2,dp			; 1, string address 1 (a)
FUN_ARG s1,dp			; 2, string address 2 (b)

	cld			;set in the direction of up
if FAR_DATA eq TRUE
	les	di,dword ptr s1[bp]	;get source address
else
	mov	di,ds
	mov	es,di
	mov	di,s1[bp]	;get source address
endif
	xor	ax,ax		;get the length of string
	xor	cx,cx		;set the counter
	dec	cx		;to 64k
	repnz	scasb		;till zero
	not	cx		;number of bytes to compare
if FAR_DATA eq TRUE
	push	ds
	les	di,dword ptr s1[bp]
	lds	si,dword ptr s2[bp]
else
	mov	di,s1[bp]
	mov	si,s2[bp]
endif
	test	cl,1		;odd number to compare ?
	jz	nope
	cmpsb
	jnz	setax1		;thats it then
nope:
	shr	cx,1
	repe	cmpsw		;do the compare
	jz	alldone		;they are equal
	sub	si,2
	sub	di,2
	cmpsb
	jnz	setax1
	cmpsb
setax:	jz	alldone
setax1:	jg	upone
	dec	ax
	jmp	alldone
upone:	inc	ax
alldone:
if FAR_DATA eq TRUE
	pop	ds		;restore ds
endif

FUN_LEAVE <si,di>
FUN_END _strcmp

end
+ARCHIVE+ strcpy.asm     907  4/10/87 11:03:32
; strcpy - copy a string
; Copyright (C) 1987 Computer Innovations, Inc.  ALL RIGHTS RESERVED

include	prologue.ah

FUN_BEG _strcpy,0,<si,di>
FUN_ARG dest,dp			; 1, the destination address
FUN_ARG src,dp			; 2, the source address

	cld			;set in the direction of up
if FAR_DATA eq TRUE
	les	di,dword ptr src[bp]	;get source address
else
	mov	di,ds
	mov	es,di
	mov	di,src[bp]	;get source address
endif
	xor	ax,ax		;get the length of string
	xor	cx,cx		;set the counter
	dec	cx		;to 64k
	repnz	scasb		;till zero
	not	cx		;number of bytes to move
if FAR_DATA eq TRUE
	push	ds
	lds	si,dword ptr src[bp]
	les	di,dword ptr dest[bp]
else
	mov	si,src[bp]
	mov	di,dest[bp]
endif
	shr	cx,1
	rep	movsw		;move them
	jnc	nope
	movsb
nope:
	mov	ax,dest[bp]	;return dest address
if FAR_DATA eq TRUE
	mov	dx,es
	pop	ds		;restore ds
endif

FUN_LEAVE <si,di>
FUN_END _strcpy

end
+ARCHIVE+ strlen.asm     522  3/23/87 11:42:38
; strlen - return the length of a string
; Copyright (C) 1987 Computer Innovations, Inc.  ALL RIGHTS RESERVED

include	prologue.ah

FUN_BEG _strlen,0,<di>
FUN_ARG string,dp

	cld			;set in the direction of up
if FAR_DATA eq TRUE
	les	di,dword ptr string[bp]	;get pointer
else
	mov	di,ds
	mov	es,di
	mov	di, string[bp]	;get the address of the string
endif
	xor	ax,ax
	xor	cx,cx		;set the counter
	dec	cx		;to 64k
	repnz	scasb		;till zero
	sub	ax,2
	sub	ax,cx

FUN_LEAVE <di>
FUN_END _strlen

end
+ARCHIVE+ sysint.asm    2078  6/30/87 15:15:30
; SYSINT: Executes an interrupt with registers set up.
; Copyright (C) 1986 by Computer Innoviations, Inc. ALL RIGHTS RESERVED.

; 14-nov-86,jew,rewrite

	include	prologue.ah

;	entry	1, the interrupt vector (*4  for absolute address)
;		2, pointer to register values for call
;		3, pointer to area to save returned register values
;
;	exit 	machine status register value returned as func value
;
;	structure for register values is
;		struct regval {unsigned ax,bx,cx,dx,si,di,ds,es;};

_TEXT	segment
		assume	cs:_TEXT,ds:nothing
FUN_PROC	_sysint
FUN_ARG	a1,2
FUN_ARG	a2,dp
FUN_ARG	a3,dp
 
	enter	0,0
	push	ds
	push	es
	push	si
	push	di
	cld		;DOS 2 bug sometimes leaves this set!
	mov	al,a1[bp]
	cmp	al,25h
	je	special_case
	cmp	al,26h
	je	special_case
	push	di
special_case:
	pushf
	push	cs
if CPU_TYPE eq 0
	mov	ax,offset _TEXT:part2
	push	ax
else
	push	offset _TEXT:part2
endif
	mov	ax,-10[bp]
	and	ah,0FCh	; Clear IF and TF bits (ONLY!)
	push	ax
	xor	bx,bx
	mov	ds,bx
	mov	bl,a1[bp]
if CPU_TYPE eq 0
	shl	bx,1
	shl	bx,1
else
	shl	bx,2
endif
	push	2[bx]
	push	[bx]
if FAR_DATA eq TRUE
	lds	si,a2[bp]
else
	mov	ds,-2[bp]
	mov	si,a2[bp]
endif
	mov	di,ss
	mov	es,di
	sub	sp,16
	mov	di,sp
	mov	cx,8
	rep	movsw	; Fastest way of loading up stack -
	pop	ax
	pop	bx
	pop	cx
	pop	dx
	pop	si
	pop	di
	pop	ds
	pop	es
	iret
part2:
	mov	bp,sp	; BP may have been altered.  We must SP, and
	pushf		; the known discrepancy between them here (8).
	push	es
	push	ds
	push	di
	push	si
	push	dx
	push	cx
	push	bx
	push	ax
if FAR_DATA eq TRUE
	les	di,dword ptr a3+10[bp]
else
	mov	es,-2+10[bp]	;We're loading ES with the value of
				;C86's DS register.  Tricky!
	mov	di,a3+10[bp]
endif
	mov	si,ss
	mov	ds,si
	mov	si,sp
	mov	cx,8
	cld
	rep	movsw
	add	sp,16
	mov	ax,-2[bp]	;Return flag value (trust me)
	popf			;Set processor to that state, too!
	pop	di		;That's the extra copy
	pop	di		;That's the real McCoy.
	pop	si
	pop	es
	pop	ds
	pop	bp
	ret			;all done
FUN_END	_sysint
	end
+ARCHIVE+ sysint21.asm  1410 12/22/86 12:21:30
; sysint21 - execute an interrupt with registers set up
; Copyright (c) 1984,85,86 Computer Innovations Inc, ALL RIGHTS RESERVED.
	title	sysint21

	include	prologue.ah

;	entry	1, pointer to register values for call
;		2, pointer to area to save returned register values

;	exit 	machine status register value returned as func value

;	structure for register values is
;		struct regval{ unsigned ax,bx,cx,dx,si,di,ds,es;};

FUN_BEG	_sysint21,0,<si,di>
FUN_ARG source,dp
FUN_ARG dest,dp
	push	ds		;save important registers
if	FAR_DATA eq TRUE 
	lds	bx,dword ptr source[bp]
else
	mov	bx,source[bp]	;get source registers
endif
	mov	ax,[bx]
	mov	cx,04[bx]
	mov	dx,06[bx]
	mov	si,08[bx]
	mov	di,10[bx]
	mov	es,14[bx]
	push	word ptr 02[bx]	   ; to go in bx
	push	word ptr 12[bx]	   ; to go in ds
	pop	ds
	pop	bx

	int	21h		;do the interrupt
sysint1:
	pushf			;save result flags for return

	push	bx		; need bx and ds
	push	ds

if	FAR_DATA eq TRUE
	lds	bx,dword ptr dest[bp]
else
	mov	bx,ss
	mov	ds,bx
	mov	bx,dest[bp]	;get dest regs
endif

	mov	[bx],ax	; set rrv
	mov	04[bx],cx
	mov	06[bx],dx
	mov	08[bx],si
	mov	10[bx],di
	mov	14[bx],es
	pop	word ptr 12[bx]	; ds
	pop	word ptr 02[bx]	; bx
	mov	ax,-8[bp]	;result flags for user
	popf			;result flags for the processor itself!
	pop	ds		;restore segment registers
FUN_LEAVE	<si,di>
FUN_END	_sysint21
	end
