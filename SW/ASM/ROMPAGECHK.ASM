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

	bsr	readpages

	ldaa	#$17
	staa	MEMPAGE_SEL
;	ldaa	MEMPAGE_SEL
;	jsr	F_PUTHEX

	jmp	F_RESET

readpages proc
	ldab	#MEMPAGE_ROM
loop	stab	MEMPAGE_SEL
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

hello	db	10, 13, 'RAMPAGES CHECK', 0
page	db	10, 13, 'Page ', 0
