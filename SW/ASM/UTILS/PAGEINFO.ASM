		org	$100

		include ../../DEVMAP.INC

MEMPAGE_HI	equ	$10

romstart	equ	$C000

		ldx	#title
		int	$23

		clrb
loop		pshb
		pshb

		sei
		ldaa	MEMPAGE_SEL
		psha
		anda	#MEMPAGE_FMASK
		oraa	#MEMPAGE_HI	; we use upper memory space for pages
		aba
		staa	MEMPAGE_SEL

		ldx	#$A55A
		cpx	romstart
		beq	calc
		ldx	#$5AA5
		cpx	romstart
		beq	calc
		pula
		staa	MEMPAGE_SEL
		cli
		pula
		bra	next

calc		ldx	#romstart	; контролна сума на ROM
		clra
calcloop	adda	0,x
		inx
		cpx	#romstart+$2000
		bne	calcloop
		staa	chksum

		ldx	#copy
		clrb
		ldaa	#8
		int	$2d

		pula
		staa	MEMPAGE_SEL
		cli

		pula

		ldx	#nlspc2
		int	$23
		int	$25
		ldx	#spc2
		int	$23
		cmpa	#8
		bcs	ramtype
		ldx	#rom
		bra	showtype
ramtype		ldx	#ram
showtype	int	$23
		ldx	#spc1
		int	$23
		ldx	#name
		int	$23
		ldx	#spc4
		int	$23
		tst	chksum
		beq	csokay
		ldx	#csbad
		bra	showcs
csokay		ldx	#csok
showcs		int	$23
next		pulb
		incb
		cmpb	#$10
		bne	loop

		ldx	#nl
		int	$23
		rts

title		db	10
		db	'*** RAM/ROM Pages info ***', 10, 10
		db	'PAGE TYPE NAME        CSUM       ', 10, 0
nl		db	10, 0
nlspc2		db	10, '  ', 0
spc4		db	' '
spc3		db	' '
spc2		db	' '
spc1		db	' ', 0
ram		db	'RAM', 0
rom		db	'ROM', 0
csok		db	'GOOD', 0
csbad		db	'FAIL', 0
name		db	'        ', 0
chksum		db	0
copy		dw	romstart+2
		dw	name
