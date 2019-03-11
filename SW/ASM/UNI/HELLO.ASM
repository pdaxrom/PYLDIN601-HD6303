	org	$100

	ldx	#hello
	int	$23

	int	$38
;	rts

hello	db	10, "Hello", 10, 0
