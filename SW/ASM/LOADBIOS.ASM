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

	ldaa	MEMPAGE_SEL
	oraa	#MEMSPACE_FN1
	staa	MEMPAGE_SEL
;	jsr	F_PUTHEX

	lds	#$0FFF
	ldx	#$F000
loop	pula
	staa	0,x
	inx
	bne	loop

	ldx	$FFFE
	jmp	0,x

hello	db	'BIOS loader: move 0x1000-0x1FFF to 0xF000 in memspace 4', 10, 13, 0
