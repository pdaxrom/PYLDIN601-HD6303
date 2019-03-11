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
	jsr	F_UART_PUTS

	ldaa	#VPU_B_GRF|VPU_B_AUTO
	staa	VPU_CONFIG

	ldx	#0
	stx	VPU_ADDR

	ldx	#kim
loop	ldd	0,x
	staa	VPU_DATA
	stab	VPU_DATA
	inx
	inx
	cpx	#kim+8000
	bne	loop

	jmp	F_RESET

hello	db	'Hello, Graphics mode!', 10, 13, 0

kim	INCLUDE KIM.INC
