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

	ldaa	PS2_DATA
	jsr	F_PUTHEX

	ldx	#nl
	jsr	F_PUTSTR

	pulx
	dex
	bra	loop

	jmp	F_RESET

hello	db	'Hello, PS2'
nl	db	10, 13, 0
