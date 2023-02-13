;
; Use the following two lines to put a title and subtitle on the assembly
; listing.  We usually put some descriptive information on the title line
; and our copyright notice on the subtitle.
;
	TITLE	func -- Description of function
	SUBTTL	Copyright 1986 by Lattice, Inc.
;
; The next line creates a module name record in the output file.  If it
; is not present, the library manager will use the file name to identify
; the module when it is installed in a library.  Usually, we use the
; source file name (without the .ASM extension) as both the module name
; and the function name.
;
;
	NAME	func
;
; The next statement fetches the memory model interface macros.  If you
; have used the standard installation procedures, there will be a file
; named DOS.MAC in each of the memory model subdirectories.  With the
; latest MS-DOS assembler, you can specify the appropriate subdirectory
; on the command line, as follows:
;
;	masm /I\lc\s func;
;
; which specifies that macro files can be found in the S-model subdirectory.
;
; If you don't have this assembler, you should construct a batch file
; that copies the appropriate macro file to the current directory, as
; follows:
;
;	copy \lc\s\dos.mac
;	masm func;
;	del dos.mac
;
	INCLUDE	DOS.MAC
;
; The next statement fetches the NDP macros, and should only be included
; if you are accessing the 8087 or 80287.  There is only one copy of 
; 8087.MAC, and the standard installation program installs it in the
; base directory "\lc".  As mentioned above, you can specify this directory
; on the assembler command line as:
;
;	masm /I\lc /I\lc\s func;
;
; or you can copy 8087.MAC to the current directory via a batch file:
;
;	copy \lc\8087.mac
;	copy \lc\s\dos.mac
;	masm func;
;	del 8087.mac
;	del dos.mac
;
	INCLUDE	8087.MAC
;
; The following statements show how you would define the arguments for
; this function, which we'll assume is called with an integer, a double,
; and a pointer.  The SETX statement defines the symbol X with a value
; equal to the size of the BP save area and the return address area.  This
; makes it possible to access arguments via this kind of coding:
;
;	MOV	AX,[BP+X].ARG1		; get first argument
;
	SETX
	IF	LDATA
ARGS	STRUC
ARG1	DW	?			; first argument is an integer
ARG2	DD	?			; second argument is a pointer
ARG3	DQ	?			; third argument is a double
ARGS	ENDS
	ELSE
ARGS	STRUC
ARG1	DW	?			; first argument is an integer
ARG2	DW	?			; second argument is a pointer
ARG3	DQ	?			; third argument is a double
ARGS	ENDS
	ENDIF
;
; The following statements define the static data associated with this
; function.  Use the PUBLIC operation to define items that can be
; accessed by name from other modules.  Also, any data items defined in
; other modules and accessed from this one need to be defined via the
; EXTRN operation.
;
	DSEG				; begin data segment
	PUBLIC	abc	
abc	DW	3			; "abc" is a public integer
DEF	DB	32 DUP(?)		; "DEF" is a local 32-byte buffer
	EXTRN	_NDP:BYTE		; gives access to "_NDP"
	PEXTRN	environ			; gives access to "environ" pointer
	ENDDS				; end data segment
;
; The following statements begin the code segment.  Note that external
; functions must be declared via the FEXTRN macro.
;
	FEXTRN	fopen	
	FEXTRN	fclose

	PSEG				; begin program segment
;
; The following statements are the typical function entry prologue.  You
; must use this sequence if you are accessing function arguments via the
; method described above (i.e. using SETX).  Also note that if you use
; this sequence, local stack variables are addressed by negative offsets
; from BP.
;
	BEGIN	func			; establish procedure name, etc.
	PUSH	BP			; save caller's stack frame pointer
	MOV 	BP,SP			; establish our stack frame pointer
;
; The following statement allocates space for local stack variables.  You can
; eliminate it if there are none.  Note that the size is in bytes and should
; be an even number.
; 
	SUB	SP,10			; allocate 10 bytes for locals
;
; Your function code goes here.  If you want your function to work correctly
; in all memory models, you will need to carefully code all pointer 
; operations.  For example, the following code will get the integer
; referenced by the pointer ARG2:
;
	IF	LDATA
	LES	DI,[BP+X].ARG2		; get pointer (D and L models)
	ELSE
	MOV	DI,[BP+X].ARG2		; get pointer (S and P models)
	ENDIF
	MOV	AX,ES:[DI]		; get integer
;
; The following sequence ends the assembly.
;
	MOV	SP,BP			; restore stack pointer
	POP	BP			; restore frame pointer
	RET				; return to caller
func	ENDP				; end the procedure "func"
	ENDPS				; end the program segment
	END				; end the source file

