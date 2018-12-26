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

	ldaa	$E600
	jsr	F_UART_PUTHEX

	ldaa	#$C3
	staa	IO_L8BIT
	staa	IO_L7HI
	staa	IO_L7LO

	ldx	#nl
	jsr	F_UART_PUTS
	ldaa	IO_L8BIT
	jsr	F_UART_PUTHEX
	ldx	#nl
	jsr	F_UART_PUTS
	ldaa	IO_L7HI
	jsr	F_UART_PUTHEX
	ldx	#nl
	jsr	F_UART_PUTS
	ldaa	IO_L7LO
	jsr	F_UART_PUTHEX

loop	ldaa	IO_SWKEYS
	jsr	F_UART_PUTHEX
	ldx	#nl
	jsr	F_UART_PUTS
;	bra	loop

	jmp	F_RESET

hello	db	'SimpleIO TEST!'
nl	db	10, 13, 0
