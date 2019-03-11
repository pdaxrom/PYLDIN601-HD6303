;
; Check RTC IRQ
;

	include ../../DEVMAP.INC

	org $100

	ldx	#hello
	int	$23

	ldaa	#01
	staa	IO_L7HI
	inca
	staa	IO_L7LO

	clr	$F0
	clr	$F1
	clr	$F2

	sei

; Setup interrupt router
	ldaa	INT_ROUTER
	oraa	#%00000100	; IRQS5 - INT_SEL_IRQ2
	staa	INT_ROUTER

; HD6303Y Enable IRQ1 input
	ldaa	REG_RP5CR
	oraa	#BIT_IRQ2E
	staa	REG_RP5CR

; Setup timer
	ldaa	#0
	staa	IO_TIM_CONFIG

; Set 50 Hz interrupts
; 12MHz/50 = 240000 = $3A980
;
	ldaa	#$03
	staa	IO_TIM_DIV
	ldx	#$A980
	stx	IO_TIM_DIV+1
; Enable interrupts and start timer
	ldaa	#(IO_TIM_IEN | IO_TIM_RUN)
	staa	IO_TIM_CONFIG

	ldaa	#$FF
	ldab	MEMPAGE_SEL
	ldx	#irqhandler
	int	$2F

	ldx	#text1
	int	$23

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
print	int	$23
	bra	loop

but1txt	db	'Button 1 pressed!', 10, 0
but2txt db	'Button 2 pressed!', 10, 0
but3txt db	'Button 3 pressed!', 10, 0

irqhandler proc
	ldaa	IO_TIM_STATUS
	bita	#IO_TIM_IRQ
	beq	ret
; Increase time
	ldx	$F1
	inx
	stx	$F1
	cpx	#50
	bne	ret
	clr	$F1
	clr	$F2
	inc	$F0

	ldab	$F0
	andb	#$0F
	ldx	#ledhex
	abx
	ldaa	0,x
	staa	IO_L7LO

	ldab	$F0
	rorb
	rorb
	rorb
	rorb
	andb	#$0F
	ldx	#ledhex
	abx
	ldaa	0,x
	staa	IO_L7HI
ret	rts
	endp

hello	db	'IRQ test', 10, 0
text1	db	'Started', 10, 0

ledhex	db	$3f, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F, $77, $7C, $39, $5E, $79, $71
