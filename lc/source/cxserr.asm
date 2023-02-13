	TITLE	CXSERR -- Process system error code
	SUBTTL	Copyright 1985 by Lattice, Inc.
	NAME	CXSERR
	INCLUDE	DOS.MAC
	SETX
;**
;
; name		CXSERR -- process system error code (retain regs)
;		CXSERZ -- process system error code (zero regs)
;		CXSERA -- process system error code in AX
;		CXCERR -- callable entry point for CXSERA
;
; inputs	AL => MSDOS error code if CF is set (CXSERR,CXSERZ)
;		AX => OS/2 error code if AX is non-zero (CXSERA)
;		1st arg => OS/2 error code or 0 (CXCERR)
;
; outputs	1. AX,BX are -1 if error, else
;		    Retained if CXSERR
;		    Cleared if CXSERZ
;		2. UNIX error code is put into errno.  
;		3. DOS error info is save as noted below.
;
; description	CXSERR translates an MSDOS error code into a UNIX
;		error code.  MSDOS errors are indicated by the carry flag
;		being set when INT21 returns.  For DOS version 2, the true
;		error code is in AX, and CXSERR puts it into _oserr.  For
;		DOS version 3 and above, the OS/2 family-mode function
;		DosErrClass is called to get the true error code, class,
;		locus, and action.  These are placed into _oserr, _oserc,
;		_oserl, and _osera, respectively.
;		
;		The alternate entry point CXSERZ is the same as CXSERR
;		except that it clears AX and BX if no error occurred.
;
;		CXSERA is used in the ADOS environment, where a non-zero
;		value in AX indicates an error.
;
;**
	PUBLIC	_OSERC,_OSERA,_OSERL,_OSCEF
	DSEG

;
; DOS error information
;
	EXTRN	_DOS:BYTE		; dos version number
	EXTRN	ERRNO:WORD		; UNIX error number
	EXTRN	_OSERR:WORD		; error code
_OSERC	DB	0			; error class
_OSERA	DB	0			; error action
_OSERL	DB	0			; error locus
_OSCEF	DB	0			; critical error flag
;
; DOS-to-UNIX error code translation table
;
ERRTAB	DB	0			; 00  no error
	DB	22			; 01  invalid function
	DB	2			; 02  file not found
	DB	2			; 03  path not found
	DB	23			; 04  no handles left
	DB	13			; 05  access denied
	DB	9			; 06  invalid handle
	DB	0			; 07  memory pool is mutilated
	DB	12			; 08  insufficient memory
	DB	22			; 09  invalid memory block address
	DB	22			; 10  invalid environment
	DB	22			; 11  invalid format
	DB	22			; 12  invalid access code
	DB	22			; 13  invalid data
	DB	0			; 14  
	DB	19			; 15  invalid drive
	DB	13			; 16  attempt to remove CD
	DB	13			; 17  not same device
	DB	24			; 18  no more files
	DB	30			; 19  can't write protected disk
	DB	19			; 20  unknown unit
	DB	6			; 21  drive not ready
	DB	6			; 22  unknown command
	DB	5			; 23  data error
	DB	0			; 24  bad request structure length
	DB	5			; 25  seek error
	DB	5			; 26  unknown media type
	DB	5			; 27  sector not found
	DB	5			; 28  printer out of paper
	DB	5			; 29  write fault
	DB	5			; 30  read fault
	DB	5			; 31  general failure
	DB	13			; 32  sharing violation
	DB	13			; 33  lock violation
	DB	5			; 34  invalid disk change
	DB	5			; 35  FCB unavailable
	DB	0			; 36
	DB	0			; 37
	DB	0			; 38
	DB	0			; 39
	DB	0			; 40
	DB	0			; 41
	DB	0			; 42
	DB	0			; 43
	DB	0			; 44
	DB	0			; 45
	DB	0			; 46
	DB	0			; 47
	DB	0			; 48
	DB	0			; 49
	DB	0			; 50
	DB	0			; 51
	DB	0			; 52
	DB	0			; 53
	DB	0			; 54
	DB	0			; 55
	DB	0			; 56
	DB	0			; 57
	DB	0			; 58
	DB	0			; 59
	DB	0			; 60
	DB	0			; 61
	DB	0			; 62
	DB	0			; 63
	DB	0			; 64
	DB	0			; 65
	DB	0			; 66
	DB	0			; 67
	DB	0			; 68
	DB	0			; 69
	DB	0			; 70
	DB	0			; 71
	DB	0			; 72
	DB	0			; 73
	DB	0			; 74
	DB	0			; 75
	DB	0			; 76
	DB	0			; 77
	DB	0			; 78
	DB	0			; 79
	DB	17			; 80  file exists
	DB	0			; 81
	DB	0			; 82  cannot make
	DB	0			; 83  fail on INT24

MAXNO	EQU	83			; highest DOS error number
	ENDDS

	EXTRN	DosErrClass:FAR

	PSEG
;
; OS/2 error handler
;
	BEGIN	CXSERA
	OR	AX,AX
	JZ	S4			; branch if no error
	STC
;
; DOS family error handler
;
	ENTRY	CXSERR
	JNC	S4			; branch if no error
S0:	TEST	_OSCEF,2
	JZ	S0A			; branch if no critical error
	MOV	AX,83			; set error code 83
	AND	_OSCEF,1		; reset critical error flag
S0A:	MOV	_OSERR,AX		; save OS error code
	CMP	_DOS,3
	JL	S1			; branch if DOS 1 or 2
	IF	FAMILY
	SUB	SP,6
	MOV	BX,SP
	PUSH	AX			; push error code
	PUSH	SS			; push local "class" RA
	PUSH	BX
	PUSH	SS			; push local "action" RA
	ADD	BX,2
	PUSH	BX
	PUSH	SS			; push local "locus" RA
	ADD	BX,2
	PUSH	BX
	CALL	DosErrClass		; get extended error codes
	MOV	CX,SS:[BX-4]
	MOV	_OSERC,CL
	MOV	CX,SS:[BX-2]
	MOV	_OSERA,CL
	MOV	CX,SS:[BX]
	MOV	_OSERL,CL
	ADD	SP,6
	ENDIF
S1:	MOV	AX,_OSERR
	CMP	AL,MAXNO		; translate DOS code to UNIX code
	JLE	S2
	XOR	AL,AL
S2:	MOV	BX,OFFSET DGROUP:ERRTAB
	XLAT
	XOR	AH,AH
	OR	AX,AX
	JNZ	S3
	DEC	AX
S3:	MOV	ERRNO,AX		; load errno
	MOV	AX,-1			; return -1 (short and long form)
	MOV	BX,AX
	RET
S4:	TEST	_OSCEF,2
	JNZ	S0			; branch if critical error
	MOV	_OSERR,0		; reset _OSERR
	RET
;
; Enter here to clear AX,BX if no error
;
	ENTRY	CXSERZ
	JC	S0
	TEST	_OSCEF,2
	JNZ	S0
	XOR	AX,AX
	XOR	BX,BX
	JMP	S4
;
; This is a C-callable version of CXSERA
;
	ENTRY	CXCERR
	PUSH	BP
	MOV	BP,SP
	MOV	AX,[BP+X]
	CALL	CXSERA
	POP	BP
	RET
CXSERA	ENDP
	ENDPS
	END
