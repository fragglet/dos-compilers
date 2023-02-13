	TITLE	CXKERR -- Stack overflow error routin
	SUBTTL	Copyright 1985 by Lattice, Inc.
	NAME	CXKERR
	INCLUDE	DOS.MAC
;**
;
; name		CXKERR -- terminate execution after stack overflow
;
; description	This function is called when a stack overflow is detected.
;		It displays a message and aborts.
;
;**
	SETX
	FEXTRN	XCABT

	DSEG
OVFERR	DB	"*** STACK OVERFLOW ***",0DH,0AH,"$"
	ENDDS

	PSEG
	BEGIN	CXKERR
	ENTRY	XCOVF
	MOV	DX,OFFSET DGROUP:OVFERR
	JMP	XCABT
CXKERR	ENDP
	ENDPS
	END

