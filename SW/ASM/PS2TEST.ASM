;
; Check GPIO
;
; GPIO 0 - LED
; GPIO 1 - LED
; GPIO 2 - BUTTON to GND
; GPIO 3 - BUTTON to GND
;

	include ../DEVMAP.INC
	include ../ROM/BOOTMEM.INC
	include ../ROM/BOOTROM.INC

	org $100

	sei

	ldx	#hello
	jsr	F_PUTSTR

	ldx	#20
loop	pshx
loop1	ldaa	PS2_CONFIG
	bita	#PS2_BIT_RDY
	beq	loop1

	ldab	PS2_DATA

	bra	show

	cmpa	oldc
	beq	loop1
;	bne	show
	cmpb	oldd
	bne	show
	bra	loop1

show
	staa	oldc
	stab	oldd

	jsr	F_PUTHEX
	tba
	jsr	F_PUTHEX

	ldx	#nl
	jsr	F_PUTSTR

	pulx
	dex
	bra	loop

	jmp	F_RESET

oldc	db	0
oldd	db	0

hello	db	'Hello, PS2'
nl	db	10, 13, 0
