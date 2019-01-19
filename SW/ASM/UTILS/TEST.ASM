	org	$100

	ldx	#hello
	int	$23

	ldaa	#$F0
	staa	$17

	ldaa	#1
	jsr	$DA32

;	int	$38
	rts

hello	db	10, "Hello", 10, 0
