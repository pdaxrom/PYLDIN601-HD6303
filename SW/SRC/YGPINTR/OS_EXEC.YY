;------------------------------------------------------------------------------
 ²®¢  ¡¥¸¥ ¢ startup.y

		lda	#_Execute
		int	_GetIntVec
		stb	OldExecute
		stx	OldExecute+1
		ldb	Bank2page
		ldx	#NewExecute
		int	_SetIntVec

		lda	#_UniDOSshell
		int	_GetIntVec
		stb	OldOSshell
		stx	OldOSshell+1
		ldb	Bank2page
		ldx	#NewOSshell
		int	_SetIntVec
;------------------------------------------------------------------------------
  ²®¢  ¡¥¸¥ ¢ exitycode.y
		lda	#_Execute
		ldb	OldExecute
		ldx	OldExecute+1
		int	_SetIntVec

		lda	#_UniDOSshell
		ldb	OldOSshell
		ldx	OldOSshell+1
		int	_SetIntVec

		lda	#_Terminate
		int	_GetIntVec
;------------------------------------------------------------------------------
¨ ²®¢  ¡¥¸¥ ¢ exitycode.y

NewOSshell	ldx	#OldOSshell
		bra	ExecuteShell
NewExecute	ldx	#OldExecute

ExecuteShell	proc
		lda	OSshellFLAG	; ¨«¨ ¯ºª ¥  ª²¨¢¥­ OS shell (execute)
		bne	CallOldIntrpt	; ¯³±ª ¬¥ ­®¢¨¿ ² ªº¢ ª° © ³¸¨²¥ ±¨.
		inc	OSshellFLAG
		stx	LongWork	; ±¯ ±¿¢ ¬¥ X °¥£¨±²º° 
					; ¨ ±º±²®¿­¨¥²® ­  ¨­²¥°¯°¥² ²®° 

		ldx	HiMemPtr	; §  ¤  ¬®¦¥¬ ¯®±«¥ ¤  ¿ ®±¢®¡®¤¨¬
		stx	ReleaseMem

		ldx	#YregistersSz + SaveAreaSize
		clrb			; ¢§¥¬ ¬¥ ²®«ª®¢  ¯ ¬¥² ª®«ª®²® ­¨
		int	_GetMem 	; ²°¿¡¢  §  ±¯ ±¿¢ ­¥²®
		stx	wrkF+2
		bne	OK
NoMemory	lda	#66		; insuficient memory (UniDOS's error)
		sta	SWI_A
		rts

CallOldIntrpt	ldb	x, 0		; ¢ X ¨¬ ¬¥  ¤°¥±  ­  ±² °¨¿ interrupt
		ldx	x, 1		; OSshell ¨«¨ Execute
		int	_ChainIntrpt
OK
		ldx	#Yregisters
		stx	wrkF
		lda	#YregistersSz
		clrb	;#/YregistersSz
		ldx	#wrkF
		int	_MoveMem
		adda	wrkF+2+1
		adcb	wrkF+2
		sta	IOfile+1
		stb	IOfile
		ldx	#SaveArea
		stx	IOsize
		ldx	#IOsize
		lda	#SaveAreaSize
		clrb	;#/SaveAreaSize
		int	_MoveMem

		ldx	wrkF+2
		stx	SaveAreaPtr
		ldx	LongWork	; ¨§¢¨ª¢ ¬¥ ±² °¨¿ interrupt
		bsr	CallOldIntrpt	; ¨ ±«¥¤ ¢°º¹ ­¥²® ¬³ ¢º§±² ­®¢¿¢ ¬¥
					; ±º±²®¿­¨¥²® ­  ¨­²¥°¯°¥² ²®° 
		ldx	SaveAreaPtr
		stx	wrkF
		ldx	#Yregisters
		stx	wrkF+2
		lda	#YregistersSz
		clrb	;#/YregistersSz
		ldx	#wrkF
		int	_MoveMem
		adda	wrkF+1
		adcb	wrkF
		sta	LongWork+1
		stb	LongWork
		ldx	#SaveArea
		stx	LongWork+2
		ldx	#LongWork
		lda	#SaveAreaSize
		clrb	;#/SaveAreaSize
		int	_MoveMem

		ldx	ReleaseMem	; release memory
		int	_Release
		clr	OSshellFLAG
		rts
		endp;	ExecuteShell

;------------------------------------------------------------------------------
