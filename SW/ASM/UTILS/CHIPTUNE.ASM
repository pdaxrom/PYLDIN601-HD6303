	include ../../DEVMAP.INC

	org $100

	ldx	#hello
	int	$23

	sei

loop	ldx	#buf
read	bsr	uart_in
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

	cli

exit	ldx	#bye
	int	$23
	rts

uart_in		proc
		ldaa	REG_TRCSR
		anda	#$C0		;FILTER OUT RDRF AND ORFE
		cmpa	#$00
		beq	uart_in		;WAIT FOR CHARACTER
		cmpa	#$40
		beq	uartin1		;CHECK FOR FRAMING ERROR
		ldaa	REG_RDR         ;READ RECIEVED CHARACTER
		rts
uartin1		ldaa	REG_RDR		;ON ERROR, FLUSH BUFFER AND CLEAR ERROR FLAG
		bra	uart_in
		endp

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

hello	db	$0c, $0a, 'AY-3-8912 SERIAL CHIPTUNE!', $0a, 0
busy	db	'SPI busy, try again', 0
bye	db	$0a, 'Bye!', $0a, 0

buf	ds	16
