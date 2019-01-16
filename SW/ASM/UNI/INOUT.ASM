	org	$100

	ldx	#hello
	int	$23

loop	int	$20
	int	$22
	bra	loop

	int	$01

hello	db	10, 13, "read/write char", 10, 13, 0
