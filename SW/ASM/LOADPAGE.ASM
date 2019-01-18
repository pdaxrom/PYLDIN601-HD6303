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

MEMSPACE_FN1	EQU	%10000000

	org $100

	sei

	ldx	#hello
	jsr	F_UART_PUTS

	jsr	F_UART_IN
	jsr	F_PUTCHAR
	anda	#$07
	staa	page

	ldaa	MEMPAGE_SEL
	anda	#MEMPAGE_FMASK|$10
	oraa	#$10
	oraa	page
	staa	MEMPAGE_SEL
;	jsr	F_PUTHEX

	lds	#$0FFF
	ldx	#$C000
loop	pula
	staa	0,x
	inx
	cpx	#$E000
	bne	loop

	jmp	F_RESET

hello	db	'PAGE loader: move 0x1000-0x2FFF to 0xC000 in page ', 10, 13, 0
page	db	0
