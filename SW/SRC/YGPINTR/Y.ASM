;******************************************************************************
;*									      *
;*			       Ycode Interpreter			      *
;*									      *
;*				  Version 1.10				      *
;*			     (RAM resident version)			      *
;*									      *
;*			  (c) 1989 ƒ¥®°£¨ ¥²°®¢ /YGP/			      *
;*									      *
;*		Processor:		MC6800 (‘Œ 601) 		      *
;*		Computer:		º«¤¨­ 601			      *
;*		Operating System:	UniDOS (R)			      *
;*									      *
;*		Language:		MC6800 Assembler		      *
;*									      *
;*	‘¯¥¶¨ «­¨ ¡« £®¤ °­®±²¨ ­ 	Ž°«¨­  ˜®¯®¢ /Eagle/		      *
;*					ˆ¢®    ¥­®¢			      *
;*									      *
;*		       € ±º¹® ¨ ­ 	‚ «¥°¨ ’°¨´®­®¢ /YWY/		      *
;*									      *
;******************************************************************************

		ORG	$100		; ² §¨ · ±² ¥ .CMD file

		include interrup.inc
		include undocume.inc
		include globals.Y

;     ’ §¨ · ±² ®² ¨­²¥°¯°¥² ²®°  ¥ ¯®¬®¹­ , ¨§¯®«§³¢  ±¥ ± ¬® §  ±º§¤ ¢ ­¥²®,
; ²¥±²¢ ­¥²® ¨ ®²« ¦¤ ­¥²® ­   ¨­²¥°¯°¥² ²®° .	¥  ± ¬® ·¥  ­¥ ¥ ­³¦­ ,  ­® ¨
; ²°¿¡¢  ¤  ±¥ ¯°¥¬ µ­¥ ¯°¨ ®ª®­· ²¥«­®²® § ¢º°¸¢ ­¥ ­  ¯°®¤³ª² .
;     ˆ­²¥°¯°¥² ²®°  ±¥ ¨­±² «¨°  ª ²® °¥§¨¤¥­²­  ¯°®£° ¬  ®² ´¨ª±¨° ­¨¿  ¤°¥±
; RAMstart ¨ § ¥¬  $4000 ¡ ©²  ¬¿±²® (².¥. 16 Kbytes).
;     „¢¥²¥ · ±²¨ ­  ¨­²¥°¯°¥² ²®°  ±¥ § °¥¦¤ ²  ¥¤­  ±«¥¤ ¤°³£  ¢ ² §¨ ¯ ¬¥².
; Š ²® 1 ¡ ­ª  ±¥ § °¥¦¤  ®² RAMstart   ¢²®°  ®² RAMstart + $2000.
;     °¨  ­ ¯¨±¢ ­¥²® ­   ² §¨ · ±²  ®² ¨­²¥°¯°¥² ²®°  ¥ ¢§¥²® ¢ ¯°¥¤¢¨¤,  ·¥
; °¥§¨¤¥­²­ ²  ®¡« ±² ­  ª®¬¯¾²º°   º«¤¨­ - 601 ¥ ®² $ba.. ­ £®°¥,  § ²®¢  ±¥
; ¯®±² ¢¿   ¤°¥±   RAMstart = $ba00 - $4000.  ® ¢±¨·ª® ¥ ² ª  ­ ¯¨± ­®,  ·¥ ¥
; ¤®±² ²º·­® ¤  ±¥ ±¬¥­¨  ¤°¥±  RAMstart ¨ ¨­²¥°¯°¥² ²®°  ¹¥ ±¥ § °¥¤¨ ®² ¤°³£
;  ¤°¥±.

		error	bank1addr / $c000 ; ²°¿¡¢  ¤  ±¬¥ ­  RAM
		error	bank2addr / $c000 ; ²°¿¡¢  ¤  ±¬¥ ­  RAM

InstallYcode	proc
		ds	$11, 1		; ±« £ ¬¥ 11 NOP-  §  ¤  ¡º¤¥ ¯®·­¥¬
		ldx	#CrightMsg	; ¯°®£° ¬ ²  ®²  ¤°¥± $111
		int	_Wstr

		lda	ResidentPtr+1	; ¯°®¢¥°¿¢ ¬¥ ¤ «¨ Resident > RAMstart
		ldb	ResidentPtr
		cmpb	#/RAMstart	; ±° ¢­¿¢ ¬¥ ±² °¸¨²¥ ¡ ©²®¢¥
		bhi	NotHere 	; Resident > RAMstart => ­¿¬  £®
		bcs	MayHere 	; Resident < RAMstart => ¬®¦¥ ¡¨ ¥ ²³ª
		cmpa	#RAMstart	; ±° ¢­¿¢ ¬¥ ¬« ¤¸¨²¥ ¡ ©²®¢¥
		bhi	CantInstall	; Lo(Resident) > Lo(RAMstart) (Hi = Hi)

MayHere
		ldx	#RAMstart	; ¢¥°®¿²­® ¨¬  ² ªº¢ ¨ ²°¿¡¢  ± ¬®
		stx	wrk_1		; ¤  £® § ¬¥­¨¬ ± ²®§¨. ® ¯º°¢® ¯°®¢¥-
		ldx	#ROMheader	; °¿¢ ¬¥ ¤ «¨ ­ ¨±²¨­  ¨¬ 
		stx	wrk_2
		lda	#10		; first 10 bytes match?
loop		ldx	wrk_1
		ldb	x, 0
		inx
		stx	wrk_1
		ldx	wrk_2
		xorb	x, 0
		bne	CantInstall	; ­¥ ±º¢¯ ¤ ² => ¨¬  ­¥¹® ¤°³£®
		inx
		stx	wrk_2
		deca
		bne	loop
		ldx	#Replaced	; ±º®¡¹¥­¨¥²® ª®¥²® ¹¥ ¤ ¤¥¬
		stx	WhatOccure	; ¹¥ ¡º¤¥ ·¥ ¥ § ¬¥­¥­

		ldx	#bank1addr	; ¨­²¥°¯°¥² ²®°  ¥ ²³ª  ±¥£  ¤  ¬³
		clra			; ­ ¯° ¢¨¬ CheckSum in case of
loop1		adda	x, 0
		inx
		cpx	#bank1addr + $2000
		bne	loop1
		tsta
		beq	_1_IsOK
		ldx	#Bank1Bad
		int	_Wstr
_1_IsOK
		ldx	#bank2addr
		clra
loop2		adda	x, 0
		inx
		cpx	#bank2addr + $2000
		bne	loop2
		tsta
		beq	_2_IsOK
		ldx	#Bank2Bad
		int	_Wstr
_2_IsOK
		jmp	LoadInterpreter

NotHere 	clra
GetMemLoop	ldb	#8		; Get one Page on Page Boundary
		ldx	#$100
		int	_GetMem
		cpx	#0
		beq	CantInstall	; ²®¢  ­¥ ²°¿¡¢  ¤  ±¥ ±«³·¢ 
		inca
		cpx	#RAMstart
		bne	GetMemLoop
		cmpa	#$40		; ®²¤¥«¨«¨ «¨ ±¬¥ ª®«ª®²® ²°¿¡¢ 
		bcs	CantInstall
		int	_Resident
		jmp	LoadInterpreter

CantInstall	ldx	#CantMsg
		int	_Wstr
		int	_Terminate

CantMsg 	db	10, "Can't install Interpreter!", 0
Interpreters	db	10, "Interpreter's ", 0
Installed	db	' Installed', 0
Replaced	db	' Replaced', 0
Bank		db	'Bank ', 0
Name		db	'Y1.RAM', 0
Error1		db	10, 'I/O error $', 0
Error2		db	' loading file ', 0
Error3		db	' opening file ', 0
CrightMsg	db	'Ycode interpreter: RAM resident version.', 0
Bank1Bad	db	10, "Bank 1 fails check.", 7, 0
Bank2Bad	db	10, "Bank 2 fails check.", 7, 0

FreadTBL	dw	RAMstart
		dw	$2000		; ¢±¥ª¨ ´ ©« ¥ ¤º«º£ $2000

FopenTBL	dw	Name, 0

WhatOccure	dw	Installed

LoadInterpreter proc

		jsr	LoadROMbank
		inc	Name+1		; ­®¬¥°  ­  ¡ ­ª ² 
		ldx	#RAMstart + $2000
		stx	FreadTBL
		jsr	LoadROMbank
		int	_Terminate
		endp;	LoadInterpreter


LoadROMbank	proc

		ldx	#FopenTBL
		lda	#1
		int	_Fopen
		tsta
		beq	OKopened
		ldx	#Error1
		int	_Wstr
		int	_Whex
		ldx	#Error3
		int	_Wstr
		bra	ErrorName
OKopened	stb	FileHandle
		ldx	#FreadTBL
		tba			; set file handle
		int	_Fread
		tsta
		beq	OKreaded
		ldx	#Error1
		int	_Wstr
		int	_Whex
		ldx	#Error2
		int	_Wstr
ErrorName	ldx	#Name
		int	_Wstr
		int	_Terminate
OKreaded
		ldx	FreadTBL
		jsr	InitROMbank
		ldx	#Interpreters
		int	_Wstr
		ldx	#Bank
		int	_Wstr
		lda	Name+1
		int	_Wchar		; write Bank No
		ldx	WhatOccure
		int	_Wstr
		lda	FileHandle
		int	_Fclose
		rts

FileHandle	db	0
		endp;	LoadROMbank

; ˆ­¨¶¨ «¨§ ¶¨¿ ­  ROM ¡ ­ª  ² ª  ª ª²® ¡¨ ¡¨«  ¨­¨¶¨ «¨§¨° ­   ª® ¡¥¸¥ ­  ROM.
; import: X - start address in RAM of this ROM bank

InitROMbank	proc
		stx	wrk_		; ±¬¿² ¬¥  ¤°¥±  ­  ² ¡«¨¶ ²  ±
		lda	#16		; ¨­²¥°º¯²¨. (StartAddress + $16)
		clrb
		adda	wrk_+1
		adcb	wrk_
		sta	wrk_1+1
		stb	wrk_1
		ldx	wrk_1

loop		lda	x
		beq	ExitLoop
		clrb
		stx	wrk_1
		ldx	x, 1
		int	_SetIntVec
		ldx	wrk_1
		inx
		inx
		inx
		bra	loop
ExitLoop
		ldx	wrk_
		jmp	x, 10		; (jsr + rts) make a cold initialize
		endp;	InitROMbank

wrk_		ds	2		; ° ¡®²­¨ ¯°®¬¥­«¨¢¨
wrk_1		ds	2		; ­¿¬ ² ­¨¹® ®¡¹® ± Globals
wrk_2		ds	2		; ­  ¨­²¥°¯°¥² ²®° 

		endp;	InstallYcode

;------------------------------------------------------------------------------
ROMheader
		dw	$a55a		; ª ª²® £® ¨±ª  BIOS
		db	'YGPascal'
Initialize	jmp	0		; cold init address
		jmp	0

IntrptTbl				; start of interrupt table

		END.	RAMversion
