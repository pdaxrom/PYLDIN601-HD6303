	org	$100

	ldx	#hello
	int	$23

	int	$01

hello	db	10, 13, "Hello", 10, 13, 0
