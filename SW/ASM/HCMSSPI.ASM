;
; HJ12864-COG-5
;
; POUT0 - PIN_RS
; POUT1 - PIN_BLN
;

PIN_RS	equ	$01
PIN_BLN	equ	$02

	include ../DEVMAP.INC

	include ../ROM/BOOTMEM.INC

	include ../ROM/BOOTROM.INC

	org $100

	sei

	lds	#$fff

	ldx	#hello
;	int	F_PUTSTR
	jsr	F_UART_PUTS

	jsr	disp_init

	ldx	#font
	jsr	send_data

	jmp	F_RESET

send_byte proc
;	jsr	printhex
busy	ldab	SPI_STATUS
	bitb	#SPI_READY
	beq	busy
	staa	SPI_DATA+1
	rts
	endp

send_cmd proc
;	jsr	printhex
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
;	jsr	printhex
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

printhex proc
	pshx
	psha
	pshb
	jsr	F_UART_PUTHEX
	tba
	jsr	F_UART_PUTHEX
	ldx	#crlf
	jsr	F_UART_PUTS
	pulb
	pula
	pulx
	rts
crlf	db	10, 13, 0
	endp

hello	db	'HCMS test', 10, 13, 0

font	db	 $00, $00, $00, $00, $00	; ' '
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
