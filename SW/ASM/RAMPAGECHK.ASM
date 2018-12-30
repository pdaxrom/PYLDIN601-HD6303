;
; ram pages check
;

	include ../DEVMAP.INC
	include ../ROM/BOOTMEM.INC
	include ../ROM/BOOTROM.INC

	org $100

	ldx	#hello
	jsr	F_PUTSTR

; Setup page port (P6)
	ldaa	#0
	staa	REG_PORT6
	ldaa	#$FF
	staa	REG_DDRP6

	clra
loop	staa	MEMPAGE_SEL
	staa	$c200
	tab
	addb	#$10
	stab	$d200
	inca
	cmpa	#16
	bne	loop

	bsr	readpages

	jmp	F_RESET

readpages proc
	clrb
loop	stab	MEMPAGE_SEL
	ldx	#page
	jsr	F_PUTSTR
	tba
	jsr	F_PUTHEX
	ldaa	#32
	jsr	F_PUTCHAR
	ldaa	$c200
	jsr	F_PUTHEX
	ldaa	#32
	jsr	F_PUTCHAR
	ldaa	$d200
	jsr	F_PUTHEX
	incb
	cmpb	#16
	bne	loop
	rts
	endp

hello	db	10, 13, 'RAMPAGES CHECK', 0
page	db	10, 13, 'Page ', 0
