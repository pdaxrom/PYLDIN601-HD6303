;
; Check RTC IRQ
;

	include ../DEVMAP.INC
	include ../ROM/BOOTMEM.INC
	include ../ROM/BOOTROM.INC

	org $100

	sei

	ldx	#hello
;	int	F_PUTSTR
	jsr	F_UART_PUTS

	ldaa	#01
	staa	IO_L7HI
	inca
	staa	IO_L7LO

	clr	$80
	clr	$81
	clr	$82

; HD6303Y Enable IRQ1 input
	ldaa	REG_RP5CR
	oraa	#BIT_IRQ1E
	staa	REG_RP5CR

; Enable VBL IRQ
	ldaa	VPU_CONFIG
	oraa	VPU_B_IEN
	staa	VPU_CONFIG

	ldx	#irqhandler
	stx	VIRQ

	ldx	#text1
	jsr	F_UART_PUTS

	cli

loop	ldaa	IO_SWKEYS
	staa	IO_L8BIT
	bita	#1
	beq	next
	ldx	#but1txt
	bra	print
next	bita	#2
	beq	next2
	ldx	#but2txt
	bra	print
next2	bita	#4
	beq	loop
	ldx	#but3txt
print
	jsr	F_UART_PUTS
	bra	loop

but1txt	db	'Button 1 pressed!', 10, 13, 0
but2txt db	'Button 2 pressed!', 10, 13, 0
but3txt db	'Button 3 pressed!', 10, 13, 0

irqhandler proc
	ldaa	VPU_CONFIG
	bita	#VPU_B_IRQ
	beq	ret
; Increase time
	ldx	$81
	inx
	stx	$81
	cpx	#50
	bne	ret
	clr	$81
	clr	$82
	inc	$80

	ldab	$80
	andb	#$0F
	ldx	#ledhex
	abx
	ldaa	0,x
	staa	IO_L7LO

	ldab	$80
	rorb
	rorb
	rorb
	rorb
	andb	#$0F
	ldx	#ledhex
	abx
	ldaa	0,x
	staa	IO_L7HI
ret	rti
	endp

hello	db	'Video IRQ test', 10, 13, 0
text1	db	'Started', 10, 13, 0

ledhex	db	$3f, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F, $77, $7C, $39, $5E, $79, $71
