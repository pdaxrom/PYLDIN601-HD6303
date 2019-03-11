;
;
;

	include ../../DEVMAP.INC

MEMSPACE_FN1	EQU	%10000000

	org $100

	cli

	ldx	#hello
	int	$23

	int	$20
	int	$22
	anda	#$07
	staa	page

	ldx	#nl
	int	$23

	sei

	ldaa	MEMPAGE_SEL
	psha
	anda	#MEMPAGE_FMASK|$10
	oraa	#$10
	oraa	page
	staa	MEMPAGE_SEL

	sts	tmps
	lds	#$BFFF
	ldx	#$1000
loop	pula
	staa	0,x
	inx
	cpx	#$3000
	bne	loop
	lds	tmps

	pula
	staa	MEMPAGE_SEL

	cli

	rts

hello	db	10, 'PAGE saver', 10, 'Move to 0x1000-0x2FFF from page ', 0
nl	db	10, 0
page	db	0
tmps	dw	0
