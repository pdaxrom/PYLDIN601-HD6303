;
; Check GPIO
;
; GPIO 0 - LED
; GPIO 1 - LED
; GPIO 2 - BUTTON to GND
; GPIO 3 - BUTTON to GND
;

	include ../DEVMAP.INC
	include ../ROM/BOOTMEM.INC
	include ../ROM/BOOTROM.INC
	include UNI/MEMORY.INC

KEY_E0		EQU	$10
KEY_F0		EQU	$80
SCANBITS	EQU	old_key

;SH_SCROLL	EQU	$80
;SH_CAPS		EQU	$40
;SH_CYR		EQU	$20
;SH_NUM		EQU	$10
SH_RALT		EQU	$80
SH_ALT		EQU	$40
SH_RCTRL	EQU	$20
SH_CTRL		EQU	$10
SH_CYR		EQU	$04
SH_RSHIFT	EQU	$02
SH_SHIFT	EQU	$01

LK_SCROLL	EQU	$80
LK_CAPS		EQU	$40
LK_CYR		EQU	$20
LK_NUM		EQU	$10

	org $100

	sei

	ldx	#hello
	jsr	F_PUTSTR

; HD6303Y Enable IRQ1 input
	ldaa	REG_RP5CR
	oraa	#BIT_IRQ1E
	staa	REG_RP5CR

	ldaa	#$FF
	jsr	ps2write
	jsr	ps2read
	jsr	ps2read
	cmpa	#$AA
	beq	next
	jmp	F_RESET

next	ldx	#okay
	jsr	F_PUTSTR

	ldaa	PS2_CONFIG
	oraa	#PS2_BIT_IEN
	staa	PS2_CONFIG

	ldx	#irqhandler
	stx	VIRQ

	ldaa	#$FF
	staa	scancode
	clr	shiftstatus
	clr	lockstatus
	clr	scanbits

	ldx	#text1
	jsr	F_UART_PUTS

	cli

loop		cli
		nop
		nop
		sei
		ldab	scancode
		cmpb	#$FF
		beq	loop
		ldaa	#$FF
		staa	scancode

		pshb
		clrb
		ldaa	shiftstatus
		bita	#SH_CTRL|SH_RCTRL
		beq	checkshift
		ldx	#kb_ctrl
		bra	decode
checkshift	bita	#SH_SHIFT|SH_RSHIFT
		beq	checkalt
		orab	#1
checkalt	bita	#SH_ALT|SH_RALT
		beq	checkcaps
		orab	#4
checkcaps	ldaa	lockstatus
		bita	#LK_CAPS
		beq	checkcyr
		orab	#2
checkcyr	bita	#LK_CYR
		beq	gettab
		orab	#4
gettab		ldx	#tablist
		abx
		abx
		ldx	0,x

decode		pulb
		cli
		abx
		ldaa	0,x

	jsr	F_PUTCHAR
	jsr	F_PUTHEX
	ldaa	shiftstatus
	jsr	F_PUTHEX
	ldaa	lockstatus
	jsr	F_PUTHEX
	ldaa	scanbits
	jsr	F_PUTHEX

	ldx	#nl
	jsr	F_PUTSTR

	bra	loop

irqhandler	proc
		sei
		ldaa	PS2_CONFIG
		bita	#PS2_BIT_IEN
		bne	check_key
		jmp	exit
check_key	bita	#PS2_BIT_RDY
		bne	read_scan
		jmp	exit

read_scan	ldaa	PS2_DATA

		cmpa	#$E0
		bne	check_f0
		ldaa	scanbits
		oraa	#key_e0
		staa	scanbits
		jmp	exit
check_f0	cmpa	#$F0
		bne	check_shift
		ldaa	scanbits
		oraa	#key_f0
		staa	scanbits
		jmp	exit
check_shift	cmpa	#$12
		beq	shift
		cmpa	#$59
		beq	rshift
		cmpa	#$14
		beq	ctrl
		cmpa	#$11
		beq	alt

		ldab	scanbits
		bitb	#key_f0
		beq	savescan
		ldab	#$FF
		stab	scancode
		bra	chklock
savescan	staa	scancode

chklock		cmpa	#$58
		beq	capslock
		cmpa	#$7E
		beq	scrollock
		cmpa	#$77
		beq	numlock
		cmpa	#$1F
		beq	cyrlock
		bra	return

shift		ldaa	#SH_SHIFT
		bra	chkshift
rshift		ldaa	#SH_RSHIFT
chkshift	ldab	scanbits
		andb	#KEY_F0|KEY_E0
		cmpb	#KEY_F0|KEY_E0
		bne	chkshift1
		bra	return
chkshift1	cmpb	#KEY_E0
		bne	sereset
		bra	return
ctrl		ldaa	#SH_CTRL
		bra	sereset
alt		ldaa	#SH_ALT
sereset		ldab	scanbits
		bitb	#KEY_E0
		beq	sereset2
		lsla
sereset2	bitb	#KEY_F0
		bne	clrshbit
		oraa	shiftstatus
		staa	shiftstatus
		bra	return
clrshbit	coma
		anda	shiftstatus
		staa	shiftstatus
		bra	return

capslock	ldaa	#LK_CAPS
		bra	setlock
scrollock	ldaa	#LK_SCROLL
		bra	setlock
numlock		ldaa	#LK_NUM
		bra	setlock
cyrlock		ldaa	#LK_CYR

setlock		ldab	#KEY_F0
		bitb	scanbits
		bne	return
		
		eora	lockstatus
		staa	lockstatus
		bsr	setleds

return		ldaa	scanbits
		anda	#$FF^(KEY_F0|KEY_E0)
		staa	scanbits
exit		rti
		endp

setleds		proc
		ldaa	PS2_CONFIG
		anda	#$FF^PS2_BIT_IEN
		staa	PS2_CONFIG
		clrb
		ldaa	lockstatus
		bita	#LK_SCROLL
		beq	chknum
		orab	#$01
chknum		bita	#LK_NUM
		beq	chkcaps
		orab	#$02
chkcaps		bita	#LK_CAPS
		beq	chkcyr
		orab	#$04
chkcyr		bita	#LK_CYR
		beq	write
		orab	#$01
write		ldaa	#$ED
		bsr	ps2write
		bsr	ps2read
		tba
		bsr	ps2write
		bsr	ps2read
		ldaa	PS2_CONFIG
		oraa	#PS2_BIT_IEN
		staa	PS2_CONFIG
		rts
		endp

ps2read		proc
		ldaa	PS2_CONFIG
		bita	#PS2_BIT_RDY
		beq	ps2read
		ldaa	PS2_DATA
		rts
		endp

ps2write	proc
		staa	PS2_DATA
loop0		ldaa	PS2_CONFIG
		bita	#PS2_BIT_BSY
		bne	loop0
		rts
		endp

tablist		dw	kb, kb_shift, kbcaps, kbcaps_shift
		dw	kbcyr, kbcyr_shift, kbcyrcaps, kbcyrcaps_shift

;		 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
kb
	db	  0, $D1,   0, $CD, $CB, $C9, $CA, $D4,   0, $D2, $D0, $CE, $CC, $ED, '`',   0	; 00
	db	  0,   0,   0,   0,   0, 'q', '1',   0,   0,   0, 'z', 's', 'a', 'w', '2', $FB	; 10
	db	  0, 'c', 'x', 'd', 'e', '4', '3',   0,   0, ' ', 'v', 'f', 't', 'r', '5',   0	; 20
	db	  0, 'n', 'b', 'h', 'g', 'y', '6',   0,   0,   0, 'm', 'j', 'u', '7', '8',   0	; 30
	db	  0, ',', 'k', 'i', 'o', '0', '9',   0,   0, '.', '/', 'l', ';', 'p', '-',   0	; 40
	db	  0,   0, "'",   0, '[', '=',   0,   0, $FC,   0, $C0, ']',   0, '\',   0,   0	; 50
	db	  0,   0,   0,   0,   0,   0, $7F,   0,   0, $C6,   0, $C1, $C5,   0,   0,   0	; 60
	db	$FA, $F9, $C3,   0, $C2, $C4, $1B,   0, $D3,   0, $C7,   0,   0, $C8,   0,   0	; 70
	db	  0,   0,   0, $CF,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80

;		 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
kb_shift
	db	  0, $DD,   0, $D9, $D7, $D5, $D6, $E0,   0, $DE, $DC, $DA, $D8, $EE, '~',   0	; 00
	db	  0,   0,   0,   0,   0, 'Q', '!',   0,   0,   0, 'Z', 'S', 'A', 'W', '@', $FB	; 10
	db	  0, 'C', 'X', 'D', 'E', '$', '#',   0,   0, ' ', 'V', 'F', 'T', 'R', '%',   0	; 20
	db	  0, 'N', 'B', 'H', 'G', 'Y', '^',   0,   0,   0, 'M', 'J', 'U', '&', '*',   0	; 30
	db	  0, '<', 'K', 'I', 'O', ')', '(',   0,   0, '>', '?', 'L', ':', 'P', '_',   0	; 40
	db	  0,   0, '"',   0, '{', '+',   0,   0, $FC,   0, $C0, '}',   0, '|',   0,   0	; 50
	db	  0,   0,   0,   0,   0,   0, $7F,   0,   0, $C6,   0, $C5, $C5,   0,   0,   0	; 60
	db	$FA, $F9, $C7,   0, $C6, $C8, $1B,   0, $DF,   0, $C7,   0,   0, $C8,   0,   0	; 70
	db	  0,   0,   0, $DB,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80

;		 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
kbcaps
	db	  0, $D1,   0, $CD, $CB, $C9, $CA, $D4,   0, $D2, $D0, $CE, $CC, $ED, '`',   0	; 00
	db	  0,   0,   0,   0,   0, 'Q', '1',   0,   0,   0, 'Z', 'S', 'A', 'W', '2', $FB	; 10
	db	  0, 'C', 'X', 'D', 'E', '4', '3',   0,   0, ' ', 'V', 'F', 'T', 'R', '5',   0	; 20
	db	  0, 'N', 'B', 'H', 'G', 'Y', '6',   0,   0,   0, 'M', 'J', 'U', '7', '8',   0	; 30
	db	  0, ',', 'K', 'I', 'O', '0', '9',   0,   0, '.', '/', 'L', ';', 'P', '-',   0	; 40
	db	  0,   0, "'",   0, '[', '=',   0,   0, $FC,   0, $C0, ']',   0, '\',   0,   0	; 50
	db	  0,   0,   0,   0,   0,   0, $7F,   0,   0, $C6,   0, $C1, $C5,   0,   0,   0	; 60
	db	$FA, $F9, $C3,   0, $C2, $C4, $1B,   0, $D3,   0, $C7,   0,   0, $C8,   0,   0	; 70
	db	  0,   0,   0, $CF,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80

;		 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
kbcaps_shift
	db	  0, $DD,   0, $D9, $D7, $D5, $D6, $E0,   0, $DE, $DC, $DA, $D8, $EE, '~',   0	; 00
	db	  0,   0,   0,   0,   0, 'q', '!',   0,   0,   0, 'z', 's', 'a', 'w', '@', $FB	; 10
	db	  0, 'c', 'x', 'd', 'e', '$', '#',   0,   0, ' ', 'v', 'f', 't', 'r', '%',   0	; 20
	db	  0, 'n', 'b', 'h', 'g', 'y', '^',   0,   0,   0, 'm', 'j', 'u', '&', '*',   0	; 30
	db	  0, '<', 'k', 'i', 'o', ')', '(',   0,   0, '>', '?', 'l', ':', 'p', '_',   0	; 40
	db	  0,   0, '"',   0, '{', '+',   0,   0, $FC,   0, $C0, '}',   0, '|',   0,   0	; 50
	db	  0,   0,   0,   0,   0,   0, $7F,   0,   0, $C6,   0, $C5, $C5,   0,   0,   0	; 60
	db	$FA, $F9, $C7,   0, $C6, $C8, $1B,   0, $DF,   0, $C7,   0,   0, $C8,   0,   0	; 70
	db	  0,   0,   0, $DB,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80

;		 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
kb_ctrl
	db	  0, $E9,   0, $E5, $E3, $E1, $E2, $EC,   0, $EA, $E8, $E6, $E4, $ED, '`',   0	; 00
	db	  0,   0,   0,   0,   0, $11, '1',   0,   0,   0, $1A, $13, $01, $17, '2', $FB	; 10
	db	  0, $03, $18, $04, $05, '4', '3',   0,   0, $FE, $16, $06, $14, $12, '5',   0	; 20
	db	  0, $0E, $02, $08, $07, $19, '6',   0,   0,   0, $0D, $0A, $15, '7', '8',   0	; 30
	db	  0, ',', $0B, $09, $0F, '0', '9',   0,   0, '.', '/', $0C, ';', $10, '-',   0	; 40
	db	  0,   0, "'",   0, '[', '=',   0,   0, $FC,   0, $F0, ']',   0, '\',   0,   0	; 50
	db	  0,   0,   0,   0,   0,   0, $EF,   0,   0, $F6,   0, $F1, $F5,   0,   0,   0	; 60
	db	$FA, $F9, $F3,   0, $F2, $F4, $1B,   0, $EB,   0, $F7,   0,   0, $F8,   0,   0	; 70
	db	  0,   0,   0, $E7,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80

;		 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
kbcyr
	db	  0, $D1,   0, $CD, $CB, $C9, $CA, $D4,   0, $D2, $D0, $CE, $CC, $ED, $F1,   0	; 00
	db	  0,   0,   0,   0,   0, '©', '1',   0,   0,   0, 'ø', 'ª', '¥', '∂', '2', $FB	; 10
	db	  0, '±', '∑', '¢', '≥', '4', '3',   0,   0, ' ', '¨', '†', '•', '™', '5',   0	; 20
	db	  0, '≤', '®', '∞', 'Ø', '≠', '6',   0,   0,   0, 'º', 'Æ', '£', '7', '8',   0	; 30
	db	  0, '°', '´', '∏', 'π', '0', '9',   0,   0, 'æ', '.', '§', '¶', 'ß', '-',   0	; 40
	db	  0,   0, 'Ω',   0, 'µ', '=',   0,   0, $FC,   0, $C0, '∫',   0, '\',   0,   0	; 50
	db	  0,   0,   0,   0,   0,   0, $7F,   0,   0, $C6,   0, $C1, $C5,   0,   0,   0	; 60
	db	$FA, $F9, $C3,   0, $C2, $C4, $1B,   0, $D3,   0, $C7,   0,   0, $C8,   0,   0	; 70
	db	  0,   0,   0, $CF,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80

;		 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
kbcyr_shift
	db	  0, $DD,   0, $D9, $D7, $D5, $D6, $E0,   0, $DE, $DC, $DA, $D8, $EE, $F0,   0	; 00
	db	  0,   0,   0,   0,   0, 'â', '!',   0,   0,   0, 'ü', 'õ', 'î', 'ñ', '"', $FB	; 10
	db	  0, 'ë', 'ó', 'Ç', 'ì', ';', '’',   0,   0, ' ', 'å', 'Ä', 'Ö', 'ä', '%',   0	; 20
	db	  0, 'í', 'à', 'ê', 'è', 'ç', ':',   0,   0,   0, 'ú', 'é', 'É', '&', '*',   0	; 30
	db	  0, 'Å', 'ã', 'ò', 'ô', ')', '(',   0,   0, 'û', ',', 'Ñ', 'Ü', 'á', '_',   0	; 40
	db	  0,   0, 'ù',   0, 'ï', '+',   0,   0, $FC,   0, $C0, 'ö',   0, '/',   0,   0	; 50
	db	  0,   0,   0,   0,   0,   0, $7F,   0,   0, $C6,   0, $C5, $C5,   0,   0,   0	; 60
	db	$FA, $F9, $C7,   0, $C6, $C8, $1B,   0, $DF,   0, $C7,   0,   0, $C8,   0,   0	; 70
	db	  0,   0,   0, $DB,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80

;		 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
kbcyrcaps
	db	  0, $D1,   0, $CD, $CB, $C9, $CA, $D4,   0, $D2, $D0, $CE, $CC, $ED, $F1,   0	; 00
	db	  0,   0,   0,   0,   0, 'â', '1',   0,   0,   0, 'ü', 'õ', 'î', 'ñ', '2', $FB	; 10
	db	  0, 'ë', 'ó', 'Ç', 'ì', '4', '3',   0,   0, ' ', 'å', 'Ä', 'Ö', 'ä', '5',   0	; 20
	db	  0, 'í', 'à', 'ê', 'è', 'ç', '6',   0,   0,   0, 'ú', 'é', 'É', '7', '8',   0	; 30
	db	  0, 'Å', 'ã', 'ò', 'ô', '0', '9',   0,   0, 'û', '.', 'Ñ', 'Ü', 'á', '-',   0	; 40
	db	  0,   0, 'ù',   0, 'ï', '=',   0,   0, $FC,   0, $C0, 'ö',   0, '\',   0,   0	; 50
	db	  0,   0,   0,   0,   0,   0, $7F,   0,   0, $C6,   0, $C1, $C5,   0,   0,   0	; 60
	db	$FA, $F9, $C3,   0, $C2, $C4, $1B,   0, $D3,   0, $C7,   0,   0, $C8,   0,   0	; 70
	db	  0,   0,   0, $CF,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80

;		 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
kbcyrcaps_shift
	db	  0, $DD,   0, $D9, $D7, $D5, $D6, $E0,   0, $DE, $DC, $DA, $D8, $EE, $F0,   0	; 00
	db	  0,   0,   0,   0,   0, '©', '!',   0,   0,   0, 'ø', 'ª', '¥', '∂', '"', $FB	; 10
	db	  0, '±', '∑', '¢', '≥', ';', '’',   0,   0, ' ', '¨', '†', '•', '™', '%',   0	; 20
	db	  0, '≤', '®', '∞', 'Ø', '≠', ':',   0,   0,   0, 'º', 'Æ', '£', '&', '*',   0	; 30
	db	  0, '°', '´', '∏', 'π', ')', '(',   0,   0, 'æ', ',', '§', '¶', 'ß', '_',   0	; 40
	db	  0,   0, 'Ω',   0, 'µ', '+',   0,   0, $FC,   0, $C0, '∫',   0, '/',   0,   0	; 50
	db	  0,   0,   0,   0,   0,   0, $7F,   0,   0, $C6,   0, $C5, $C5,   0,   0,   0	; 60
	db	$FA, $F9, $C7,   0, $C6, $C8, $1B,   0, $DF,   0, $C7,   0,   0, $C8,   0,   0	; 70
	db	  0,   0,   0, $DB,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80


hello	db	'Hello, PS2 Keyboard'
nl	db	10, 13, 0
text1	db	'Press any keys!!!', 10, 13, 0

okay	db	'PS/2 Keyboard initialized.', 10, 13, 0
