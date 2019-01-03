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

	ldab	#10
	ldaa	#1
loop	bsr	ps2led
	lsla
	bita	#$08
	beq	next
	ldaa	#1
next	ldx	#0
loop1	dex
	bne	loop1
	decb
	bne	loop

	jmp	F_RESET

ps2led	proc
	psha
	ldaa	#$ED
	bsr	ps2write
	bsr	ps2read
	pula
	psha
	bsr	ps2write
	bsr	ps2read
	pula
	rts
	endp

ps2read	proc
	ldaa	PS2_CONFIG
	bita	#PS2_BIT_RDY
	beq	ps2read
	ldaa	PS2_DATA
	rts
	endp

ps2write proc
	staa	PS2_DATA
	psha
loop0	ldaa	PS2_CONFIG
	bita	#PS2_BIT_BSY
	bne	loop0
	pula
	rts
	endp

hello	db	'Hello, PS2 leds'
nl	db	10, 13, 0
