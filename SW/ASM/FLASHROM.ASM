;
; ROM FLASHER
;
; 14000 - UniBIOS
; 18000 - UniDOS
;
;
; 1F000 - BIOS
;

	include ../DEVMAP.INC
	include ../ROM/BOOTMEM.INC
	include ../ROM/BOOTROM.INC

	org $100

	sei

	ldx	#hello
	jsr	F_PUTSTR

; Setup page port (P6)
;	ldaa	#0
;	staa	REG_PORT6
;	ldaa	#$FF
;	staa	REG_DDRP6

	ldx	#code
	jsr	F_PUTSTR

	jsr	readid

	jsr	F_PUTHEX
	tba
	jsr	F_PUTHEX

	ldx	#rwquest
	jsr	F_PUTSTR

	jsr	F_UART_IN
	jsr	F_PUTCHAR

	cmpa	#'y'
	beq	gowrite
	cmpa	#'Y'
	bne	readonly

gowrite

	ldab	#$01		; addr
	ldx	#$4000		;
	jsr	addrtopage

	ldx	#wrdata
	std	0,x

	ldd	#$1000
	std	2,x

	ldd	#$2000		; length
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
	jsr	F_PUTSTR

	jsr	F_PUTHEX

readonly	ldx	#nl
		jsr	F_PUTSTR

	ldab	#$01		; addr
	ldx	#$4000		;
	jsr	addrtopage

	psha
	pshb
	jsr	F_PUTHEX
	tba
	jsr	F_PUTHEX
	ldx	#nl
	jsr	F_PUTSTR
	pulb
	pula

	jsr	setrompage

	psha
	pshb
	jsr	F_PUTHEX
	tba
	jsr	F_PUTHEX
	ldx	#nl
	jsr	F_PUTSTR
	pulb
	pula

	ldx	#$1000
	jsr	wintoram

	jmp	F_RESET

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
		jsr	F_PUTSTR
		jsr	F_PUTHEX
		tba
		jsr	F_PUTHEX
		pulb
		pula
		pulx
		rts
		endp

printwrtot	proc
		pshx
		ldx	#txtwritetotal
		jsr	F_PUTSTR
		jsr	F_PUTHEX
		pulx
		rts
		endp

hello		db	10, 13, 'FLASHROM Utility', 0
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
