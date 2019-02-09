;    *=$1000
    *=$100
;
;
;
start
    psha
    pshb
    pshx
    ldaa	#44
    ldx		#$a55a
    lds		#$1000
    ldd		$04
    ldd		$e628
    bne	~exit
    xgdx
    ldx		#hello
    stx		$80
    sts		$4000
    ldaa	0,x
    ldab	$fa,x
    ldd		220,x
    std		x
    MUL
    nop
    ABA
    ABX
    int		$20
    int		$22
    PULX
    PULB
    PULA
    jsr		$e0
    jsr		$F006
    jmp		$F000
~exit
    RTS

dat
    .byte	$33
hello
    .text	"HELLO, WORLD!"
    .byte	0
