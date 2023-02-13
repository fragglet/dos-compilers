+ARCHIVE+ ldivide3.asm  2882  9/18/87 16:29:56
;
; 80386 long divide routines
;
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
;
;       09-Sep-87 nlp created ludiv/lsdiv
;	15-Sep-87 nlp created ludivide/lsdivide
;
;
;       Note: these functions are meant to be executed
;       on a 386 in real mode. Any other use constitutes
;       an exercise in re-booting your machine.
;
	include prologue.ah

;	entry points:
;
;	ludiv - long unsigned divide
;	lsdiv - long signed divide

;
;	conventions:
;
;       for a / b
;
;       push a
;	push b
;	call lsdiv
;	result in dxax
;

; unsigned divide
FUN_BEG ludiv,0,<>
FUN_ARG	divisor,4
FUN_ARG	dividend,4
        db      066h
        mov     ax,word ptr dividend[bp]        ; eax <- dividend
        db      066h
        xor     dx,dx                           ; clear edx
        db      066h
        div     word ptr divisor[bp]            ; result in eax
        db      066h
        mov     dx,ax                           ; copy answer to edx
        db      066h
        shr     dx,16                           ; answer in dx:ax
        leave
        ret     8
FUN_END ludiv


; signed divide
FUN_BEG	lsdiv,0,<>
FUN_ARG	divisor,4
FUN_ARG dividend,4
        db      066h
        mov     ax,word ptr dividend[bp]        ; eax <- dividend
        db      066h
        cwd                                     ; sign extend
        db      066h
        idiv    word ptr divisor[bp]            ; result in eax
        db      066h
        mov     dx,ax                           ; copy answer to edx
        db      066h
        shr     dx,16                           ; answer in dx:ax
        leave
        ret     8
FUN_END	lsdiv


;
;entry points:
;
; a / b
;
; a in dxax
; b in bxcx
; result in dxax
;

	_TEXT	segment
	assume	cs:_TEXT,ds:DGROUP

FUN_PROC	ludivide

	; put dx in high-word of eax
	xchg 	ax,dx 		
	db	066h			
	shl	ax,16		
	mov	ax,dx

	; edx <- 0
	db	066h
	xor	dx,dx
	
	; put bx in high-word of ecx
	xchg	bx,cx
	db	066h
	shl	cx,16
	mov	cx,bx


	; div eax by ecx
	db	066h
	div	cx
	
        db      066h
        mov     dx,ax                           ; copy answer to edx
        db      066h
        shr     dx,16                           ; answer in dx:ax

	ret
FUN_END	ludivide

	_TEXT	segment
	assume	cs:_TEXT,ds:DGROUP

FUN_PROC	lsdivide

	; put dx in high-word of eax
	xchg 	ax,dx 		
	db	066h			
	shl	ax,16		
	mov	ax,dx
	
	; sign extende eax into edx
	db	066h
	cwd

	; put bx in high-word of ecx
	xchg	bx,cx
	db	066h
	shl	cx,16
	mov	cx,bx


	; div eax by ecx
	db	066h
	idiv	cx

        db      066h
        mov     dx,ax                           ; copy answer to edx
        db      066h
        shr     dx,16                           ; answer in dx:ax

	ret
FUN_END	lsdivide


end



+ARCHIVE+ lmodulo3.asm  2801  9/18/87 16:28:52
;
; 80386 long modulo routines
;
; Copyright (c) 1987 Computer Innovations Inc, ALL RIGHTS RESERVED.
;
;
;       09-Sep-87 nlp created lsmod/lumod
;	15-Sep-87 nlp created lsmodulo/lumodulo
;
;
;       Note: these functions are meant to be executed
;       on a 386 in real mode. Any other use constitutes
;       an exercise in re-booting your machine.

	include prologue.ah

;	entry points:
;
;	lumod - long unsigned modulus
; 	lsmod - long signed modulus

;
;	conventions:
;
;       for a % b
;       push a
;	push b
;	call lsmod
;	result in dxax
;


FUN_BEG lumod,0,<>
FUN_ARG divisor,4
FUN_ARG dividend,4
        db      066h
        mov     ax,word ptr dividend[bp]        ; eax <- dividend
        db      066h
        xor     dx,dx                           ; clear edx
        db      066h
        div     word ptr divisor[bp]            ; result in edx
        db      066h
        mov     ax,dx                           ; copy answer to eax
        db      066h
        shr     dx,16                           ; answer in dx:ax
        leave
        ret     8
FUN_END lumod


FUN_BEG lsmod,0,<>
FUN_ARG divisor,4
FUN_ARG dividend,4
        db      066h
        mov     ax,word ptr dividend[bp]        ; eax <- dividend
        db      066h
        cwd
        db      066h
        idiv     word ptr divisor[bp]           ; result in edx
        db      066h
        mov     ax,dx                           ; copy answer to eax
        db      066h
        shr     dx,16                           ; answer in dx:ax
        leave
        ret     8
FUN_END lsmod




;
;entry points:
;
; a % b
;
; a in dxax
; b in bxcx
; result in dxax
;

	_TEXT	segment
	assume	cs:_TEXT,ds:DGROUP

FUN_PROC	lumodulo

	; put dx in high-word of eax
	xchg 	ax,dx 		
	db	066h			
	shl	ax,16		
	mov	ax,dx
	
	;	clear edx
	db	066h
	xor	dx,dx

	; put bx in high-word of ecx
	xchg	cx,bx
	db	066h
	shl	cx,16
	mov	cx,bx

	; div eax by ecx
	db	066h
	div	cx
	
        db      066h
        mov     ax,dx                           ; copy answer to eax

        db      066h
        shr     dx,16                           ; answer in dx:ax

	ret
FUN_END	lumodulo

	_TEXT	segment
	assume	cs:_TEXT,ds:DGROUP

FUN_PROC	lsmodulo

	; put dx in high-word of eax
	xchg 	ax,dx 		
	db	066h			
	shl	ax,16		
	mov	ax,dx
	
	;	extend eax into edx
	db	066h
	cwd

	; put bx in high-word of ecx
	xchg	cx,bx
	db	066h
	shl	cx,16
	mov	cx,bx


	; div eax by ecx
	db	066h
	idiv	cx

        db      066h
        mov     ax,dx                           ; copy answer to eax

        db      066h
        shr     dx,16                           ; answer in dx:ax

	ret
FUN_END	lsmodulo


end



