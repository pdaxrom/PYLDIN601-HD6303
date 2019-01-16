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

; HD6303Y Enable IRQ1 input
	ldaa	REG_RP5CR
	oraa	#BIT_IRQ1E
	staa	REG_RP5CR

	ldaa	PS2_CONFIG
	oraa	#PS2_BIT_IEN
	staa	PS2_CONFIG

	ldx	#irqhandler
	stx	VIRQ

	ldx	#text1
	jsr	F_UART_PUTS

	cli

loop	bra	loop

irqhandler proc
	ldaa	PS2_CONFIG
	bita	#PS2_BIT_IEN
	beq	ret
	bita	#PS2_BIT_RDY
	beq	ret
	ldaa	PS2_DATA
	jsr	F_PUTHEX
	ldx	#nl
	jsr	F_PUTSTR
ret	rti
	endp

hello	db	'Hello, PS2 Keyboard'
nl	db	10, 13, 0
text1	db	'Press any keys!!!', 10, 13, 0
