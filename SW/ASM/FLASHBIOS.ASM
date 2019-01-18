;
; BIOS ROM FLASHER
;
; 1F000 - BIOS
;

	include ../DEVMAP.INC
	include ../ROM/BOOTMEM.INC
	include ../ROM/BOOTROM.INC

	org $100

	sei

	ldx	#hello
	jsr	uart_puts

; Setup page port (P6)
	ldaa	#0
	staa	REG_PORT6
	ldaa	#$FF
	staa	REG_DDRP6

	ldx	#code
	jsr	uart_puts

	jsr	readid

	jsr	uart_outhex
	tba
	jsr	uart_outhex

	ldx	#rwquest
	jsr	uart_puts

	jsr	uart_in
	jsr	uart_out

	cmpa	#'y'
	beq	gowrite
	cmpa	#'Y'
	bne	readonly

gowrite

	ldab	#$01		; addr
	ldx	#$F000		;
	jsr	addrtopage

	ldx	#wrdata
	std	0,x

	ldd	#$1000
	std	2,x

	ldd	#$1000		; length
	lsrd
	lsrd
	lsrd
	lsrd
	lsrd
	lsrd
	lsrd
	stab	4,x

	jsr	writerom

	ldx	#nl
	jsr	uart_puts

	jsr	uart_outhex

readonly	ldx	#nl
		jsr	uart_puts

	ldab	#$01		; addr
	ldx	#$E000		;
	jsr	addrtopage

	psha
	pshb
	jsr	uart_outhex
	tba
	jsr	uart_outhex
	ldx	#nl
	jsr	uart_puts
	pulb
	pula

	jsr	setrompage

	psha
	pshb
	jsr	uart_outhex
	tba
	jsr	uart_outhex
	ldx	#nl
	jsr	uart_puts
	pulb
	pula

	ldx	#$1000
	jsr	wintoram

	ldx	$FFFE

	jmp	0,x

; Write command
; X - ADDR
; A - CMD
writecmd	proc
		pshx
		xgdx
		psha
		lsra
		lsra
		lsra
		lsra
		lsra
		oraa	#MEMPAGE_ROM
		pshb
		tab
		ldaa	MEMPAGE_SEL
		anda	#MEMPAGE_FMASK
		aba
		pulb
		staa	MEMPAGE_SEL
		pula
		anda	#$1F
		addd	#$C000
		xgdx
		staa	0,x
		pulx
		rts
		endp

delay		proc
		pshx
		ldx	#2000
loop		dex
		bne	loop
		pulx
		rts
		endp

readid		proc
		pshx
		ldx	#$5555
		ldaa	#$AA
		jsr	writecmd

		ldx	#$2AAA
		ldaa	#$55
		jsr	writecmd

		ldx	#$5555
		ldaa	#$90
		jsr	writecmd

		jsr	delay

		ldaa	MEMPAGE_SEL
		anda	#MEMPAGE_FMASK
		oraa	#MEMPAGE_ROM
		staa	MEMPAGE_SEL

		ldaa	$C000
		psha
		ldaa	$C001
		psha

		ldx	#$5555
		ldaa	#$AA
		jsr	writecmd

		ldx	#$2AAA
		ldaa	#$55
		jsr	writecmd

		ldx	#$5555
		ldaa	#$F0
		jsr	writecmd

		jsr	delay
		pulb
		pula
		pulx
		rts
		endp

; Write sector
; X - ptr
;
; ptr dw sector
; ptr dw buffer
;
writesec	proc
		pshb
		pshx
		ldx	#$5555
		ldaa	#$AA
		jsr	writecmd

		ldx	#$2AAA
		ldaa	#$55
		jsr	writecmd

		ldx	#$5555
		ldaa	#$A0
		jsr	writecmd
		pulx
		pshx
		ldd	0,x
		bsr	setrompage
		sts	tmps
		lds	2,x
		des
		xgdx
		ldab	#128
loop		pula
		staa	0,x
		inx
		decb
		bne	loop
		lds	tmps

;		jsr	delay
;		jsr	delay
;		jsr	delay
;		jsr	delay
;		jsr	delay
;		jsr	delay
;		jsr	delay
;		jsr	delay

		dex
waitfinish	cmpa	0,x
		bne	waitfinish
		clra
		bra	exit
error		ldaa	#1
exit		pulx
		pulb
		rts
		endp

; Set rom page and return address
; IN:
; D - rom page
; OUT:
; D - address
setrompage	proc
		lsld
		lsld
		psha
		pshb
		anda	#$0F
		bita	#$08
		beq	next
		oraa	#$10
next		oraa	#MEMPAGE_ROM
		tab
		ldaa	MEMPAGE_SEL
		anda	#MEMPAGE_FMASK
		aba
		staa	MEMPAGE_SEL
		pulb
		pula
		lsld
		lsld
		lsld
		lsld
		lsld
		anda	#$1F
		addd	#$C000
		rts
		endp

; Address to rom page
; In:
; BX - Address
; Out:
; D - rom page
addrtopage	proc
		lsrb
		xgdx
		rora
		rorb
		lsrd
		lsrd
		lsrd
		lsrd
		lsrd
		lsrd
		rts
		endp

; X - addr
wintoram	proc
		psha
		pshb
		pshx
		xgdx
		addd	#$2000
		xgdx
		sts	tmps
		txs
		ldx	#$DFFF
loop		ldaa	0,x
		psha
		dex
		cpx	#$BFFF
		bne	loop
		lds	tmps
		pulx
		pulb
		pula
		rts
		endp
; Write ROM
;
; X - write data
;
writerom	proc
		pshb
		pshx
loop		ldd	0,x
		bsr	printwrsec
		ldaa	4,x
		bsr	printwrtot
		tst	4,x
		beq	exit
		jsr	writesec
		ldd	0,x
		addd	#1
		std	0,x
		ldd	2,x
		addd	#128
		std	2,x
		dec	4,x
		bra	loop
exit		clra
		pulx
		pulb
		rts
		endp

printwrsec	proc
		pshx
		psha
		pshb
		ldx	#txtwritesec
		jsr	uart_puts
		jsr	uart_outhex
		tba
		jsr	uart_outhex
		pulb
		pula
		pulx
		rts
		endp

printwrtot	proc
		pshx
		ldx	#txtwritetotal
		jsr	uart_puts
		jsr	uart_outhex
		pulx
		rts
		endp

uart_in		proc
		ldaa	REG_TRCSR
		anda	#$C0		;FILTER OUT RDRF AND ORFE
		cmpa	#$00
		beq	uart_in		;WAIT FOR CHARACTER
		cmpa	#$40
		beq	uartin1		;CHECK FOR FRAMING ERROR
		ldaa	REG_RDR         ;READ RECIEVED CHARACTER
		rts
uartin1		ldaa	REG_RDR		;ON ERROR, FLUSH BUFFER AND CLEAR ERROR FLAG
		bra	uart_in
		endp

uart_out	proc
		pshb
uartou1		ldab	REG_TRCSR	;Get Status Reg 
		aslb			;TDRE->C
		aslb
		aslb
		bcc	uartou1		;READY FOR NEXT CHARACTER
		staa	REG_TDR
		pulb
		rts
		endp

uart_puts 	proc
		pshx
		psha
loop		ldaa	0,x
		tsta
		beq	exit
		bsr	uart_out
		inx
		bra	loop
exit		pula
		pulx
		rts
		endp

uart_outhex	proc
		psha
		pshb
		tab
		bsr	OUTNIBH
		tba
		bsr	OUTNIBL
		pulb
		pula
		rts
OUTNIBH		lsra
		lsra
		lsra
		lsra
OUTNIBL		anda	#$0F
		oraa	#$30
		cmpa	#$39
		bls	OUTNIBX
		adda	#$7
OUTNIBX 	bsr	uart_out
		rts
		endp

get_word	proc
		bsr	uart_in
		tab
		bsr	uart_in
		psha
		pshb
		pulx
		rts
		endp

hello		db	10, 13, 'FLASH BIOS Utility', 0
code		db	10, 13, 'Flash Manufacture/Device code ', 0
nl		db	10, 13, 0
txtwritesec	db	10, 13, 'Write sector ', 0
txtwritetotal	db	', Total ', 0

rwquest		db	10, 13, 'Write (y/N)? '

tmps		dw	0

wrdata		dw	0
		dw	0
		db	0

mancode		db	0
devcode		db	0
