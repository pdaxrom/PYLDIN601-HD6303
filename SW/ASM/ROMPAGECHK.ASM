;
; ram pages check
;

	include ../DEVMAP.INC
	include ../ROM/BOOTMEM.INC
	include ../ROM/BOOTROM.INC

	org $100

	sei

	ldx	#hello
	jsr	F_PUTSTR

; Setup page port (P6)
	ldaa	#0
	staa	REG_PORT6
	ldaa	#$FF
	staa	REG_DDRP6

	jsr	readpages

;	ldaa	#$17
;	staa	MEMPAGE_SEL
;	ldaa	MEMPAGE_SEL
;	jsr	F_PUTHEX

	ldx	#nl
	jsr	F_PUTSTR
	ldx	#nl
	jsr	F_PUTSTR

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

	ldaa	#MEMPAGE_ROM
	staa	MEMPAGE_SEL

	ldaa	$C000
	staa	mancode
	ldaa	$C001
	staa	devcode

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

	ldx	#code
	jsr	F_PUTSTR

	ldaa	mancode
	jsr	F_PUTHEX
	ldaa	devcode
	jsr	F_PUTHEX

	jmp	F_RESET

readpages proc
	clrb
loop	orab	#MEMPAGE_ROM
	stab	MEMPAGE_SEL
	ldx	#page
	jsr	F_PUTSTR
	tba
	jsr	F_PUTHEX
	ldaa	#32
	jsr	F_PUTCHAR
	ldaa	$CFFE
	jsr	F_PUTHEX
	ldaa	#32
	jsr	F_PUTCHAR
	ldaa	$DFFE
	jsr	F_PUTHEX
	incb
	cmpb	#$20
	bne	loop
	rts
	endp

; Write command
; X - ADDR
; A - CMD
writecmd proc
	pshx
	xgdx
	psha
	lsra
	lsra
	lsra
	lsra
	lsra
	oraa	#MEMPAGE_ROM
	staa	MEMPAGE_SEL
	pula
	anda	#$1F
	addd	#$C000
	xgdx
	staa	0,x
	pulx
	rts
	endp

delay	proc
	pshx
	ldx	#2000
loop	dex
	bne	loop
	pulx
	rts
	endp

hello	db	10, 13, 'RAMPAGES CHECK', 0
page	db	10, 13, 'Page ', 0
code	db	10, 13, 'Manufacture/Device code ', 0
nl	db	10, 13, 0

mancode	db	0
devcode	db	0
