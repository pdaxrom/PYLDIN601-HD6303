;
; RAM checker
;

	include ../../DEVMAP.INC

	org $100

	ldx	#hello
	int	$23

	ldx	#ramstart
	stx	RAM_START
	tsx
	xgdx
	subd	#$400
	xgdx
	stx	RAM_END

;
;
;
	ldaa	#$00
	jsr	fillbyte

	ldaa	#$ff
	jsr	fillbyte

	ldaa	#$aa
	jsr	fillbyte

	ldaa	#$55
	jsr	fillbyte

	ldaa	#$a5
	jsr	fillbyte

	ldaa	#$5a
	jsr	fillbyte

;
;
;
	ldaa	#8
	staa	RAM_STEP

	ldaa	#$00
	jsr	fillbyte_step

	ldaa	#$ff
	jsr	fillbyte_step

	ldaa	#$aa
	jsr	fillbyte_step

	ldaa	#$55
	jsr	fillbyte_step

	ldaa	#$a5
	jsr	fillbyte_step

	ldaa	#$5a
	jsr	fillbyte_step

;
;
;
	jsr	fillram

	rts

fillram proc
	ldaa	#0
loop	ldx	#fillram1
	int	$23
	int	$25
	ldx	RAM_START
loopw	staa	0,x
	inx
	cpx	RAM_END
	blo	loopw
	ldx	RAM_START
loopr	ldab	0,x
	cba
	bne	error
	inx
	cpx	RAM_END
	blo	loopr
	ldx	#okay
	int	$23
	inca
	cmpa	#0
	bne	loop
	rts
error	pshx
	ldx	#failed
	int	$23
	tba
	int	$25
	ldx	#failed1
	int	$23
	pulx
	ldab	#16
err1	ldaa	0,x
	int	$25
	ldaa	#32
	int	$22
	decb
	cmpb	#0
	bne	err1
	rts
	endp

fillbyte proc
loop	ldx	#fillram1
	int	$23
	int	$25
	ldx	RAM_START
loopw	staa	0,x
	inx
	cpx	RAM_END
	blo	loopw
	ldx	RAM_START
loopr	ldab	0,x
	cba
	bne	error
	inx
	cpx	RAM_END
	blo	loopr
	ldx	#okay
	int	$23
	rts
error	pshx
	ldx	#failed
	int	$23
	tba
	int	$25
	ldx	#failed1
	int	$23
	pulx
	ldab	#16
err1	ldaa	0,x
	int	$25
	ldaa	#32
	int	$22
	decb
	cmpb	#0
	bne	err1
	rts
	endp

fillbyte_step proc
loop	ldx	#fillram1
	int	$23
	int	$25
	ldx	RAM_START
loopw	staa	0,x
	ldab	RAM_STEP
	abx
	cpx	RAM_END
	blo	loopw
	ldx	RAM_START
loopr	ldab	0,x
	cba
	bne	error
	ldab	RAM_STEP
	abx
	cpx	RAM_END
	blo	loopr
	ldx	#okay
	int	$23
	rts
error	pshx
	ldx	#failed
	int	$23
	tba
	int	$25
	ldx	#failed1
	int	$23
	pulx
	ldab	#16
err1	ldaa	0,x
	int	$25
	ldaa	#32
	int	$22
	decb
	cmpb	#0
	bne	err1
	rts
	endp

hello	db	10, 'RAM CHECK', 10, 0
fillram1 db	'Fill RAM with byte ', 0
okay	db	' Okay', 10, 0
failed	db	' Failed ($',0
failed1 db	')', 10, 0

RAM_START	dw	0
RAM_END		dw	0
RAM_STEP	db	0

ramstart
