	TITLE	PORT I/O FUNCTIONS
	SUBTTL	Copyright 1982 by Lattice, Inc.
	NAME	PORTIO
	INCLUDE	DOS.MAC

	IF	LPROG
X	EQU	6		;OFFSET OF ARGUMENTS
	ELSE
X	EQU	4		;OFFSET OF ARGUMENTS
	ENDIF

	PSEG
;**
;
; name		inp -- input byte from port
;
; synopsis	c = inp(port);
;		int c;		returned byte
;		int port;	port address
;
; description	This function inputs a byte from the specified port
;		address and returns it as the function value.
;
;**
	PUBLIC	INP
	IF	LPROG
INP	PROC	FAR
	ELSE
INP	PROC	NEAR
	ENDIF
	PUSH	BP		;SAVE BP
	MOV	BP,SP
	MOV	DX,[BP+X]	;GET PORT ADDRESS
	IN	AL,DX		;GET INPUT BYTE
	XOR	AH,AH		;CLEAR HIGH BYTE
	POP	BP
	RET
INP	ENDP
	PAGE
;**
;
; name		outp -- output byte to port
;
; synopsis	outp(port,c);
;		int port;	port address
;		int c;		byte to send
;
; description	This function sends the specified character to
;		the specified port.
;
;**
	PUBLIC	OUTP
	IF	LPROG
OUTP	PROC	FAR
	ELSE
OUTP	PROC	NEAR
	ENDIF
	PUSH	BP		;SAVE BP
	MOV	BP,SP
	MOV	DX,[BP+X]	;GET PORT ADDRESS
	MOV	AX,[BP+X+2]	;GET OUTPUT BYTE
	OUT	DX,AL
	POP	BP
	RET
OUTP	ENDP
	ENDPS	
	END
