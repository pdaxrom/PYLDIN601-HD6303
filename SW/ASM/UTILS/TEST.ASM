	include ../../DEVMAP.INC

scrbase 	equ	$ED13
scrsize 	equ	$ED15
scrrows 	equ	$ED17
scrcols 	equ	$ED18

	org	$100

	ldx	#hello
	int	$23

	rts

hello	db	10, "Hello", 10, 0
