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

	ldaa	#VPU_B_AUTO
	staa	VPU_CONFIG

	ldx	#0
	stx	VPU_ADDR

	ldx	#40*25
	clra
loop	staa	VPU_DATA
	inca
	dex
	bne	loop

	ldaa	VPU_CONFIG
	oraa	#VPU_B_CUR|VPU_B_CURINV
	staa	VPU_CONFIG

	ldaa	#3
	staa	VPU_CURPOS
	ldaa	#0
	staa	VPU_CURLINS
	ldaa	#7
	staa	VPU_CURLINE

	ldaa	VPU_CONFIG
	jsr	F_PUTHEX
	ldaa	VPU_CURPOS
	jsr	F_PUTHEX
	ldaa	VPU_CURLINS
	jsr	F_PUTHEX
	ldaa	VPU_CURLINE
	jsr	F_PUTHEX

exit	jmp	F_RESET

hello	db	'Hello, Text mode!', 10, 13, 0

