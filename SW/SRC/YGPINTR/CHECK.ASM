;******************************************************************************
;*									      *
;*			       Ycode Interpreter			      *
;*									      *
;*				  Version 1.10				      *
;*			 (Check RAM resident version)			      *
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

		include interrupts.inc
		include undocumented.inc
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
;     ’®§¨ ¯°®£° ¬  ¥ ¢±º¹­®±² ¨§¢ ¤ª  ®² § °¥¦¤ ¹ ²  ¢ RAM.

		error	bank1addr / $c000 ; ²°¿¡¢  ¤  ±¬¥ ­  RAM
		error	bank2addr / $c000 ; ²°¿¡¢  ¤  ±¬¥ ­  RAM

CheckYcode	proc
		ds	$11, 1		; ±« £ ¬¥ 11 NOP-  §  ¤  ¡º¤¥ ¯®·­¥¬
		ldx	#CrightMsg	; ¯°®£° ¬ ²  ®²  ¤°¥± $111
		int	_Wstr

		lda	ResidentPtr+1	; ¯°®¢¥°¿¢ ¬¥ ¤ «¨ Resident > RAMstart
		ldb	ResidentPtr
		cmpb	#/RAMstart	; ±° ¢­¿¢ ¬¥ ±² °¸¨²¥ ¡ ©²®¢¥
		bhi	NotHere 	; Resident > RAMstart => ­¿¬  £®
		bcs	MayHere 	; Resident < RAMstart => ¬®¦¥ ¡¨ ¥ ²³ª
		cmpa	#RAMstart	; ±° ¢­¿¢ ¬¥ ¬« ¤¸¨²¥ ¡ ©²®¢¥
		bhi	NotHere 	; Lo(Resident) > Lo(RAMstart) (Hi = Hi)

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
		bne	NoInterpreter	; ­¥ ±º¢¯ ¤ ² => ¨¬  ­¥¹® ¤°³£®
		inx
		stx	wrk_2
		deca
		bne	loop

		ldx	#bank1addr
		clra
loop1		adda	x, 0
		inx
		cpx	#bank1addr + $2000
		bne	loop1
		ldx	#Bank1OK
		tsta
		beq	print_1
		ldx	#Bank1Bad
print_1 	int	_Wstr

		ldx	#bank2addr
		clra
loop2		adda	x, 0
		inx
		cpx	#bank2addr + $2000
		bne	loop2
		ldx	#Bank2OK
		tsta
		beq	print_2
		ldx	#Bank2Bad
print_2 	int	_Wstr
		int	_Terminate

NotHere 	ldx	#NoInterpreter
		int	_Wstr
		int	_Terminate

CrightMsg	db	'CheckSum for Ycode interpreter', 0
NoInterpreter	db	"Interpreter not in memory!", 0
Bank1OK 	db	10, "Bank 1 is OK.", 0
Bank2OK 	db	10, "Bank 2 is OK.", 0
Bank1Bad	db	10, "Bank 1 fails check.", 0
Bank2Bad	db	10, "Bank 2 fails check.", 0

wrk_		ds	2
wrk_1		ds	2
wrk_2		ds	2
		endp;	CheckYcode

;------------------------------------------------------------------------------
ROMheader
		dw	$a55a		; ª ª²® £® ¨±ª  BIOS
		db	'YGPascal'
		jmp	0		; cold inti address
		jmp	0
		END.	Check Interpreter
