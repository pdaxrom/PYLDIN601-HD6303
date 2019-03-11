	include ../DEVMAP.INC
	include ../ROM/BOOTMEM.INC
	include ../ROM/BOOTROM.INC

	org $100

	ldx	#hello
	jsr	F_PUTSTR

loop	ldx	#buf
read	jsr	F_UART_IN
	staa	0,x
	inx
	cpx	#buf+16
	bne	read

	ldx	#buf
	ldaa	#14

	jsr	psg_write

	ldaa	IO_SWKEYS
	bita	#1
	beq	loop

exit	ldx	#bye
	jsr	F_PUTSTR
	jmp	F_RESET

psg_write proc
	pshx
	pshb
	psha
	tab
	clra
loop	staa	PSG_ADDR
	psha
	ldaa	0,x
	staa	PSG_DATA
	pula
	inx
	inca
	decb
	bne	loop
	pula
	pulb
	pulx
	rts
	endp

hello	db	$0c, $0a, $0d, 'AY-3-8912 SERIAL CHIPTUNE!', $0a, $0d, 0
busy	db	'SPI busy, try again', 0
bye	db	$0a, $0d, 'Bye!', $0a, $0d, 0

buf	ds	16
