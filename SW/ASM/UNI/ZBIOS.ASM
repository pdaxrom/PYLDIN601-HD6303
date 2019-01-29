; ***********************************************************
; *							    *
; *	      ОПЕРАЦИОННА СИСТЕМА    U n i D O S	    *
; *	    за персонален микрокомпютър ПЪЛДИН 601 A	    *
; *							    *
; *    Copyright (C) 1988  НИПЛ "Програмно осигуряване"     *
; *							    *
; *		 (C) 1988  Иво Найденов НЕНОВ		    *
; *		 (C) 1988  Орлин Димитров ШОПОВ 	    *
; *							    *
; ***********************************************************
; *							    *
; *		  Basic Input/Output System		    *
; *		  Version 2.50 / 01-Mar-1990		    *
; *							    *
; ***********************************************************
;		list	off

; ПРЕДУПРЕЖДЕНИЕ:
; Текста на операционната система се дава само за справка.
; Всяко директно обръщение към кода или модифициране на
; променливите на операционната система нарушава концепцията
; за съвместимост с различни версии. НИПЛ "Програмно осигуряване"
; си запазва правото да прави промени в кода и променливите на
; операционната система с цел подобрение на функционирането.
; Не се поема никаква отговорност за несъвместимост на програмни
; продукти, неспазили протокола за използване на операционната
; система с бъдещи версии.
; Обръщенията към операционната система следва да се извършват
; по протокола описан в ръководството за потребителя.

;-----------------------------------------------------------

		include ../../DEVMAP.INC
		include MEMORY.INC

; Upper half of RAM/ROM used for pages
MEMPAGE_HI	equ	$10

;---------------
; RAM work area locations:
swihndl_x	equ	$2A

		list	on
		section $ED50

;---------------------------- Keyboard ---------------------
kbd_temp	ds	2

;---------------------------- WriteChar --------------------
curaddr 	ds	2
altaddr 	ds	2
queuelen	ds	1
queueptr	ds	2
queuebuf	ds	3
scrtmp		ds	1
scrtmpx 	ds	2
putchar_x	ds	2

;---------------------------- Floppy -----------------------
recalib_flg	ds	1
mcounter	ds	1
tc		ds	1
olddrive	ds	1
track_A 	ds	1
track_B 	ds	1
drive		ds	1
track		ds	1
head		ds	1
sector		ds	1
buffer		ds	2
retcode 	ds	1
headdrive	ds	1
transfer_buff	ds	9
counter 	ds	2
retry		ds	1
double_step	ds	1

;---------------------------- Pseudo RS --------------------
allcap		ds	1

;---------------------------- Getline ----------------------
maxb		ds	1

		error	(*-1)/$ED80
		ends
;		list	off

;***********************************************************

		org	$F000
		int	$30		;call monitor
		rts
		jmp	putc

;-----------------------------------------------------------

reshndl 	proc			; драйвер за обработка на RESET
		sei			; забраняване на прекъсванията

		ldaa	#$04		;ENABLE INTERNAL UART, INTERNAL CLOCK, 115200 BAUD
		staa	REG_RMCR
		ldaa	#$0A		;ENABLE RECIEVE AND TRANSMITT DATA
		staa	REG_TRCSR
		ldaa	REG_RDR		;FLUSH BUFFER AND CLEAR ERROR FLAGS

		ldaa	REG_PORT6	; MEMPAGE Port initialization
		anda	#MEMPAGE_FMASK|MEMPAGE_HI
		staa	REG_PORT6
		ldaa	#$FF
		staa	REG_DDRP6

		ldaa	REG_RP5CR	; HD6303Y Enable IRQ1 input
		oraa	#BIT_IRQ1E
		staa	REG_RP5CR

		ldaa	#VPU_B_CURINV|VPU_B_AUTO|VPU_B_IEN	; VPU initialization
		staa	VPU_CONFIG
		ldaa	#1
		staa	VPU_AUTOOFFS
		ldx	#screen
		stx	VPU_VADDR
		ldaa	#39
		staa	VPU_HSIZE
		ldaa	#215
		staa	VPU_VSIZE

		ldx	#swipag 	; нулиране на таблицата с адресите
reshndl1	clr	0,x		; на интеръптите и страниците им
		inx
		cpx	#swipag+$280
		bne	reshndl1
		ldab	#$70		;установяване на интеръпти 00-37
		lds	#restbl-1
		ldx	#swivec
reshndl2	pula
		staa	0,x
		inx
		decb
		bne	reshndl2

		ldx	#$a55a
		cpx	resmagic
		beq	warm
		stx	resmagic

		ldx	#lowerram
ramtest3	clr	0,x		; нулиране на оперативната памет
		inx
		cpx	#upperram-$80
		bne	ramtest3

		ldx	#0
		stx	hundreds
		stx	minutes
		ldx	#$101
		stx	day
		ldx	#1989
		stx	year
warm
		ldaa	MEMPAGE_SEL 	; изключване на страничния ROM
		anda	#MEMPAGE_FMASK|MEMPAGE_HI
		staa	MEMPAGE_SEL

		ldx	#uartcon
		stx	swivec+$F8*2

		clr	indos		; изчистване на флага
		clr	equipment	; изчистване на флага
		clr	configuration	; флагове за флопитата

;		clr	fdcslct
;		inc	fdcslct

		ldx	#contbl
		stx	conparms
		ldx	cur_replace,x
		stx	cursor_start
		clr	insert_mode
		clr	macroflg	; макро клавитура
		ldx	#0
		stx	macro_def_ptr

		ldx	#fddtbl
		stx	fddparms

		ldx	#kbd_buffer
		stx	kbd_store
		stx	kbd_load
		ldaa	#$60
		staa	cursor_blink

		ldx	#rstbl
		stx	rsparms

		ldx	#upperram
		txs

		clra			; инициализация на видео режима
		clrb
		int	$12

		ldx	#title		; името на компютъра
		int	$23

		ldab	MEMPAGE_SEL		; проверка на страничните ROM
		clrb
romloop 	ldaa	MEMPAGE_SEL
		anda	#MEMPAGE_FMASK
		oraa	#MEMPAGE_HI	; we use upper memory space for pages
		aba
		staa	MEMPAGE_SEL
		ldx	#$a55a		; за 2764 и 27128 първа част
		bitb	#%00000100
		beq	romt0
		ldx	#$5aa5		; за 27128 втора част
romt0		cpx	romstart
		bne	nextrom

		ldx	#romstart	; контролна сума на ROM
		clra
romloop1	adda	0,x
		inx
		cpx	#romstart+$2000
		bne	romloop1
		tsta
		bne	nextrom
		pshb

		ldx	#romstart+$10	; закачане на интеръпт драйверите
romtl		stx	x1		; от страничните ROM
		ldaa	0,x
		beq	romte
		ldab	MEMPAGE_SEL
		ldx	1,x
		int	$2f
		ldx	x1
		inx
		inx
		inx
		bra	romtl
romte
		jsr	romstart+$a	; инициализация на страничните ROM
		pulb
nextrom 	incb
		cmpb	#$10
		bcs	romloop 	;<
		ldaa	MEMPAGE_SEL
		anda	#MEMPAGE_FMASK|MEMPAGE_HI
		staa	MEMPAGE_SEL

		ldx	#$F000
		clra
mainrom 	adda	x
		inx
		bne	mainrom
		tsta
		beq	mainrom_ok
		int	$00
mainrom_ok

		ldaa	#$FF
		staa	scancode
		clr	shiftstatus
		clr	lockstatus
		clr	scanbits

		ldaa	PS2_CONFIG
		bita	#PS2_BIT_RDY
		beq	ps2noflush
		ldaa	PS2_DATA

ps2noflush	ldaa	#$FF		; reset keyboard
		jsr	ps2write
		tsta
		bne	ps2skip
		jsr	ps2read
		jsr	ps2read
		cmpa	#$AA
		bne	ps2skip
		ldx	#ps2okay
		int	$23

		ldaa	PS2_CONFIG	; enable PS/2 interrupt
		oraa	#PS2_BIT_IEN
		staa	PS2_CONFIG
ps2skip

		ldab	#2		; init printer port
		int	$26

		ldab	#4
		ldaa	#%100110
		int	$27

		cli

		ldaa	#$40		; initialize
		int	$17		; reset FDC

		ldx	#bootparm	; инициализация на флопи-контролера
		ldaa	#$41		; read lba sector 0
		int	$17		;
		tsta
		bne	nofloppy
		ldx	$2fe		; проверка за принадлежност
		cpx	#$a55a
		bne	nofloppy
		jsr	$150
nofloppy
resetloop	int	$01		; край по RESET вектора
		bra	resetloop

		endp
;---------------------------------------
inthandlers	proc
		global	nmihndl, irqhndl, icfhndl, ocfhndl, tofhndl, scihndl, traphndl, cmihndl, irq2hndl

irq2hndl 				; драйвр за ICF прекъсване
		ldab	swipag+127	;int $f9
		andb	#$0f
		ldx	swivec+$FF*2	;intFF
		bra	irqhndl1

cmihndl 				; драйвр за NMI прекъсване
		ldab	swipag+127	;int02
		lsrb
		lsrb
		lsrb
		lsrb
		ldx	swivec+$FE*2	;intFE
		bra	irqhndl1

traphndl 				; драйвр за ICF прекъсване
		ldab	swipag+126	;int $f9
		andb	#$0f
		ldx	swivec+$FD*2	;intFD
		bra	irqhndl1

scihndl 				; драйвр за NMI прекъсване
		ldab	swipag+126	;int02
		lsrb
		lsrb
		lsrb
		lsrb
		ldx	swivec+$FC*2	;intFC
		bra	irqhndl1

tofhndl 				; драйвр за ICF прекъсване
		ldab	swipag+125	;int $f9
		andb	#$0f
		ldx	swivec+$FB*2	;intFB
		bra	irqhndl1

ocfhndl 				; драйвр за NMI прекъсване
		ldab	swipag+125	;int02
		lsrb
		lsrb
		lsrb
		lsrb
		ldx	swivec+$FA*2	;intFA
		bra	irqhndl1

icfhndl 				; драйвр за ICF прекъсване
		ldab	swipag+124	;int $f9
		andb	#$0f
		ldx	swivec+$F9*2	;intF9
		bra	irqhndl1

nmihndl 				; драйвр за NMI прекъсване
		ldab	swipag+1	;int02
		lsrb
		lsrb
		lsrb
		lsrb
		ldx	swivec+4	;int02
		bra	irqhndl1

;---------------
irqhndl
		ldab	swipag+4	;int09
		ldx	swivec+18
		tst	PS2_CONFIG	; check keyboard
		bmi	irqhndl1
		ldab	swipag+1	;int03
		ldx	swivec+6	;int03
		tst	VPU_CONFIG	; драйвер за Video IRQ прекъсване и
		bpl	irqhndl1	; 50 Hz
		ldab	swipag+2	;int05
		ldx	swivec+10	;int05
irqhndl1	ldaa	MEMPAGE_SEL 	; обща част на NMI и IRQ драйверите
		psha
		andb	#$0f
		beq	irqhndl2
		psha
		ldaa	MEMPAGE_SEL
		anda	#MEMPAGE_FMASK|MEMPAGE_HI
		aba
		staa	MEMPAGE_SEL
		pula
irqhndl2	cpx	#0
		beq	irqhndl3
		jsr	0,x
irqhndl3	pula
		staa	MEMPAGE_SEL
		rti
		endp

;---------------------------------------
swihndl 	proc			; драйвер за обработка на SWI
		sei			; осигурява псевдо-инструкцията INT
		inc	indos		; ниво на вложеност
		tsx
		lds	5,x		; компенсиране на PC за номера на
		des			; интеръпта
		pula			; номер на интеръпта
		ins
		sts	5,x
		txs
		psha
		bsr	exchregs	; размяна на SWI променливите и стека
		pula			; номер на интеръпта
		ldab	MEMPAGE_SEL 	; текуща ROM страница
		pshb			; спасява се в стека

		tab			; извличане на страницата на интеръпта
		lsrb
		stab	swihndl_x+1
		ldab	#/swipag
		stab	swihndl_x
		ldx	swihndl_x
		ldab	swipag,x
		bcs	swihndl1	;odd-low
		lsrb
		lsrb
		lsrb
		lsrb
swihndl1	andb	#$0f
		beq	swihndl4
		psha
		ldaa	MEMPAGE_SEL
		anda	#MEMPAGE_FMASK|MEMPAGE_HI
		aba
		staa	MEMPAGE_SEL
		pula
swihndl4
		ldab	#$77		;$ee/2
		asla			; извличане на адреса на интеръпта
		rolb
		staa	swihndl_x+1
		stab	swihndl_x
		ldx	swihndl_x
		ldaa	swivec+1,x
		ldab	swivec,x
		beq	swihndl2
		bsr	swihndl3	; изпълнение на интеръпта
swihndl2
		sei			; въстановяване след интеръпта
		pulb
		stab	MEMPAGE_SEL 	; предишната страница
		tsx
		bsr	exchregs	; размяна на регистрите и стека
		dec	indos		; ниво на вложеност
		rti

exchregs
		ldaa	1,x
		ldab	swib		; регистър B
		staa	swib
		stab	1,x

		ldaa	2,x
		ldab	swia		; регистър A
		staa	swia
		stab	2,x

		ldaa	3,x
		ldab	swix		; регистър X
		staa	swix
		stab	3,x

		ldaa	4,x
		ldab	swix+1
		staa	swix+1
		stab	4,x

		ldaa	0,x		; регистър P
		ldab	swic
		staa	swic
		stab	0,x
		rts

swihndl3
		psha			; зареждане на регистрите и
		pshb			; изпълнение
		ldaa	swic
		tap
		ldx	swix
		ldab	swib
		ldaa	swia
		cli
		rts
		endp

;--------------------------------------
; RESET
;--------------------------------------
reset		proc
loop0
;loop0		ldaa	piacra
;		eora	#8
;		staa	piacra
;loop1		dex
;		bne	loop1
		bra	loop0
		endp

uartcon		proc
		ldx	#title
		bsr	uart_puts
		ldx	#uartlogo
		bsr	uart_puts
		int	$23

		sei

loop		jsr	uart_in
		cmpa	#'L'
		beq	cmd_load
		cmpa	#'S'
		beq	cmd_save
		cmpa	#'G'
		beq	cmd_go
		ldaa	#'E'
		jsr	uart_out
		bra	loop

cmd_load	bsr	get_block_addr
cmd_lo1		jsr	uart_in
		staa	0,x
		inx
		cpx	fddparms
		bne	cmd_lo1
cmd_oka		ldaa	#'O'
		jsr	uart_out
		bra	loop

cmd_save	bsr	get_block_addr
cmd_sa1		ldaa	0,x
		jsr	uart_out
		inx
		cpx	fddparms
		bne	cmd_sa1
		bra	cmd_oka

cmd_go		bsr	get_word
		pshx
		xgdx
		bsr	uart_outhex
		tba
		bsr	uart_outhex
		pulx
		jmp	0,x
		endp

get_block_addr proc
		bsr	get_word
		pshx
		bsr	get_word
		stx	fddparms
		pulx
		rts
		endp

uart_puts 	proc
		pshx
		psha
loop		ldaa	0,x
		tsta
		beq	exit
		jsr	uart_out
		inx
		bra	loop
exit		pula
		pulx
		rts
		endp

uart_outhex	proc
		psha
		pshb
		tab
		bsr	OUTNIBH
		tba
		bsr	OUTNIBL
		pulb
		pula
		rts
OUTNIBH		lsra
		lsra
		lsra
		lsra
OUTNIBL		anda	#$0F
		oraa	#$30
		cmpa	#$39
		bls	OUTNIBX
		adda	#$7
OUTNIBX 	jsr	uart_out
		rts
		endp

get_word	proc
		jsr	uart_in
		tab
		jsr	uart_in
		psha
		pshb
		pulx
		rts
		endp

;--------------------------------------
; TIME SUPPORT
;--------------------------------------
timer		proc
		ldx	#0
		cpx	synchro_addr
		beq	timer0
		ldd	synchro_addr
		std	VPU_VADDR
		stx	synchro_addr

timer0		ldaa	hundreds
		inca
		inca
		cmpa	#100
		bcs	timer1
		clra
timer1
		staa	hundreds
		bne	exit

		int	$06		; 1 sec

		ldaa	seconds
		inca
		cmpa	#60
		bcs	timer2
		clra
timer2
		staa	seconds
		tsta
		bne	exit

		ldaa	minutes
		inca
		cmpa	#60
		bcs	timer3
		clra
timer3
		staa	minutes
		bne	exit

		ldaa	hours
		inca
		cmpa	#24
		bcs	timer4
		clra
timer4
		staa	hours
		bne	exit

		ldaa	day
		inca
		cmpa	#32
		bcs	timer5
		ldaa	#1
timer5
		staa	day
		cmpa	#1
		bne	exit

		ldaa	month
		inca
		cmpa	#13
		bcs	timer6
		ldaa	#1
timer6
		staa	month
		cmpa	#1
		bne	exit

		inc	year
exit		rts
		endp

;---------------------------------------
; KEYBOARD
;---------------------------------------
int09		proc
		ldaa	PS2_CONFIG
		bita	#PS2_BIT_RDY
		bne	read_scan
		jmp	exit

read_scan	bita	#PS2_BIT_REL
		beq	read_scan2
		ldaa	scanbits
		oraa	#key_f0
		staa	scanbits

read_scan2	ldaa	PS2_DATA

		cmpa	#$E0
		bne	check_f0
		ldaa	scanbits
		oraa	#key_e0
		staa	scanbits
		jmp	exit
check_f0	cmpa	#$F0
		bne	check_shift
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
		jmp	return
savescan	staa	scancode

		ldx	swivec+16
		psha
		clrb
		ldaa	shiftstatus
		bita	#SH_CTRL|SH_RCTRL
		beq	checkshift
		ldx	8,x
		bra	decode
checkshift	bita	#SH_SHIFT|SH_RSHIFT
		beq	checkcyr
		orab	#1
checkcyr	psha
		ldaa	lockstatus
		bita	#LK_CYR
		beq	checkalt
		orab	#2
checkalt	pula
		bita	#SH_ALT|SH_RALT
		beq	gettab
		eorb	#2
gettab		abx
		abx
		ldx	0,x
decode		pulb
		abx
		ldaa	0,x
		bsr	key2buf

		ldaa	scancode
		cmpa	#$58
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
exit		rts

key2buf		pshb
		ldab	lockstatus
		bitb	#LK_CAPS
		beq	checkcapsend
		cmpa	#'A'
		blo	checkcapsend
		cmpa	#'Z'
		bhi	checkcaps2
capshiftup	adda	#$20
		bra	checkcapsend
checkcaps2	cmpa	#'a'
		blo	checkcapsend
		cmpa	#'z'
		bhi	checkcaps3
capshiftdn	suba	#$20
		bra	checkcapsend
checkcaps3	cmpa	#$80
		blo	checkcapsend
		cmpa	#$9F
		bhi	checkcaps4
		bra	capshiftup
checkcaps4	cmpa	#$A0
		blo	checkcapsend
		cmpa	#$BF
		bls	capshiftdn
checkcapsend	pulb

		ldx	kbd_store
		inx
		cpx	#kbd_buffer_end
		bne	decode1
		ldx	#kbd_buffer
decode1		stx	kbd_temp	; new kbd_store
		cpx	kbd_load	; buffer full ?
		beq	decode2		; yes
		ldx	kbd_store	; store char
		staa	x
		ldx	kbd_temp
		stx	kbd_store
decode2		rts
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
		pshx
		ldx	#0
		staa	PS2_DATA
loop0		ldaa	PS2_CONFIG
		dex
		beq	error
check		bita	#PS2_BIT_BSY
		bne	loop0
		clra
exit		pulx
		rts
error		ldaa	#$FF
		bra	exit
		endp

;---------------------------------------

int10		proc			; тест на клавитурата
		sei
		ldaa	#$FF
		ldx	kbd_load
		cpx	kbd_store
		beq	return
		ldaa	x
return		staa	swia
		rts
		endp

;---------------------------------------
int11		proc
		ldaa	VPU_CONFIG
		oraa	#VPU_B_CUR
		staa	VPU_CONFIG
loop		cli
		nop
		nop
		sei
		ldx	kbd_load
		cpx	kbd_store
		beq	loop

		ldaa	x
		inx
		cpx	#kbd_buffer_end
		bne	skip
		ldx	#kbd_buffer
skip		stx	kbd_load
		staa	swia
		ldaa	VPU_CONFIG
		anda	#$FF^VPU_B_CUR
		staa	VPU_CONFIG
		rts
		endp

;---------------------------------------
; INIT VIDEO MODE
;---------------------------------------
;  A - mode: 0 - text40, B = 0 - b/w, B <> 0 - attr
;	     1 - graf16
;	     2 - graf4, B - palette
;	     3 - graf2
;	     4 - text40, B = 0
;
int12		proc			; инициализация на видеорежима
initscr 	sei
		anda	#$7f
		cmpa	#5
		bcs	modeok
		rts

modeok		anda	#3		;force 4 --> 0
		clr	queuelen
		stx	scrbase
		stx	scraddr
		staa	scrmode
		staa	tmpx+1

		cmpa	#2		;grmidres
		bne	initscr1
		stab	palette
		andb	#3
		aslb
		aslb
		aslb
		bra	initscr3

initscr1	tsta			; text40 ?
		bne	initscr2	; no
		tstb			; b/w ?
		beq	initscr2
		stab	attribute
	    ;	ldab	#4
	    ;	db	$C1		; CMPB #
initscr2	clrb

initscr3	
;		ldaa	#/piatbl
;		staa	tmpx
;		ldx	tmpx
;		orab	piatbl,x
;		ldaa	piadrb
;		anda	#$C1
;		staa	piadrb
;		orab	piadrb
;		stab	piadrb

		ldx	#videotbl
		ldaa	6,x		; rows
		ldab	scrmode
		andb	#3
		bne	grafmode
textmode
		staa	scrrows 	; брой редове
		inca			; service lines
		inca			;
		bsr	setrows
		ldaa	1,x
		staa	scrcols 	; брой символи на ред
		bsr	setcols
		ldx	16,x
		stx	scrsize

		ldaa	VPU_CONFIG
		anda	#$FF^VPU_B_GRF
		staa	VPU_CONFIG

		ldd	#screen
		std	scrbase		; начален адрес на екрана
		tst	swia
		bpl	textmode1
		ldd	scraddr
textmode1	std	scraddr
		bra	setmode1
grafmode
		bsr	setrows
		ldaa	1,x
		bsr	setcols

		ldaa	VPU_CONFIG
		oraa	#VPU_B_GRF
		staa	VPU_CONFIG

		ldd	scrbase
		bra	setmode1x	;we use emulation to send graphics screen to vpu

setmode1	std	VPU_VADDR
setmode1x	tst	swia
		bmi	return

		ldx	#system_line	;clear system line
		ldab	#80
;		ldab	scrcols
;		aslb
loop		clr	x
		inx
		decb
		bne	loop

		ldaa	#12		;cls
		int	$22
return		rts

setcols		deca
		staa	VPU_HSIZE
		rts
setrows 	asla
		asla
		asla
		deca
		staa	VPU_VSIZE
		rts
		endp

;---------------------------------------
; GET VIDEO MODE
;---------------------------------------
int13		proc			; процедурата експортира:
		sei
		ldx	scrbase 	; базов адрес на екрана
		ldab	palette
		ldaa	scrmode
		bita	#3
		bne	j1
		ldab	attribute
j1		jmp	rtswix
		endp

;---------------------------------------
; GET CURSOR POSITION
;---------------------------------------
int14		proc			; процедурата експортира:
		sei
		ldx	scraddr 	; адрес на екрана,
		ldaa	ch		; хоризонтална позиция на курсора
j1		ldab	cv		; вертикална позиция и
		jmp	rtswix
		endp

;---------------------------------------
; SET CURSOR POSITION
;---------------------------------------
int15		proc			; процедурата експортира:
		sei
		cmpb	scrrows
		bcc	sorry
		stab	cv
j1		cmpa	scrcols
		bcc	sorry
		staa	ch
sorry		jmp	fixcur
		endp

;---------------------------------------
; SET ATTRIBUTE
;---------------------------------------
int16		proc
		sei
		stab	attribute
		rts
		endp

;---------------------------------------
; SERIAL SUPPORT
;---------------------------------------
rs232c		proc			; или серийния вход
		global	int18, int19, uart_in, uart_out
int18		bsr	uart_in
		clc
		staa	swia
		tpa
		staa	swic
		rts
uart_in		ldaa	REG_TRCSR
		anda	#$C0		;FILTER OUT RDRF AND ORFE
		cmpa	#$00
		beq	uart_in		;WAIT FOR CHARACTER
		cmpa	#$40
		beq	uartin1		;CHECK FOR FRAMING ERROR
		ldaa	REG_RDR         ;READ RECIEVED CHARACTER
		rts
uartin1		ldaa	REG_RDR		;ON ERROR, FLUSH BUFFER AND CLEAR ERROR FLAG
		bra	uart_in

int19
uart_out	pshb
uartou1		ldab	REG_TRCSR	;Get Status Reg 
		aslb			;TDRE->C
		aslb
		aslb
		bcc	uartou1		;READY FOR NEXT CHARACTER
		staa	REG_TDR
		pulb
		rts
		endp

;---------------------------------------
; GETCHAR
;---------------------------------------
; procedure reads keyboard and expands keys

int20		proc
;		int	$18
;		cmpa	#$0D
;		bne	exid
;		ldaa	#$C0
;exid		jmp	rtswia

again		tst	macroflg
		bne	inmacro
get_key 	int	$11		;get key
		cmpa	#_BREAK
		beq	break
		ldx	conparms
		cmpa	key_break,x
		bne	search
break		int	$04
		bra	get_key

search		ldx	macro_def_ptr
		beq	exit
search_loop	ldab	x
		cmpb	#$ff
		beq	exit
		cba
		beq	found
skip_loop	inx
		ldab	x
		bne	skip_loop
		inx
		bra	search_loop
found
		stx	macroptr
inmacro 	ldx	macroptr
		inx
		stx	macroptr
		ldaa	x
		staa	macroflg
		beq	again
exit		jmp	rtswia
		endp


;---------------------------------------
; GetLine (mini version)
;---------------------------------------
; Import: X - buffer pointer, B - max length
; Export: A - length
;
;---------------------------------------
int21		proc
		ldaa	scrcols
		suba	ch
		deca
		cba
		bcc	ok
		tab
ok		stab	maxb
		clrb
again		int	$20
		cmpa	#$c0		;Fkeys not collected
		beq	done
		bhi	again

		cmpa	#_BACKSPACE
		bne	char
		tstb
		beq	again
		dex
		decb
		bra	echo

char
		cmpb	maxb
		bne	store
		ldaa	#7
		bra	echo

store		staa	x
		inx
		incb
		cmpa	#$20		;control keys not echoed
		bcs	again
echo		int	$22
		bra	again

done		clr	x
		stab	swia
		rts
		endp

;---------------------------------------
; WRITE CHAR
;---------------------------------------
putc		psha
		pshb
		tab
		tpa
		psha
		tba
		sei
		stx	putchar_x
		bsr	int22
		ldx	putchar_x
		pula
		tap
		pulb
		pula
		rts

int22		proc			; писане на символ на екрана
		global	fixcur
;		int	$19
;		rts
		sei
		ldab	scrmode
		andb	#3
		bne	return0 	;graphic modes not supported
		tst	queuelen
		beq	screen0
		ldx	queueptr	; проверка за опашка
		staa	0,x
		inx
		stx	queueptr
		dec	queuelen
		bne	return1
		ldx	#queuebuf
		ldab	0,x		;command
		cmpb	#$1f		;attribute
		bne	queue1
		ldaa	1,x
		staa	attribute
return0 	rts
queue1		cmpb	#$1b		;esc
		bne	queue2
		ldaa	1,x		; печат на символа като нормален
		bra	normchar
queue2		cmpb	#$1e		;goxy
		bne	return1
		ldaa	1,x
		suba	#$20		; установяване на позицията на курсора
	   ;	ldab	scrmode
	   ;	bne	queue20
	   ;	asla			; for mode 40
queue20 	cmpa	scrcols
		bcc	queue21
		staa	ch
queue21 	ldaa	2,x
		suba	#$20
		cmpa	scrrows
		bcc	queue22
		staa	cv
queue22 	bra	fixcur

screen0
		cmpa	#$7f		; проверка за контролни символи
		beq	screen1
		cmpa	#$20
		bcc	normchar
screen1 	jmp	ctrlchar

normchar    ;	psha
	    ;	ldaa	scrmode
	    ;	bne	normchar0
	    ;	ldaa	attribute
	    ;	bsr	normchar1
normchar0   ;	pula
normchar1	ldx	curaddr 	; нормален символ
		bsr	putchar
adv		ldaa	ch
		inca
		cmpa	scrcols
;		bcs	adv_ok
;		jmp	lf
		bcc	return1
adv_ok		staa	ch
		ldx	curaddr
		inx
		stx	curaddr
		jmp	putcursor
return1 	rts

putchar 	stx	scrtmpx 	; поставяне на символа на екрана
		pshb
		staa	scrtmp
		stx	VPU_ADDR
		staa	VPU_DATA

		ldd	scrtmpx
		subd	scrsize
		xgdx
		cpx	scrbase
		bcs	putchar2
		stx	altaddr
		ldaa	scrtmp
		stx	VPU_ADDR
		staa	VPU_DATA

putchar2	pulb
		ldx	scrtmpx
		rts

fixcur					; фиксиране на курсора
		ldaa	scrcols
		staa	scrtmp
		ldab	cv
		pshb
		clra
		psha
		ldab	ch
		clra
		addd	scraddr
		std	curaddr
fixcur1		lsr	scrtmp
		bcc	fixcur2
		addd	curaddr
		std	curaddr
fixcur2		pula
		pulb
		asld
		pshb
		psha
		tst	scrtmp
		bne	fixcur1
		ins
		ins

putcursor				; поставяне на курсора
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
		ldaa	cv
		asla
		asla
		asla
		tab
		adda	cursor_start
		staa	VPU_CURLINS
		addb	cursor_end
		stab	VPU_CURLINE
		ldaa	ch
		staa	VPU_CURPOS
		rts

ctrlchar				; контролен символ
		cmpa	#$7f
		bne	ctrl1e
del		jsr	bs		; DEL
		ldx	curaddr
		ldaa	#$20
		jmp	putchar

ctrl1e		cmpa	#$1e		; GOTOXY
		bne	ctrl1b
		ldab	#2
		bra	setqueue

ctrl1b		cmpa	#$1F		; attribute
		beq	setqueue1
		cmpa	#$1b		; ESCAPE
		bne	ctrl18
setqueue1	ldab	#1
setqueue	ldx	#queuebuf
		staa	0,x
		inx
		stx	queueptr
		stab	queuelen
		rts

ctrl18		cmpa	#$18		; clear to end of line
		bne	ctrl0d
cleol		ldx	curaddr 	; изчистване до края на реда
		ldab	ch
cleol1		cmpb	scrcols
		bcc	cleol2
	  ;	ldaa	scrmode
	  ;	bne	cleol3
	  ;	ldaa	attribute
	  ;	jsr	putchar
	  ;	inx
	  ;	incb
cleol3		ldaa	#$20
		jsr	putchar
		inx
		incb
		bne	cleol1
cleol2		rts

ctrl0d		cmpa	#$0d		; CARRIAGE RETURN
		bne	ctrl0c
cr		clr	ch
		jmp	fixcur

ctrl0c		cmpa	#$0c
		bne	ctrl0a
cls					; изчистване на екрана
		ldx	scrbase
		stx	VPU_ADDR
		ldab	scrrows
		aslb
		ldaa	scrcols
		mul
		xgdx
		clra
cls1		staa	VPU_DATA	; 1,x for 601a
		dex
		bne	cls1
		bsr	clear_sysline

home		clr	ch		; курсора в горния ляв ъгъл
		clr	cv
		ldx	scraddr
		stx	curaddr
		jmp	putcursor

clear_sysline	ldd	scraddr
		addd	scrsize
		xgdx
		stx	system_scrbase

		sei
		sts	tmps
		lds	#system_line-1
		stx	VPU_ADDR
		ldab	#40
		clra
clear_sysl0	staa	VPU_DATA
		decb
		bne	clear_sysl0
		ldab	#40
clear_sysloop	pula
		pula
		staa	VPU_DATA
		decb
		bne	clear_sysloop
		lds	tmps
		rts

ctrl0a		cmpa	#$0a
		bne	ctrl09
lf					; ред надолу
		clr	ch		; for lf = cr+lf
		ldaa	cv
		inca
		cmpa	scrrows
		bcc	scroll
		staa	cv
		jmp	fixcur		; for lf = cr+lf

scroll					; скрол нагоре
		ldab	scrcols
		clra
		addd	scraddr
scroll4		std	scraddr
		subd	scrsize
		xgdx
		cpx	scrbase
		xgdx
		bcc	scroll4
		ldd	scraddr
		addd	scrsize
		subb	scrcols
		sbca	#0
		xgdx
		stx	altaddr

		clrb
		jsr	cleol1
		jsr	clear_sysline
		ldx	scraddr
		stx	synchro_addr
		jmp	fixcur

ctrl09		cmpa	#$09		; табулация
		bne	ctrl08
tab		ldaa	ch
		adda	#8
		anda	#%11111000
		cmpa	scrcols
		bcc	tab9
		staa	ch
tab9		jmp	fixcur

ctrl08		cmpa	#$08		; BACKSPACE
		bne	ctrl07
bs		ldaa	ch
		beq	bs9
		dec	ch
		ldx	curaddr
		dex
		stx	curaddr
bs9		jmp	putcursor


ctrl07		cmpa	#$07
		bne	return2
bell					; BELL
return2 	rts
		endp

;---------------------------------------
; WRITE LINE
;---------------------------------------
int23		proc			; писане на ред
putln		ldaa	0,x
		beq	putln1
		int	$22
		inx
		bra	putln
putln1		rts
		endp

;-----------------------------------------
; UNISGNED MULTIPLY
;-----------------------------------------
; BA = A * B
int28		proc
		mul
		bra	alt_rtswib
		endp

;-----------------------------------------
; UNSIGNED DIVISION
;-----------------------------------------
;Unsigned division 16b/16b = 16b, 16b
;
;x:= x div ba
;ba:= x mod ba
;ba = $FFFF - error: division by zero
;-----------------------------------------
int29		proc
		global	alt_rtswix, alt_rtswib, alt_rtswia
		stx	x1		;delimo
		stab	x2		;delitel
		staa	x2+1		;delitel
		bne	ok
		tstb
		bne	ok
		coma
		comb
		bra	error
ok
		clra
		clrb
		ldx	#17
loop		rolb
		rola

		subd	x2
		bcc	skip
		addd	x2

skip		rol	x1+1
		rol	x1
		dex
		bne	loop
		com	x1+1
		com	x1
		ldx	x1
error
alt_rtswix	stx	swix
alt_rtswib	staa	swib
alt_rtswia	stab	swia
		rts
;error		jmp	rtswix
		endp

;-----------------------------------------
; ALLOCATE MEMORY
;-----------------------------------------
; ENTER:
; X - number of bytes
; B - allignment  0..8
;	2^B
;RETURN : X = 0   -   aloc. error
;	  X - pointer
;-----------------------------------------
int2A		proc
		sei
		cmpb	#9
		bcc	error
		stx	x1
		beq	exit		; 2.12 / 1-Nov-89
		tsx
		stx	x2

		ldd	himem
		subd	x1
		bcs	error
		std	x1

		ldaa	swib
		ldab	#$ff
loop1		tsta
		beq	exit_loop1
		aslb
		deca
		bra	loop1
exit_loop1	andb	x1+1
		stab	x1+1
		ldaa	x1
		subd	himem
		addd	x2
		bcc	error
		std	x2
		deca
		xgdx
		cpx	lomem
		bcs	error

		ldx	x2
loop2		pula
		staa	x
		inx
		cpx	x1
		bne	loop2
		stx	himem
		ldx	x2
		txs
exit		ldx	himem
		stx	swix
		rts
error		ldx	#0
		stx	swix
		rts
		endp

;-----------------------------------------
; RELEASE MEMORY
;-----------------------------------------
; ENTER:
; X - pointer
;RETURN :
;	  X - size
;-----------------------------------------
int2B		proc
		sei
		stx	x1

		ldx	x1
		cpx	himem
		bls	error
		cpx	resident
		bhi	error

		sts	x2
		txs
		ldx	himem
		bra	entry1
loop1		ldaa	x
		psha
entry1		dex
		cpx	x2
		bne	loop1

		ldd	x1
		subd	himem
		std	swix

		ldx	x1
		stx	himem
		rts
error		ldx	#0
		stx	swix
		rts
		endp


;---------------------------------------
; MARK RESIDENT
;---------------------------------------
int2c		proc
rsdnt		ldx	himem
		stx	resident
		rts
		endp

;-----------------------------------------
; MOVE MEMORY
;-----------------------------------------
; ENTER:
; X - pointer
;	X1 - src
;	X2 - dest
; BA - length
;RETURN : X - number of bytes
;-----------------------------------------
int2D		proc
		sei
		ldx	x
		stx	x2		;src_beg
		dex
		stx	x1		;src_end
		ldx	swix
		ldx	x, 2
		stx	x4		;dst_beg

		staa	swix+1
		stab	swix

		ldx	swix
		beq	rts2
		xgdx
		addd	x1
		std	x1

		sts	tmps

		subd	x2
		addd	x4
		std	x3

		ldx	x4
		cpx	x2
		bls	mvleft

mvright 				; местене надясно
		lds	x3
		ldx	x1
		inx
mvright1	dex
		ldaa	0,x
		psha
		cpx	x2
		bne	mvright1
		bra	mvend
mvleft					; местене наляво
		lds	x2
		ldx	x4
mvleft0 	des
		dex
mvleft1 	inx
		pula
		staa	0,x
		cpx	x3
		bne	mvleft1
mvend		lds	tmps
rts2		rts

		endp
;---------------------------------------
; GET INTERRUPT VECTOR
;---------------------------------------
int2e		proc			; получаване на интеръпт вектор
getvec
		sei
		tab
		lsrb
		stab	tmpx+1
		ldab	#/swipag
		stab	tmpx
		ldx	tmpx
		ldab	swipag,x
		bcs	getvec1 	;odd-low
		lsrb
		lsrb
		lsrb
		lsrb
getvec1 	andb	#$0f
		stab	swib
		ldab	#$77		;$ee/2
		asla
		rolb
		staa	tmpx+1
		stab	tmpx
		ldx	tmpx
		ldx	swivec,x
		stx	swix
		rts
		endp

;---------------------------------------
; SET INTERRUPT VECTOR
;---------------------------------------
int2f		proc
putvec					; задаване на интеръпт вектор
		sei
		sts	tmps
		txs
		ins
		staa	tmpb
		lsra
		staa	tmpx+1
		ldaa	#/swipag
		staa	tmpx
		ldx	tmpx
		ldaa	#$0f		;hi
		bcc	*+4
		ldaa	#$f0		;lo
		anda	swipag,x
		staa	tmpa
		tba			;rompage
		anda	#$0f
		bcs	*+6
		asla
		asla
		asla
		asla
		oraa	tmpa
		staa	swipag,x
		ldaa	#$77
		ldab	tmpb
		aslb
		rola
		stab	tmpx+1
		staa	tmpx
		ldx	tmpx
		sts	0,x
		lds	tmps
		rts
		endp

;---------------------------------------
; PRESERVE MEMORY	  enter: BA - size, exit: X - old lomem, BA - size
;---------------------------------------
int_35		proc
		sei
		ldx	lomem
		stx	swix
		sts	tmps
		dec	tmps

		tab
		ldaa	swib
		addd	lomem
		xgdx
		cpx	tmps
		bcc	check_bad
		std	lomem

		rts
check_bad	clr	swib
		clr	swia
		rts
		endp

;---------------------------------------
; GET FREE MEMORY
;---------------------------------------
int_36		proc
		sei
		ldx	lomem
		sts	tmps

		ldd	tmps
		deca
		subd	lomem
		bcc	ok
		clrb
		clra
ok		jmp	alt_rtswix
		endp

;---------------------------------------
; CHAIN INTERRUPT
;---------------------------------------
int_37		proc
		sei
		cpx	#0
		bne	ok
		ldx	#sysrts 	;force return
		stx	swix
		clrb			;don't change page
ok
		tsx
		stab	2,x		;corresponding page

		ldd	swix		;go to it via rts exit from this int
		std	8,x		;pc

		ldaa	3,x		;pass original ZP parms
		staa	swic
		ldab	4,x
		ldaa	5,x
		ldx	6,x
		jmp	rtswix

		endp

;---------------------------------------

restbl					; таблица с начални стойности на
					; интеръптите
		dw	reset		;00
		dw	uartcon		;01	RESET
		dw	0		;02	NMI
		dw	0		;03	IRQ
		dw	0		;04	USER INTERRUPT (CTRL+C)
		dw	timer		;05	IRQ 50Hz
		dw	0		;06	IRQ 1Hz
		dw	0		;07	CRITICAL ERROR
		dw	kblist		;08	KEYBOARD TABLES (601-M)
		dw	int09		;09	IRQ KEYBOARD
		dw	0		;0a	KEYBOARD MACROS
		dw	0		;0b
		dw	0		;0c
		dw	upperram	;0d
		dw	lowerram	;0e
		dw	upperram	;0f
		dw	int10		;	CHECK KEY
		dw	int11		;	READ KEY
		dw	int12		;	VIDEOMODE INIT
		dw	int13		;	GET VIDEOMODE
		dw	int14		;	GET CURSOR
		dw	int15		;	SET CURSOR
		dw	int16		;16	SET ATTR
		dw	0		;17	FLOPPY CTRL
		dw	int18		;18	UART_IN
		dw	int19		;19	UART_OUT
		dw	0		;1A
		dw	0		;1B
		dw	0		;1c
		dw	0		;1d
		dw	0		;1e
		dw	0		;1f
		dw	int20		;	READ CHAR
		dw	int21		;	READ STRING
		dw	int22		;	PUT CHAR
		dw	int23		;	PUT STRING
		dw	0		;24
		dw	0		;25
		dw	0		;26	PRINTER CTRL
		dw	0		;27
		dw	int28		;28	UMUL
		dw	int29		;29	UDIV
		dw	int2a		;	ALLOC
		dw	int2b		;	FREE
		dw	int2c		;	SET RESIDENT
		dw	int2d		;	MEM MOVE
		dw	int2e		;	GET INT
		dw	int2f		;	SET INT
		dw	0		;30  - mon
		dw	0		;31  - basic
		dw	0		;32
		dw	0		;33  - play
		dw	0		;34  - draw
		dw	int_35		;	ALLOC MEM
		dw	int_36		;	GET FREE MEM
		dw	int_37		;	CALL INT

;---------------
fddtbl					; параметри за флопи
		db	$6F
		db	$03
		db	$2		;sector lng
		db	$9		;eot
		db	$2A		;gap1
		db	$FF		;dtl
		db	$50		;gap2
		db	$FF		;fill byte
		db	$80		;motor

bootparm	dw	$0100		; параметри за INT17 за boot
		db	0
		dw	$0000

contbl					; параметри за клавитурата
		db	$13		;pause
		db	$3		;break
		db	6,7		;cursor replace
		db	0,7		;cursor insert
		db	$20,7		;cursor write

videotbl	db	63,40,48,5,38,0,25,31,0,7,$20,7
		dw	$F000,$F000,40*25

piatbl		db	0,$3E,$24,$38,0

rstbl					; параметри за серийния вход/изход
		db	$7e		;bauds - 1200
		db	$08		;bits
		db	$80		;no parity + 2 stop

;---------------------------------------

		db	10
		db	'(C) Software RDL 1987-1989, Ivo Nenov',10
		db	' & Orlin Shopov - Eagle software',10
		db	'(C) pdaXrom.org 1997-2019, Alexander Chukov',10,0
uartlogo	db	10,13,'Serial bootloader',10,13,0
ps2okay		db	10,'PS/2 keyboard connected',0

kblist		dw	kb, kb_shift, kbcyr, kbcyr_shift
		dw	kb_ctrl

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
	db	  0, 'C', 'X', 'D', 'E', '$', '#',   0,   0, $FD, 'V', 'F', 'T', 'R', '%',   0	; 20
	db	  0, 'N', 'B', 'H', 'G', 'Y', '^',   0,   0,   0, 'M', 'J', 'U', '&', '*',   0	; 30
	db	  0, '<', 'K', 'I', 'O', ')', '(',   0,   0, '>', '?', 'L', ':', 'P', '_',   0	; 40
	db	  0,   0, '"',   0, '{', '+',   0,   0, $FC,   0, $C0, '}',   0, '|',   0,   0	; 50
	db	  0,   0,   0,   0,   0,   0, $7F,   0,   0, $C6,   0, $C5, $C5,   0,   0,   0	; 60
	db	$FA, $F9, $C7,   0, $C6, $C8, $1B,   0, $DF,   0, $C7,   0,   0, $C8,   0,   0	; 70
	db	  0,   0,   0, $DB,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80

;		 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
kbcyr
	db	  0, $D1,   0, $CD, $CB, $C9, $CA, $D4,   0, $D2, $D0, $CE, $CC, $ED, $F1,   0	; 00
	db	  0,   0,   0,   0,   0, '�', '1',   0,   0,   0, '�', '�', '�', '�', '2', $FB	; 10
	db	  0, '�', '�', '�', '�', '4', '3',   0,   0, ' ', '�', '�', '�', '�', '5',   0	; 20
	db	  0, '�', '�', '�', '�', '�', '6',   0,   0,   0, '�', '�', '�', '7', '8',   0	; 30
	db	  0, '�', '�', '�', '�', '0', '9',   0,   0, '�', '.', '�', '�', '�', '-',   0	; 40
	db	  0,   0, '�',   0, '�', '=',   0,   0, $FC,   0, $C0, '�',   0, '\',   0,   0	; 50
	db	  0,   0,   0,   0,   0,   0, $7F,   0,   0, $C6,   0, $C1, $C5,   0,   0,   0	; 60
	db	$FA, $F9, $C3,   0, $C2, $C4, $1B,   0, $D3,   0, $C7,   0,   0, $C8,   0,   0	; 70
	db	  0,   0,   0, $CF,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80

;		 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
kbcyr_shift
	db	  0, $DD,   0, $D9, $D7, $D5, $D6, $E0,   0, $DE, $DC, $DA, $D8, $EE, $F0,   0	; 00
	db	  0,   0,   0,   0,   0, '�', '!',   0,   0,   0, '�', '�', '�', '�', '"', $FB	; 10
	db	  0, '�', '�', '�', '�', ';', '�',   0,   0, $FD, '�', '�', '�', '�', '%',   0	; 20
	db	  0, '�', '�', '�', '�', '�', ':',   0,   0,   0, '�', '�', '�', '&', '*',   0	; 30
	db	  0, '�', '�', '�', '�', ')', '(',   0,   0, '�', ',', '�', '�', '�', '_',   0	; 40
	db	  0,   0, '�',   0, '�', '+',   0,   0, $FC,   0, $C0, '�',   0, '/',   0,   0	; 50
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

		list	on
		ds	$FFC9 - *, $FF
		checksum

title		db	7,30,48,32
;name		db	'Pyldin 601Z',0
name		db	$8B, $A8, $AB, $A8, $B2, ' 601  ', 0

		error	*-serial_no
		dw	%1011010001100001	;90-03-01
		dw	$0000			;serial no

		error	*-bios_date
		dw	%1011010001100001	;90-03-01

		error	*-bios_version
		db	3,0			;version 2.50

		error	*-rtswix
		stx	swix		; експортиране на резултати

		error	*-rtswib
		stab	swib		; от интеръпт драйвери

		error	*-rtswia
		staa	swia

		error	*-sysrts
		rts			; sysrts

		error	*-hard_version
		db	$40		; Lilit 601

		dw	irq2hndl
		dw	cmihndl
		dw	traphndl
		dw	scihndl
		dw	tofhndl
		dw	ocfhndl
		dw	icfhndl
		dw	irqhndl
		dw	swihndl
		dw	nmihndl
		dw	reshndl
		error	*
		end
;---------------------------------------
