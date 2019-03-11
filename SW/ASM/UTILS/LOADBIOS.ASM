;

	include ../../DEVMAP.INC

MEMSPACE_FN1	EQU	%10000000

	org $100

	ldx	#hello
	int	$23

	sei

;	ldaa	MEMPAGE_SEL
;	anda	#$FF^MEMPAGE_FMASK
	clra
	oraa	#MEMSPACE_FN1
	staa	MEMPAGE_SEL

	lds	#$0FFF
	ldx	#$F000
loop	pula
	staa	0,x
	inx
	bne	loop

	ldx	$FFFE
	jmp	0,x

hello	db	10, 'BIOS loader: move 0x1000-0x1FFF to 0xF000 in memspace 4', 10, 0
