; ***********************************************************
; *							    *
; *	      ОПЕРАЦИОННА СИСТЕМА    U n i D O S	    *
; *	    за пе░▒онален мик░окомп╛▓║░ ПЪЛДИН 601	    *
; *							    *
; *    Copyright (C) 1988  НИПЛ "П░ог░амно о▒иг│░┐ване"     *
; *							    *
; *		 (C) 1988  Иво Найденов НЕНОВ		    *
; *		 (C) 1988  Леонид Давидови╖ КАЛЕВ	    *
; *		 (C) 1988  О░лин Дими▓░ов ШОПОВ 	    *
; *							    *
; ***********************************************************
; *							    *
; *		      U  n  i  B  I  O	S		    *
; *		  Version 3.02 / 01-Apr-1990		    *
; *							    *
; ***********************************************************
		list	off
; ПРЕДУПРЕЖДЕНИЕ:
; Тек▒▓а на опе░а╢ионна▓а ▒и▒▓ема ▒е дава ▒амо за ▒п░авка.
; В▒┐ко ди░ек▓но об░║╣ение к║м кода или моди┤и╢и░ане на
; п░оменливи▓е на опе░а╢ионна▓а ▒и▒▓ема на░│╕ава кон╢еп╢и┐▓а
; за ▒║вме▒▓имо▒▓ ▒ ░азли╖ни ве░▒ии. НИПЛ "П░ог░амно о▒иг│░┐ване"
; ▒и запазва п░аво▓о да п░ави п░омени в кода и п░оменливи▓е на
; опе░а╢ионна▓а ▒и▒▓ема ▒ ╢ел подоб░ение на ┤│нк╢иони░ане▓о.
; Не ▒е поема никаква о▓гово░но▒▓ за не▒║вме▒▓имо▒▓ на п░ог░амни
; п░од│к▓и, не▒пазили п░о▓окола за използване на опе░а╢ионна▓а
; ▒и▒▓ема ▒ б║де╣и ве░▒ии.
; Об░║╣ени┐▓а к║м опе░а╢ионна▓а ▒и▒▓ема ▒ледва да ▒е изв║░╕ва▓
; по п░о▓окола опи▒ан в ░║ковод▒▓во▓о за по▓░еби▓ел┐.

;------------------------------------------------------------

		include memory.inc

;------------------------------------------------------------
		list	on
DustBin 	equ	$FFFF		;clipped dots plotted here
putc		equ	$F003		;text screen write char

setvideo	=	$16		;^V - set video mode cmd
MaxGX		=	640
MAxGY		=	400

min_bios_vers	=	$0201
max_bios_vers	=	$03FF

regs		equ	swic

;------------------------------------------------------------
; ПРОМЕНЛИВИ:

		section $28
;monitor
pc		ds	2
mnem		ds	2
oper		ds	2
opcode		ds	1

;screen driver
;!!! do not modify the following variables
scrp		ds	2
fontp		ds	2
fptr		ds	2
tfore		ds	1
tback		ds	1
tfxb		ds	1
gfore		ds	1
gback		ds	1
gfxb		ds	1
dblp		ds	2
screenb 	ds	2		;graphic screen base
cursorp 	ds	2

; these may be used by anyone who does not call the scrn driver
ctr		ds	1
ctr1		ds	1
pstk		ds	2
p1		ds	2
bytead		ds	2

; graphics, do not touch these
row		ds	2
col		ds	2
mask		ds	1

;music
mus_ptr 	ds	2
tmp		ds	2
Corr		ds	2
CorrB		equ	Corr+1
Pia1		equ	mus_ptr
Pia2		equ	mus_ptr+1
Per1		equ	tmp
Per2		equ	tmp+1

;graphics temporary (overwrite music vars)
dxc		equ	mus_ptr 	;cir
dyc		equ	tmp		;cir
er		equ	Corr	;(&CorrB) - 2 byte (line/hline)

xx		ds	2		;circle
yy		ds	2		;circle
x0		ds	2		;gen - internal x co
y0		ds	2		;gen - int. y co

;(overwite scrn drv temp. vars)
GrTmp		equ	ctr		;gen
PicByte 	equ	ctr1		;pixel
dx		equ	p1		;hline/bar
dy		equ	dyc

oldptr		equ	mus_ptr
oldmask 	equ	tmp

shape_length	equ	xx		;fm.cir
shape_ptr	equ	yy
shape_scale	equ	x0
shape_steps	equ	x0+1

;Graphics picture combine flags.
;			    | fun    | RplXor | And |NandOrn|RplOrOrn| gcol |
;								      fn No
;			       P	 ff	 ff    00	 ff	0
RplXor		ds	1   ; P xor S	 ff	 ff    00	 00	1
And		ds	1   ;	1	 ff	 ff    ff	 ff	2
NandOrn 	ds	1   ;	~S	 ff	 ff    ff	 00	3
RplOrOrn	ds	1   ;	0	 ff	 00    00	 ff	4
			    ;	S	 ff	 00    00	 00	5
			    ;	1	 ff	 00    ff	 ff	6
; P - New picture	    ;	~S	 ff	 00    ff	 00	7
; S - Original screen value ; P or S	 00	 ff    00	 ff	8
;			    ; P & ~S	 00	 ff    00	 00	9
;			    ; P | ~S	 00	 ff    ff	 ff	a
;			    ; ~(P&S)	 00	 ff    ff	 00	b
;			    ; ~P & S	 00	 00    00	 ff	c
			    ; P & S	 00	 00    00	 00	d
			    ; P & ~S	 00	 00    ff	 ff	e
			    ; ~(P&S)	 00	 00    ff	 00	f

		error	(*-1)/$60
		ends

;---------------------------------------
;RAM variables
		section $BF00

;---------------------------- Graphics ---------------------
scrr		ds	1		;screen left
scrb		ds	1
scrl		ds	1
scrt		ds	1		;top

bytes		ds	1		;no of bytes per char
Pixels		ds	2		;pixels/byte
shiftcnt	=	Pixels+1	;bits/pixel
colormask	ds	1		;color mask (num of cols. - 1)
putca		ds	2		;putc routine addr

cmdchr		ds	1
qaddr		ds	2		;jmp addr for qued commands
qcnt		ds	1		;no of chars to put in the que
queue_buffer	ds	5
qptr		ds	2		;que ptr
cx1		ds	2		;cursor sve

max_screenb	ds	2
screen_size	ds	2

cx		equ	queue_buffer+1
cy		equ	queue_buffer+3

aa		ds	2
bb		ds	2
ca		ds	2
cb		ds	2
ax		ds	2
ay		ds	2
centrx		ds	2
centry		ds	2

XDir		equ	centrx		;line
YDir		equ	centrx+1
count		equ	centry		;line

old_xx		ds	2		;circle
old_yy		ds	2		;circle
fill_flag	ds	1		;circle

;Graphics window limits
GrLeft		ds	2	; internal units (pixel)
GrRight 	ds	2
GrRightL	ds	2	; in bits (=logical or logic./2 (601))
GrTop		ds	2
GrBot		ds	2


;---------------------------- Music ------------------------
np		ds	2
svx		ds	2
tmbr		ds	1

;---------------------------- Monitor ----------------------
bufferptr	ds	2
prntbuff	ds	2
suffchar	ds	1
mode		ds	1
qflg		ds	1
errflg		ds	1
tflg		ds	1
dflg		ds	1
amod		ds	1
code		ds	1
tmp1		ds	2
ptr		ds	2
diskbuff	equ	queue_buffer+1		;4 bytes
handle		equ	queue_buffer

;---------------------------- Pseudo RS --------------------
allcap		ds	1

;---------------------------- GetLine ----------------------
buf_beg 	ds	2
buf_end 	ds	2
buf_max 	ds	2
cursor		ds	2
line_ch 	ds	1
line_cv 	ds	1
cursor_h	ds	1
cursor_v	ds	1
editflg 	ds	1

		error	(*-1)/$BF80
		ends

;-----------------------------------------------------------
		org	$C000
		dw	$A55A
		db	'UniBIOS '
		jmp	init
		jmp	monitor

		db	1
		dw	monitor

		db	4
		dw	monitor

		db	$1A
		dw	int1A

		db	$1B
		dw	int1B

		db	$21
		dw	int21

		db	$24
		dw	int24

		db	$25
		dw	int25

		db	$30
		dw	monitor

		db	$60
		dw	int_60

		db	$61
		dw	int_61

		db	$63
		dw	int_63

		db	$64
		dw	int_64

		db	$65
		dw	int_65

		db	$66
		dw	int_66

		db	$67
		dw	int67

		db	$6D
		dw	int_6D

		db	$6E
		dw	int_6E

		db	$6F
		dw	int_6F

		db	0

;----------------------------------------------------------
;the following should be in one page !!!
page
scrmarg 				;screen right & bootom margin
		db	40,25
		db	10,25
		db	20,25
		db	40,25
		db	80,25

pcaddr
		dw	0		;not used
		dw	putcgr16
		dw	putcgr4
		dw	putcgr2
		dw	0		;not used

;default bg & fg colours
defbg		db	0		;not used
deffg		db	0		;not used
		db	0,255
		db	0,255
		db	0,255

modetbl 	db	colortbl&255
		db	colortbl1&255
		db	colortbl2&255
		db	colortbl3&255

PixShft 	db	0,0	;Pixels/byte & bits/bixel
		db	2,4
		db	4,2
		db	8,1

colortbl
colortbl1	db	$00,$11,$22,$33,$44,$55,$66,$77
		db	$88,$99,$aa,$bb,$cc,$dd,$ee,$ff
colortbl2	db	$00,$55,$aa,$ff
colortbl3	db	$00,$ff
;*......

		list	off
;----------------------------------------------------------
init		proc
		ldab	bios_version
		ldaa	bios_version+1

		cmpb	#/min_bios_vers
		bne	cmp1
		cmpa	#min_bios_vers
cmp1		bcs	bad_version

		cmpb	#/max_bios_vers
		bne	cmp2
		cmpa	#max_bios_vers
cmp2		bls	version_ok

bad_version	ldx	#bad_text
		int	$23
		int	$00

version_ok
		ldaa	#$22
		ldab	rompage
		ldx	#int_22
		int	$2f

		ldaa	#$15
		ldx	#int_15
		int	$2f

		ldaa	#$12
		int	$2e
		ldaa	#$62
		int	$2f
		ldaa	#$12
		ldab	rompage
		ldx	#int_12
		int	$2F

		ldx	#16000			;Screensize
		stx	screen_size
		tst	hard_version
		bmi	advanced
		lsr	screen_size		;8000 for 601
		ror	screen_size+1
advanced
		ldx	#0
		stx	screenb
		ldab	resident
		ldaa	resident+1
		suba	screen_size+1	  ;screen_size
		sbcb	screen_size
		stab	max_screenb
		staa	max_screenb+1

		clr	qcnt		;init0
		ldx	#fontbase
		stx	fptr
		ldx	#dbltbl
		stx	dblp

		ldaa	#%11111111	;all font_pages
		ldab	#/font		;start of font
		int	$64
		clr	palette

		ldx	#16
		clrb
		int	$2A
		stx	prntbuff

		ldx	#81
		clrb
		int	$2A
		int	$2C
		stx	bufferptr
		clr	x

		ldaa	#$40
		oraa	equipment
		staa	equipment

		ldx	#text
		int	$23
		rts

text		db	10,'UniBIOS  Version 3.02',0
bad_text	db	10,'Bad BIOS version',0
		endp

monitor 	proc
		ldaa	#$a
		ldab	rompage
		ldx	#macros
		int	$2F	;disable kbd macros
		ldaa	#0
		ldab	rompage
		ldx	#breakpoint
		int	$2F
		jmp	monitor0

macros		db	201,'UUUUUUUU',$C0,0
		db	202,'PPPPPPPP',$C0,0
		db	$FF
mover					; п░о╢ед│░а за ме▒▓ене на паме▓
		sei
		sts	tmps
		ldaa	a1+1		;src end - извли╖ане на па░аме▓░и▓е
		ldab	a1		;	   на команда▓а MOVE
		suba	a2+1		;src beg
		sbcb	a2
		adda	a4+1		;dst beg
		adcb	a4
		staa	a3+1		;dst end
		stab	a3

		ldaa	a4		; оп░едел┐не на по▒ока▓а на ме▒▓ене
		cmpa	a2		; на паме▓
		bne	move1
		ldaa	a4+1
		cmpa	a2+1
move1		bls	mvleft
mvright 				; ме▒▓ене над┐▒но
		lds	a3
		ldx	a1
		inx
mvright1	dex
		ldaa	0,x
		psha
		cpx	a2
		bne	mvright1
		bra	mvend
mvleft					; ме▒▓ене нал┐во
		lds	a2
		ldx	a4
mvleft0 	des
		dex
mvleft1 	inx
		pula
		staa	0,x
		cpx	a3
		bne	mvleft1
mvend		lds	tmps
		cli
rts2		rts
move					; в╡одна ▓о╖ка на команда▓а
		tst	dflg		; MOVE на мони▓о░а
		bne	mover
		jmp	syntax_error

zoom					; в╡одна ▓о╖ка на команда▓а ZOOM
		tst	dflg
		bne	zoom0
		jmp	syntax_error
zoom0		sei			; използва п░о╢ед│░а▓а за ме▒▓ене
		sts	tmps		; на паме▓ нал┐во за да ░азмножи
		ldx	a1		; об░аза
		stx	a3
		lds	a4
		ldx	a2
		bra	mvleft0

monitor0
loop					; главен ╢ик║л на мони▓о░а
		jsr	newln		; пе╖а▓ на нов ░ед
		ldaa	#27		; о▓пе╖а▓ване на п░омп▓
		int	$22
		ldaa	#4
		int	$22
		ldx	bufferptr	; п░о╖и▓ане на ░ед в ▒и▒▓емни┐ б│┤е░
		stx	ptr
		ldab	#80		; ▒ мак▒имална д║лжина 80 ▒имвола
		int	$21
		clr	errflg		; ини╢иализа╢и┐ на ┤лагове▓е
		clr	mode
		clr	qflg
		clr	tflg

loopc0
		clr	dflg
		clr	a1
		clr	a1+1
loopc
		ldx	ptr
		ldaa	0,x
		bne	loopc1
		ldaa	mode
		jsr	spce
		bra	loop
loopc1
		inx
		stx	ptr
		tst	qflg
		beq	notqu
		staa	a1+1
		ldaa	#' '
		staa	dflg
		bra	notd1
notqu
		cmpa	#'a'            ; п░еоб░аз│ване в главни б│кви
		bcs	notlower
		cmpa	#'z'
		bhi	notlower
		anda	#$5f
notlower
		cmpa	#'0'            ; п░ове░ка за ╕е▒▓наде▒е▓и╖на ╢и┤░а
		bcs	notd1
		cmpa	#':'
		bcs	digit
		cmpa	#'A'
		bcs	notd1
		cmpa	#'G'
		bcs	dig1

notd1
		tst	mode
		bne	nocpy
		tst	dflg
		beq	nocpy
		ldx	a1
		stx	a2
		stx	a3
nocpy
		ldx	#cmds		; п░ове░ка за команда
findc

		cmpa	0,x
		beq	foundc
		inx
		inx
		inx
		cpx	#cmde
		bne	findc
		bsr	syntax_error
		bra	loopc

foundc		ldx	1,x		; изп║лнение на команда▓а
		ldaa	mode

		clr	mode
		jsr	0,x
		bra	loopc0

dig1
		suba	#7		; на▓░│пване на ╖и▒ло в A1
digit		suba	#48

		ldab	a1
		asl	a1+1
		rolb
		asl	a1+1
		rolb
		asl	a1+1
		rolb
		asl	a1+1
		rolb
		stab	a1
		oraa	a1+1
		staa	a1+1
		sec
		ror	dflg
		jmp	loopc

spce					; команда <SPACE> (░аздел▓ел)
		tst	dflg
		beq	stmode
		tsta
		beq	todec
		bpl	rts1		;err?

		staa	mode		;keep store mode
		ldaa	a1+1
		ldx	a3
		staa	0,x
		inx
		stx	a3
rts1		rts

cpy1
		ldx	a1
		stx	a4
		rts
cpy2
		ldaa	#1
		staa	tflg
stmode		staa	mode
		rts
set
		ldaa	#-1
		bra	stmode

syntax_error	tst	errflg		; пе╖а▓ на ▒║об╣ение за г░е╕ка
		bne	syntax_errorz
		dec	errflg
prnerror	ldx	#errortxt
		int	$23		;putline
syntax_errorz	rts
errortxt	db	10,'Error',7,0

todec					; п░о╢ед│░а за пе╖а▓ на д│ма в
		bsr	newln		; де▒е▓и╖ен ┤о░ма▓
		jsr	pr24
		ldx	a1
		stx	a2
		jsr	pra2hex
		jsr	preq
		jsr	prsp
		int	$24
		rts

newln					; нов ░ед на ек░ана
		ldaa	#10
		int	$22		;putchar
		rts

prnt					; в╡одна ▓о╖ка на команда▓а PRINT
		tst	dflg
		bne	prnt1
		ldx	a2
		stx	a1
prnt1					; п░о╢ед│░а за пе╖а▓ на ▒║▒░жание▓о
		bsr	newln		; на паме▓▓а в ╕е▒▓наде▒е▓и╖ен и
		jsr	pra2hex 	; ▒имволен ┤о░ма▓
		int	$6D		; max screen cols
		lsra
		clrb
prnt4		suba	#5
		bcs	prnt5
		incb
		bra	prnt4
prnt5		aslb
		pshb
		ldx	prntbuff
prnt2
		jsr	prsp
		jsr	nextbyte
		staa	0,x
		inx
		decb
		bne	prnt2

		jsr	pr2sp
		pulb
		ldx	prntbuff
prnt3
		ldaa	#27
		int	$22
		ldaa	0,x
		int	$22
		inx
		decb
		bne	prnt3

		jsr	cmpa2a1
		bls	prnt1
		rts

breakpoint
;		ldaa	swic
;		staa	regs
;		ldx	swib
;		stx	regs+1
;		ldx	swix
;		stx	regs+3
		tsx
		ldx	8,x
		stx	pc
		stx	a2
		bsr	newln
		jsr	pra2hex
		jsr	prsp
		ins			;compensate stack
		ins
		ins
		ins
		ins
		ins
		ins
		ins
		ins
		ins
		dec	indos
		bsr	regdump0
		jmp	monitor0

regdump 				; п░о╢ед│░а за о▓пе╖а▓ване на
		bsr	newln		; ▒║д║░жание▓о на ░еги▒▓░и▓е
regdump0	ldx	#reglist
		bsr	prval1
		ldaa	regs+2
		bsr	prval
		ldaa	regs+1
		bsr	prval
		ldab	regs+3
		ldaa	regs+4
		bsr	prdval
		sts	tmps
		ldab	tmps
		ldaa	tmps+1
		bsr	prdval
		ldaa	regs
		int	$25
		rts

prdval		stab	a2
		staa	a2+1
		jsr	pra2hex
		bsr	prreg
		bra	prval1
prreg		ldaa	0,x
		inx
regdump4	int	$22
		rts

prval		int	$25
		jsr	prsp
prval1		bsr	prreg
		jmp	preq

reglist 	db	'ABXSPCC'

a1pc		tst	dflg
		beq	rts5
		ldx	a1
		stx	pc
rts5		rts
go					; в╡одна ▓о╖ка на команда▓а GO
		bsr	a1pc
		bsr	go1
		stab	regs+1
		staa	regs+2
		stx	regs+3
		tpa
		staa	regs
		rts

go1
		ldx	#regs+4
		ldaa	pc+1
		psha
		ldaa	pc
		psha
		ldab	#5
push		ldaa	0,x
		psha
		dex
		decb
		bne	push
		rti			;load regs & jump

quote					; │▒▓анов┐ване на ▒имволен мод
		staa	mode		;keep mode
		com	qflg
		rts

quit		ins			; из╡од о▓ мони▓о░а
		ins
		rts

vfy					; в╡одна ▓о╖ка на команда▓а VERIFY
		tst	dflg
		bne	vfy0
		jmp	syntax_error
vfy0
		sei
		sts	tmps
		lds	a4
		des
		ldx	a2
		dex
vfy1		inx
		pulb
		ldaa	0,x
		cba
		beq	vfy2
		sts	a4
		lds	tmps
		cli
		pshb
		psha
		stx	a2
		jsr	newln
		jsr	pra2hex
		pula
		int	$25
		ldaa	#'|'
		int	$22	       ;putchar
		pula
		int	$25
		sei
		sts	tmps
		lds	a4
		ldx	a2
vfy2
		cpx	a1
		bne	vfy1
		lds	tmps
		cli
		rts


pra2hex
		ldaa	a2
		int	$25
		ldaa	a2+1
		int	$25
		jmp	prsp

cmpa2a1 	ldaa	a2
		cmpa	a1
		bne	cmpa2a1z
		ldaa	a2+1
		cmpa	a1+1
cmpa2a1z	rts

nextbyte	stx	tmp1		; ╖е▓ене на ▒ледва╣и┐ бай▓, използва
		bsr	take0		; ▒е о▓ ░азли╖ни п░о╢ед│░и
		bcc	nextbyt1
		stx	a1
nextbyt1
		psha
		int	$25
		pula
		ldx	tmp1
		rts

take		bsr	cmpa2a1 	; ╖е▓ене на ▒ледва╣и┐ бай▓, използва
		bhi	takeend 	; ▒е о▓ ░азли╖ни п░о╢ед│░и
take0		ldx	a2
		ldaa	0,x
		inx
		stx	a2
		beq	takeend
		clc
		rts
takeend 	sec
		rts

outputl 	int	$19	       ;в╡одна ▓о╖ка на команда▓а OUTPUT
output		bsr	take
		bcc	outputl
		rts

input					; INPUT
		tst	dflg
		bne	input0
sy_err		jmp	syntax_error
input0
		jsr	cmpa2a1
		bhi	inputrts
		int	$18
		bcs	input_error
		ldx	a2
		staa	0,x
		inx
		stx	a2
		bne	input0
inputrts	rts
input_error	jmp	prnerror

cassread	int	$1a		;READ
		tstb
		bne	cassread_ok
		tsta
		beq	input_error
cassread_ok	stx	pc
		rts

casswrite	ldx	a2		;WRITE
		bsr	suba2a1
		int	$1b
		rts

suba2a1 	ldaa	a1+1
		ldab	a1
		suba	a2+1
		sbcb	a2
		rts

;---------------
load
		bsr	disk0
		beq	sy_err
		ldaa	#1		;r_only
		int	$4A		;open
		tsta
		bne	disk_err
		bsr	disk5
		int	$4C		;read
		tsta
		bne	disk_err
		bra	close

save
		bsr	disk0
		beq	sy_err
		clra			;normal
		int	$4B		;create
		tsta
		bne	disk_err
		bsr	disk5
		int	$4D		;write
		tsta
		bne	disk_err

close		ldaa	handle
		int	$4E		;close
		tsta
		beq	disk_ok
disk_err	psha
		ldaa	#10
		int	$22
		pula
		ldx	lomem
		clr	x		;just in case no UniDOS
		int	$3D
		int	$23
disk_ok 	rts


disk0		tst	dflg
		beq	disk0b
		tst	tflg
		beq	disk0b

		ldaa	#' '
		ldx	ptr
disk1l		cmpa	x		;skip spaces
		bne	disk1b
		inx
		bra	disk1l
disk1b
		stx	diskbuff
		ldx	#0
		stx	diskbuff+2

		ldx	ptr
disk2l		tst	x
		beq	disk2b
		inx
		bra	disk2l
disk2b		stx	ptr

		ldx	#diskbuff	;ZF = 0 !!!
disk0b		rts


disk5		stab	handle
		ldx	a2
		stx	diskbuff
		jsr	suba2a1
		adda	#1
		adcb	#0
		staa	diskbuff+3
		stab	diskbuff+2
		ldx	#diskbuff
		ldaa	handle
		rts

;---------------

disasm					; в╡одна ▓о╖ка на команда▓а LIST
		tst	dflg
		bne	disa1
		ldx	a2
		stx	a1
disa1
		jsr	cmpa2a1
disx		bls	dis1
		rts
dis1					; ди▒а▒ембли░а една ин▒▓░│к╢и┐
		jsr	newln
		jsr	pra2hex
		jsr	nextbyte
		staa	opcode
		jsr	prsp
		ldaa	opcode
		cmpa	#$50
		bcs	dis3
		cmpa	#$80
		anda	#$0f
		bcs	dis2
		oraa	#$50
		db	$8c
dis2		oraa	#$40
dis3		staa	code

		ldab	opcode
		ldx	#xlattbl
dis4		ldaa	0,x
		inx
		tsta
		beq	dis5
		cba
		bne	dis4
		clr	opcode
		bra	dis7
dis5		ldaa	0,x
		cba
		beq	dis6
		inx
		inx
		tsta
		bne	dis5
		bra	dis7
dis6		ldaa	1,x
		staa	code
dis7
		ldaa	opcode
		cmpa	#$8d
		bne	dis8
		ldaa	#$21
		staa	opcode
dis8
		lsra
		lsra
		lsra
		lsra
		staa	tmpx+1
		ldab	#/suffix
		stab	tmpx
		ldx	tmpx
		ldaa	suffix,x
		psha
		tab
		ldaa	#$20
		andb	#3
		beq	k1
		addb	#$40
		aba
k1		staa	suffchar
		pula
		lsra
		lsra
		staa	amod

		ldaa	opcode
		cmpa	#$3f
		bne	k8
		ldaa	#1
		staa	amod
		bra	k9
k8
		cmpa	#$8c
		beq	l1
		cmpa	#$8e
		beq	l1
		cmpa	#$ce
		beq	l1
		anda	#%11111011
		cmpa	#$32
		beq	k8a
		cmpa	#$33
		bne	k9
k8a		adda	#$61-$32
		staa	suffchar
k9
		ldaa	amod
		cmpa	#7
		bne	k2
		jsr	pr2sp
		bra	k5
k2		cmpa	#3
		bne	k3
l1		bsr	jmpnextb
		staa	oper
		bsr	jmpnextb
		staa	oper+1
		bra	k4
k3		clr	oper
		bsr	jmpnextb
		staa	oper+1
k5		jsr	pr2sp
k4		jsr	pr2sp

		jsr	pr2sp
		ldaa	code
		bsr	prmnem
		jsr	proper
		jmp	disa1
jmpnextb	jmp	nextbyte

suffix		db	$1c,$1c,$10,$1c,$1d,$1e,$08,$0c
		db	$01,$05,$09,$0d,$02,$06,$0a,$0e
xlattbl 	db	$61,$71,$62,$72,$65,$75,$6b,$7b,$4e,$5e
		db	$83,$93,$a3,$b3,$c3,$d3,$e3,$f3
		db	$cc,$dc,$ec,$fc,$cd,$dd,$ed,$fd
		db	$87,$c7,$9d,$8f,$cf,$21,$00

		dw	$8d21
		dw	$ce60
		dw	$de60
		dw	$ee60
		dw	$fe60
		dw	$df61
		dw	$ef61
		dw	$ff61
		dw	$0000		;terminate

prmnem
		asla
		staa	tmpx+1
		ldab	#/mnemtbl
		stab	tmpx
		ldx	tmpx
		ldx	mnemtbl,x
		stx	mnem
		ldab	mnem
		ldaa	mnem+1
		lsrb
		lsrb
		lsrb
		bsr	prmnch
		ldab	mnem
		ldaa	mnem+1
		asla
		rolb
		asla
		rolb
		bsr	prmnch
		ldab	mnem+1
		lsrb
		bsr	prmnch
		ldaa	#$20
		ldab	mnem+1
		lsrb
		bcc	prmnemz
		ldaa	suffchar
prmnemz 	int	$22	       ;putchar
pr2sp		bsr	prsp
prsp		ldaa	#$20
		int	$22
		rts

prmnch		tba
		inca
		anda	#$1f
		bne	prmnchs
		ldaa	#$A0		;for final $FF
prmnchs 	adda	#$5F
		int	$22
		rts

pr23		ldaa	#'#'
		int	$22	       ;putchar
pr24		ldaa	#'$'
		int	$22
		rts

prx		ldaa	#','
		int	$22	       ;putchar
		ldaa	#'x'
		int	$22
		rts

preq		ldaa	#'='
		int	$22	       ;putchar
		rts

proper
		ldab	amod
		cmpb	#0
		bne	proper1
		bsr	pr23
		ldaa	oper
		beq	properl
		bra	properha
proper1 	cmpb	#1
		bne	proper2
		bsr	pr24
		bra	properl
proper2 	cmpb	#2
		bne	proper3
		bsr	pr24
		bsr	properl
		bra	prx
proper3 	cmpb	#3
		bne	proper4
proper3a	bsr	pr24
properh 	ldaa	oper
properha	int	$25
properl 	ldaa	oper+1
		int	$25
		rts
proper4
		cmpb	#4
		bne	properz
		ldab	oper+1
		clra
		cmpb	#$80
		adca	#$ff
		addb	a2+1
		adca	a2
		stab	oper+1
		staa	oper
		bra	proper3a
properz 	rts

mnemtbl 				; паке▓и░ан запи▒ на мнемоники▓е
		dw	$fffe
		dw	$73e0		;nop
		dw	$fffe,$fffe,$fffe,$fffe
		dw	$a060		;tap
		dw	$a402		;tpa
		dw	$4bb0		;inx
		dw	$2170		;dex
		dw	$1b2c		;clv
		dw	$996c		;sev
		dw	$1b06		;clc
		dw	$9946		;sec
		dw	$1b12		;cli
		dw	$9952		;sei
		dw	$9882		;sba
		dw	$1882		;cba
		dw	$fffe,$fffe,$fffe,$fffe
		dw	$a044		;tab
		dw	$a082		;tba
		dw	$fffe
		dw	$2042		;daa
		dw	$fffe
		dw	$0882		;aba
		dw	$fffe,$fffe,$fffe,$fffe
		dw	$1482		;bra
		dw	$14e4		;bsr
		dw	$1212		;bhi
		dw	$1326		;bls
		dw	$10c6		;bcc
		dw	$10e6		;bcs
		dw	$138a		;bne
		dw	$1162		;beq
		dw	$1586		;bvc
		dw	$15a6		;bvs
		dw	$1418		;bpl
		dw	$1352		;bmi
		dw	$11ca		;bge
		dw	$1328		;blt
		dw	$11e8		;bgt
		dw	$130a		;ble
		dw	$a4f0		;tsx
		dw	$4ba6		;ins
		dw	$8559		;pula
		dw	$8559		;pulb
		dw	$2166		;des
		dw	$a626		;txs
		dw	$84d1		;psha
		dw	$84d1		;pshb
		dw	$fffe
		dw	$9526		;rts
		dw	$fffe
		dw	$9512		;rti
		dw	$fffe,$fffe
		dw	$b852		;wai
		dw	$4ba8		;int
		dw	$714f		;neg
		dw	$fffe,$fffe
		dw	$1bdb		;com
		dw	$64e5		;lsr
		dw	$fffe
		dw	$93e5		;ror
		dw	$0ce5		;asr
		dw	$0cd9		;asl
		dw	$93d9		;rol
		dw	$2147		;dec
		dw	$fffe
		dw	$4b87		;inc
		dw	$a4e9		;tst
		dw	$5360		;jmp
		dw	$1b25		;clr
		dw	$9d45		;sub
		dw	$1b61		;cmp
		dw	$9887		;sbc
		dw	$fffe
		dw	$0b89		;and
		dw	$1269		;bit
		dw	$6103		;lda
		dw	$9d03		;sta
		dw	$2be5		;eor
		dw	$0907		;adc
		dw	$7c83		;ora
		dw	$0909		;add
		dw	$1c30		;cpx
		dw	$54e4		;jsr
		dw	$6126		;lds
		dw	$9d26		;sts
		dw	$6130		;ldx
		dw	$9d30		;stx

cmds					; ▓абли╢а ▒ команди▓е и ад░е▒и▓е
		db	' '
		dw	spce
		db	"'"
		dw	quote
		db	'"'
		dw	quote
		db	'<'
		dw	cpy1
		db	','
		dw	cpy1
		db	'.'
		dw	cpy2
		db	'='
		dw	set
		db	':'
		dw	set
		db	'?'
		dw	regdump
		db	'G'
		dw	go
		db	'I'
		dw	input
		db	'L'
		dw	load
		db	'M'
		dw	move
		db	'O'
		dw	output
		db	'P'
		dw	prnt
		db	'Q'
		dw	quit
		db	'R'
		dw	cassread
		db	'S'
		dw	save
		db	'U'
		dw	disasm
		db	'V'
		dw	vfy
		db	'W'
		dw	casswrite
		db	'Z'
		dw	zoom
cmde		endp
					; к░ай на мони▓о░а

;----------------------------------------------------------
;  Graphics BIOS
;--------------------------------------------------------
;----------------------------------------------------------
; INT 12 - init video mode
; IMPORT: A - video_mode
;	  X - screen address
;----------------------------------------------------------
int_12		proc
		anda	#$7F
		beq	txtmode
		cmpa	#4
		beq	txtmode
		andb	#3
		stab	palette
		stx	screenb
		jmp	vmode
txtmode 	ldaa	swia
		int	$62
		rts
		endp

;----------------------------------------------------------
; INT 15 - set cursor
; import: A - x pos
;	  B - y pos
;----------------------------------------------------------
int_15		proc
		psha
		ldaa	#30
		int	$22
		pula
		adda	#32
		int	$22
		tba
		adda	#32
		int	$22
		rts
		endp


;----------------------------------------------------------
; INT 60 - allocate graphic screen
; EXPORT:
;	  X - screen address
;----------------------------------------------------------
int_60		proc
		ldx	screen_size
		ldab	#3
		int	$2a
		stx	screenb
		stx	swix
		rts
		endp

;----------------------------------------------------------
; INT 61 - disable graphic screen
;----------------------------------------------------------
int_61		proc
		ldx	#0
		stx	screenb
		clra
		clrb
		int	$12
		rts
		endp

;----------------------------------------------------------
; INT 63 - return graphic screen base & size
; export: X - screen base
;	  BA - size
;----------------------------------------------------------
int_63		proc
		ldx	screenb
		ldab	screen_size
		ldaa	screen_size+1
		stx	swix
		stab	swib
		staa	swia
		rts
		endp

;----------------------------------------------------------
; INT 64 - set font page
; IMPORT:  A - bits coressponding to fontpages
;	   B - memory_page (MSB of 32 bytes font addr) , if several
;	       fontpages used, subsequent memory pages used
;----------------------------------------------------------
int_64		proc
		ldx	#fontbase
loop		lsra
		bcc	notset
		stab	x
		incb		;for subsequent
notset		inx
		tsta
		bne	loop
		rts
		endp

;----------------------------------------------------------
; INT 22 - write char
; IMPORT: A - char
;----------------------------------------------------------
int_22		proc
		global	vmode, gcol
		global	putcgr16, putcgr4, putcgr2
drv0
;		ldx	screenb
;		beq	putctxt

		tst	qcnt
		beq	noq
		ldx	qptr
		staa	0,x
		inx
		stx	qptr
		dec	qcnt
		bne	rts11
		ldaa	scrmode
		anda	#3
		bne	jump1
		ldaa	cmdchr
		cmpa	#setvideo
		beq	jump1
		jsr	putc		       ;send all the queue over
		ldx	#queue_buffer	       ;to the old driver
send		ldaa	0,x
		jsr	putc
		inx
		cpx	qptr
		bne	send
rts11		rts

putctxt
		jmp	putc		;use old handler

;		ldx	cursorp
;		staa	0,x
;		jmp	fwd

jump1
		ldx	qaddr
jmpx		jmp	0,x		;dispatch

escape		ldaa	queue_buffer
		bra	norm
noq
		cmpa	#32
		bcs	ctrl
		ldab	scrmode
		andb	#3
		beq	putctxt
		cmpa	#127		;del
		beq	del
norm
		ldx	cursorp
		stx	scrp
		clrb
		asla
		rolb
		asla
		rolb
		asla
		rolb
		staa	fontp+1
		stab	fptr+1
		ldx	fptr
		ldaa	fontbase,x	;get font base page
		staa	fontp
		beq	nopage
		ldx	putca
		jmp	0,x
nopage		rts			;do nothing (no font available)

;** control character
ctrl
		staa	cmdchr
		staa	p1+1
		ldaa	#/qctbl
		staa	p1
		ldx	p1
		ldaa	qctbl,x 	;get que count
		staa	qcnt
		asl	p1+1
		ldaa	#/funtbl
		staa	p1
		ldx	p1
		ldx	funtbl,x
		tst	qcnt
		bne	ctrl1
		ldaa	scrmode
		anda	#3
		bne	jmpx		;graph mode, my handler
		ldaa	cmdchr
		jmp	putc		;txt mode, old handler
ctrl1
		stx	qaddr
		ldx	#queue_buffer
		stx	qptr
pxit		rts

del
		bsr	bs
		ldaa	#' '
		bsr	norm
		bra	bs
putcgr4
		sei
		sts	pstk
		lds	fontp
		des			;adjust for pull
		ldaa	#8
		staa	ctr
nextl4
		pula
		tab
		anda	#15
		staa	dblp+1
		ldx	dblp
		ldaa	dbltbl,x
		lsrb
		lsrb
		lsrb
		lsrb
		stab	dblp+1
		ldx	dblp
		ldab	dbltbl,x
		ldx	scrp
		anda	tfxb
		eora	tback
		staa	8,x
		andb	tfxb
		eorb	tback
		stab	0,x
		inx
		stx	scrp
		dec	ctr
		bne	nextl4

		lds	pstk
		cli
		bra	fwd

putcgr2
		sts	pstk
		sei
		lds	fontp
		des			;adj for pull
		ldab	#8
		ldx	scrp
nextl2
		pula
		anda	tfxb
		eora	tback
		staa	0,x
		inx
		decb
		bne	nextl2

		lds	pstk
		cli

fwd
		ldaa	ch
		inca
		cmpa	scrr
		beq	pxit
		staa	ch
		ldaa	bytes
		adda	cursorp+1
		staa	cursorp+1
		bcc	fwd2
		inc	cursorp
fwd2		jmp	setcur

bs
		ldaa	ch
		cmpa	scrl
		beq	bs1
		deca
		staa	ch
bs1
		jmp	fixcur

putcgr16
		bra	fwd

smode
		ldaa	queue_buffer
vmode
		anda	#7
		staa	scrmode
		beq	txtmode_
		cmpa	#4
		bne	chk0
txtmode_	jmp	txtmode
chk0
		anda	#3
		staa	scrmode
		ldx	screenb
		beq	chk_bad

; check for valid screenbase (>= himem and <$c000)
		ldab	screenb
		ldaa	screenb+1
		cmpb	himem
		bne	chk1
		cmpa	himem+1
chk1		bcs	chk_bad
		cmpb	max_screenb
		bne	chk2
		cmpa	max_screenb+1
chk2		bls	chk_ok
chk_bad 	ldx	#0
		stx	screenb
		clra
		clrb
		bra	vmode		;force text mode
chk_ok
		ldaa	scrmode
		asla
		staa	p1+1
		ldab	#1
		ldx	#crtp
		lsra
		beq	mod0
		ldab	#64
modx		lsrb			;get byte count
		inx			;& crt table address
		deca
		bne	modx
mod0
		stab	bytes		;bytes/char

		ldaa	0,x
		staa	colormask

		ldaa	#/page
		staa	p1
		ldx	p1
		ldx	pcaddr,x
		stx	putca		;putc routine addr
		ldx	p1
		ldx	scrmarg,x
		stx	scrr
		ldaa	hard_version	;601A?
		bpl	p601		;no
		asl	scrr		;double screen width for 601A
p601		clr	scrl
		clr	scrt

		ldx	p1
		ldx	PixShft,x	;pixels/byte & bits/pixel
		stx	Pixels

;default graph. window
		ldx	#0
		stx	GrTop
		stx	GrLeft
		ldx	#MaxGY/2
		stx	GrBot
		ldx	#MaxGX
		stx	GrRight
		stx	GrRightL
		ldaa	#3
		ldab	hard_version
		bmi	zzzz
		asr	GrRightL
		ror	GrRightL+1
		inca
zzzz		suba	scrmode
		beq	vmyy
vmxx		lsr	GrRight
		ror	GrRight+1
		deca
		bne	vmxx
vmyy

;default fg & bg colour
		ldx	p1
		ldaa	deffg,x
		staa	tfore
		staa	gfore
		ldaa	defbg,x
		staa	tback
		staa	gback
		eora	deffg,x
		staa	tfxb
		staa	gfxb
;replace mode
		clra
		jsr	gcolf

		ldaa	scrmode
		ldab	palette
		ldx	screenb
		bra	setmode

txtmode 	ldab	attribute
setmode 	int	$62
		rts

cls
		ldx	scrl
		stx	ch
		jsr	fixcur
cleos
		ldx	ch
		stx	cx1
		bsr	cleoln
		ldaa	scrl
		staa	ch
cle0
		inc	cv
		ldaa	cv
		cmpa	scrb
		beq	cle1
		jsr	fixcur0
		bsr	cleoln
		bra	cle0
cle1
		ldx	cx1
		stx	ch
		jmp	fixcur0

newline
		jsr	cr
		jmp	down

cleoln
		ldx	cursorp
		ldaa	bytes
		staa	ctr
		ldab	tback
cle3
		ldaa	scrr
		suba	ch
cle4
		stab	0,x
		inx
		deca
		bne	cle4
		dec	ctr
		bne	cle3
clerts		rts

goxy		ldab	queue_buffer+1
		subb	#32
		ldaa	queue_buffer
		suba	#32
		cmpa	scrr
		bcc	clerts			;offscreen!
		cmpb	scrb
		bcc	clerts			;offscreen!
		stab	cv
		bra	fixcurz

cr
		ldaa	scrl
fixcurz 	staa	ch
fixcur		bsr	fixcur0
setcur

;set 6845 cursor to match cursorp
		ldaa	cursorp
		staa	ctr
		ldaa	cursorp+1
		ldab	scrmode
		beq	sctext
		lsr	ctr
		rora
		lsr	ctr
		rora
		lsr	ctr
		rora
sctext
		ldab	hard_version
		bne	bza2		;skip cursor corr. for 601A
;*bza!
		adda	#1
		bcc	bza2
		inc	ctr
bza2
		ldab	#15
		jsr	set6845
		decb
		ldaa	ctr
		jsr	set6845

		ldx	kbd_load
		cpx	kbd_store
		beq	checkend
		ldaa	x
		ldx	conparms
		cmpa	#_BREAK
		beq	is_break
		cmpa	key_break,x
		bne	check_pause
is_break	int	$11		;remove from buffer
		int	$04
		ldx	conparms
check_pause	cmpa	#_PAUSE
		beq	is_pause
		cmpa	key_pause,x
		bne	checkend
is_pause	int	$11		;remove from buffer
		int	$11
checkend
		rts
fixcur0
		ldaa	cv
		tab
		asla
		asla
		aba
;		tst	scrmode   ;old, text mode now handled elsewhere
;		beq	fixc1
		clrb
		lsra
		rorb
		tst	hard_version
		bmi	fixc2		;*$280 (640) for 601A
		lsra
		rorb			;ab=cv*$140
;		bra	fixc2
;fixc1
;		 tab
;		 clra
;		 aslb
;		 rola
;		 aslb
;		 rola
;		 aslb
;		 rola			 ;ab=cv * $28
fixc2
		addb	screenb+1
		stab	cursorp+1
		adca	screenb
		staa	cursorp
;calc		x	offset (=cx * bytes )
		clr	ctr
		ldaa	ch
		ldab	scrmode
		beq	fixc4		;txt mode -> scale = 1
		asla
		asla			;*4
fixc3
		asla			;*2^(3-mode)
		rol	ctr
		incb
		cmpb	#4
		bne	fixc3
fixc4
		adda	cursorp+1
		staa	cursorp+1
		ldaa	cursorp
		adca	ctr
		staa	cursorp
		rts

down
		ldaa	cv
		inca
		cmpa	scrb
		beq	scrollu
		staa	cv
		jmp	fixcur

scrollu
		ldx	ch
		stx	cx1
		ldx	scrl
		stx	ch
scrollu0
		jsr	fixcur0
		ldx	cursorp
		stx	p1
		sts	pstk
		ldab	scrr
		subb	scrl
		stab	ctr1
		sei
scrlu1
		inc	cv
		jsr	fixcur0
		ldaa	cv
		cmpa	scrb
		beq	scrlu2
		ldaa	bytes
		staa	ctr

		lds	cursorp
		des
		ldx	p1
scrlu4
		ldab	ctr1
scrlu3
		pula
		staa	0,x
		inx
		decb
		bne	scrlu3
		dec	ctr
		bne	scrlu4

		ldx	cursorp
		stx	p1
		jmp	scrlu1
scrlu2
		lds	pstk
		cli

		ldx	p1
		stx	cursorp
		dec	cv
		jsr	cleoln

		ldx	cx1
		stx	ch
		jmp	fixcur0


set6845
		stab	crtaddr
		staa	crtdata
		rts

color					;set text color
					;queue_buffer>127 - set backgr. col
		bsr	color0
		tstb
		bpl	colorf
		staa	tback
		ldaa	tfore
colorf		staa	tfore
		eora	tback
		staa	tfxb
		rts
color0
		ldaa	scrmode
		staa	p1+1
		ldaa	#/page
		staa	p1
		ldx	p1
		ldaa	queue_buffer
		tab
		anda	colormask
		adda	modetbl,x
		staa	p1+1
		ldx	p1
		ldaa	0,x
		rts

gcol		bsr	color0

		tstb
		bpl	colorg
		staa	gback
		ldaa	gfore
colorg		staa	gfore
		eora	gback
		staa	gfxb

; logic-function masks
		ldaa	queue_buffer+1
gcolf
		eora	#$0d		;to make 0 be replace mode

		bsr	gcfun
		stab	RplOrOrn
		bsr	gcfun
		stab	NandOrn
		bsr	gcfun
		stab	And
		bsr	gcfun
		stab	RplXor
		rts
gcfun
		clrb
		lsra
		rolb
		negb
		rts

spalette
		ldaa	queue_buffer
		anda	#3
		staa	palette
		asla
		asla
		asla
		staa	queue_buffer
		ldaa	piadrb
		anda	#%11100111
		oraa	queue_buffer
		staa	piadrb
		rts

bell
		ldaa	#7
		jmp	putc		;text write char

skip		rts
;rom data

crtp
		db	0  ;color mask
		db	15
		db	3
		db	1

funtbl
		dw	skip		;0
		dw	skip		;1
		dw	skip		;2
		dw	skip		;3
		dw	color		;4
		dw	gcol		;5
		dw	spalette	;6
		dw	bell		;7
		dw	bs		;8
		dw	skip		;9
		dw	newline 	;a
		dw	skip		;b
		dw	cls		;c
		dw	cr		;d
		dw	skip		;e
		dw	skip		;f
		dw	plot		;10
		dw	skip		;11
		dw	skip		;12
		dw	skip		;13
		dw	skip		;14
		dw	fwd		;15
		dw	smode		;16
		dw	skip		;17
		dw	cleoln		;18
		dw	cleos		;19
		dw	skip		;1a
		dw	escape		;1b
		dw	skip		;1c
		dw	skip		;1d
		dw	goxy		;1e
		dw	skip		;1f

qctbl
		db	0,0,0,0,1,2,1,0
		db	0,0,0,0,0,0,0,0
		db	5,0,0,0,0,0,1,0
		db	0,0,0,1,0,0,2,0

		endp

;bit double tbl
dbltbl
		db	$00,$03,$0c,$0f
		db	$30,$33,$3c,$3f
		db	$c0,$c3,$cc,$cf
		db	$f0,$f3,$fc,$ff

;----------------------------------------------------------
; GRAPHIC FUNCTIONS
;----------------------------------------------------------

masktbl 	db	$f0,$f0,$f0,$f0,$0f,$0f,$0f,$0f        ;lo
		db	$c0,$c0,$30,$30,$0c,$0c,$03,$03        ;mi
		db	$80,$40,$20,$10,$08,$04,$02,$01        ;hi

;----------------------------------------------------------
; INT 65 - return current coordinates
; import: X - pointer to 4 bytes buffer
;----------------------------------------------------------
int_65		proc
		ldab	col
		ldaa	col+1
		stab	0,x
		staa	1,x
		ldab	row
		ldaa	row+1
		stab	2,x
		staa	3,x
		rts
		endp

;----------------------------------------------------------
; INT 66 - graphic plot command
; import: A - command: 1 - move, 2 - plot, 3 - point, 4 - circle, $80 - rel
;		0 - setcolor and plot function
;	  X - pointer to coordinate couple (x,y)
;----------------------------------------------------------
int_66		proc
		global	plot
		tsta
		bne	pl
		ldaa	1,x
		staa	queue_buffer
		ldaa	3,x
		staa	queue_buffer+1
		jmp	gcol
pl
		staa	queue_buffer
		ldx	0,x
		stx	cx
		ldx	swix
		ldx	2,x
		stx	cy

plot
		ldaa	scrmode
		bita	#3
		beq	sorry		;no plot in text modes
		ldaa	queue_buffer
		bpl	absolute
		ldaa	cx+1
		ldab	cx
		adda	col+1
		adcb	col
		staa	cx+1
		stab	cx

		ldaa	cy+1
		ldab	cy
		adda	row+1
		adcb	row
		staa	cy+1
		stab	cy

absolute	ldaa	queue_buffer
		anda	#$7F
		deca
		bne	_1
		jmp	move		;1

_1		deca
		bne	_2
		jmp	line		;2

_2		deca
		bne	_3
		jmp	point		;3

_3		deca
		bne	_4
		jmp	circle		;4

_4		deca
		bne	_5
		jmp	bar

_5		deca
		bne	_6
		jmp	disc

_6		deca
		bne	_7
;		jmp	triangle

_7		deca
		bne	_8
		jmp	shape

_8
sorry		rts
		endp

move
		ldx	cy
		stx	row
		ldx	cx
		stx	col
duh		rts

point		proc
		bsr	move
		jmp	putpixel
		endp


;void elipse ( cx, cy, a, b, clr )
;int cx, cy, a, b;
;enum color clr;
;{
;  int x, aa, bb, ca, cb, y = 0, dx, dy;
;  int ax, ay;
;
;  x = a;
;  aa = a;
;  cb = 1; ay = a;
;  bb = b;
;  ca = 1;
;
;  if (a>b) {
;    aa *= a;
;    cb = b; ay *= b;
;  }
;  if (a<b) {
;    bb *= b;
;    ca = a;
;  }
;
;  dy = aa/2;
;  dx = bb/2;
;
;  ax = 0;
;
;
;  do
;  {
;    putdot ( cx + x, cy + y, clr);
;    putdot ( cx + x, cy - y, clr);
;    putdot ( cx - x, cy - y, clr);
;    putdot ( cx - x, cy + y, clr);
;    dy += ay; /* cb * x; */
;    if (dy > aa) { y++; dy -= aa; ax+=ca; }
;    dx += ax; /* ca * y; */
;    if (dx > bb) { x--; dx -= bb; ay-=cb; }
;  } while ( (x >= 0) && ( y <= b ));
;}

disc		db	$86		;ldaa #, so set fill_flag
circle		clra			;$4F
		staa	fill_flag

		ldab	col+1
		ldaa	col
		jsr	xcnv
		stab	centrx+1
		staa	centrx
		ldx	row
		stx	centry
		lsr	centry
		ror	centry+1

		ldx	#0
		stx	yy		; yy = 0
		stx	ax		; ax = 0
		inx			; ldx  #1
		stx	ca		; ca = 1
		stx	cb		; cb = 1

		ldab	cx+1		; A
		ldaa	cx
		jsr	xcnv		; to internal
		stab	xx+1
		staa	xx		; xx = A
		bne	duh		; A>255, get out!
		stab	aa+1
		staa	aa		; aa = A
		stab	ay+1
		staa	ay		; ay = A

		ldab	cy+1		; B
		ldaa	cy
		lsra
		rorb			; to internal
		stab	bb+1		; bb = B
		staa	bb
		bne	duh		; B>255, go out!

; ( (a,b) = bb )
		cmpa	aa
		bne	cne1
		cmpb	aa+1
cne1		beq	circle0
		bcc	cne2		;A<B ?

;    aa *= aa;
;    cb = bb; ay *= bb; 		;A>B
		ldaa	aa+1		;aa<>0??
		tab
		int	$28		;square
		staa	aa+1
		stab	aa		;aa = lo(aa)*lo(aa);
		ldaa	ay+1
		ldab	bb+1
		int	$28
		staa	ay+1
		stab	ay		;ay = lo(ay)*lo(bb)
		ldx	bb
		stx	cb		;cb=bb
		bra	circle0

cne2					;A<B
;  if (a<b) {
;    bb *= b;
;    ca = a;
		ldaa	bb+1
		tab
		int	$28
		staa	bb+1
		stab	bb		;bb = lo(bb)*lo(bb)
		ldx	aa
		stx	ca		;ca = A

circle0

		ldx	aa
		stx	dyc
		lsr	dyc
		ror	dyc+1		; dy = aa / 2

		ldx	bb
		stx	dxc
		lsr	dxc
		ror	dxc+1		 ; dx = bb / 2

		ldx	#$ffff
		stx	old_xx
		stx	old_yy

circle1
		ldx	yy		; y step
		cpx	old_yy
		bne	circle3 	; yes, plot
		tst	fill_flag
		bne	circle4_	; no Y move, skip fill

		ldx	xx		; x step
		cpx	old_xx
		bne	circle3 	; yes, plot

circle4_	jmp	circle4 	; no, skip putpixels

circle3 	ldaa	centrx+1	; cx - xx, cy + yy
		ldab	centrx
		suba	xx+1
		sbcb	xx
		staa	x0+1
		stab	x0

		ldaa	centry+1
		ldab	centry
		adda	yy+1
		adcb	yy
		staa	y0+1
		stab	y0

		tst	fill_flag
		beq	disc1		; no fill, so do putpixels

; hline cx-xx to cx+xx at cy+yy
		ldx	xx
		stx	dx
		sec
		rol	dx+1
		rol	dx		;*2+1
		jsr	hline
		jmp	disc1a

disc1		jsr	calcintad
		jsr	pixel
;-
disc1a
		ldx	yy		; avoid putpixel second time, if y is 0
		beq	circle3a
		ldaa	centry+1	; cx - xx, cy - yy
		ldab	centry
		suba	yy+1
		sbcb	yy
		staa	y0+1
		stab	y0

		tst	fill_flag
		beq	disc2		; no fill, so do putpixels

; hline cx-xx to cx+xx at cy-yy
; dx already okay
		jsr	hline
		jmp	circle4 	; done fill
disc2
		jsr	calcintad
		jsr	pixel
circle3a
		tst	fill_flag
		bne	circle4
		ldx	xx		; avoid putpixel second time, if x is 0
		beq	circle3b
		ldaa	centrx+1	; cx + xx, cy - yy
		ldab	centrx
		adda	xx+1
		adcb	xx
		staa	x0+1
		stab	x0
		jsr	calcintad
		jsr	pixel
;-
		ldx	yy		; avoid putpixel second time, if y is 0
		beq	circle3b
		ldaa	centry+1	; cx + xx, cy + yy
		ldab	centry
		adda	yy+1
		adcb	yy
		staa	y0+1
		stab	y0
		jsr	calcintad
		jsr	pixel
circle3b
;-
circle4
		ldx	xx
		stx	old_xx
		ldx	yy
		stx	old_yy

		ldaa	dyc+1		 ; dy += ay
		ldab	dyc
		adda	ay+1
		adcb	ay
		staa	dyc+1
		stab	dyc
		suba	aa+1
		sbcb	aa

		bcs	circle5 	;<?
		bne	circle55
		tsta
		beq	circle5 	;=?

circle55	staa	dyc+1
		stab	dyc
		inc	yy+1		; y++
		bne	circle59
		inc	yy
circle59	ldaa	ca+1
		ldab	ca
		adda	ax+1
		adcb	ax
		staa	ax+1
		stab	ax


circle5
		ldaa	dxc+1		 ; dx += ax
		ldab	dxc
		adda	ax+1
		adcb	ax
		staa	dxc+1
		stab	dxc
		suba	bb+1
		sbcb	bb
		bcs	circle6 	;<?
		bne	circle66
		tsta
		beq	circle6 	;=?
circle66
		staa	dxc+1
		stab	dxc
		ldx	xx		; x--
		dex
		stx	xx
		ldaa	ay+1
		ldab	ay
		suba	cb+1
		sbcb	cb
		staa	ay+1
		stab	ay		; ay -= cb

circle6 	ldx	xx
		bpl	circle7

		rts
circle7 	jmp	circle1

;*******************************
xcnv				;convert X coordinate (b,a) into physical
				;value (pixel offset)
		staa	GrTmp

		ldaa	scrmode
xcnvlp		cmpa	#3
		beq	xcnve
		asr	GrTmp
		rorb
		inca
		bra	xcnvlp
xcnve		ldaa	hard_version
		bmi	cnv601A
		asr	GrTmp
		rorb
cnv601A 	ldaa	GrTmp
		rts

;line from row, col to cx,cy
line
;		jsr	calcbyad

;convert X to physical
		ldab	col+1
		ldaa	col
		bsr	xcnv
		stab	x0+1
		staa	x0

;convert Y to physical
		ldab	row+1	;old y coord.
		ldaa	row
		asra
		rorb
		stab	y0+1
		staa	y0

		jsr	calcintad

;new X
		ldab	cx+1
		ldaa	cx
		stab	col+1
		staa	col	;set new X as current
		bsr	xcnv
		subb	x0+1
		sbca	x0
		staa	XDir
		bpl	XAbs
;neg dx
		comb
		coma
		addb	#1
		adca	#0
XAbs
		stab	dx+1
		staa	dx

;new Y
		ldab	cy+1
		ldaa	cy
		stab	row+1	;store as currrent
		staa	row
		asra
		rorb		;to physical
		subb	y0+1
		sbca	y0	;delta
		staa	YDir	;direction flag
		bpl	YAbs
;negate
		comb
		coma
		addb	#1
		adca	#0
YAbs
		stab	dy+1
		staa	dy

		addb	dx+1
		adca	dx		;step count
		incb			;correct for decrement
		stab	count+1
		inca			;...
		staa	count

		ldab	dy+1
		ldaa	dy
		cmpa	dx
		bne	dxlo
		cmpb	dx+1
dxlo		bcc	YLine	;dy>=dx

;XLine
		ldab	dx+1
		ldaa	dx
		comb
		coma
		addb	#1
		adca	#0
XL1		stab	er+1
		staa	er
XL2		jsr	pixel
		bsr	XInc
		beq	fin
		ldab	er+1
		ldaa	er
		addb	dy+1
		adca	dy
		bcc	XL1
		subb	dx+1
		sbca	dx
		stab	er+1
		staa	er
		bsr	YInc
		bne	XL2
fin
		rts

YLine
		ldab	dy+1
		ldaa	dy
		comb
		coma
		addb	#1
		adca	#0
YL1		stab	er+1
		staa	er
YL2		jsr	pixel
		bsr	YInc
		beq	fin
		ldab	er+1
		ldaa	er
		addb	dx+1
		adca	dx
		bcc	YL1
		subb	dy+1
		sbca	dy
		stab	er+1
		staa	er
		bsr	XInc
		bne	YL2
		bra	fin

;Increment X pos by +/- 1 (acc to XDir);
;return: ZFlag = 1 - zero count reached
XInc
		dec	count+1
		bne	XI1
		dec	count
		bne	XI1
		rts
XI1
		ldaa	XDir
		bmi	XNeg
;positive X move
		ldab	x0+1
		ldaa	x0
		addb	#1
		adca	#0
		stab	x0+1
		staa	x0
		jmp	calcintad
;negative X move
XNeg

		ldab	x0+1
		ldaa	x0
		subb	#1
		sbca	#0
		stab	x0+1
		staa	x0
		jmp	calcintad

;Increment Y pos by +/- 1 (acc to XDir);
;return: ZFlag = 1 - zero count reached
YInc
		dec	count+1
		bne	YI1
		dec	count
		bne	YI1
		rts
YI1
		ldaa	YDir
		bmi	YNeg

;positive Y move
		ldab	y0+1
		ldaa	y0
		addb	#1
		adca	#0
		stab	y0+1
		staa	y0
		jmp	calcintad
;negative Y move
YNeg

		ldab	y0+1
		ldaa	y0
		subb	#1
		sbca	#0
		stab	y0+1
		staa	y0
		jmp	calcintad
;*******************************

bar		proc
		ldab	col+1
		ldaa	col
		cmpa	cx
		bne	bar1
		cmpb	cx+1
bar1		bcs	bar2	;okay, col<cx

; swap ab & cx
		ldx	col	;x=ab
		ldab	cx+1
		ldaa	cx	;ab=cx
		stx	cx	;cx=x

bar2
		jsr	xcnv
		stab	x0+1
		staa	x0
		ldab	cx+1
		ldaa	cx
		jsr	xcnv
		subb	x0+1
		sbca	x0	;get pixel count
		incb
		bne	*+3
		inca
		stab	dx+1
		staa	dx	;store pix. cnt. in dx

		ldab	row+1
		ldaa	row
		cmpa	cy
		bne	bar3
		cmpb	cy+1
bar3		bcs	bar4	;okay, row<cy

; swap row & cy
		ldx	cy
		stab	cy+1
		staa	cy
;
		stx	y0

		asr	y0		;to physical
		ror	y0+1
		bra	bar5		;a,b still intact

bar4
		asra
		rorb
		stab	y0+1
		staa	y0

		ldab	cy+1
		ldaa	cy
bar5		asra
		rorb
		stab	dy+1
		staa	dy

; go ahead
		bsr	HlineXClip
		beq	brts		;offscreen!

barlp
		bsr	hline0
		ldx	y0
		cpx	dy
		beq	brts
		inx
		stx	y0
		bra	barlp

brts		rts
		endp


;adjust x0 & dx for Hline to be onscreen
;return ZF=1 if the whole line is offscreen
HlineXClip	proc
;left margin check
		ldab	x0+1
		ldaa	x0
		bpl	HlcPos

		coma
		comb
		sec
		adcb	dx+1
		adca	dx
		bmi	HlOffscr	;-x0>dx
		stab	dx+1
		staa	dx
		oraa	dx+1
		beq	HlOffscr	;-x0=dx

		clrb
		clra
		stab	x0+1
		staa	x0		;0->x0
HlcPos
;right margin check
		cmpa	GrRight
		bne	hlc2
		cmpb	GrRight+1
hlc2		bcc	HlOffscr
		addb	dx+1
		adca	dx		;right end of line
		subb	GrRight+1
		sbca	GrRight
		bmi	hlcOkay
		coma
		comb
		sec
		adcb	dx+1	;(dx)-(a,b)
		adca	dx
hlcOkay 	ldaa	#1	;zf=0
		rts
HlOffscr	clra
		rts
		endp
; horizontal line from x0,y0  to x0+dx,y0 (intern. coords)
; (internal use by bar, triangle & disc)
hline		bsr	HlineXClip
		beq	hlrts
hline0
		ldx	dx
		stx	er
		beq	hlrts
		jsr	calcintad
		ldx	bytead
		cpx	#DustBin	;Y clip? (X clip should not occur!)
		beq	hlrts		;Clip!

		ldab	mask
		bmi	dobytes0	;byte boundary?
leftbits	jsr	pixel
		ldaa	mask
		ldab	shiftcnt
doshft		lsra
		decb
		bne	doshft
		staa	mask
		bcs	dobytes
;decr. count
		ldx	er
		dex
		stx	er
		bne	leftbits	;no, do more
hlrts		rts			;done

dobytes
		ldab	bytead+1	;next byte
		ldaa	bytead		;on the same row
		addb	#8
		adca	#0
		stab	bytead+1
		staa	bytead
dobytes0
; more full bytes?
		ldaa	er
		bne	fullb
		ldaa	er+1
		cmpa	Pixels
		bcc	fullb

;no, do right bits & quit
		clra			;trick to make
		ldab	shiftcnt	;the correct mask
mskshft 	sec			;for the 1st pixel
		rora			;in a byte
		decb
		bne	mskshft

		bra	RBits
rightbits
		ldaa	mask
		ldab	shiftcnt
doshftr 	lsra
		decb
		bne	doshftr

RBits		staa	mask
		jsr	pixel
		ldx	er
		dex
		stx	er	;=0?
		bne	rightbits	;no, do more
		rts			;done

;do full bytes
fullb		ldaa	#$ff
		staa	mask
		jsr	pixel
		ldab	er+1
		ldaa	er
		subb	Pixels
		sbca	#0
		stab	er+1
		staa	er
		oraa	er+1
		bne	dobytes 	;go for more bytes/bits
		rts

putpixel	bsr	calcbyad
pixel
		ldx	bytead
pixel0		ldaa	gfore
		staa	PicByte

; put bit(s) of PicByte into (0,x). Bits to be changed are
; defined in mask (1s changed, 0s unchanged).
; combine with original picrute defined by: RplXor, And, NandOrn,
; RplOrOrn (see gcol - set graph. coolor & function)
PutByte
		ldaa	PicByte
		oraa	RplXor
		anda	0,x
		staa	GrTmp
		ldaa	PicByte
		anda	And
		oraa	NandOrn
		eora	GrTmp

		tst	RplOrOrn
		bne	PBSkip
		eora	0,x
PBSkip
		anda	mask
		eora	0,x
		staa	0,x
		rts

;calculate graph. pixel addr. x0, y0 in internal coords
calcintad
		ldab	y0
		ldaa	y0+1
		psha
		pshb

		ldaa	#3
		suba	scrmode
		beq	CiaDir
		staa	GrTmp
		ldab	x0+1
		ldaa	x0
CiaLp		aslb
		rola
		dec	GrTmp
		bne	CiaLp
		bra	calcbt0

CiaDir
		ldab	x0+1
		ldaa	x0
		bra	calcbt0

; calc. graph. pixel addr. col, row absolute coords.
calcbyad

		ldab	row
		ldaa	row+1
		asrb
		rora
		psha
		pshb

		ldab	col+1
		ldaa	col

		tst	hard_version
		bmi	minus	;601A
		asra
		rorb
minus
calcbt0
;do clip
		cmpa	GrRightL
		bne	calcby3
		cmpb	GrRightL+1
calcby3 	bcc	ClipIt

		stab	bytead+1
		staa	bytead
		andb	#7

		ldaa	scrmode
		asla
		asla
		asla
		aba
		staa	svx+1
		ldaa	#/masktbl-8
		staa	svx
		ldx	svx
		ldaa	masktbl-8,x
		staa	mask
		eorb	bytead+1
		stab	bytead+1

;row offset
		pulb
		pula

		cmpb	GrBot
		bne	cla1
		cmpa	GrBot+1
cla1		bcc	ClipIt2

		psha
		anda	#$f8
		tab
		lsra
		lsra
		aba		;A=A*5/4
		rora		;/8 (could be lsra, just in case)
		pulb
		aslb
		andb	#$0e
		tst	hard_version
		bmi	x601A
		aslb
		lsra
		rorb
x601A		lsra
		rorb
		addb	screenb+1
		adca	screenb
;		stab	linead+1
;		staa	linead

		addb	bytead+1
		adca	bytead
		stab	bytead+1
		staa	bytead

		ldaa	#1		;ZF=0
		rts

ClipIt		pula	;throw away rubbish
		pula
ClipIt2 	ldx	#DustBin
		stx	bytead	;clip
		rts			;ZF=0  (DustBin<>0)

;---------------
shape		proc
; shape structute: 1 word size (in bytes), followed by them
; each byte: bit7 - 0 = pen up, 1 = pen down
;  direct. bits654 - 0 = +x, 2 = +y, 4 = -x, 6 = -y
;  length bits3210 - 0 = 1 step, F = 16 steps

		ldx	#DustBin
		stx	oldptr
		clr	oldmask

		ldx	cx
		ldx	0,x
		stx	shape_length
		ldx	cx
		inx
		inx
		stx	shape_ptr
		ldaa	cy+1
		staa	shape_scale	;bits 654 - additional rotation
					;bits 3210 - scale factor
loopb
		ldx	shape_length
		bne	more
		rts
more		dex
		stx	shape_length

		ldx	shape_ptr
		ldaa	0,x
		anda	#%00001111	;steps
		inca
		staa	shape_steps

		ldab	shape_scale
		andb	#%00001111	;scale
		incb

		clra
loopm		lsrb
		bcc	skip
		adda	shape_steps
skip		asl	shape_steps
		tstb
		bne	loopm
		staa	shape_steps

loopp		ldx	shape_ptr
		ldab	0,x
		andb	#%01110000
		addb	shape_scale	;mind no carry from b3 to b4
		andb	#%01110000	;dir

; X and Y increments depend on the bits of direction in the following way:
;    direction bits ---->  000	001  010  011  100  101  110  111
;    col increment  ---->   +	 +	   -	-    -	       +
;    row increment  ---->	 +    +    +	     -	  -    -

		ldx	row
		bitb	#%00110000
		beq	row_ok		; direction is 000 or 100
		bitb	#%01000000
		beq	inc_row 	; direction is 001 or 010 or 011
		dex
		db	$c1		;cmpb # <=> skip 1
inc_row 	inx
		stx	row
row_ok
		addb	#%00100000	; make things like row cases
		ldx	col
		bitb	#%00110000
		beq	col_ok
		bitb	#%01000000
		beq	inc_col
		dex
		db	$c1		;cmpb # <=> skip 1
inc_col 	inx
		stx	col
col_ok
		ldx	shape_ptr
		ldaa	0,x
		bpl	no_draw

		jsr	calcbyad
		ldx	bytead
		ldaa	mask
		cpx	oldptr
		bne	differ
		cmpa	oldmask
		beq	no_draw
differ		staa	oldmask
		stx	oldptr

		jsr	pixel
no_draw 	dec	shape_steps
		bne	loopp
		ldx	shape_ptr
		inx
		stx	shape_ptr
		jmp	loopb

		endp

;-----------------------------------------------------------
; MUSIC FUNCTIONS
;-----------------------------------------------------------
;-----------------------------------------------------------
; int 6E - player
; import X - pointer to music - 3-byte structure : note, duration, pause
;						   units 7 msec
;				1-byte structure : FE-F8 tember, FF - end
;-----------------------------------------------------------

int_6E		proc
		sei
		ldaa	#1
		staa	tmbr
		stx	np
pp
		ldx	np
		ldaa	x
		psha
		ldaa	1,x
		bsr	bzz
		pula
		cpx	#0
		beq	skip1
		ldab	tmbr
		jsr	int_6F
skip1		ldx	np
		ldaa	2,x
		bsr	bzz
		cpx	#0
		beq	skip2
		ldaa	#0
		ldab	#1
		jsr	int_6F
skip2		ldx	np
		inx
		inx
contloop	inx
		ldaa	0,x
		cmpa	#$f8
		bcs	cont
		coma
		anda	#7
		beq	fin
		staa	tmbr
		bra	contloop

cont		stx	np
		jmp	pp

bzz
		clrb
		staa	svx+1
		stab	svx
		asla
		rolb
		asla
		rolb
		asla
		rolb
		adda	svx+1
		adcb	svx
		lsrb
		rora
		staa	svx+1
		stab	svx
		ldx	svx
fin		rts

		endp

;-----------------------------------------------------------
; INT 6F - play subroutine
; import: A - note: 0 - pause, 1-72
;	  B - tembre: 1-7
;	  X - duration in units of 1.536 msec
;-----------------------------------------------------------
;
; Play subroutine.
; Entry:
;   a - note (0-pause, 1..72)
;   b - tembre (1..7)
;   x - length (1..65536 in 1.536 msec increments)
;   interrupts msut be disabled !!!
;
; Exit: registers garbled, location $10-$15 garbled
;

int_6F		proc
		sei
		stx	tmp
		psha
		pshb
		ldab	tmp
		ldaa	tmp+1
		jsr	time_adjust
		pulb
		pula
		psha
		pshb			;save regs
		asla
		staa	mus_ptr+1	;make ptr into period table
		ldaa	#/PTbl
		staa	mus_ptr
		ldx	mus_ptr
		ldab	PTbl,x		;get period
		ldaa	PTbl+1,x	;get period correction
		ldx	tmp
		stab	Per1
		staa	Corr
		adda	#7
		staa	CorrB
		pulb			;Tembre
		ldaa	Per1
tshift		lsra			;shift B times to calc 0-wave
		decb
		bne	tshift
		tsta
		bne	*+3
		inca
		tab
		ldaa	per1	       ;calc 1-wave
		sba
		staa	per1
		stab	per2
		ldaa	piacrb	      ;make CRB constants
		staa	Pia1	       ;for 0-wave
		staa	Pia2	       ;and 1-wave
		pulb
		tstb
		beq	ppp
		eora	#8
		staa	Pia2
ppp		clrb

;do play
y3
		ldaa	Pia2		;C 3
		staa	piacrb		;C 5-8
		ldaa	Per1		;C 3-11
play1
		jsr	delay		;P 24
		subb	#8		;P 2
		bcc	px1		;P 4-6
		dex			;P 4-10
		bne	y1		;P 4-14
		rts
px1
		inx			;P 4-10
		dex			;P 4-14
y1
		deca			;P 2-16
		nop			;P 2-18
		nop			;P 2-20
		bne	play1		;P 4-24 + delay = 48

		ldaa	Pia1		;C 3-14
		staa	piacrb		;C 5-19
		ldaa	Per2		;C 3-22
		nop			;C 2-24
play2
		jsr	delay
		subb	#8
		bcc	px2
		dex
		bne	y2
		rts
px2
		inx
		dex
y2
		deca
		bne	play2		;P 24

		ldaa	Corr		;C 3-27
z1		deca			;p 2
		bne	z1		;p 4-6

		subb	CorrB		;C 3-30
		bcc	x3		;C 4-34
		dex			;C 4-38
		bne	y3		;C 4-42 = 7 * 6
		rts
x3
		nop			;C 2-36
		nop			;C 2-38
		bra	y3		;C 4-42

delay		inx	;4
		dex	;4
		nop	;2
		rts	;5 + 9(jsr) = 24

; Time for one period total
; 24 * (Per1+Per2) + 6 * Corr + 42 = 6 * (4*P + Corr + 7)


PTbl
		db	2,2		; pause
		db	252,7		;-29
		db	238,6		;-28
		db	225,3		;-27
		db	212,6		;-26
		db	200,6		;-25
		db	189,4		;-24
		db	178,7		;-23
		db	168,7		;-22
		db	159,3		;-21
		db	150,4		;-20
		db	141,8		;-19
		db	133,8		;-18
		db	126,4		;-17
		db	119,3		;-16
		db	112,6		;-15
		db	106,3		;-14
		db	100,4		;-13
		db	 94,7		;-12
		db	 89,4		;-11
		db	 84,4		;-10
		db	 79,6		;-9
		db	 75,2		;-8
		db	 71,1		;-7
		db	 67,1		;-6
		db	 63,3		;-5
		db	 59,6		;-4
		db	 56,3		;-3
		db	 53,2		;-2
		db	 50,2		;-1
		db	 47,4		;0
		db	 44,7		;1
		db	 42,2		;2
		db	 39,8		;3
		db	 37,6		;4
		db	 35,5		;5
		db	 33,5		;6
		db	 31,6		;7
		db	 29,8		;8
		db	 28,2		;9
		db	 26,6		;10
		db	 25,2		;11
		db	 23,6		;12
		db	 22,4		;13
		db	 21,2		;14
		db	 19,8		;15
		db	 18,7		;16
		db	 17,7		;17
		db	 16,7		;18
		db	 15,7		;19
		db	 14,8		;20
		db	 14,2		;21
		db	 13,3		;22
		db	 12,5		;23
		db	 11,8		;24
		db	 11,2		;25
		db	 10,5		;26
		db	 10,1		;27
		db	  9,4		;28
		db	  8,8		;29
		db	  8,4		;30
		db	  7,8		;31
		db	  7,5		;32
		db	  7,1		;33
		db	  6,6		;34
		db	  6,3		;35
		db	  5,8		;36
		db	  5,6		;37
		db	  5,3		;38
		db	  5,1		;39
		db	  4,7		;40
		db	  4,4		;41
		db	  4,2		;42
		db	  4,1		;43
		db	  3,7		;44
		db	  3,5		;45
		db	  3,4		;46
		db	  3,2		;47
		db	  3,1		;48
		db	  2,7		;49
		db	  2,6		;50
		db	  2,5		;51
		db	  2,4		;52
		db	  2,3		;53
		db	  2,2		;54
		db	  2,1		;55

		endp

;---------------
time_adjust	proc
					;BA * 1.536 msec; assume 1.5625
		lsrb			;divide by 32
		rora			;BA * 50 msec
		lsrb
		rora
		lsrb
		rora
		lsrb
		rora
		lsrb
		rora
		adca	#0
		adcb	#0

loop1		suba	#20
		sbcb	#0
		bcs	break1
		inc	seconds
		bra	loop1
break1		adda	#20
		ldab	hundreds
loop2		addb	#5
		deca
		bne	loop2
		stab	hundreds
		subb	#100
		bcs	cont2
		stab	hundreds
		inc	seconds
cont2
		ldaa	seconds
		suba	#60
		bcs	exit
		staa	seconds
		inc	minutes

		ldaa	minutes
		cmpa	#60
		bcs	exit
		clr	minutes
		inc	hours

		ldaa	hours
		cmpa	#24
		bcs	exit
		clr	hours
		inc	day

exit		rts

		endp
;-----------------------------------------------------------


;---------------------------------------
; CASSETTE SUPPORT
;---------------------------------------
cassette	proc
		global	int1A, int1B
; X - buffer
; BA - length

int1A		sei			; cload
		ldx	#0		;if error
		stx	swib
		ldx	#x1
		bsr	lsync
int1Aloop0	bsr	recv
		bne	error
		staa	x
		inx
		cpx	#x1+4
		bne	int1Aloop0

		ldx	x1
		stx	swix
int1Aloop	bsr	recv
		bne	error
		staa	x
		inx
		cpx	x2
		bne	int1Aloop

		ldaa	x2+1
		ldab	x2
		suba	x1+1
		sbcb	x1
		stab	swib
		staa	swia
error		rts

recv		ldab	#$FF
		stab	allcap
		ldaa	#$80
re1		bsr	cbit
		rora
		bcc	re1
cbit		bsr	sync
		bcc	sync
		com	allcap
sync		psha
sy4		ldaa	piadrb
		bpl	sy4
		ldab	#22
		clc
sy2		decb
		beq	sy3
		ldaa	piadrb
		bmi	sy2
		com	allcap
		jsr	wait1
sy3		pula
		rts

lsync
		sei
		ldaa	#100
lsy1		bsr	sync
		bcc	lsync
		deca
		bne	lsy1
ls1		bsr	sync
		bcs	ls1
		rts

int1B		sei			;csave
		stx	x1
		adda	x1+1
		adcb	x1
		staa	x2+1
		stab	x2

lead		ldx	#10000
le1		sec
		bsr	trbitc
		dex
		bne	le1
		clc
		bsr	trbitc

		ldx	#x1
int1Bloop0	ldaa	x
		bsr	transm
		inx
		cpx	#x1+4
		bne	int1Bloop0

		ldx	x1
int1Bloop	ldaa	x
		bsr	transm
		inx
		cpx	x2
		bne	int1Bloop
		rts

transm		ldab	#$ff
		stab	allcap
		ldab	#8
trn1		rora
		bsr	trbitc
		decb
		bne	trn1
		lsr	allcap
trbitc		pshb
		bsr	trclk
		bcc	tra1
		com	allcap
		db	$85
trclk		pshb
		ldab	piadrb
		orab	#$40
		stab	piadrb
tra1		jsr	wait1
		ldab	piadrb
		andb	#$BF
		stab	piadrb
		bsr	wait1
		pulb
		rts

wait1		ldab	#20
wa1		decb
		bne	wa1
		ldab	allcap
		rts
		endp

;---------------------------------------
; GETLINE
;---------------------------------------
int21		proc
		global	int67
		clra			; п░о╖и▓ане на ░ед
		clc
		bra	getln_ok

int67					;edit_line
		sec
getln_ok	ror	editflg
		stx	buf_beg
		addb	buf_beg+1
		stab	buf_max+1
		ldab	#0		;не пип ╖е пл┐▒!
		adcb	buf_beg
		stab	buf_max

		ldx	buf_beg
		tsta
		beq	getln_ok1	;don't display
getln_ok0	tst	x
		beq	getln_ok1
		inx
		cpx	buf_max
		bne	getln_ok0
getln_ok1	stx	cursor
		stx	buf_end
getln_ok2	tst	x
		beq	getln_ok3
		cpx	buf_max
		beq	getln_ok3
		inx
		bra	getln_ok2
getln_ok3	clr	x
		cpx	buf_max
		beq	getln_ok4
		inx
		bra	getln_ok3
getln_ok4
		clr	insert_mode
		ldx	conparms
		ldx	cur_replace,x
		stx	cursor_start
		int	$14
		stab	line_cv
		staa	line_ch
getln0
		ldab	line_cv
		ldaa	line_ch
		int	$15
		ldx	buf_beg
getln01 	cpx	cursor
		bne	getln02
		int	$14
		stab	cursor_v
		staa	cursor_h
		ldx	cursor
getln02 	cpx	buf_end
		beq	getln04
		ldaa	x
		cmpa	#' '
		bcc	getln03

		ldaa	#27		;escape
		tst	editflg
		bmi	getln03a
		ldaa	#'^'
getln03a	int	$22

		ldaa	x
		tst	editflg
		bmi	getln03
		adda	#'@'

getln03 	int	$22
		inx
		bra	getln01
getln04
		cpx	buf_max
		beq	getln05
		ldaa	#' '
		int	$22
		inx
		bra	getln04
;		ldaa	#24
;		int	$22
getln05 	ldaa	cursor_h
		ldab	cursor_v
		int	$15
;get_key
		int	$20
		ldx	#commands
getln1		cmpa	x
		bne	getln2
		ldab	1,x
		stab	tmpx+1
		ldab	#/commands_end
		stab	tmpx
		ldx	tmpx
		jmp	commands_end,x

getln2		inx
		inx
		cpx	#commands_end
		bne	getln1

		ldx	cursor
		cpx	buf_max
		bne	getln7
		ldaa	#7
		int	$22
getln0_ 	bra	getln0
getln7
		cmpa	#$c0
		bcs	getln70
		tst	editflg
		bpl	getln0_ 	;Fkeys not collected in getline mode
		jmp	enter		;Fkeys terminate in editline mode

getln70 	psha
		tst	insert_mode
		beq	getln6
;do insert
		ldx	buf_end
		cpx	buf_max
		beq	getln71
		inx
		stx	buf_end
		ldx	buf_max
getln71 	dex
		ldaa	x
		inx
		staa	x
		dex
		cpx	cursor
		bne	getln71
getln6		pula
		staa	x
		cpx	buf_end
		tpa
		inx
		stx	cursor
		tap
		bne	getln5
		stx	buf_end
getln5		jmp	getln0

;---------------
commands
		db	_ENTER, enter - commands_end
		db	_INSERT, insert - commands_end
		db	_LEFT, left - commands_end
		db	_RIGHT, right - commands_end
		db	_HOME, khome - commands_end
		db	_END, end - commands_end
		db	_BACKSPACE, backspace - commands_end
		db	_ESCAPE, escape - commands_end
commands_end

enter		tst	editflg
		bpl	enter0
		staa	swib

enter0		ldx	buf_end
		clr	x
		ldaa	buf_end+1
		suba	buf_beg+1
		jmp	rtswia

insert
		ldx	conparms
		com	insert_mode
		beq	insert1
		inx
		inx
insert1 	ldx	cur_replace,x
		stx	cursor_start
		bra	exit1

left		ldx	cursor
		cpx	buf_beg
		beq	left1
		dex
left1		bra	exit

right		ldx	cursor
		cpx	buf_end
		beq	right1
		inx
right1		bra	exit

khome		ldx	buf_beg
		bra	exit

end		ldx	buf_end
exit		stx	cursor
exit1		jmp	getln0

backspace	ldx	cursor
		cpx	buf_end
		bne	delete
		cpx	buf_beg
		beq	delete
		dex
		stx	cursor
delete		inx
		ldaa	x
		dex
		staa	x
		inx
		cpx	buf_max
		bne	delete
		ldx	buf_end
		cpx	buf_beg
		beq	delete1
		dex
		stx	buf_end
delete1 	bra	exit1

escape		ldx	buf_beg
		cpx	buf_end
		bne	escape1
escape0 	tst	x
		beq	escape1
		inx
		cpx	buf_max
		bne	escape0
escape1
		stx	buf_end
		bra	exit

		endp

;---------------------------------------
; WRITE DECIMAL WORD
;---------------------------------------
int24		proc
		ldx	swix		; ин▓е░║п▓ за пе╖а▓ане на д│ма
		stx	x1		; в де▒е▓и╖ен ┤о░ма▓
		ldab	#4
		ldx	#dectbl
		clr	x2+1
prdec0
		ldaa	#'0'
		staa	x2
prdec1		ldaa	x1
		psha
		ldaa	x1+1
		psha
		suba	1,x
		staa	x1+1
		ldaa	x1
		sbca	0,x
		staa	x1
		bcc	prdec2
		pula
		staa	x1+1
		pula
		staa	x1
		ldaa	x2
		tst	x2+1
		beq	prdec3
		int	$22	       ;putchar
prdec3		inx
		inx
		decb
		bpl	prdec0
		tst	x2+1
		bne	prdec4
		int	$22
prdec4		rts
prdec2		inc	x2
		inc	x2+1
		ins
		ins
		bra	prdec1

dectbl		dw	10000,1000,100,10,1

		endp

;---------------------------------------
; WRITE HEX BYTE
;---------------------------------------

int25		proc			; ин▓е░║п▓ за пе╖а▓ане на бай▓ в
prhex2		psha			; в ╕е▒▓наде▒е▓и╖ен ┤о░ма▓
		lsra
		lsra
		lsra
		lsra
		bsr	prhex1
		pula
prhex1		anda	#$f
		oraa	#$30
		cmpa	#$3a
		bcs	prhexz
		adda	#7
prhexz		int	$22
		rts
		endp


;-----------------------------------------------------------
; INT 6D - get max screen col & row   in A and B
;-----------------------------------------------------------
int_6D		proc
		ldx	#scrmarg
		ldaa	scrmode
		beq	break
loop		inx
		inx
		deca
		bne	loop
break		ldab	1,x
		ldaa	0,x
		stab	swib
		ldab	scrmode
		andb	#3
		beq	ok
		tst	hard_version
		bpl	ok
		asla
ok		staa	swia
		rts
		endp

;-----------------------------------------------------------

		list	on
		checksum
		ds	$D800 - *
		list	off
		include font.inc
		end

