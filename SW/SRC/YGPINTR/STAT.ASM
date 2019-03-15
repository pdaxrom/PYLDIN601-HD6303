;******************************************************************************
;*									      *
;*			       Ycode Statistics.			      *
;*									      *
;*				  Version 1.00				      *
;*									      *
;*			  (c) 1989 Гео░ги Пе▓░ов /YGP/			      *
;*									      *
;******************************************************************************

                org     $100
		include interrupts.inc
		include globals.y
		include sys_page.y

StatisticsCalc	proc
		ldx	#CPright
		int	_Wstr

		lda	EquipmentBYTE
		anda	#EquipYcode
		bne	HasYcode
		ldx	#NoYcode
		int	_Wstr
		rts
HasYcode
                ;ldx     Version
                ;cpx     #$100
		lda     Sys_Ver
                beq     bad_version
                cmpa    #Version
                bhi     bad_version
                lda     Sys_Ver+1
                cmpa    #55
                bcs     bad_version
                cmpa    #Flavour
                bhi     bad_version
                bra     VersionOK
bad_version
		ldx	#BadVersion
		int	_Wstr
		rts
VersionOK
		jsr	SwapVectors

		ldx	#TypeExit
		int	_Wstr
		int	_UniDOSshell	; call UniDOS shell
		jsr	SwapVectors

		lda	#10
		int	_Wchar
		lda	#'-'
		ldb	#30
minus_loop	int	_Wchar
		decb
		bne	minus_loop
		ldx	#Total
		int	_Wstr
		ldx	#Instructions+1
		int	_Wstr

		ldx	#TTLInstrCounter
		jsr	PrWordHex

		ldx	#Total
		int	_Wstr
		ldx	#MicroSec+1
		int	_Wstr
		lda	TTLMSCounter
		beq	NotLarge
		int	_Whex
NotLarge
		ldx	#TTLMSCounter+1
		jsr	PrWordHex

		int	_Terminate

CPright 	db	'Ycode statistics 1.00. (c) 1989 YGP.', 10, 0
TypeExit	db	'Type EXIT to exit statistics', 10, 0
NoYcode 	db	'No Ycode interpreter in system', 7, 0
BadVersion      db      'Incorrect version of Ycode interpreter', 7, 0
		endp;	Statistics

Total		db	10, 'Total ', 0
Instructions	db	10, 'Instructions $', 0
MicroSec	db	10, 'MicroSeconds $', 0

; ------- Bump Instruction Counter -------
; Increment 4 byte Counter by 1
; Export:   A = Number of micro seconds. X register destroyed

BumpCounter	proc

		lda	#2+6+4		; 2
		tst	MustCalc	; 6
		beq	NoCarry 	; 4

		adda	#2+5+4+6+4	; 2
		ldx	InstrCounter+2	; 5
		inx			; 4
		stx	InstrCounter+2	; 6
		bne	NoCarry 	; 4

		adda	#2+5+4+6
		ldx	InstrCounter
		inx
		stx	InstrCounter

NoCarry 	adda	#2 + 9 + 5	; 9 for jsr + 5 for rts
		rts
		endp;	BumpCounter

; ------- Bump MicroSeconds counter -------
; Increment 4 byte Counter by 20 MiliSeconds

BumpMScounter	proc

BumpConst	=	20 * 1000 - (8 + 11 * 5 + 5 + 9) - 400

		lda	MustCalc	; 4
		beq	DontCalc	; 4

		lda	#BumpConst	; 2
		ldb	#/BumpConst	; 2
		adda	MScounter+4	; 4
		adcb	MScounter+3	; 4
		sta	MScounter+4	; 5
		stb	MScounter+3	; 5

		lda	MScounter+2	; 4
		ldb	MScounter+1	; 4
		adca	#0		; 2
		adcb	#0		; 2
		sta	MScounter+2	; 5
		stb	MScounter+1	; 5

		lda	MScounter	; 4
		adca	#0		; 2
		sta	MScounter	; 5

DontCalc	;rts			 ; 5 + 9
		ldb	I_50_Hz+1
		ldx	I_50_Hz+2
		int	_ChainIntrpt
		endp;	BumpMScounter

Counters
InstrCounter	ds	4, 0
MScounter	ds	5, 0		; 5 bytes дава▓ около 148 ╖а▒а (▒▓ига▓)
CountersSz	=	9
MustCalc	db	0		; ако е 0 не ▒е ▒м┐▓а

; interrupt vectors table

InterruptTable

I_50_Hz 	db	_50_Hz
		db	0
		dw	BumpMScounter

ReadKey 	db	_ReadKey
		db	0
		dw	New_ReadKey

DiskIO		db	_DiskIO
		db	0
		dw	New_DiskIO

Printer 	db	_Printer
		db	0
		dw	New_Printer

Terminate	db	_Terminate
		db	0
		dw	New_Terminate

CallYcode	db	_CallYcode
		db	0
		dw	New_CallYcode

DbgActivate	db	_DbgActivate
		db	0
		dw	New_DbgActivate

		db	0		; end of table

; ------- Swap Interrupt Vectors -------
; Размен┐ interrupt век▓о░и▓е о▓ ▓абли╢а▓а ▒ ▓ези о▓ BIOS

SwapVectors	proc

		ldx	#InterruptTable
		sei			; ░або▓а▓а е опа▒на
loop		lda	x, 0
		beq	ExitLoop	; 0 зна╖и к░ай на ▓абли╢а▓а
		stx	wrkX+2

		int	_GetIntVec	; get interrupt vector (from BIOS)
		stb	wrkB		; temporary save
		stx	wrkX

		ldx	wrkX+2
		ldb	x, 1
		ldx	x, 2
		int	_SetIntVec	; по▒▓ав┐ме ▓ози о▓ ▓абли╢а▓а

		ldx	wrkX+2		; по▒▓ав┐ме о░игинални▓е в ▓абли╢а▓а
		ldb	wrkB
		stb	x, 1
		lda	wrkX+1		; BA ка▓о 16 би▓ов ░еги▒▓║░
		ldb	wrkX
		sta	x, 3
		stb	x, 2

		inx
		inx
		inx
		inx
		bra	loop

ExitLoop
		cli
		rts

wrkB		ds	2
wrkX		ds	4
		endp;	SwapVectors

; ------- Print LongWord in Hex -------
; Import X = ptr to begining of word (Bsex+)

PrWordHex	proc
		pha
		lda	x, 0
		int	_Whex
		lda	x, 1
		int	_Whex
		lda	x, 2
		int	_Whex
		lda	x, 3
		int	_Whex
		pla
		rts
		endp;	PrWordHex


New_ReadKey	ldx	#ReadKey
		bra	CallOriginal
New_DiskIO	ldx	#DiskIO
		bra	CallOriginal
New_Printer	ldx	#Printer

CallOriginal	proc
		ldb	MustCalc	; preserve MustCalc
		clr	MustCalc
		phb

		ldb	x, 1		; викаме ▒▓а░и┐ interrupt
		ldx	x, 2		; и ▒лед ▓ова показваме help lines
		bsr	CallInterrupt

		plb
		stb	MustCalc
		rts

CallInterrupt	int	_ChainIntrpt

		endp;	CallOriginal

New_Terminate	proc

		jsr	Display

		ldb	Terminate+1
		ldx	Terminate+2
		int	_ChainIntrpt
		endp;	New_Terminate

TTLInstrCounter ds	4, 0
TTLMScounter	ds	5, 0		; 5 bytes дава▓ около 148 ╖а▒а (▒▓ига▓)

InYcode 	db	0

New_DbgActivate proc
		jsr	SwapMainLoop
		lda	#1
		sta	MustCalc

		ldx	#DbgActivate
		jmp	CallOriginal

		endp;	New_DbgActivate

PatchCode	jmp	CalcYcode
;DbgPatch        =       InterpreterCode + 10   ???
DbgPatch        =       RAM_code + 10

CalcYcode	proc
		sei			; 2
		stx	ipc
		pha			; 4
		jsr	BumpCounter
		adda	#2+4+4+2+3+3+2+5*11
		tab			; 2
		lda	MScounter+4	; 4
		sba			; 2
		sta	MScounter+4	; 5
		lda	MScounter+3	; 4
		sbca	#0		; 2
		sta	MScounter+3	; 5
		lda	MScounter+2	; 4
		sbca	#0		; 2
		sta	MScounter+2	; 5
		lda	MScounter+1	; 4
		sbca	#0		; 2
		sta	MScounter+1	; 5
		lda	MScounter+0	; 4
		sbca	#0		; 2
		sta	MScounter+0	; 5

		pla			; 4
		asla
		cli			; 2
		jmp	DbgPatch+3	; 3 + 3 за идване и о▓иване
		endp;	CalcYcode

New_CallYcode	proc
		lda	#1
		sta	InYcode
		clr	MustCalc

		ldb	CallYcode+1
		ldx	CallYcode+2
		bsr	CallInterrupt
		jmp	Display

CallInterrupt	int	_ChainIntrpt
		endp;	New_CallYcode

Display 	proc

		lda	InYcode
		bne	Is
		rts
Is
		jsr	SwapMainLoop
		clr	MustCalc	; DontCalc
		clr	InYcode
		ldx	#Instructions
		int	_Wstr
		ldx	#InstrCounter
		jsr	PrWordHex

		lda	InstrCounter+3
		adda	TTLInstrCounter+3
		sta	TTLInstrCounter+3
		lda	InstrCounter+2
		adca	TTLInstrCounter+2
		sta	TTLInstrCounter+2
		lda	InstrCounter+1
		adca	TTLInstrCounter+1
		sta	TTLInstrCounter+1
		lda	InstrCounter
		adca	TTLInstrCounter
		sta	TTLInstrCounter
		lda	#'('
		int	_Wchar
		ldx	#TTLInstrCounter
		jsr	PrWordHex
		lda	#')'
		int	_Wchar

		ldx	#MicroSec
		int	_Wstr
		lda	MSCounter
		beq	NotLarge
		int	_Whex
NotLarge
		ldx	#MSCounter+1
		jsr	PrWordHex

		lda	MSCounter+4
		adda	TTLMSCounter+4
		sta	TTLMSCounter+4
		lda	MSCounter+3
		adca	TTLMSCounter+3
		sta	TTLMSCounter+3
		lda	MSCounter+2
		adca	TTLMSCounter+2
		sta	TTLMSCounter+2
		lda	MSCounter+1
		adca	TTLMSCounter+1
		sta	TTLMSCounter+1
		lda	MSCounter
		adca	TTLMSCounter
		sta	TTLMSCounter

		lda	#'('
		int	_Wchar
		lda	TTLMSCounter
		beq	NotLargeTTL
		int	_Whex
NotLargeTTL
		ldx	#TTLMSCounter+1
		jsr	PrWordHex
		lda	#')'
		int	_Wchar

		ldx	#Counters
		clra
		ldb	#CountersSz
ClrLoop 	sta	x, 0
		inx
		decb
		bne	ClrLoop
		rts
		endp;	Display

SwapMainLoop	proc
		sei
		pha
		phb
		lda	PatchCode
		ldb	DbgPatch
		sta	DbgPatch
		stb	PatchCode

		lda	PatchCode+1
		ldb	DbgPatch+1
		sta	DbgPatch+1
		stb	PatchCode+1

		lda	PatchCode+2
		ldb	DbgPatch+2
		sta	DbgPatch+2
		stb	PatchCode+2
		plb
		pla
		cli
		rts
		endp;	SwapMainLoop

		END. StatisticsCalc