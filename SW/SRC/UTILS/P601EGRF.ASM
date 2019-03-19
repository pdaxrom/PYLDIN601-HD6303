;
; LILITH-601:
; PYLDIN-601 GRAPHICS MODES EMULATOR
;

		include ../../DEVMAP.INC

		ldx	#hello
		int	$23

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

; Set 10 Hz interrupts
; 12MHz/10 = 1200000 = $124F80
;
		ldaa	#$12
		staa	IO_TIM_DIV
		ldx	#$4F80
		stx	IO_TIM_DIV+1
; Enable interrupts and start timer
		ldaa	#(IO_TIM_IEN | IO_TIM_RUN)
		staa	IO_TIM_CONFIG

		ldaa	#$FF
		ldab	MEMPAGE_SEL
		ldx	#irqhandler
		int	$2F

		cli

		ldx	#text1
		int	$23

		int	$2C
		rts

;
screenb		equ	$BDDD
screen_size	equ	$BF19
scrmode		equ	$ED12
scrcols		equ	$ED18

irqhandler	proc
		ldaa	IO_TIM_STATUS
		bita	#IO_TIM_IRQ
		bne	checkmode
ret		rts
checkmode	ldaa	scrmode
		bita	#3
		bne	setup
		clr	curmode
		rts
setup		sei
		cmpa	curmode
		beq	bitblit
		staa	curmode
		ldx	#0
		stx	VPU_VADDR
		ldaa	#40
		staa	VPU_AUTOOFFS

bitblit		ldaa	#25
		staa	rowcnt
		ldaa	#41
		staa	colcnt
		ldx	screenb
		ldd	#0
loopline	std	fb_addr
		std	VPU_ADDR
		dec	colcnt
		beq	nextline
		ldd	0,x
		staa	VPU_DATA
		stab	VPU_DATA
		ldd	2,x
		staa	VPU_DATA
		stab	VPU_DATA
		ldd	4,x
		staa	VPU_DATA
		stab	VPU_DATA
		ldd	6,x
		staa	VPU_DATA
		stab	VPU_DATA
		ldab	#8
		abx
		ldd	fb_addr
		addd	#1
		bra	loopline
nextline	dec	rowcnt
		beq	ret
		ldaa	#41
		staa	colcnt
		ldd	fb_addr
		addd	#40*7
		bra	loopline
		endp

curmode		db	0
fb_addr		dw	0
colcnt		db	0
rowcnt		db	0

hello		db	'Pyldin-601 graphic modes emulator', 10
		db	'(c) sashz <sashz@pdaXrom.org>, 2019', 10, 0
text1		db	'Driver installed.', 10, 0
