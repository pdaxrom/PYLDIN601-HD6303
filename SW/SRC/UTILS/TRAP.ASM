	include ../../DEVMAP.INC

scrbase 	equ	$ED13
scrsize 	equ	$ED15
scrrows 	equ	$ED17
scrcols 	equ	$ED18

		ldx	#hello
		int	$23

		ldaa	#$fd
		clrb
		ldx	#traphndl
		int	$2f
		rts

traphndl	proc
		ldx	#traperror
loop		ldaa	0,x
		beq	next
		int	$19
		inx
		bra	loop
next
		rts
traperror	db	"Trap interrupt!", 10, 13, 0
		endp

hello		db	10, "Hello TRAP", 10, 0
