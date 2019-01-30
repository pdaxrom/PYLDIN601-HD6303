;
; HJ12864-COG-5
;
; POUT0 - PIN_RS
; POUT1 - PIN_BLN
;

PIN_RS	equ	$01
PIN_BLN	equ	$02

	include ../../DEVMAP.INC
	include ../UNI/MEMORY.INC

		section 0
dispx		ds	1
dispy		ds	1
dispw		ds	1
disph		ds	1
font		ds	2
framebuf	ds	2
		ends

		org $100

		ldx	#hello
		int	$23

		ldx	#disptbl
		ldaa	#16
		staa	dispw,x
		ldaa	#2
		staa	disph,x
		clr	dispx,x
		clr	dispy,x

		jsr	disp_init

		ldaa	#$0c
		bsr	putchar

		ldx	#$FFCE
		bsr	putstring
		ldaa	#10
		bsr	putchar

readkey		int	$20
		int	$25
		bsr	putchar


		ldx	#disptbl
		ldx	framebuf,x
		jsr	send_data

		bra	readkey

		rts

putstring	proc
loop		ldaa	0,x
		beq	exit
		pshx
		bsr	putchar
		pulx
		inx
		bra	loop
exit		rts
		endp

putchar		proc
		sei
		ldx	#disptbl
		cmpa	#$0D
		bne	chkclr
		clr	dispx,x
		bra	exit
chkclr		cmpa	#$0C
		bne	checklf
		clr	dispx,x
		clr	dispy,x
		bra	clrscr
checklf		cmpa	#$0A
		beq	linefeed
		psha
		clrb
		ldaa	dispy,x
calcy		tsta
		beq	calcx
		addb	dispw,x
		deca
		bra	calcy
calcx		ldaa	#5
		mul
		addb	dispx,x
		addb	dispx,x
		addb	dispx,x
		addb	dispx,x
		addb	dispx,x
		addd	framebuf,x
		std	tmpx
		pula
		ldab	#5
		mul
		addd	font,x
		xgdx
		sts	tmps
		txs
		ldx	tmpx
		pula
		staa	0,x
		pula
		staa	1,x
		pula
		staa	2,x
		pula
		staa	3,x
		pula
		staa	4,x
		lds	tmps

		ldx	#disptbl
		ldaa	dispx,x
		inca
		cmpa	dispw,x
		bhs	exit
		staa	dispx,x
exit		cli
		rts
linefeed	clr	dispx,x
		ldaa	dispy,x
		inca
		cmpa	disph,x
		bhs	scroll
		staa	dispy,x
		bra	exit
scroll		ldaa	dispw,x
		ldab	#5
		mul
		pshb
		ldx	framebuf,x
scrol1		ldaa	80,x
		staa	0,x
		inx
		decb
		bne	scrol1
		pulb
		clra
scrol2		staa	0,x
		inx
		decb
		bne	scrol2
		bra	exit
clrscr		ldx	#disptbl
		ldaa	dispw,x
		ldab	disph,x
		mul
		ldaa	#5
		mul
		ldx	framebuf,x
		clra
clrscr1		staa	0,x
		inx
		decb
		bne	clrscr1
		bra	exit
		endp

send_byte proc
busy	ldab	SPI_STATUS
	bitb	#SPI_READY
	beq	busy
	staa	SPI_DATA+1
	rts
	endp

send_cmd proc
	pshb

	ldab	SPI_POUT
	orab	#PIN_RS
	stab	SPI_POUT

	ldab	SPI_CONFIG
	andb	#$FF^SPI_SS0
	stab	SPI_CONFIG

	ldab	#8
loop	pshb
	bsr	send_byte
	pulb
	decb
	bne	loop

busy	ldab	SPI_STATUS
	bitb	#SPI_READY
	beq	busy

	ldab	SPI_CONFIG
	orab	#SPI_SS0
	stab	SPI_CONFIG

	pulb
	rts
	endp

send_data proc
	psha
	pshb
	pshx

	ldab	SPI_POUT
	andb	#$FF^PIN_RS
	stab	SPI_POUT

	ldab	SPI_CONFIG
	andb	#$FF^SPI_SS0
	stab	SPI_CONFIG

	pshx
	ldab	#40
loop1	pshb
	ldaa	120,x
	bsr	send_byte
	inx
	pulb
	decb
	bne	loop1
	pulx

	pshx
	ldab	#40
loop2	pshb
	ldaa	80,x
	bsr	send_byte
	inx
	pulb
	decb
	bne	loop2
	pulx

	pshx
	ldab	#40
loop3	pshb
	ldaa	40,x
	bsr	send_byte
	inx
	pulb
	decb
	bne	loop3
	pulx

	pshx
	ldab	#40
loop4	pshb
	ldaa	0,x
	jsr	send_byte
	inx
	pulb
	decb
	bne	loop4
	pulx

busy	ldab	SPI_STATUS
	bitb	#SPI_READY
	beq	busy

	ldab	SPI_CONFIG
	orab	#SPI_SS0
	stab	SPI_CONFIG

	pulx
	pulb
	pula
	rts
	endp

delay	proc
	pshb
	psha
loop	ldab	#110
loop1	decb
	bne	loop1
	deca
	bne	loop
	pula
	pulb
	rts
	endp

disp_init proc
	ldaa	SPI_POUT
	anda	#$FF^PIN_BLN
	staa	SPI_POUT

	ldaa	#2
	staa	SPI_PRESCALER
	ldaa	SPI_CONFIG
	oraa	#(SPI_SSM | SPI_SS0)
	staa	SPI_CONFIG

	ldaa	#$68	; 01001100
	jsr	send_cmd

	rts
	endp

hello	db	'HCMS test', 10, 0

disptbl	db	0, 0	; W, W
	db	0, 0	; X, Y
	dw	font5x7
	dw	grfbuff

grfbuff	ds	32*5	; framebuffer

font5x7
	db	 $FF, $FF, $FF, $FF, $FF	; 00
	db	 $FF, $FF, $FF, $FF, $FF	; 01
	db	 $FF, $FF, $FF, $FF, $FF	; 02
	db	 $FF, $FF, $FF, $FF, $FF	; 03
	db	 $FF, $FF, $FF, $FF, $FF	; 04
	db	 $FF, $FF, $FF, $FF, $FF	; 05
	db	 $FF, $FF, $FF, $FF, $FF	; 06
	db	 $FF, $FF, $FF, $FF, $FF	; 07
	db	 $FF, $FF, $FF, $FF, $FF	; 08
	db	 $FF, $FF, $FF, $FF, $FF	; 09
	db	 $FF, $FF, $FF, $FF, $FF	; 0A
	db	 $FF, $FF, $FF, $FF, $FF	; 0B
	db	 $FF, $FF, $FF, $FF, $FF	; 0C
	db	 $FF, $FF, $FF, $FF, $FF	; 0D
	db	 $FF, $FF, $FF, $FF, $FF	; 0E
	db	 $FF, $FF, $FF, $FF, $FF	; 0F
	db	 $FF, $FF, $FF, $FF, $FF	; 10
	db	 $FF, $FF, $FF, $FF, $FF	; 11
	db	 $FF, $FF, $FF, $FF, $FF	; 12
	db	 $FF, $FF, $FF, $FF, $FF	; 13
	db	 $FF, $FF, $FF, $FF, $FF	; 14
	db	 $FF, $FF, $FF, $FF, $FF	; 15
	db	 $FF, $FF, $FF, $FF, $FF	; 16
	db	 $FF, $FF, $FF, $FF, $FF	; 17
	db	 $FF, $FF, $FF, $FF, $FF	; 18
	db	 $FF, $FF, $FF, $FF, $FF	; 19
	db	 $FF, $FF, $FF, $FF, $FF	; 1A
	db	 $FF, $FF, $FF, $FF, $FF	; 1B
	db	 $FF, $FF, $FF, $FF, $FF	; 1C
	db	 $FF, $FF, $FF, $FF, $FF	; 1D
	db	 $FF, $FF, $FF, $FF, $FF	; 1E
	db	 $FF, $FF, $FF, $FF, $FF	; 1F

	db	 $00, $00, $00, $00, $00	; ' '
	db	 $00, $00, $5F, $00, $00	; '!'
	db	 $00, $07, $00, $07, $00	; '"'
	db	 $14, $7F, $14, $7F, $14	; '#'
	db	 $24, $2A, $7F, $2A, $12	; '$'
	db	 $23, $13, $08, $64, $62	; '%'
	db	 $36, $49, $55, $22, $50	; '&'
	db	 $00, $05, $03, $00, $00	; '''
	db	 $00, $1C, $22, $41, $00	; '('
	db	 $00, $41, $22, $1C, $00	; ')'
	db	 $08, $2A, $1C, $2A, $08	; '*'
	db	 $08, $08, $3E, $08, $08	; '+'
	db	 $00, $50, $30, $00, $00	; ','
	db	 $08, $08, $08, $08, $08	; '-'
	db	 $00, $60, $60, $00, $00	; '.'
	db	 $20, $10, $08, $04, $02	; '/'
	db	 $3E, $51, $49, $45, $3E	; '0'
	db	 $00, $42, $7F, $40, $00	; '1'
	db	 $42, $61, $51, $49, $46	; '2'
	db	 $21, $41, $45, $4B, $31	; '3'
	db	 $18, $14, $12, $7F, $10	; '4'
	db	 $27, $45, $45, $45, $39	; '5'
	db	 $3C, $4A, $49, $49, $30	; '6'
	db	 $01, $71, $09, $05, $03	; '7'
	db	 $36, $49, $49, $49, $36	; '8'
	db	 $06, $49, $49, $29, $1E	; '9'
	db	 $00, $36, $36, $00, $00	; ':'
	db	 $00, $56, $36, $00, $00	; ';'
	db	 $00, $08, $14, $22, $41	; '<'
	db	 $14, $14, $14, $14, $14	; '='
	db	 $41, $22, $14, $08, $00	; '>'
	db	 $02, $01, $51, $09, $06	; '?'
	db	 $32, $49, $79, $41, $3E	; '@'
	db	 $7E, $11, $11, $11, $7E	; 'A'
	db	 $7F, $49, $49, $49, $36	; 'B'
	db	 $3E, $41, $41, $41, $22	; 'C'
	db	 $7F, $41, $41, $22, $1C	; 'D'
	db	 $7F, $49, $49, $49, $41	; 'E'
	db	 $7F, $09, $09, $01, $01	; 'F'
	db	 $3E, $41, $41, $51, $32	; 'G'
	db	 $7F, $08, $08, $08, $7F	; 'H'
	db	 $00, $41, $7F, $41, $00	; 'I'
	db	 $20, $40, $41, $3F, $01	; 'J'
	db	 $7F, $08, $14, $22, $41	; 'K'
	db	 $7F, $40, $40, $40, $40	; 'L'
	db	 $7F, $02, $04, $02, $7F	; 'M'
	db	 $7F, $04, $08, $10, $7F	; 'N'
	db	 $3E, $41, $41, $41, $3E	; 'O'
	db	 $7F, $09, $09, $09, $06	; 'P'
	db	 $3E, $41, $51, $21, $5E	; 'Q'
	db	 $7F, $09, $19, $29, $46	; 'R'
	db	 $46, $49, $49, $49, $31	; 'S'
	db	 $01, $01, $7F, $01, $01	; 'T'
	db	 $3F, $40, $40, $40, $3F	; 'U'
	db	 $1F, $20, $40, $20, $1F	; 'V'
	db	 $7F, $20, $18, $20, $7F	; 'W'
	db	 $63, $14, $08, $14, $63	; 'X'
	db	 $03, $04, $78, $04, $03	; 'Y'
	db	 $61, $51, $49, $45, $43	; 'Z'
	db	 $00, $00, $7F, $41, $41	; '['
	db	 $02, $04, $08, $10, $20	; '\'
	db	 $41, $41, $7F, $00, $00	; ']'
	db	 $04, $02, $01, $02, $04	; '^'
	db	 $40, $40, $40, $40, $40	; '_'
	db	 $00, $01, $02, $04, $00	; '`'
	db	 $20, $54, $54, $54, $78	; 'a'
	db	 $7F, $48, $44, $44, $38	; 'b'
	db	 $38, $44, $44, $44, $20	; 'c'
	db	 $38, $44, $44, $48, $7F	; 'd'
	db	 $38, $54, $54, $54, $18	; 'e'
	db	 $08, $7E, $09, $01, $02	; 'f'
	db	 $08, $14, $54, $54, $3C	; 'g'
	db	 $7F, $08, $04, $04, $78	; 'h'
	db	 $00, $44, $7D, $40, $00	; 'i'
	db	 $20, $40, $44, $3D, $00	; 'j'
	db	 $00, $7F, $10, $28, $44	; 'k'
	db	 $00, $41, $7F, $40, $00	; 'l'
	db	 $7C, $04, $18, $04, $78	; 'm'
	db	 $7C, $08, $04, $04, $78	; 'n'
	db	 $38, $44, $44, $44, $38	; 'o'
	db	 $7C, $14, $14, $14, $08	; 'p'
	db	 $08, $14, $14, $18, $7C	; 'q'
	db	 $7C, $08, $04, $04, $08	; 'r'
	db	 $48, $54, $54, $54, $20	; 's'
	db	 $04, $3F, $44, $40, $20	; 't'
	db	 $3C, $40, $40, $20, $7C	; 'u'
	db	 $1C, $20, $40, $20, $1C	; 'v'
	db	 $3C, $40, $30, $40, $3C	; 'w'
	db	 $44, $28, $10, $28, $44	; 'x'
	db	 $0C, $50, $50, $50, $3C	; 'y'
	db	 $44, $64, $54, $4C, $44	; 'z'
	db	 $00, $08, $36, $41, $00	; '{'
	db	 $00, $00, $7F, $00, $00	; '|'
	db	 $00, $41, $36, $08, $00	; '}'
	db	 $08, $08, $2A, $1C, $08	; '~'
	db	 $08, $1C, $2A, $08, $08	; ' '
	db	 $7C, $12, $11, $12, $7C	; 80
	db	 $7F, $49, $49, $49, $31	; 81
	db	 $7F, $49, $49, $49, $36	; 82
	db	 $7F, $01, $01, $01, $01	; 83
	db	 $60, $3F, $21, $3F, $60	; 84
	db	 $7F, $49, $49, $49, $41	; 85
	db	 $77, $08, $7F, $08, $77	; 86
	db	 $22, $41, $49, $49, $36	; 87
	db	 $7F, $10, $08, $04, $7F	; 88
	db	 $7E, $10, $09, $04, $7E	; 89
	db	 $7F, $08, $14, $22, $41	; 8A
	db	 $40, $3E, $01, $01, $7F	; 8B
	db	 $7F, $02, $0C, $02, $7F	; 8C
	db	 $7F, $08, $08, $08, $7F	; 8D
	db	 $3E, $41, $41, $41, $3E	; 8E
	db	 $7F, $01, $01, $01, $7F	; 8F
	db	 $7F, $09, $09, $09, $06	; 90
	db	 $3E, $41, $41, $41, $22	; 91
	db	 $01, $01, $7F, $01, $01	; 92
	db	 $07, $48, $48, $48, $3F	; 93
	db	 $0E, $11, $7F, $11, $0E	; 94
	db	 $63, $14, $08, $14, $63	; 95
	db	 $3F, $20, $20, $3F, $60	; 96
	db	 $07, $08, $08, $08, $7F	; 97
	db	 $7F, $40, $7E, $40, $7F	; 98
	db	 $3F, $20, $3F, $20, $7F	; 99
	db	 $01, $7F, $48, $48, $30	; 9A
	db	 $7F, $48, $30, $00, $7F	; 9B
	db	 $00, $7F, $48, $48, $30	; 9C
	db	 $22, $41, $49, $49, $3E	; 9D
	db	 $7F, $08, $3E, $41, $3E	; 9E
	db	 $46, $29, $19, $09, $7F	; 9F
	db	 $20, $54, $54, $54, $78	; A0
	db	 $3C, $4A, $4A, $4A, $31	; A1
	db	 $7C, $54, $54, $28, $00	; A2
	db	 $7C, $04, $04, $0C, $00	; A3
	db	 $60, $3C, $24, $3C, $60	; A4
	db	 $38, $54, $54, $54, $18	; A5
	db	 $6C, $10, $7C, $10, $6C	; A6
	db	 $00, $44, $54, $54, $28	; A7
	db	 $7C, $20, $10, $08, $7C	; A8
	db	 $7C, $21, $12, $09, $7C	; A9
	db	 $7C, $10, $28, $44, $00	; AA
	db	 $40, $38, $04, $04, $7C	; AB
	db	 $7C, $08, $10, $08, $7C	; AC
	db	 $7C, $10, $10, $10, $7C	; AD
	db	 $38, $44, $44, $44, $38	; AE
	db	 $7C, $04, $04, $04, $7C	; AF
	db	 $7C, $14, $14, $14, $08	; B0
	db	 $38, $44, $44, $44, $00	; B1
	db	 $04, $04, $7C, $04, $04	; B2
	db	 $0C, $50, $50, $50, $3C	; B3
	db	 $08, $14, $7C, $14, $08	; B4
	db	 $44, $28, $10, $28, $44	; B5
	db	 $3C, $20, $20, $3C, $60	; B6
	db	 $0C, $10, $10, $10, $7C	; B7
	db	 $7C, $40, $7C, $40, $7C	; B8
	db	 $3C, $20, $3C, $20, $7C	; B9
	db	 $04, $7C, $50, $50, $20	; BA
	db	 $7C, $50, $20, $00, $7C	; BB
	db	 $00, $7C, $50, $50, $20	; BC
	db	 $28, $44, $54, $54, $38	; BD
	db	 $7C, $10, $38, $44, $38	; BE
	db	 $48, $54, $34, $14, $7C	; BF

	db	 $FF, $FF, $FF, $FF, $FF	; C0
	db	 $FF, $FF, $FF, $FF, $FF	; C1
	db	 $FF, $FF, $FF, $FF, $FF	; C2
	db	 $FF, $FF, $FF, $FF, $FF	; C3
	db	 $FF, $FF, $FF, $FF, $FF	; C4
	db	 $FF, $FF, $FF, $FF, $FF	; C5
	db	 $FF, $FF, $FF, $FF, $FF	; C6
	db	 $FF, $FF, $FF, $FF, $FF	; C7
	db	 $FF, $FF, $FF, $FF, $FF	; C8
	db	 $FF, $FF, $FF, $FF, $FF	; C9
	db	 $FF, $FF, $FF, $FF, $FF	; CA
	db	 $FF, $FF, $FF, $FF, $FF	; CB
	db	 $FF, $FF, $FF, $FF, $FF	; CC
	db	 $FF, $FF, $FF, $FF, $FF	; CD
	db	 $FF, $FF, $FF, $FF, $FF	; CE
	db	 $FF, $FF, $FF, $FF, $FF	; CF
	db	 $FF, $FF, $FF, $FF, $FF	; D0
	db	 $FF, $FF, $FF, $FF, $FF	; D1
	db	 $FF, $FF, $FF, $FF, $FF	; D2
	db	 $FF, $FF, $FF, $FF, $FF	; D3
	db	 $FF, $FF, $FF, $FF, $FF	; D4
	db	 $FF, $FF, $FF, $FF, $FF	; D5
	db	 $FF, $FF, $FF, $FF, $FF	; D6
	db	 $FF, $FF, $FF, $FF, $FF	; D7
	db	 $FF, $FF, $FF, $FF, $FF	; D8
	db	 $FF, $FF, $FF, $FF, $FF	; D9
	db	 $FF, $FF, $FF, $FF, $FF	; DA
	db	 $FF, $FF, $FF, $FF, $FF	; DB
	db	 $FF, $FF, $FF, $FF, $FF	; DC
	db	 $FF, $FF, $FF, $FF, $FF	; DD
	db	 $FF, $FF, $FF, $FF, $FF	; DE
	db	 $FF, $FF, $FF, $FF, $FF	; DF
	db	 $FF, $FF, $FF, $FF, $FF	; E0
	db	 $FF, $FF, $FF, $FF, $FF	; E1
	db	 $FF, $FF, $FF, $FF, $FF	; E2
	db	 $FF, $FF, $FF, $FF, $FF	; E3
	db	 $FF, $FF, $FF, $FF, $FF	; E4
	db	 $FF, $FF, $FF, $FF, $FF	; E5
	db	 $FF, $FF, $FF, $FF, $FF	; E6
	db	 $FF, $FF, $FF, $FF, $FF	; E7
	db	 $FF, $FF, $FF, $FF, $FF	; E8
	db	 $FF, $FF, $FF, $FF, $FF	; E9
	db	 $FF, $FF, $FF, $FF, $FF	; EA
	db	 $FF, $FF, $FF, $FF, $FF	; EB
	db	 $FF, $FF, $FF, $FF, $FF	; EC
	db	 $FF, $FF, $FF, $FF, $FF	; ED
	db	 $FF, $FF, $FF, $FF, $FF	; EE
	db	 $FF, $FF, $FF, $FF, $FF	; EF
	db	 $FF, $FF, $FF, $FF, $FF	; F0
	db	 $FF, $FF, $FF, $FF, $FF	; F1
	db	 $FF, $FF, $FF, $FF, $FF	; F2
	db	 $FF, $FF, $FF, $FF, $FF	; F3
	db	 $FF, $FF, $FF, $FF, $FF	; F4
	db	 $FF, $FF, $FF, $FF, $FF	; F5
	db	 $FF, $FF, $FF, $FF, $FF	; F6
	db	 $FF, $FF, $FF, $FF, $FF	; F7
	db	 $FF, $FF, $FF, $FF, $FF	; F8
	db	 $FF, $FF, $FF, $FF, $FF	; F9
	db	 $FF, $FF, $FF, $FF, $FF	; FA
	db	 $FF, $FF, $FF, $FF, $FF	; FB
	db	 $FF, $FF, $FF, $FF, $FF	; FC
	db	 $FF, $FF, $FF, $FF, $FF	; FD
	db	 $FF, $FF, $FF, $FF, $FF	; FE
	db	 $FF, $FF, $FF, $FF, $FF	; FF
