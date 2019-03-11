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

	ldaa	SPI_CONFIG
	anda	#$FF^(SPI_16B)
	oraa	#(SPI_SSM | SPI_SS1 | SPI_SS0)
	staa	SPI_CONFIG
	ldaa	#40
	staa	SPI_PRESCALER

	ldaa	SPI_CONFIG
	anda	#$FF^SPI_SS1
	staa	SPI_CONFIG

	ldaa	#$AA
	jsr	sdspi_write
	jsr	F_PUTHEX


	jsr	F_UART_IN

	ldaa	SPI_CONFIG
	oraa	#SPI_SS1
	staa	SPI_CONFIG

	jmp	F_RESET

sdspi_write proc
	global	sdspi_read
	staa	SPI_DATA+1
loop	ldaa	SPI_STATUS
	bita	#SPI_READY
	beq	loop
	ldaa	SPI_DATA+1
	rts
sdspi_read ldaa	#$FF
	bra	sdspi_write
	endp

hello	db	'Hello, World!', 10, 13, 0
