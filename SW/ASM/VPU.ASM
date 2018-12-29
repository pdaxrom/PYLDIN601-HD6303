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

	ldaa	VPU_HSOFFS
	jsr	F_PUTHEX
	ldaa	VPU_VSOFFS
	jsr	F_PUTHEX

	ldaa	VPU_CONFIG
	jsr	F_PUTHEX
	ldaa	VPU_AUTOOFFS
	jsr	F_PUTHEX

	ldaa	#VPU_B_GRF|VPU_B_AUTO
	staa	VPU_CONFIG

	ldx	#nl
	jsr	F_PUTSTR

	ldx	#0
	stx	VPU_ADDR

	ldx	#40
	clra
loop	bsr	showad
	jsr	F_PUTHEX
	staa	VPU_DATA
	inca
	dex
	bne	loop

	ldx	#0
	stx	VPU_ADDR

	ldx	#40
loop1	bsr	showad
	ldaa	VPU_DATA
	jsr	F_PUTHEX
	dex
	bne	loop1

	jmp	F_RESET

showad	proc
	psha
	pshb
	pshx
	ldx	#nl
	jsr	F_PUTSTR
	ldaa	VPU_ADDR
	jsr	F_PUTHEX
	ldaa	VPU_ADDR+1
	jsr	F_PUTHEX
	pulx
	pulb
	pula
	rts
	endp

nl	db	10,13,0

hello	db	'Hello, World!', 10, 13, 0
