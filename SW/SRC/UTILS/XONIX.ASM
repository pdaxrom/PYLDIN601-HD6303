;
; XONIX GAME
;
; (c) Alexander Chukov <sash@pdaXrom.org>, 1994-2019
;

		INCLUDE ../../DEVMAP.INC

L_ED0E		EQU	$ED0E
L_E628		EQU	$E628
L_80  		EQU	$80
SWIA  		EQU	$2E
L_E62B		EQU	$E62B
L_E601		EQU	$E601
L_E600		EQU	$E600
L_F2AB		EQU	$F2AB

SCRADDR		EQU	$0000
SCRWIDTH	EQU	42	; $2A
SCRHEIGHT	EQU	24	; $18

		org	$100

		ldaa	#$0C
		int	$22

		ldx	#ctrlc
		clrb
		ldaa	#$04
		int	$2F
		ldaa	#$22
		int	$2E
		stab	int22_page
		stx	int22_addr
		clrb
		ldx	#int22
		int	$2F
		ldx	#int33
		clrb
		ldaa	#$33
		int	$2F

;		ldx	#L_0153	; constant?
;		stx	L_F2AB

		ldaa	VPU_VADDR
		staa	b_vpu_vaddr
		ldaa	VPU_AUTOOFFS
		staa	b_vpu_aoffs
		ldaa	VPU_HSIZE
		staa	b_vpu_hsize
		ldaa	VPU_CONFIG
		staa	b_vpu_config

		ldx	#SCRADDR
		stx	VPU_VADDR
		ldaa	#SCRWIDTH-1
		staa	VPU_HSIZE

		jsr	vpu_incoff

		jmp	init

ctrlc		ldx	b_vpu_vaddr
		stx	VPU_VADDR
		ldaa	b_vpu_aoffs
		staa	VPU_AUTOOFFS
		ldaa	b_vpu_hsize
		staa	VPU_HSIZE
		ldaa	b_vpu_config
		staa	VPU_CONFIG

		ldaa	#$22
		ldab	int22_page
		ldx	int22_addr
		int	$2F
		int	$38
L_0153		rts

vpu_incon	psha
		ldaa	VPU_CONFIG
		oraa	#VPU_B_AUTO
		staa	VPU_CONFIG
		pula
		rts

vpu_incoff	psha
		ldaa	VPU_CONFIG
		anda	#$FF^VPU_B_AUTO
		staa	VPU_CONFIG
		pula
		rts

b_vpu_config	db	0
b_vpu_hsize	db	0
b_vpu_vaddr	dw	0
b_vpu_aoffs	db	0

L_015C		dw	SCRADDR
		dw	SCRADDR+SCRWIDTH
putstraddr	dw	$0000
charaddr	dw	$0000
lives		dw	$0000
level		dw	$0000
scores		dw	$0000
bonus		dw	$0000
PLAYER_X	db	$00	; '.'
PLAYER_Y	db	$00	; '.'
PLAYER_CURX	db	$00	; '.'
PLAYER_CURY	db	$00	; '.'
PLAYER_BG		db	$00	; '.'
gamespeed	dw	$0000

init		ldaa	#$01
		staa	level+1
		ldaa	#$07
		staa	lives+1
		ldx	#$0000	; external address?
		stx	scores
		stx	bonus

		ldx	#2300	; initial speed
		stx	gamespeed

		ldx	#SCRADDR
		ldaa	#$20
L_01A1		stx	VPU_ADDR
		staa	VPU_DATA
		inx
		cpx	#SCRADDR+SCRWIDTH*SCRHEIGHT+128
		bne	L_01A1

		jsr	showtitles

		ldx	#SCRADDR+SCRWIDTH*SCRHEIGHT
		ldaa	#$20
L_01B1		stx	VPU_ADDR
		staa	VPU_DATA
		inx
		cpx	#SCRADDR+SCRWIDTH*SCRHEIGHT+128
		bne	L_01B1

		ldaa	#$14
		staa	PLAYER_X
		staa	PLAYER_CURX
		ldaa	#$00
		staa	PLAYER_Y
		staa	PLAYER_CURY

		ldaa	#$D1
		staa	PLAYER_BG
		clr	L_0434
		jsr	clearscr
		jsr	showinfo
		clr	L_0236
		jmp	GAMEPLAY

		db	$8F	; '�'
		db	$BA	; '�'
		db	$AB	; '�'
		db	$A4	; '�'
		db	$A8	; '�'
		db	$AD	; '�'
		db	$20	; ' '
		db	$36	; '6'
		db	$30	; '0'
		db	$31	; '1'
		db	$20	; ' '
		db	$2D	; '-'
		db	$20	; ' '
		db	$A3	; '�'
		db	$A0	; '�'
		db	$A2	; '�'
		db	$AD	; '�'
		db	$AE	; '�'
		db	$00	; '.'

putstr		ldx	putstraddr
		ldaa	$00,x
		tsta
		beq	putstr1
		inx
		stx	putstraddr
		ldx	charaddr
		stx	VPU_ADDR
		staa	VPU_DATA
		inx
		stx	charaddr
		bra	putstr
putstr1		rts

int22		ldx	charaddr
		stx	VPU_ADDR
		ldaa	SWIA
		staa	VPU_DATA
		inx
		stx	charaddr
		rts

int33		ldx	#$0005	; external address?
		ldaa	$00,x
		psha
		ldaa	$01,x
		psha
		ldx	$02,x
		stx	L_80
		tst	L_0236
		bne	L_0231
		ldaa	#$32
		ldab	#$05
		ldx	#$0006	; external address?
		int	$6F
L_0231		ldx	L_80
		pula
		pulb
		rts
L_0236		db	$00	; '.'

getcharaddr	pshb
		psha
		ldx	#getchadrtmp
		ldaa	#SCRWIDTH
		int	$28
		staa	$01,x
		pula
		psha
		adda	$01,x
		adcb	#/SCRADDR
		staa	$01,x
		stab	$00,x
		pula
		pulb
		ldx	$00,x
		rts
getchadrtmp	db	$00	; '.'
		db	$00	; '.'

readkey		clrb
readkey1	int	$10
;		ldaa	L_E628
		cmpa	#$FF
		bne	readkey2
		decb
		bne	readkey1
		rts
;		sei
readkey2	int	$11
		rts

;		ldx	#L_015C	; constant?
;		ldaa	#$00
;		ldab	#$04
;		int	$2D
;		ldx	#SCRADDR
;		ldaa	#$29
;L_026E		clr	$00,x
;		inx
;		deca
;		bne	L_026E
;		rts

showenemy	ldaa	level+1
		ldx	#tblenemy
L_027B		psha
		ldaa	$00,x
		ldab	$01,x
		stx	L_030D
		jsr	getcharaddr
		stx	VPU_ADDR
		clr	VPU_DATA
		ldx	L_030D
		adda	$02,x
		addb	$03,x
		jsr	getcharaddr
		stx	VPU_ADDR
		tst	VPU_DATA
		bne	L_02A3
		psha
		ldaa	#$4F
		staa	VPU_DATA
		pula
		ldx	L_030D
		staa	$00,x
		stab	$01,x
L_02A3		ldx	L_030D
		ldaa	$00,x
		ldab	$01,x
		adda	$02,x
		jsr	getcharaddr
		stx	VPU_ADDR
		ldaa	VPU_DATA
		ldx	L_030D
		tsta
		beq	L_02C2
		neg	$02,x
		int	$33
		cmpa	#$EA
		bne	L_02C2
		jsr	L_0437
L_02C2		ldaa	$00,x
		ldab	$01,x
		addb	$03,x
		jsr	getcharaddr
		stx	VPU_ADDR
		ldaa	VPU_DATA
		ldx	L_030D
		tsta
		beq	L_02DE
		neg	$03,x
		int	$33
		cmpa	#$EA
		bne	L_02DE
		jsr	L_0437
L_02DE		ldx	L_030D
		ldaa	$00,x
		ldab	$01,x
		adda	$02,x
		addb	$03,x
		jsr	getcharaddr
		stx	VPU_ADDR
		ldaa	VPU_DATA
		ldx	L_030D
		tsta
		beq	L_0301
		neg	$03,x
		neg	$02,x
		int	$33
		cmpa	#$EA
		bne	L_0301
		jsr	L_0437
L_0301		inx
		inx
		inx
		inx
		pula
		deca
		beq	L_030C
		jmp	L_027B
L_030C		rts
L_030D		dw	$0000

clearscr	ldab	#$19
L_0311		ldaa	#$28
L_0313		psha
		pshb
		decb
		jsr	getcharaddr
		stx	VPU_ADDR
		ldaa	#$D1
		staa	VPU_DATA
		pulb
		pula
		deca
		bne	L_0313
		decb
		bne	L_0311
		ldab	#$14
L_0327		ldaa	#$24
L_0329		psha
		pshb
		adda	#$02
		addb	#$02
		jsr	getcharaddr
		stx	VPU_ADDR
		clr	VPU_DATA
		jsr	L_059A
		pulb
		pula
		deca
		bne	L_0329
		decb
		bne	L_0327
		rts

cursoraddr	dw	$0000
setcursor	psha
		pshb
;		sei
		ldx	#cursoraddr
		ldaa	$01,x
		ldab	$00,x
		psha
		ldaa	#$0E
		staa	L_E600
		stab	L_E601
		pulb
		inca
		staa	L_E600
		stab	L_E601
		pulb
		pula
		rts

GAMEPLAY	ldaa	PLAYER_CURX
		ldab	PLAYER_CURY
		jsr	getcharaddr
		stx	VPU_ADDR
		ldaa	PLAYER_BG
		staa	VPU_DATA
		ldaa	PLAYER_X
		ldab	PLAYER_Y
		staa	PLAYER_CURX
		stab	PLAYER_CURY
		jsr	getcharaddr
		stx	VPU_ADDR
		jsr	chkplayerpos
		staa	PLAYER_BG
		ldaa	#$EA
		stx	VPU_ADDR
		staa	VPU_DATA
		inx
		inx
		stx	cursoraddr
		jsr	setcursor
		jsr	L_047D
		jsr	showenemy
		ldx	gamespeed
L_0398		dex
		cpx	#$0000	; external address?
		bne	L_0398
		jmp	winordie

playerctl	jsr	readkey
		cmpa	#$C0
		bne	L_03C0
		tst	L_0236
		beq	L_03B2
		clr	L_0236
		bra	L_03B5
L_03B2		inc	L_0236
L_03B5		ldx	#$0028	; external address?
		ldaa	#$28
		ldab	#$07
		int	$6F
		ldab	#$C0
L_03C0		cmpa	#$1B
		bne	CHK_RIGHT
		jmp	init

CHK_RIGHT	cmpa	#$C2		; right
		bne	CHK_LEFT
		inc	PLAYER_X
		bra	CHK_MINX
CHK_LEFT	cmpa	#$C1		; left
		bne	CHK_UP
		dec	PLAYER_X
		bra	CHK_MINX
CHK_UP		cmpa	#$C4		; up
		bne	CHK_DOWN
		dec	PLAYER_Y
		bra	CHK_MINX
CHK_DOWN	cmpa	#$C3		; down
		bne	CHK_MINX
		inc	PLAYER_Y
		bra	CHK_MINX
CHK_MINX	ldaa	PLAYER_X
		cmpa	#$FF
		bne	CHK_MAXX
		inc	PLAYER_X
CHK_MAXX	cmpa	#$28
		bne	CHK_MINY
		dec	PLAYER_X
CHK_MINY	ldaa	PLAYER_Y
		cmpa	#$FF
		bne	CHK_MAXY
		inc	PLAYER_Y
CHK_MAXY	cmpa	#$18
		bne	CHK_ENDXY
		dec	PLAYER_Y
CHK_ENDXY	jmp	GAMEPLAY

chkplayerpos	ldaa	VPU_DATA
		tsta
		bne	L_042D
		ldaa	#$EA
		tst	L_0434
		bne	L_042D
		psha
		ldaa	PLAYER_X
		ldab	PLAYER_Y
		staa	L_0435
		stab	L_0436
		inc	L_0434
		pula
L_042D		cmpa	#$4F
		bne	L_0433
		bra	L_0437
L_0433		rts
L_0434		db	$00	; '.'
L_0435		db	$00	; '.'
L_0436		db	$00	; '.'

L_0437		tst	L_0434
		beq	L_0472
		stx	L_030D
		psha
		pshb
		ldx	#SCRADDR
L_0444		stx	VPU_ADDR
		ldaa	VPU_DATA
		cmpa	#$EA
		bne	L_044C
		clr	VPU_DATA
L_044C		cmpa	#$4F
		bne	L_0452
		clr	VPU_DATA
L_0452		inx
		cpx	#SCRADDR+SCRWIDTH*SCRHEIGHT+128
		bne	L_0444
		clr	PLAYER_BG
		ldaa	#$14
		staa	PLAYER_X
		ldab	#$00
		stab	PLAYER_Y
		pulb
		pula
		clr	L_0434
		ldx	L_ED0E
		clr	$00,x
		dec	lives+1
L_0472		psha
		pshb
		jsr	showinfo
		ldx	L_030D
		pulb
		pula
		rts

; check if cutted
L_047D		ldaa	PLAYER_BG
		cmpa	#$D1
		bne	L_04B4
		tst	L_0434
		beq	L_04B4
		ldx	#SCRADDR
L_048C		stx	VPU_ADDR
		ldaa	VPU_DATA
		cmpa	#$EA
		bne	L_04A3
		stx	L_030D
		ldx	scores
		inx
		stx	scores
		ldx	L_030D
		ldaa	#$D1
		staa	VPU_DATA
L_04A3		inx
		cpx	#SCRADDR+SCRWIDTH*SCRHEIGHT+128
		bne	L_048C
		clr	L_0434
		ldx	L_ED0E
		clr	$00,x
		jsr	L_04B5
L_04B4		rts

L_04B5		clra
		clrb
L_04B7		clra
L_04B8		jsr	getcharaddr
		stx	VPU_ADDR
		psha
		ldaa	VPU_DATA
		cmpa	#$4F
		pula
		bne	L_04C6
		jsr	fillarea
L_04C6		inca
		cmpa	#$27
		bne	L_04B8
		incb
		cmpb	#$18
		bne	L_04B7
		jsr	L_056D
		rts

fillarea	staa	L_05B5
		stab	L_05B6
		inca
		jsr	getcharaddr
		stx	VPU_ADDR
		tst	VPU_DATA
		beq	L_0504
		suba	#$02
		jsr	getcharaddr
		stx	VPU_ADDR
		tst	VPU_DATA
		beq	L_0504
		inca
		incb
		jsr	getcharaddr
		stx	VPU_ADDR
		tst	VPU_DATA
		beq	L_0504
		subb	#$02
		jsr	getcharaddr
		stx	VPU_ADDR
		tst	VPU_DATA
		beq	L_0504
		ldaa	L_05B5
		ldab	L_05B6
		rts

L_0504		inc	VPU_DATA
L_0506		ldx	#SCRADDR
L_0509		stx	VPU_ADDR
		ldaa	VPU_DATA
		cmpa	#$01
		beq	L_051C
		inx
		cpx	#SCRADDR+SCRWIDTH*SCRHEIGHT
		bne	L_0509
		ldaa	L_05B5
		ldab	L_05B6
		rts

L_051C		stx	L_0569
		stx	L_056B
		stx	VPU_ADDR
		inc	VPU_DATA
		dex
		stx	VPU_ADDR
		tst	VPU_DATA
		bne	L_052B
		inc	VPU_DATA
L_052B		inx
		inx
		stx	VPU_ADDR
		tst	VPU_DATA
		bne	L_0531
		inc	VPU_DATA
L_0531		ldaa	L_0569+1
		ldab	L_0569
		adda	#$2A
		adcb	#$00
		staa	L_0569+1
		stab	L_0569
		ldx	L_0569
		stx	VPU_ADDR
		tst	VPU_DATA
		bne	L_054A
		inc	VPU_DATA
L_054A		ldaa	L_056B+1
		ldab	L_056B
		suba	#$2A
		sbcb	#$00
		staa	L_0569+1
		stab	L_0569
		ldx	L_0569
		stx	VPU_ADDR
		tst	VPU_DATA
		bne	L_0563
		inc	VPU_DATA
L_0563		ldx	L_056B
		jmp	L_0506
L_0569		dw	$0000
L_056B		dw	$0000

L_056D		ldx	#SCRADDR
L_0570		stx	VPU_ADDR
		ldaa	VPU_DATA
		tsta
		bne	L_0589
		ldaa	#$D1
		staa	VPU_DATA
		stx	L_030D
		ldx	scores
		inx
		stx	scores
		ldx	L_030D
		bra	L_058F
L_0589		cmpa	#$02
		bne	L_058F
		clr	VPU_DATA
L_058F		bsr	L_059A
		inx
		cpx	#SCRADDR+SCRWIDTH*SCRHEIGHT
		bne	L_0570
		jsr	showinfo
L_059A		ldab	#$0A
		ldaa	L_E62B
		eora	#$08
		staa	L_E62B
L_05A4		decb
		bne	L_05A4
		ldab	#$06
		ldaa	L_E62B
		eora	#$08
		staa	L_E62B
L_05B1		decb
		bne	L_05B1
		rts

L_05B5		db	$00	; '.'
L_05B6		db	$00	; '.'
int22_page	db	$00	; '.'
int22_addr	dw	$0000

txtinfostr	db	$42	; 'B'
		db	$6F	; 'o'
		db	$6E	; 'n'
		db	$75	; 'u'
		db	$73	; 's'
		db	$3A	; ':'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$53	; 'S'
		db	$63	; 'c'
		db	$6F	; 'o'
		db	$72	; 'r'
		db	$65	; 'e'
		db	$3A	; ':'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$4C	; 'L'
		db	$65	; 'e'
		db	$76	; 'v'
		db	$65	; 'e'
		db	$6C	; 'l'
		db	$3A	; ':'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$4C	; 'L'
		db	$69	; 'i'
		db	$76	; 'v'
		db	$65	; 'e'
		db	$73	; 's'
		db	$3A	; ':'
		db	$20	; ' '
		db	$00	; '.'
showinfo	ldaa	#$00
		ldab	#$19
		jsr	getcharaddr
		stx	charaddr
		ldx	#txtinfostr
		stx	putstraddr
		jsr	putstr
		ldaa	#$06
		ldab	#$19
		jsr	getcharaddr
		stx	charaddr
		ldx	bonus
		int	$24
		ldaa	#$11
		ldab	#$19
		jsr	getcharaddr
		stx	charaddr
		ldx	scores
		int	$24
		ldaa	#$1C
		ldab	#$19
		jsr	getcharaddr
		stx	charaddr
		ldx	level
		int	$24
		ldaa	#$25
		ldab	#$19
		jsr	getcharaddr
		stx	charaddr
		ldx	lives
		int	$24
		ldx	charaddr
		stx	VPU_ADDR
		clr	VPU_DATA
		rts

winordie	ldx	scores
		cpx	#680
		bge	newlevel
		tst	lives+1
		beq	L_0646
		jmp	playerctl

L_0646		jmp	gameover

newlevel	inc	level+1
		ldx	scores
L_064F		stx	L_030D
		ldx	bonus
		inx
		stx	bonus
		ldx	L_030D
		dex
		cpx	#$0000	; external address?
		bne	L_064F
		ldx	#$0000	; external address?
		stx	scores
		jsr	clearscr
		ldaa	#$14
		clrb
		staa	PLAYER_X
		stab	PLAYER_Y
		staa	PLAYER_CURX
		stab	PLAYER_CURY
		ldaa	#$D1
		staa	PLAYER_BG
		ldaa	lives+1
		adda	level+1
		ldab	level+1
		rorb
		clc
		sba
		staa	lives+1
		jsr	showinfo
		jmp	GAMEPLAY

showtitles	jsr	clearscr
		jsr	showinfo
		ldx	#txtintroline
		jsr	movingline
		rts
txtintroline	db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$2E	; '.'
		db	$2E	; '.'
		db	$2E	; '.'
		db	$20	; ' '
		db	$D6	; '�'
		db	$20	; ' '
		db	$97	; '�'
		db	$B3	; '�'
		db	$AA	; '�'
		db	$AE	; '�'
		db	$A2	; '�'
		db	$20	; ' '
		db	$80	; '�'
		db	$AB	; '�'
		db	$A5	; '�'
		db	$AA	; '�'
		db	$B1	; '�'
		db	$A0	; '�'
		db	$AD	; '�'
		db	$A4	; '�'
		db	$B0	; '�'
		db	$20	; ' '
		db	$3A	; ':'
		db	$20	; ' '
		db	$36	; '6'
		db	$2D	; '-'
		db	$6D	; 'm'
		db	$61	; 'a'
		db	$72	; 'r'
		db	$2D	; '-'
		db	$31	; '1'
		db	$39	; '9'
		db	$39	; '9'
		db	$34	; '4'
		db	$20	; ' '
		db	$2E	; '.'
		db	$2E	; '.'
		db	$2E	; '.'
		db	$20	; ' '
		db	$20	; ' '
		db	$97	; '�'
		db	$B3	; '�'
		db	$AA	; '�'
		db	$AE	; '�'
		db	$A2	; '�'
		db	$20	; ' '
		db	$80	; '�'
		db	$AB	; '�'
		db	$A5	; '�'
		db	$AA	; '�'
		db	$B1	; '�'
		db	$A0	; '�'
		db	$AD	; '�'
		db	$A4	; '�'
		db	$B0	; '�'
		db	$20	; ' '
		db	$AF	; '�'
		db	$B0	; '�'
		db	$A5	; '�'
		db	$A4	; '�'
		db	$B1	; '�'
		db	$B2	; '�'
		db	$A0	; '�'
		db	$A2	; '�'
		db	$AB	; '�'
		db	$BF	; '�'
		db	$A5	; '�'
		db	$B2	; '�'
		db	$20	; ' '
		db	$A2	; '�'
		db	$A5	; '�'
		db	$B0	; '�'
		db	$B1	; '�'
		db	$A8	; '�'
		db	$BE	; '�'
		db	$20	; ' '
		db	$AF	; '�'
		db	$AE	; '�'
		db	$AF	; '�'
		db	$B3	; '�'
		db	$AB	; '�'
		db	$BF	; '�'
		db	$B0	; '�'
		db	$AD	; '�'
		db	$AE	; '�'
		db	$A9	; '�'
		db	$20	; ' '
		db	$AA	; '�'
		db	$AE	; '�'
		db	$AC	; '�'
		db	$AF	; '�'
		db	$BC	; '�'
		db	$BE	; '�'
		db	$B2	; '�'
		db	$A5	; '�'
		db	$B0	; '�'
		db	$AD	; '�'
		db	$AE	; '�'
		db	$A9	; '�'
		db	$20	; ' '
		db	$A8	; '�'
		db	$A3	; '�'
		db	$B0	; '�'
		db	$BB	; '�'
		db	$20	; ' '
		db	$22	; '"'
		db	$58	; 'X'
		db	$4F	; 'O'
		db	$4E	; 'N'
		db	$49	; 'I'
		db	$58	; 'X'
		db	$22	; '"'
		db	$20	; ' '
		db	$A4	; '�'
		db	$AB	; '�'
		db	$BF	; '�'
		db	$20	; ' '
		db	$8F	; '�'
		db	$8A	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$8F	; '�'
		db	$BA	; '�'
		db	$AB	; '�'
		db	$A4	; '�'
		db	$A8	; '�'
		db	$AD	; '�'
		db	$20	; ' '
		db	$36	; '6'
		db	$30	; '0'
		db	$31	; '1'
		db	$2E	; '.'
		db	$20	; ' '
		db	$20	; ' '
		db	$82	; '�'
		db	$20	; ' '
		db	$BD	; '�'
		db	$B2	; '�'
		db	$AE	; '�'
		db	$A8	; '�'
		db	$20	; ' '
		db	$A8	; '�'
		db	$A3	; '�'
		db	$B0	; '�'
		db	$A5	; '�'
		db	$20	; ' '
		db	$A2	; '�'
		db	$A0	; '�'
		db	$AC	; '�'
		db	$20	; ' '
		db	$AD	; '�'
		db	$B3	; '�'
		db	$A6	; '�'
		db	$AD	; '�'
		db	$AE	; '�'
		db	$20	; ' '
		db	$AE	; '�'
		db	$B2	; '�'
		db	$A2	; '�'
		db	$AE	; '�'
		db	$A5	; '�'
		db	$A2	; '�'
		db	$BB	; '�'
		db	$A2	; '�'
		db	$A0	; '�'
		db	$B2	; '�'
		db	$BC	; '�'
		db	$20	; ' '
		db	$B2	; '�'
		db	$A5	; '�'
		db	$B0	; '�'
		db	$B0	; '�'
		db	$A8	; '�'
		db	$B2	; '�'
		db	$AE	; '�'
		db	$B0	; '�'
		db	$A8	; '�'
		db	$BE	; '�'
		db	$20	; ' '
		db	$B3	; '�'
		db	$20	; ' '
		db	$B8	; '�'
		db	$A0	; '�'
		db	$B0	; '�'
		db	$AE	; '�'
		db	$A2	; '�'
		db	$2C	; ','
		db	$20	; ' '
		db	$A7	; '�'
		db	$A0	; '�'
		db	$20	; ' '
		db	$BD	; '�'
		db	$B2	; '�'
		db	$AE	; '�'
		db	$20	; ' '
		db	$A2	; '�'
		db	$A0	; '�'
		db	$AC	; '�'
		db	$20	; ' '
		db	$AD	; '�'
		db	$A0	; '�'
		db	$B7	; '�'
		db	$A8	; '�'
		db	$B1	; '�'
		db	$AB	; '�'
		db	$BF	; '�'
		db	$BE	; '�'
		db	$B2	; '�'
		db	$B1	; '�'
		db	$BF	; '�'
		db	$20	; ' '
		db	$AE	; '�'
		db	$B7	; '�'
		db	$A8	; '�'
		db	$2E	; '.'
		db	$20	; ' '
		db	$8F	; '�'
		db	$B0	; '�'
		db	$A8	; '�'
		db	$20	; ' '
		db	$AD	; '�'
		db	$A0	; '�'
		db	$A1	; '�'
		db	$AE	; '�'
		db	$B0	; '�'
		db	$A5	; '�'
		db	$20	; ' '
		db	$AE	; '�'
		db	$AF	; '�'
		db	$B0	; '�'
		db	$A5	; '�'
		db	$A4	; '�'
		db	$A5	; '�'
		db	$AB	; '�'
		db	$A5	; '�'
		db	$AD	; '�'
		db	$AD	; '�'
		db	$AE	; '�'
		db	$A3	; '�'
		db	$AE	; '�'
		db	$20	; ' '
		db	$AA	; '�'
		db	$AE	; '�'
		db	$AB	; '�'
		db	$A8	; '�'
		db	$B7	; '�'
		db	$A5	; '�'
		db	$B1	; '�'
		db	$B2	; '�'
		db	$A2	; '�'
		db	$A0	; '�'
		db	$20	; ' '
		db	$AE	; '�'
		db	$B7	; '�'
		db	$A5	; '�'
		db	$A9	; '�'
		db	$20	; ' '
		db	$A2	; '�'
		db	$BB	; '�'
		db	$20	; ' '
		db	$AF	; '�'
		db	$A5	; '�'
		db	$B0	; '�'
		db	$A5	; '�'
		db	$A9	; '�'
		db	$A4	; '�'
		db	$A5	; '�'
		db	$B2	; '�'
		db	$A5	; '�'
		db	$20	; ' '
		db	$AD	; '�'
		db	$A0	; '�'
		db	$20	; ' '
		db	$B1	; '�'
		db	$AB	; '�'
		db	$A5	; '�'
		db	$A4	; '�'
		db	$B3	; '�'
		db	$BE	; '�'
		db	$B9	; '�'
		db	$A8	; '�'
		db	$A9	; '�'
		db	$20	; ' '
		db	$B3	; '�'
		db	$B0	; '�'
		db	$AE	; '�'
		db	$A2	; '�'
		db	$A5	; '�'
		db	$AD	; '�'
		db	$BC	; '�'
		db	$2E	; '.'
		db	$20	; ' '
		db	$84	; '�'
		db	$AB	; '�'
		db	$BF	; '�'
		db	$20	; ' '
		db	$B1	; '�'
		db	$B2	; '�'
		db	$A0	; '�'
		db	$B0	; '�'
		db	$B2	; '�'
		db	$A0	; '�'
		db	$20	; ' '
		db	$AD	; '�'
		db	$A0	; '�'
		db	$A6	; '�'
		db	$AC	; '�'
		db	$A8	; '�'
		db	$B2	; '�'
		db	$A5	; '�'
		db	$20	; ' '
		db	$AA	; '�'
		db	$AB	; '�'
		db	$A0	; '�'
		db	$A2	; '�'
		db	$A8	; '�'
		db	$B8	; '�'
		db	$B3	; '�'
		db	$20	; ' '
		db	$5B	; '['
		db	$52	; 'R'
		db	$45	; 'E'
		db	$54	; 'T'
		db	$55	; 'U'
		db	$52	; 'R'
		db	$4E	; 'N'
		db	$5D	; ']'
		db	$20	; ' '
		db	$2E	; '.'
		db	$2E	; '.'
		db	$2E	; '.'
		db	$20	; ' '
		db	$86	; '�'
		db	$A5	; '�'
		db	$AB	; '�'
		db	$A0	; '�'
		db	$BE	; '�'
		db	$20	; ' '
		db	$B3	; '�'
		db	$B1	; '�'
		db	$AF	; '�'
		db	$A5	; '�'
		db	$B5	; '�'
		db	$A0	; '�'
		db	$20	; ' '
		db	$21	; '!'
		db	$21	; '!'
		db	$21	; '!'
		db	$20	; ' '
		db	$20	; ' '
		db	$2E	; '.'
		db	$2E	; '.'
		db	$2E	; '.'
		db	$20	; ' '
		db	$81	; '�'
		db	$AE	; '�'
		db	$AB	; '�'
		db	$BC	; '�'
		db	$B8	; '�'
		db	$AE	; '�'
		db	$A9	; '�'
		db	$20	; ' '
		db	$AF	; '�'
		db	$B0	; '�'
		db	$A8	; '�'
		db	$A2	; '�'
		db	$A5	; '�'
		db	$B2	; '�'
		db	$20	; ' '
		db	$88	; '�'
		db	$AB	; '�'
		db	$BC	; '�'
		db	$A8	; '�'
		db	$B7	; '�'
		db	$A5	; '�'
		db	$A2	; '�'
		db	$AE	; '�'
		db	$A9	; '�'
		db	$20	; ' '
		db	$8D	; '�'
		db	$A0	; '�'
		db	$A4	; '�'
		db	$BE	; '�'
		db	$B5	; '�'
		db	$A5	; '�'
		db	$2C	; ','
		db	$20	; ' '
		db	$8A	; '�'
		db	$A8	; '�'
		db	$B0	; '�'
		db	$A8	; '�'
		db	$AB	; '�'
		db	$AB	; '�'
		db	$AE	; '�'
		db	$A2	; '�'
		db	$AE	; '�'
		db	$A9	; '�'
		db	$20	; ' '
		db	$90	; '�'
		db	$A8	; '�'
		db	$B2	; '�'
		db	$A5	; '�'
		db	$2C	; ','
		db	$20	; ' '
		db	$92	; '�'
		db	$BE	; '�'
		db	$B2	; '�'
		db	$BE	; '�'
		db	$AD	; '�'
		db	$AE	; '�'
		db	$A2	; '�'
		db	$AE	; '�'
		db	$A9	; '�'
		db	$20	; ' '
		db	$92	; '�'
		db	$A0	; '�'
		db	$AD	; '�'
		db	$BE	; '�'
		db	$B5	; '�'
		db	$A5	; '�'
		db	$2C	; ','
		db	$20	; ' '
		db	$8A	; '�'
		db	$A0	; '�'
		db	$A9	; '�'
		db	$A4	; '�'
		db	$A0	; '�'
		db	$AB	; '�'
		db	$AE	; '�'
		db	$A2	; '�'
		db	$AE	; '�'
		db	$A9	; '�'
		db	$20	; ' '
		db	$85	; '�'
		db	$AB	; '�'
		db	$A5	; '�'
		db	$AD	; '�'
		db	$A5	; '�'
		db	$20	; ' '
		db	$A8	; '�'
		db	$20	; ' '
		db	$8D	; '�'
		db	$A0	; '�'
		db	$B2	; '�'
		db	$A0	; '�'
		db	$B8	; '�'
		db	$A5	; '�'
		db	$20	; ' '
		db	$A8	; '�'
		db	$20	; ' '
		db	$A4	; '�'
		db	$B0	; '�'
		db	$B3	; '�'
		db	$A3	; '�'
		db	$A8	; '�'
		db	$AC	; '�'
		db	$2C	; ','
		db	$20	; ' '
		db	$A0	; '�'
		db	$20	; ' '
		db	$B2	; '�'
		db	$A0	; '�'
		db	$AA	; '�'
		db	$A6	; '�'
		db	$A5	; '�'
		db	$20	; ' '
		db	$AC	; '�'
		db	$AD	; '�'
		db	$A5	; '�'
		db	$2C	; ','
		db	$20	; ' '
		db	$80	; '�'
		db	$AB	; '�'
		db	$A5	; '�'
		db	$AA	; '�'
		db	$B1	; '�'
		db	$A0	; '�'
		db	$AD	; '�'
		db	$A4	; '�'
		db	$B0	; '�'
		db	$B3	; '�'
		db	$20	; ' '
		db	$21	; '!'
		db	$21	; '!'
		db	$21	; '!'
		db	$20	; ' '
		db	$00	; '.'

gameover	jsr	clearscr
		ldx	#txtnolives
		jsr	movingline
		jmp	init

txtnolives	db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$2E	; '.'
		db	$2E	; '.'
		db	$2E	; '.'
		db	$20	; ' '
		db	$93	; '�'
		db	$20	; ' '
		db	$A2	; '�'
		db	$A0	; '�'
		db	$B1	; '�'
		db	$20	; ' '
		db	$AA	; '�'
		db	$AE	; '�'
		db	$AD	; '�'
		db	$B7	; '�'
		db	$A8	; '�'
		db	$AB	; '�'
		db	$A8	; '�'
		db	$B1	; '�'
		db	$BC	; '�'
		db	$20	; ' '
		db	$A6	; '�'
		db	$A8	; '�'
		db	$A7	; '�'
		db	$AD	; '�'
		db	$A8	; '�'
		db	$2C	; ','
		db	$20	; ' '
		db	$AF	; '�'
		db	$AE	; '�'
		db	$BD	; '�'
		db	$B2	; '�'
		db	$AE	; '�'
		db	$AC	; '�'
		db	$B3	; '�'
		db	$20	; ' '
		db	$A2	; '�'
		db	$BB	; '�'
		db	$20	; ' '
		db	$A7	; '�'
		db	$A0	; '�'
		db	$AA	; '�'
		db	$AE	; '�'
		db	$AD	; '�'
		db	$B7	; '�'
		db	$A8	; '�'
		db	$AB	; '�'
		db	$A8	; '�'
		db	$20	; ' '
		db	$A8	; '�'
		db	$A3	; '�'
		db	$B0	; '�'
		db	$B3	; '�'
		db	$20	; ' '
		db	$2E	; '.'
		db	$2E	; '.'
		db	$2E	; '.'
		db	$20	; ' '
		db	$8F	; '�'
		db	$B0	; '�'
		db	$A8	; '�'
		db	$AC	; '�'
		db	$A8	; '�'
		db	$B2	; '�'
		db	$A5	; '�'
		db	$20	; ' '
		db	$AC	; '�'
		db	$AE	; '�'
		db	$A8	; '�'
		db	$20	; ' '
		db	$B1	; '�'
		db	$AE	; '�'
		db	$A1	; '�'
		db	$AE	; '�'
		db	$AB	; '�'
		db	$A5	; '�'
		db	$A7	; '�'
		db	$AD	; '�'
		db	$AE	; '�'
		db	$A2	; '�'
		db	$A0	; '�'
		db	$AD	; '�'
		db	$A8	; '�'
		db	$BF	; '�'
		db	$20	; ' '
		db	$2E	; '.'
		db	$2E	; '.'
		db	$2E	; '.'
		db	$20	; ' '
		db	$20	; ' '
		db	$84	; '�'
		db	$AB	; '�'
		db	$BF	; '�'
		db	$20	; ' '
		db	$AD	; '�'
		db	$A0	; '�'
		db	$B7	; '�'
		db	$A0	; '�'
		db	$AB	; '�'
		db	$A0	; '�'
		db	$20	; ' '
		db	$AD	; '�'
		db	$A0	; '�'
		db	$A6	; '�'
		db	$AC	; '�'
		db	$A8	; '�'
		db	$B2	; '�'
		db	$A5	; '�'
		db	$20	; ' '
		db	$AA	; '�'
		db	$AB	; '�'
		db	$A0	; '�'
		db	$A2	; '�'
		db	$A8	; '�'
		db	$B8	; '�'
		db	$B3	; '�'
		db	$20	; ' '
		db	$5B	; '['
		db	$52	; 'R'
		db	$45	; 'E'
		db	$54	; 'T'
		db	$55	; 'U'
		db	$52	; 'R'
		db	$4E	; 'N'
		db	$5D	; ']'
		db	$20	; ' '
		db	$2E	; '.'
		db	$2E	; '.'
		db	$2E	; '.'
		db	$20	; ' '
		db	$00	; '.'
movingline	stx	L_0A64
		stx	L_0A66
		stx	L_0A68
		jsr	introscreen
		clra
		ldab	#$1A
		jsr	getcharaddr
		stx	putstraddr
moviloop	ldx	putstraddr
		stx	charaddr
		ldab	#$28
L_097C		ldx	L_0A64
		ldaa	$00,x
		tsta
		bne	L_098C
		ldx	L_0A66
		stx	L_0A64
		bra	L_097C
L_098C		inx
		stx	L_0A64
		ldx	charaddr
		stx	VPU_ADDR
		staa	VPU_DATA
		inx
		stx	charaddr
		decb
		bne	L_097C
		ldx	L_0A68
		inx
		tst	$00,x
		bne	L_09A7
		ldx	L_0A66
L_09A7		stx	L_0A68
		stx	L_0A64
		jsr	lightshow
		ldx	#$2328	; external address?
L_09B3		dex
		cpx	#$0000	; external address?
		bne	L_09B3
		jsr	movireadkey
		cmpa	#$C0
		bne	moviloop
		ldx	L_ED0E
		clr	$00,x
		rts

movireadkey	jsr	readkey
		cmpa	#$FE
		beq	setspeed
		rts

setspeed	jsr	clearscr
		ldaa	#$0A
		ldab	#$0A
		jsr	getcharaddr
		stx	charaddr
		ldx	#txtspeed
		stx	putstraddr
		jsr	putstr
		ldx	charaddr
		stx	L_030D
L_09EA		ldx	L_030D
		stx	charaddr
		ldx	gamespeed
		int	$24
		ldx	charaddr
		stx	VPU_ADDR
		clr	VPU_DATA
		inx
		stx	VPU_ADDR
		clr	VPU_DATA
		dex
L_09FC		jsr	readkey
		cmpa	#$FF
		beq	L_09FC
		psha
		ldab	#$07
		ldaa	#$28
		ldx	#$001E	; external address?
		int	$6F
		pula
		ldx	L_ED0E
		clr	$00,x
		cmpa	#$C4
		bne	L_0A1A
		inc	gamespeed
L_0A1A		cmpa	#$C3
		bne	L_0A21
		dec	gamespeed
L_0A21		cmpa	#$C0
		bne	L_09EA
		pula
		pula
		rts
txtspeed	db	$53	; 'S'
		db	$70	; 'p'
		db	$65	; 'e'
		db	$65	; 'e'
		db	$64	; 'd'
		db	$3A	; ':'
		db	$20	; ' '
		db	$00	; '.'

lightshow	ldx	#SCRADDR
L_0A33		stx	VPU_ADDR
		ldaa	VPU_DATA
		cmpa	#$FA
		bne	L_0A3D
		ldaa	#$2B
		bra	L_0A5B
L_0A3D		cmpa	#$2B
		bne	L_0A45
		ldaa	#$2A
		bra	L_0A5B
L_0A45		cmpa	#$2A
		bne	L_0A4D
		ldaa	#$D0
		bra	L_0A5B
L_0A4D		cmpa	#$D0
		bne	L_0A55
		ldaa	#$DB
		bra	L_0A5B
L_0A55		cmpa	#$DB
		bne	L_0A5D
		ldaa	#$FA
L_0A5B		staa	VPU_DATA
L_0A5D		inx
		cpx	#SCRADDR+SCRWIDTH*SCRHEIGHT
		bne	L_0A33
		rts

L_0A64		dw	$0000
L_0A66		dw	$0000
L_0A68		dw	$0000
tblenemy	db	$0A	; '.'
		db	$0A	; '.'
		db	$01	; '.'
		db	$01	; '.'
		db	$10	; '.'
		db	$05	; '.'
		db	$FF	; '�'
		db	$01	; '.'
		db	$21	; '!'
		db	$11	; '.'
		db	$01	; '.'
		db	$FF	; '�'
		db	$16	; '.'
		db	$0C	; '.'
		db	$FF	; '�'
		db	$FF	; '�'
		db	$14	; '.'
		db	$14	; '.'
		db	$FF	; '�'
		db	$01	; '.'
		db	$19	; '.'
		db	$06	; '.'
		db	$01	; '.'
		db	$01	; '.'
		db	$0B	; '.'
		db	$0E	; '.'
		db	$FF	; '�'
		db	$FF	; '�'
		db	$12	; '.'
		db	$08	; '.'
		db	$01	; '.'
		db	$FF	; '�'
		db	$04	; '.'
		db	$04	; '.'
		db	$01	; '.'
		db	$01	; '.'
		db	$25	; '%'
		db	$02	; '.'
		db	$FF	; '�'
		db	$FF	; '�'

txtintroscr	db	$2A	; '*'
		db	$2A	; '*'
		db	$2B	; '+'
		db	$2B	; '+'
		db	$FA	; '�'
		db	$FA	; '�'
		db	$DB	; '�'
		db	$DB	; '�'
		db	$D0	; '�'
		db	$D0	; '�'
		db	$2A	; '*'
		db	$2A	; '*'
		db	$2B	; '+'
		db	$2B	; '+'
		db	$FA	; '�'
		db	$FA	; '�'
		db	$DB	; '�'
		db	$DB	; '�'
		db	$D0	; '�'
		db	$D0	; '�'
		db	$2A	; '*'
		db	$2A	; '*'
		db	$2B	; '+'
		db	$2B	; '+'
		db	$FA	; '�'
		db	$FA	; '�'
		db	$DB	; '�'
		db	$DB	; '�'
		db	$D0	; '�'
		db	$D0	; '�'
		db	$2A	; '*'
		db	$2A	; '*'
		db	$00	; '.'
		db	$D0	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$8F	; '�'
		db	$B0	; '�'
		db	$A8	; '�'
		db	$A2	; '�'
		db	$A5	; '�'
		db	$B2	; '�'
		db	$2C	; ','
		db	$20	; ' '
		db	$84	; '�'
		db	$A0	; '�'
		db	$B0	; '�'
		db	$BC	; '�'
		db	$BF	; '�'
		db	$20	; ' '
		db	$8C	; '�'
		db	$A5	; '�'
		db	$B9	; '�'
		db	$A5	; '�'
		db	$B0	; '�'
		db	$BF	; '�'
		db	$AA	; '�'
		db	$AE	; '�'
		db	$A2	; '�'
		db	$A0	; '�'
		db	$20	; ' '
		db	$21	; '!'
		db	$20	; ' '
		db	$20	; ' '
		db	$2B	; '+'
		db	$00	; '.'
		db	$D0	; '�'
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$D0	; '�'
		db	$D0	; '�'
		db	$D0	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$2B	; '+'
		db	$2B	; '+'
		db	$2B	; '+'
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$2B	; '+'
		db	$00	; '.'
		db	$DB	; '�'
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$D0	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$D0	; '�'
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$20	; ' '
		db	$2B	; '+'
		db	$20	; ' '
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$FA	; '�'
		db	$00	; '.'
		db	$DB	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$D0	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$D0	; '�'
		db	$20	; ' '
		db	$2A	; '*'
		db	$2A	; '*'
		db	$20	; ' '
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$20	; ' '
		db	$2B	; '+'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$FA	; '�'
		db	$00	; '.'
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$D0	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$D0	; '�'
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$20	; ' '
		db	$2B	; '+'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$DB	; '�'
		db	$00	; '.'
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$D0	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$D0	; '�'
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$20	; ' '
		db	$2A	; '*'
		db	$2A	; '*'
		db	$20	; ' '
		db	$20	; ' '
		db	$2B	; '+'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$DB	; '�'
		db	$00	; '.'
		db	$2B	; '+'
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$D0	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$D0	; '�'
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$20	; ' '
		db	$2B	; '+'
		db	$20	; ' '
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$D0	; '�'
		db	$00	; '.'
		db	$2B	; '+'
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$DB	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$D0	; '�'
		db	$D0	; '�'
		db	$D0	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$2A	; '*'
		db	$20	; ' '
		db	$2B	; '+'
		db	$2B	; '+'
		db	$2B	; '+'
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$FA	; '�'
		db	$20	; ' '
		db	$20	; ' '
		db	$D0	; '�'
		db	$00	; '.'
		db	$2A	; '*'
		db	$20	; ' '
		db	$8F	; '�'
		db	$B0	; '�'
		db	$A8	; '�'
		db	$A2	; '�'
		db	$A5	; '�'
		db	$B2	; '�'
		db	$2C	; ','
		db	$20	; ' '
		db	$85	; '�'
		db	$A2	; '�'
		db	$A3	; '�'
		db	$A5	; '�'
		db	$AD	; '�'
		db	$A8	; '�'
		db	$BF	; '�'
		db	$20	; ' '
		db	$91	; '�'
		db	$A8	; '�'
		db	$AC	; '�'
		db	$AE	; '�'
		db	$AD	; '�'
		db	$A6	; '�'
		db	$A5	; '�'
		db	$AD	; '�'
		db	$AA	; '�'
		db	$AE	; '�'
		db	$A2	; '�'
		db	$A0	; '�'
		db	$21	; '!'
		db	$2A	; '*'
		db	$00	; '.'
		db	$2A	; '*'
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$20	; ' '
		db	$2A	; '*'
		db	$00	; '.'
		db	$D0	; '�'
		db	$20	; ' '
		db	$D6	; '�'
		db	$20	; ' '
		db	$97	; '�'
		db	$B3	; '�'
		db	$AA	; '�'
		db	$AE	; '�'
		db	$A2	; '�'
		db	$20	; ' '
		db	$80	; '�'
		db	$AB	; '�'
		db	$A5	; '�'
		db	$AA	; '�'
		db	$B1	; '�'
		db	$A0	; '�'
		db	$AD	; '�'
		db	$A4	; '�'
		db	$B0	; '�'
		db	$3A	; ':'
		db	$81	; '�'
		db	$B3	; '�'
		db	$AD	; '�'
		db	$A4	; '�'
		db	$BE	; '�'
		db	$B0	; '�'
		db	$20	; ' '
		db	$39	; '9'
		db	$34	; '4'
		db	$20	; ' '
		db	$20	; ' '
		db	$2B	; '+'
		db	$00	; '.'
		db	$FA	; '�'
		db	$FA	; '�'
		db	$2B	; '+'
		db	$2B	; '+'
		db	$2A	; '*'
		db	$2A	; '*'
		db	$D0	; '�'
		db	$D0	; '�'
		db	$DB	; '�'
		db	$DB	; '�'
		db	$FA	; '�'
		db	$FA	; '�'
		db	$2B	; '+'
		db	$2B	; '+'
		db	$2A	; '*'
		db	$2A	; '*'
		db	$D0	; '�'
		db	$D0	; '�'
		db	$DB	; '�'
		db	$DB	; '�'
		db	$FA	; '�'
		db	$FA	; '�'
		db	$2B	; '+'
		db	$2B	; '+'
		db	$2A	; '*'
		db	$2A	; '*'
		db	$D0	; '�'
		db	$D0	; '�'
		db	$DB	; '�'
		db	$DB	; '�'
		db	$FA	; '�'
		db	$FA	; '�'
		db	$00	; '.'
introscreen	ldaa	#$0D
		staa	L_0A64
		ldaa	#$05
		ldab	#$07
		ldx	#txtintroscr
		stx	putstraddr
L_0C4E		psha
		pshb
		jsr	getcharaddr
		stx	charaddr
		jsr	putstr
		ldx	putstraddr
		inx
		stx	putstraddr
		pulb
		pula
		incb
		dec	L_0A64
		bne	L_0C4E
		rts
