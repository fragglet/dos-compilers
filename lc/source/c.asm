	TITLE	CXINIT - Lattice C Family-Mode Startup Routine
	SUBTTL	Copyright 1982,1983,1984,1985,1986,1987,1988 by Lattice, Inc.
	NAME	CXINIT
	INCLUDE	DOS.MAC
;*****************************************************************************
;
; name		CXINIT -- Lattice C startup routine for DOS and OS/2
;
; description	This is the startup routine for a C program under either
;		the DOS or the OS/2 environment, including "family mode".
;		It performs various low-level initializations and then 
;		calls _main.  
;
;		Portions of this module are conditionally assembled,
;		depending on the state of three variables named DOS,
;		OS2, and FAMILY.  These are defined in the common macro
;		file named LC.MAC.  The "factory supplied" version
;		is configured for family mode (i.e. FAMILY=1, DOS=0,
;		OS2=0).  You can change these to produce a smaller
;		version tailored for DOS only or OS/2 only.
;
;		NOTE:  In order for the segment structure to work correctly,
;		this module must be assembled with Version 3 or later of the
;		Microsoft assembler.  Specifically, older assemblers emit
;		segments in alphabetical order, while Version 3 and later
;		emit them in the order that they appear.   The latter is
;		required for this module.
;
;*****************************************************************************
;
; Assembly parameters
;
TAB	EQU	09H			; tab character
STKMIN  EQU	2048			; minimum stack size in c.asm
ENVMIN	EQU	1024			; minimum environment size
NHSIZE	EQU	1024			; near heap size
ABTCODE	EQU	-1			; abort code for startup routine
;*****************************************************************************
;
; External program references
;

	EXTRN	DosGetMachineMode:FAR
	EXTRN	DosGetHugeShift:FAR
	EXTRN	DosGetVersion:FAR
	EXTRN	DosExit:FAR
	EXTRN	DosDevConfig:FAR
	EXTRN	VioWrtTTY:FAR
	EXTRN	DosFreeSeg:FAR
	
	IF	LDATA EQ 0
	EXTRN	__SSIZE:WORD
	ENDIF
	

	FEXTRN	_main
;*****************************************************************************
;
; Define data group
;
	IF	LDATA
DGROUP	GROUP	NULL,NDATA,DATA,UDATA,NHEAP,HDATA
	ELSE
DGROUP	GROUP	NULL,NDATA,DATA,UDATA,STACK,NHEAP,HDATA
	ENDIF
	ASSUME	DS:DGROUP
;*****************************************************************************
;
; Define program segment
;
_TEXT	SEGMENT	BYTE PUBLIC 'CODE'
	ASSUME	CS:_TEXT

;
; Execution begins here
;
	PUBLIC	CXINIT
CXINIT	PROC	FAR
	CLD				; clear direction flag
	IF	FAMILY
	PUSH	AX			; check if DOS or OS/2 entry
	MOV	AX,ES
	OR	AX,AX
	POP	AX
	JZ	I_OS2			; branch if OS/2 or Family
	ENDIF
;*****************************************************************************
;
; Save startup information from DOS
;
	IF	DOS OR FAMILY
I_DOS:	MOV	AX,DGROUP		; set DS to DGROUP
	MOV	DS,AX
	IF	LDATA EQ 0
	MOV	BX,OFFSET DGROUP:STACK
	SUB	BX,__SSIZE
	CLI				; make stack relative to DGROUP
	MOV	SS,AX
	ADD	SP,BX
	STI
	ENDIF 
	MOV	AX,ES			; save PSP pointer
	MOV	WORD PTR _PSP+2,AX
	SUB	_TSIZE,AX		; compute size of basic block
	MOV	BX,_TSIZE		; release unneeded space
	MOV	AH,4AH
	INT	21H
	MOV	AX,ES:2CH		; save environment pointer
	MOV	WORD PTR _ENV+2,AX
	MOV	AX,ES			; save residual command line pointer
	MOV	WORD PTR _CMD+2,AX	
	MOV	WORD PTR _CMD,80H
	MOV	BL,BYTE PTR ES:80H
	MOV	BYTE PTR ES:80H,0	; put null string at beginning		
	MOV	DI,81H
	CMP	BL,0			; see if any arguments exist
	JZ	DOS1
	MOV	AL,13			; find terminating CR
	MOV	CX,128
	MOV	DI,81H
	REPNE	SCASB
	JE	DOS0
	MOV	DI,82H
DOS0:	DEC	DI			; backup to the CR
DOS1:	MOV	BYTE PTR ES:[DI],0	; replace with null byte		 
	JMP	BOTH
	ENDIF
;*****************************************************************************
;
; Save startup information from OS/2 or DOS stub loader
;
	IF	OS2 OR FAMILY
I_OS2:	INC	_XMODE			; set family mode flag
	MOV	WORD PTR _ENV+2,AX	; save environment pointer
	MOV	WORD PTR _CMD,BX	; save command line pointer
	MOV	WORD PTR _CMD+2,AX
;
; Determine machine mode (real or protected)
;
	PUSH	DS
	CPUSH	<OFFSET DGROUP:_PMODE>
	CALL	DosGetMachineMode
	CMP	_PMODE,0
	JE	BOTH			; branch if real mode
	INC	_XMODE			; set OS/2 mode flag
;
; Get segment increment value
;
	PUSH	DS
	CPUSH	<OFFSET DGROUP:_SBIT>
	CALL	DosGetHugeShift		; returns shift value
	MOV	CL,BYTE PTR _SBIT	; convert to increment
	MOV	AX,1
	SHL	AX,CL
	MOV	_SINC,AX
	ENDIF
;*****************************************************************************
;
; Common initialization for DOS and OS/2
;
BOTH:	SUB	_USIZE,OFFSET DGROUP:UDATA  ; adjust uninitialized data size
	SUB	_NMSIZE,OFFSET DGROUP:NHEAP ; adjust near heap size
	MOV	_SSIZE,SP		; save stack size
	ADD	_SSIZE,2
	IF	LDATA EQ 0
	MOV	AX,__SSIZE
	SUB	_DSIZE,AX
	SUB	_USIZE,AX
	SUB	_BASE,AX
	SUB	_SBASE,AX
	SUB	_SSIZE,OFFSET DGROUP:STACK  ; adjust stack size
	ADD	_SSIZE,AX
	MOV	_TOP,SP			; save top of stack
	ENDIF
;
; Free CX_BSS and FHEAP place holder if empty
; This allows heap growth without LMM in most S and P programs
;
	IF	LDATA EQ 0
	CMP	_XMODE,1			; family mode?
	JNZ	BOTH1				; no, skip this
	MOV	AX,WORD PTR _XSIZE		; compare start and end of cx_bss
	MOV	BX,WORD PTR _ZSIZE
	CMP	AX,BX
	JNZ	BOTH1
	PUSH	AX
	CALL	DosFreeSeg
BOTH1:	
	ENDIF
;
; Get operating system version number
;
	PUSH	DS			; get version number
	CPUSH	<OFFSET DGROUP:_DOS>
	CALL	DosGetVersion
	MOV	AX,WORD PTR _DOS	; flip major/minor
	XCHG	AL,AH
	MOV	WORD PTR _DOS,AX
	CMP	AL,2
	JGE	M0			; branch if DOS 2 or later
DOSABT:	MOV	DX,OFFSET DGROUP:DOSERR	; abort if incorrect DOS version
	JMP	NEAR PTR XCABT
ENVABT: MOV	DX,OFFSET DGROUP:ENVERR	; abort if corrupted environment
	JMP	NEAR PTR XCABT	
;
; Clear the uninitialized data area
;
M0:	XOR	AX,AX
	MOV	CX,_USIZE
	LES 	DI,DWORD PTR _UBASE
	REP 	STOSB
;
; Compute environment size
;
	LES	DI,_ENV
;	XOR	AX,AX			; AX is still zero from above
	MOV	CX,7FFFH
M01:	REPNE	SCASB			; measure 1st env string
	JNZ	ENVABT			; abort if corrupted environment
	INC	_ENVC			; bump environment string count
	SCASB
	JNZ	M01			; null string marks end of env
	CMP	_DOS,2
	JBE	M02			; bypass arg 0 work if DOS 2 or earlier
	MOV	WORD PTR _ENV,DI	; save arg0 pointer for later
	IF	FAMILY
	CMP	_XMODE,0
	JNE	M02			; branch if OS/2
	ENDIF
	IF	DOS OR FAMILY
	ADD	WORD PTR _ENV,2		; bypass arg count
	ENDIF
M02:	MOV	_ENVL,DI	 	; save environment size
	ADD	DI,_ENVC		; compute size of new env area
	ADD	DI,_ENVC
	ADD	DI,2
	IF	LDATA
	ADD	DI,_ENVC
	ADD	DI,_ENVC
	ADD	DI,2
	ENDIF
	MOV	_EUSED,DI
;
; Allocate environment space at top of stack
;
M2:	MOV	AX,_ENEED		; get needed environment size
	CMP	AX,ENVMIN
	JA	M21			; branch if above minimum
	MOV	AX,ENVMIN		; else use minimum
M21:	CMP	AX,_EUSED
	JA	M22			; branch if greater than actual size
	MOV	AX,_EUSED		; else use actual size
M22:	MOV	_ESIZE,AX		; save environment size
	CALL	STKCHK			; check if stack is large enough
	JNC	M23			; branch if yes
STKABT:	MOV	DX,OFFSET DGROUP:STKERR	; abort if stack too small
	JMP	NEAR PTR XCABT
M23:	SUB	SP,AX			; grab the space
	AND	SP,0FFFEH
	MOV	_EBASE,SP		; set up environment pointer
;
; Move environment strings to stack
;
	PUSH	DS
	LES	DI,DWORD PTR _EBASE	; get new env pointer
	MOV	CX,_ENVL		; get original env length
	LDS	SI,_ENV			; get original env pointer
	XOR	SI,SI
	REP	MOVSB			; move it
	POP	DS
;
; Build environment vector
;
	PUSH	DS
	MOV	WORD PTR environ,DI	; save vector address
	IF	LDATA
	MOV	WORD PTR environ+2,ES
	ENDIF
	MOV 	CX,-1			; set loop count for scanning
	MOV	BX,_ENVC		; get number of vector entries
	LES	DI,DWORD PTR _EBASE 	; get environment pointer
	LDS	SI,DWORD PTR environ	; get vector pointer
	XOR	AX,AX			; prepare to scan for nulls
M24:	MOV	[SI],DI			; save pointer in vector
	ADD	SI,2
	IF	LDATA
	MOV	[SI],ES
	ADD	SI,2
	ENDIF
	REPNE	SCASB			; scan to next env string
	DEC	BX			; loop till done
	JG	M24
	MOV	[SI],AX			; terminate vector with null pointer
	IF	LDATA
	MOV	[SI+2],AX
	ENDIF
	POP	DS
;
; Parse command line into null-terminated strings on the stack
;
M4:	MOV	DX,DS			; save DS in DX for awhile
	LDS	SI,DWORD PTR _CMD	; get pointer to residual command
M41:	LODSB				; skip verb string
	OR	AL,AL
	JNZ	M41
	MOV	DS,DX
	MOV	WORD PTR _CMD,SI	; update command pointer
	LDS	SI,DWORD PTR _CMD	; get pointer to residual command
M42:	CALL	SKIPWS			; advance to first arg
	MOV	CX,SI			; save its location
M43:	LODSB				; measure the argument string 
	OR	AL,AL
	JNZ	M43
	SUB	SI,CX
	INC	SI			; add 1 for extra null terminator
	SUB	SP,SI			; allocate stack space
	MOV	DS,DX
	MOV	WORD PTR _ARG,SP	; save argument array pointer
	LES	DI,DWORD PTR _ARG	; prepare to move command line
	LDS	SI,DWORD PTR _CMD
	MOV	SI,CX
	XOR	CX,CX
M44:	CALL	SKIPWS			; skip white space
	OR	AL,AL
	JZ	M48			; branch if end of command
	INC	CX			; bump arg count
	CMP	AL,'"'
	JNE	M46			; branch if not quoted arg
	LODSB				; bypass first quote
M45:	LODSB				; copy quoted arg
	OR	AL,AL
	JZ	M47
	CMP	AL,'"'
	JE	M47
	CMP	AL,'\'
	JNE	M451
	LODSB
	OR	AL,AL
	JZ	M47
M451:	STOSB
	JMP	M45
M46:	LODSB				; copy non-quoted arg
	OR	AL,AL
	JZ	M47
	CMP	AL,' '
	JE	M47
	CMP	AL,TAB
	JE	M47
	STOSB
	JMP	M46
M47:	OR	AL,AL			; set status for end of command
	MOV	AL,0			; put null terminator on string
	STOSB
	JNZ	M44			; loop if not end of command
M48:	XOR	AX,AX			; terminate array with null string
	STOSB
	MOV	DS,DX			; restore DS
	MOV	_ARGC,CX		; save argument count
	JMP	M5
;
; Put null program name at front of argument array for DOS 2
;
M5:	CMP	_DOS,2
	JA	M6
	CPUSH	0
	INC	SP
	MOV	WORD PTR _ARG,SP
	JMP	M7
;
; Copy program name to front of argument array if not DOS 2
;
M6:	LDS	SI,_ENV			; get pointer to arg0 in environment
	MOV	CX,SI			; save starting offset
M60:	LODSB				; measure string length
	OR	AL,AL
	JNZ	M60
	SUB	SI,CX			
	SUB	SP,SI			; allocate stack space
	MOV	DS,DX			; update arg array pointer
	MOV	WORD PTR _ARG,SP
	LES	DI,DWORD PTR _ARG	; move the string
	LDS	SI,_ENV
M61:	LODSB
	STOSB
	OR	AL,AL
	JNZ	M61		
	MOV	DS,DX			; restore DS
	INC	_ARGC			; bump arg count
	MOV	WORD PTR _ENV,0		; reset original environment pointer
;
; Construct argv in stack
;
M7:	MOV	AX,_ARGC		; compute vector size
	INC	AX
	ADD	AX,AX
	IF	LDATA
	ADD	AX,AX
	ENDIF
	AND	SP,0FFFEH		; make stack pointer even
	SUB	SP,AX			; allocate stack space
	MOV	BP,SP			; set up vector pointer SS:BP
	LES	DI,DWORD PTR _ARG	; get arg array pointer ES:DI
	MOV	_ARGV,BP		; save arg vector pointer
	XOR	AX,AX			; build the vector
	MOV	BX,_ARGC
	MOV	CX,-1
M71:	MOV	[BP],DI
	ADD	BP,2
	IF	LDATA
	MOV	[BP],SS
	ADD	BP,2
	ENDIF
	REPNE	SCASB
	DEC	BX
	JG	M71
	MOV	[BP],AX			; put null pointer at end
	IF	LDATA
	MOV	[BP+2],AX
	ENDIF
;
; initialize 8087 numeric data processor
;
	PUSH	DS			; push pointer to _NDP
	CPUSH	<OFFSET DGROUP:_NDP>
	CPUSH	3			; request 80287 status
	CPUSH	0	
	CALL	DosDevConfig
;
; set up args for _main and call it
;
M9:	PUSH	DS			; make ES same as DS
	POP	ES
	CPUSH	0			; push 0 to terminate stack frame list
	MOV	BP,SP			; load stack frame pointer
	CALL	_main	 		; call C main
	MOV	BX,1			; set action code to end all threads
	PUSH	BX
	PUSH	AX			; pass on the termination code
	CALL	DosExit
;*****************************************************************************
;
; name		SKIPWS -- skip white space
;
; description	This function is used to skip white space (i.e. blanks
;		and tabs) in the string referenced by DS:SI.  It
;		advances SI to point to the first non-white character,
;		and it returns that character in AL.  If the terminating
;		null is hit, AL will contain zero.
;
;*****************************************************************************
SKIPWS	PROC	NEAR
SKIP1:	LODSB
	CMP	AL,' '
	JE	SKIP1
	CMP 	AL,TAB
	JE 	SKIP1
	DEC	SI
	RET
SKIPWS	ENDP	
;*****************************************************************************
;
; name		STKCHK -- check for stack overflow
;
; description	This function checks if the stack has enough space to 
;		accomodate the byte count in AX.  If not, it returns
;		with CF set; otherwise CF is reset.  All registers are
;		preserved.
;
;*****************************************************************************
STKCHK	PROC	NEAR
	PUSH	BX
	MOV	BX,SP			; make copy of SP
	SUB	BX,AX			; do dummy allocation
	CMP	SP,BX
	JBE	CHK1			; error if wraparound
	IF	LDATA EQ 0
	CMP	BX,_BASE
	JBE	CHK1			; error if below stack limit
	ENDIF
	CLC				; success return
	POP	BX
	RET
CHK1:	STC				; failure return
	POP	BX
	RET
STKCHK	ENDP		
;*****************************************************************************
;
; name		XCABT -- Ignominious abort
;
; description	This area is entered by direct jump with a message
;		pointer in DS:DX.  It sends the message to the 
;		console via DOS function 9 and then aborts.
; 
;*****************************************************************************
	ENTRY	XCABT
	XOR	AX,AX			; measure length of string	
	MOV	BX,DX
ABT1:	CMP	BYTE PTR [BX],'$'
	JE	ABT2
	INC	BX
	INC	AX
	JMP	ABT1
ABT2:	PUSH	DS			; display the string
	PUSH	DX
	PUSH	AX
	CPUSH	0
	CALL	VioWrtTTY
	CPUSH	0			; abort
	CPUSH	ABTCODE	
	CALL	DosExit
;*****************************************************************************
;
; End the program segment
;
CXINIT	ENDP
_TEXT	ENDS
;*****************************************************************************
;
;  The "CODE" segments are followed by those with class "FAR_DATA", which
;  in turn are followed by segments in the "CONST" class.  The following
;  statements are dummy segments that force this ordering when this startup
;  module is linked first.
;
CX_FAR	SEGMENT	PARA 'FAR_DATA'
CX_FAR	ENDS

CX_CONST SEGMENT PARA 'CONST'
CX_CONST ENDS	
	PAGE
;*****************************************************************************
;
;  DGROUP includes the segments named NULL, NDATA, DATA, and UDATA.  For the
;  S and P models, it also includes the STACK segment, and for the D and L
;  models it contains a dummy segment named HDATA..  The startup 
;  routine initializes DS to point to this group, and DS must then be
;  preserved throughout the program.  The segments within DGROUP are defined
;  as follows:
;
;	NULL   => Contains compiler version number
;	NDATA  => Contains items declared as "near"
;	DATA   => Contains all static (local and global) initialized items.
;	UDATA  => Contains all static (local and global) uninitialized items.
;	STACK  => Stack (S and P models only)
;	HDATA  => Defines top of UDATA (D and L models only)
;
;  For the S and P memory models, the stack is set up relative to DGROUP 
;  (i.e. stack items can addressed via DS).  For the D and L models, the stack 
;  segment stands alone and can be up to 64K bytes.
;
;  The argument strings and the argument vector are placed at the high-order
;  end of the stack.  This is necessary because the command processor passes
;  an unparsed command line, but C main programs conventionally expect to
;  receive a "vector" of pointers to the command arguments.  The startup
;  routine treats the command line as a sequence of arguments separated by
;  white space.  If an argument contains white space, the entire argument
;  must be enclosed in double quotes.  Within such a quoted argument, a
;  double quote can be "escaped" by preceding it with a backslash.
;
;  Space is allocated above the stack for a local copy of the environment.
;  The size of this area is the greater of the actual size needed for the
;  environment passed by the parent, the assembly parameter ENVMIN, and
;  the external integer _ENEED.  This latter item can be user-defined to
;  influence the size of the local environment.

;  This local environment is constructed for two reasons:
;
;	1. To make the environment addressable under the S and P models;
;
;	2. To allow the original environment to grow as a result of "putenv"
;	   function calls.
;
;  The original environment is copied into this area, and then an environment
;  vector is constructed above it.  The external variable "environ" contains
;  a pointer to this vector, and the pointer is also passed as the third 
;  argument to the main program.  Note that the vector may move as a result
;  of calls to "putenv" or "rmvenv", but when that happens, "environ" is
;  updated.
;
;  The heap (i.e. the space used by the memory allocator) resides above the
;  environment and is also initialized by the startup routine.  Any space not
;  immediately needed for the heap (as defined by _MNEED) is returned to DOS.
;  
;  At the end of the startup routine, memory is organized in the following 
;  sequence:
;
;     S & P Models...
;
;			|=================|<--Low address (CS)         
;	Class CODE  	|      Code       |		
;			|=================|		
;	Class FAR_DATA	|    Far Data	  |     	
;			|=================|		
;	Class CONST	|    Constants	  |		
;			|=================|<--DGROUP (DS,ES,SS)		
;	Class DATA	|      NULL       |		
;			|      DATA       |             
;			|      NDATA      |
;			|      UDATA      |
;			|      STACK      |		
;			|    Arguments    |		
;			|   Environment   |		
;			|      NHEAP      | 			
;			|=================|		
;	Class FAR_BSS	|     Far BSS     |		
;			|=================|		
;	Class FAR_HEAP	|     Far Heap    |             
;			|-----------------|<--High address		
;					
;     D & L Models...
;
;			|=================|<--Low address (CS)         
;	Class CODE	|      Code       |		
;			|=================|		
;	Class FAR_DATA	|    Far Data	  |     	
;			|=================|		
;	Class CONST	|    Constants	  |		
;			|=================|<--DGROUP (DS)		
;	Class DATA	|      NULL       |		
;			|      DATA       |             
;			|      NDATA      |
;			|      UDATA      |
;			|      NHEAP      |
;			|=================|		
;	Class FAR_BSS	|     Far BSS     |		
;			|=================|<--(SS) 			
;	Class STACK	|      STACK      |		
;			|    Arguments    |		
;			|   Environment   |		
;			|=================|		
;	Class FAR_HEAP	|     Far Heap    |             
;			|-----------------|<--High address		

;
;  FOR PROPER OPERATION OF THE STANDARD MEMORY ALLOCATOR, THIS SEQUENCE IS
;  EXTREMELY IMPORTANT.  IF YOU TAMPER WITH THE STARTUP ROUTINE OR INTRODUCE
;  SEGMENTS AND CLASSES THAT DO NOT FOLLOW LATTICE CONVENTIONS, CHECK THE
;  LOAD MAP CAREFULLY.
;
;*****************************************************************************
;
; The following segment always occurs at the beginning of DGROUP.  It
; serves two purposes.  First, its existence guarantees that no valid
; pointer will have a value of 0 under the S and P models.  Second, it
; contains distinctive information that can be checked to see if any
; assignments are being made through a null pointer, which is a common
; programming bug.  Of course, this check works only under the S and P
; models, where a null pointer has a value of 0.
;
NULL	SEGMENT	PARA PUBLIC 'BEGDATA'
	PUBLIC	_VER
_VER	DB	"LC 3.30",0		; compiler identification string
;
; Abort messages for the startup routine
;
DOSERR	DB	"Incompatible DOS version",0DH,0AH,"$"
ENVERR	DB	"Corrupted environment",0DH,0AH,"$"
STKERR	DB	"Stack overflow during startup",0DH,0AH,"$"
NULL	ENDS
;*****************************************************************************
;
; This segment contains all initialized static data.
;
DATA	SEGMENT PARA PUBLIC 'DATA'
;
; External data items
;
	EXTRN	_ENEED:WORD		; environment size needed by user
;
; These items provide information about DOS and the memory model.  The 
; _DOS word contains the major version number in its low order byte and
; the minor number in its high order byte.  If you are only interested 
; in the major number, you can reference _DOS as a byte instead of a word.
;
; The _PMODE item indicates the processing mode: 0 for real, 1 for 
; protected. 
;
; The _SINC item contains the value that should be added to a segment
; or selector to get to the next logical value.  This item is correct
; in real or protected mode.  Note that _SINC is always a power of two,
; and that power is contained in _SBIT.  For example, in real mode _SBIT
; contains 12, and _SINC contains 1000H.
;
	PUBLIC	_MODEL,_DOS,_SBIT,_SINC,_PMODE,_XMODE
	IF	S8086
_MODEL	DW	0			; S model indicator
	ENDIF
	IF	P8086
_MODEL	DW	1			; P model indicator
	ENDIF
	IF	D8086
_MODEL	DW	2			; D model indicator
	ENDIF
	IF	L8086
_MODEL	DW	3			; L model indicator
	ENDIF
_DOS	DB	0			; DOS major version number
	DB	0			; DOS minor version number
_SBIT	DB	12			; segment increment bit number
_SINC	DW	1000H			; segment increment value
_PMODE	DB	0			; processor mode (0 = real)
_XMODE	DB	0			; execution mode, as follows:
					;   0 => DOS (DOS entry conditions) 
					;   1 => Family (OS/2 entry conditions)
					;   2 => OS/2
;
; Information about some objects that are passed by this process's parent.
; The addresses are all represented as far pointers.
;
	IF	DOS OR FAMILY
	PUBLIC	_PSP,_TSIZE
_PSP	DD	0			; address of PSP (DOS only)
_TSIZE	DW	SEG FHEAP		; total size in paragraphs
	IF	LDATA EQ 0
	PUBLIC  _XSIZE,_ZSIZE
_XSIZE	DW	SEG CX_BSS		; starting point of far bss
_ZSIZE	DW	SEG FHEAP		; end point of far bss
	ENDIF

	ENDIF

	PUBLIC	_ENV,_ENVL,_CMD
_ENV	DD	0			; address of original environment
_ENVL	DW	0			; size of original environment (bytes)
_CMD	DD	0			; address of original command line
;
; The following items give the base address and size of the static data
; section contained within DGROUP.  This section includes the NULL, DATA,
; and UDATA segments.
;
	PUBLIC	_DBASE,_DSIZE
_DBASE	DW	0			; address of static data section
	DW	DGROUP
	IF	LDATA 
_DSIZE	DW	OFFSET DGROUP:NHEAP	; size of static data in bytes
	ELSE
_DSIZE	DW	OFFSET DGROUP:STACK	; size of static data in bytes
	ENDIF
;
; The following items give the base address and size of the uninitialized
; data sub-section, which is a part of the data group.
; 
	PUBLIC	_UBASE,_USIZE
_UBASE	DW	OFFSET DGROUP:UDATA	; address of uninitialized data
	DW	DGROUP
	IF	LDATA
_USIZE	DW	OFFSET DGROUP:NHEAP	; size of uninitialized data
	ELSE
_USIZE	DW	OFFSET DGROUP:STACK	; size of uninitialized data
	ENDIF
;
; The following items give the base address and size of the stack section.
; This section is a part of the data group for the S and P models, but
; it stands alone for the D and L models.
;
	PUBLIC	_SBASE,_SSIZE
	IF	LDATA EQ 0
	PUBLIC	_BASE,_TOP
	ENDIF
	IF	LDATA
_SBASE	DW	0			; address of stack section
	DW	STACK
	ELSE
_SBASE	DW	OFFSET DGROUP:STACK	; address of stack section
	DW	DGROUP
	ENDIF
_SSIZE	DW	0			; size of stack in bytes
	IF	LDATA EQ 0
_TOP	DW	0			; top of stack (relative to SS)
_BASE	DW	OFFSET DGROUP:STACK	; base of stack (relative to DS)
	ENDIF
;
; The following items define the local environment area, which resides
; at the high end of the stack.  The original environment is copied to
; the stack with enough additional space to allow for new strings to
; be added via "putenv".   The size of this area is determined by
; the original environment size, the external word _ENEED, and the
; assembly paramter ENVMIN.  Space will be allocated for the largest of
; these three values.  _EBASE points to this area, _ESIZE indicates
; how many bytes it contains, and _EUSED indicates how many bytes have
; been used.
;
; This local environment area also contains the environment vector,
; which is passed as the third argument to "main" and is also available
; in the public pointer "environ".  The public integer _ENVC indicates
; how many strings are in the environment.  Then "environ" points to
; an array that contains that many pointers, followed by a NULL pointer.
;
; Notice that "putenv" and "rmvenv" may cause this vector to be moved
; within the environment area.  Therefore, you should not use the
; vector pointer passed as the third argument to "main" after you
; have called "putenv" or "rmvenv".  Use "environ" instead.
;
	PUBLIC	_EBASE,_ESIZE,_EUSED,_ENVC,environ
_EBASE	DW	0			; address of environment section
	IF	LDATA
	DW	STACK
	ELSE
	DW	DGROUP
	ENDIF
_ESIZE	DW	0			; size of environment area in bytes
_EUSED	DW	0			; number of bytes used in env area
environ	DW	0			; environment vector pointer
	IF	LDATA
	DW	STACK
	ELSE
	DW	DGROUP
	ENDIF
_ENVC	DW	0			; environment string count
;
; The following items define the near heap area.  Space from this area
; is managed by two allocators: _nsbrk/_nrbrk and _nmalloc/_nfree.  The
; former treats the area as a linear array with a "break pointer" that
; can be moved up and down.  The latter treats the area as a true heap from
; which blocks can be allocated and released in any order.  These two 
; methods conflict with each other, and so the allocators are interlocked
; to avoid mutual interference.  You may use _nsbrk/_nrbrk freely until the
; first time you call _nmalloc.  After that, the linear space used by
; _nsbrk/_nrbrk is constrained to the region between _NMBASE and the
; break point (_NMNEXT) at the time _nmalloc was called.
;
	PUBLIC	_NMBASE,_NMNEXT,_NMSIZE,_NMLINC
_NMBASE	DW	OFFSET DGROUP:NHEAP	; address of memory pool
_NMSIZE	DW 	OFFSET DGROUP:HDATA	; number of bytes in pool
_NMNEXT	DW	OFFSET DGROUP:NHEAP	; next location in linear heap
_NMLINC	DW	1024			; linear heap increment (bytes)

	PUBLIC	_NMHEAP,_NMCURR,_NMHOLD
_NMHEAP	DW	0			; start of random heap
_NMCURR	DW	0			; current block in random heap
_NMHOLD	DW	0			; hold area for "_nrealloc"
;
; The following items define the far heap area.  In real mode, this area
; is managed by two allocators: _fsbrk/_frbrk and _fmalloc/_ffree.  The
; same comments apply to this heap as to the near heap described above.
; That is, the upper limit for _fsbrk is determined the first time you
; call _fmalloc.
;
; In protected mode, the far heap actually consists of two areas.  The 
; first, used by _fsbrk/_frbrk, is a "huge block" which can grow to the
; size specified by _FMLIM, which defaults to one megabyte.  If you use
; this heap, which is a UNIX anachronism, be very careful about segment
; boundaries because the segments comprising a huge block do not use 
; adjacent selectors in the memory map.  You must add the segment increment
; _SINC to the selector when crossing a segment boundary.  Many of the
; Lattice library routines do this automatically, but you cannot count
; on the compiler's in-line code to handle the situation.  For example,
; if you use _fsbrk in such a way that a "float" or a "double" straddles
; a segment boundary, you'll probably get an addressing exception when
; your program runs.
;
; To help alleviate this problem, _fsbrk starts a new segment if the
; request will not entirely fit in the current one.  This puts some 
; holes in the heap, which may cause problems for programs which assume
; space obtained in this way is always contiguous.  Let's face it:
; You should avoid the sbrk/rbrk functions in new designs because they
; are very difficult to implement correctly on many systems.  We've done
; the best we can for OS/2, simply because some of our customers have
; old UNIX code that they don't want to change.
;
; The second far heap for protected mode is a linked list of segments
; managed by _fmalloc/_ffree.  The list is rooted in _FMHEAP, and the
; first two words of each segment contain the next segment address (i.e.
; the next selector) and the segment size in bytes, respectively.  Within
; each segment, space is managed as with _nmalloc/_nfree.
;   
	PUBLIC	_FMBASE,_FMNEXT,_FMSIZE,_FMLINC
_FMBASE	DW	0			; segment address of memory pool
_FMSIZE	DW 	0 			; paragraphs in pool (real mode only)
_FMNEXT	DW	0			; next paragraph in linear heap
_FMLINC	DW	256			; linear heap increment (paragraphs)

	PUBLIC	_FMHEAP,_FMCURR,_FMRINC,_FMHOLD
_FMHEAP	DW	0			; segment address of random heap
_FMCURR	DD	0			; current block
_FMHOLD	DD	0			; hold area for "_frealloc"
_FMRINC	DW	4096			; random heap increment (bytes)
;
; The process arguments are moved to the top of the stack as an array
; of null-terminated strings.  Then an "argument vector" is constructed 
; just below the argument strings.  The vector contains a pointer to each
; successive string.  The end of the vector is marked by a null pointer.
; Also, the last string is followed by a null string.
;
	PUBLIC	_ARG,_ARGV,_ARGC
	IF	LDATA
_ARG	DW	0			; pointer to arg array in stack
	DW	STACK
_ARGV	DW	0			; pointer to arg vector in stack
	DW	STACK
	ELSE
_ARG	DW	0			; pointer to arg array in stack
	DW	DGROUP
_ARGV	DW	0 			; pointer to arg vector in stack
	DW	DGROUP
	ENDIF
_ARGC	DW	1			; argument count
;
; The following items are used by the floating point subsystem.
;
	PUBLIC	_FPA,_FPERR
	PUBLIC	_NDPSW,_NDPCW
	PUBLIC	_SIGFPE
_FPA	DQ	0			; floating point accumulator
_FPERR	DW	0			; floating point error code
	EXTRN	_NDP:BYTE		; non-zero if 8087 is installed
_NDPSW	DW	0FFFFH			; 8087 status word
_NDPCW	DW	0			; 8087 control word
	IF	LPROG
_SIGFPE	DD	0			; Floating point error signal
	ELSE
_SIGFPE	DW	0			; Floating point error signal
	ENDIF
;
; The following items are used by the fork/wait functions.
;
	PUBLIC	_PID,_PIDR;
_PID	DW	0			; child process id
_PIDR	DD	0			; child process result codes
;
; The following item contains the main error code returned by the most
; recent DOS call made through the standard library.  That is, each time
; the standard library calls a DOS service function, it checks the return
; code and places it here.  For DOS 3, the CXSERR routine obtains the
; extended error information and places it in several other items that
; you can find in CXSERR.ASM.
;
; Note that _OSERR, unlike the UNIX error code in errno, is not "sticky".  
; That is, _OSERR gets reset to zero when the DOS service is successful.
;
	PUBLIC	_OSERR
_OSERR	DW	0			; DOS error code

DATA	ENDS
;*****************************************************************************
;
; This segment contains all data items that are explicitly declared as
; "near".
;
NDATA	SEGMENT	PARA PUBLIC 'DATA'
NDATA	ENDS
;*****************************************************************************
;
; This segment contains all uninitialized near data.
;
UDATA	SEGMENT	PARA PUBLIC 'DATA'
UDATA	ENDS
;*****************************************************************************
;
; The stack segment is a part of DGROUP in the S and P models.
;
	IF	LDATA EQ 0
STACK	SEGMENT STACK PARA 'STACK'
	DB	STKMIN DUP (?)
	EXTRN	__STACK:BYTE
STACK	ENDS
	ENDIF
;*****************************************************************************
;
; This is a the near heap, which resides at the end of DGROUP.  In OS/2
; protected mode, the near heap can grow until DGROUP fills an entire
; segment.  However, in DOS this growth may not be possible.  Two situations
; can prevent it.  When in the S or P model, the near heap cannot grow
; if the FAR_BSS class is not empty.  When in the D or L model, both
; FAR_BSS and the STACK area limit the growth of the near heap.
;
; The way to get around this problem is to pre-allocate enough space for
; the near heap.  You can do this by either changing the NHSIZE parameter
; in this module or by creating a module that contains an uninitialized
; segment named NHEAP defined as the one below.  This segment will
; combine with the one below at link time, to form a larger heap.
;
;
NHEAP	SEGMENT	PARA PUBLIC 'ENDDATA'
	DB	NHSIZE DUP(?)
NHEAP	ENDS
;*****************************************************************************
;
; This is a dummy to establish the end of the near heap, so that its size
; can be computed.
;
HDATA	SEGMENT	PARA PUBLIC 'ENDDATA'
HDATA 	ENDS
;*****************************************************************************
;
; This is a dummy to establish the position of the FAR_BSS class, which
; contains any "far" items that are not initialized.
;
CX_BSS	SEGMENT	PARA PUBLIC 'FAR_BSS'
CX_BSS	ENDS
;*****************************************************************************
;
; This is the stack segment for the D and L models.  It is not a part of
; DGROUP in those models.
;
	IF	LDATA
STACK	SEGMENT STACK PARA 'STACK'
	DB	STKMIN DUP (?)
	EXTRN	__STACK:BYTE
STACK	ENDS
	ENDIF
;*****************************************************************************
;
; This segment defines the far heap.  Under DOS, it is also used as the
; high-memory location.  In other words, you can determine the number of
; paragraphs in the basic block by subtracting the PSP segment from this
; one.  Also, when under DOS, the far heap may be relocated higher in
; memory if CX_BSS is empty and the near heap grows.
;
	IF	DOS OR FAMILY
FHEAP	SEGMENT	PARA PUBLIC 'FAR_HEAP'
	DB	2 DUP (?)
FHEAP	ENDS
	ENDIF
;*****************************************************************************
	END	CXINIT







