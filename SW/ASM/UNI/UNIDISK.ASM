;
; Lilith 601 SD/MMC driver
; (c) sashz <sashz@pdaXrom.org>, 2019
;

		include ../../DEVMAP.INC

		include MEMORY.INC

		section	$ED61
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
xbuffer		ds	2
retcode 	ds	1
headdrive	ds	1
lbasector	ds	4
buffer		ds	2
counter 	ds	5
retry		ds	1
sdmode		ds	1

		error	(*-1)/$ED7C
		ends

		org	$C000
		dw	$A55A
		db	'UniDISK '
		jmp	init
		jmp	print_version

		db	$17
		dw	int17

		db	$EE
		dw	umult

		db	$EF
		dw	udiv

		db	0

init		jsr	print_version
		clr	SDMODE
		jsr	sd_init
		staa	drive

		ldaa	SDMODE
		bita	#SD_CT_MMC
		beq	nxt1
		ldx	#t_mmc
		int	$23
nxt1		bita	#SD_CT_SD1
		beq	nxt2
		ldx	#t_sd1
		int	$23
nxt2		bita	#SD_CT_SD2
		beq	nxt3
		ldx	#t_sd2
		int	$23
nxt3		bita	#SD_CT_BLOCK
		beq	nxt4
		ldx	#t_blk
		int	$23
nxt4

		rts
print_version	ldx	#title
		int	$23
		rts

title		db	10, 'UniDISK  Version 1.0 ', 0

nl		db	10, 0

t_mmc		db	'MMC', 0
t_sd1		db	'SD', 0
t_sd2		db	'SDHC/XC', 0
t_blk		db	' LBA', 0

int17		proc
		sei

;		int	$25

		cmpa	#$40
		beq	init

		ldab	2,x		; emulation only for drive A
		tstb
		bne	error

		cmpa	#$41		; read sector
		bne	next1
		tst	drive
		bne	error

		ldaa	#'R'
		bsr	showmode

		ldd	0,x
		std	buffer
		ldd	3,x
		std	lbasector+2
		ldd	#0
		std	lbasector
		ldx	#lbasector
		jsr	sd_read
		bra	donex

next1		cmpa	#$42		; write sector
		bne	next2
		tst	drive
		bne	error

		ldaa	#'W'
		bsr	showmode

		ldd	0,x
		std	buffer
		ldd	3,x
		std	lbasector+2
		ldd	#0
		std	lbasector
		ldx	#lbasector
		jsr	sd_write
		bra	donex

next2		cmpa	#$43
		bne	next3

		ldaa	#'S'
		bsr	showmode
		bra	init2

next3		cmpa	#$44
		bne	init

		ldaa	#'F'
		bsr	showmode
		bra	init2

init		ldaa	#'I'
		bsr	showmode

init2		jsr	sd_init
		staa	drive
donex		tsta
		beq	done
error		ldaa	#$80
done		staa	swia
		rts
		endp

showmode	proc
		pshx
		pshb
		ldab	scrmode
		andb	#$03
		bne	return
		xgdx
		ldd	system_scrbase
		addd	#40+39
		std	VPU_ADDR
		xgdx
		staa	VPU_DATA
return		pulb
		pulx
		rts
		endp

;
; Select spi device
; A 1 Enable / 0 Disable
sdspi_select 	proc
		tsta
		beq	disable
		ldaa	SPI_CONFIG
		anda	#$FF^SPI_SS1
		staa	SPI_CONFIG
		bra	okay
disable		ldaa	SPI_CONFIG
		oraa	#SPI_SS1
		staa	SPI_CONFIG
okay		rts
		endp

sdspi_write	proc
		global	sdspi_read
		staa	SPI_DATA+1
loop		ldaa	SPI_STATUS
		bita	#SPI_READY
		beq	loop
		ldaa	SPI_DATA+1
		rts
sdspi_read	ldaa	#$FF
		bra	sdspi_write
		endp

sd_delay	proc
		pshx
		ldx	#1000
loop		dex
		bne	loop
		pulx
		rts
		endp

sd_init_cmd0	db	$40, $00, $00, $00, $00, $95
sd_init_cmd1	db	$41, $00, $00, $00, $00, $FF
sd_init_cmd8	db	$48, $00, $00, $01, $AA, $87
sd_init_cmd16	db	$50, $00, $00, $02, $00, $FF
sd_init_cmd55	db	$77, $00, $00, $00, $00, $01
sd_init_acmd41	db	$69, $40, $00, $00, $00, $00
sd_init_cmd58	db	$7A, $00, $00, $00, $00, $00

SD_CT_MMC	equ	$01
SD_CT_SD1	equ	$02
SD_CT_SD2	equ	$04
SD_CT_BLOCK	equ	$08

;
; Initialize SD card
; Return A - error code
;        B - card type
;
sd_init		proc
		pshb
		pshx
		ldaa	SPI_CONFIG
		anda	#$FF^(SPI_16B)
		oraa	#(SPI_SSM | SPI_SS1 | SPI_SS0)
		staa	SPI_CONFIG
		ldaa	#40
		staa	SPI_PRESCALER
		jsr	sd_disable
		ldab	#10
loop		jsr	sdspi_read
		decb
		bne	loop

		ldaa	#2
		staa	SPI_PRESCALER

		ldx	#sd_init_cmd0
		ldab	#10
loop1		jsr	sd_command
		cmpa	#$01
		beq	init_sdver
		bsr	sd_delay
		decb
		bne	loop1
		ldaa	#1
		jmp	exit

init_sdver	ldx	#sd_init_cmd8
		jsr	sd_command
		cmpa	#$01
		bne	init_mmc
		bsr	sdspi_read
		bsr	sdspi_read
		bsr	sdspi_read
		tab
		jsr	sdspi_read
		xgdx
		cpx	#$AA01
		beq	init_sdv2
		ldaa	#$82
		bra	exit

init_sdv2	ldab	#$FF
loop2		ldx	#sd_init_cmd55
		jsr	sd_command
		ldx	#sd_init_acmd41
		jsr	sd_command
		tsta
		beq	init_ccs
		jsr	sd_delay
		decb
		bne	loop2
		ldaa	#$83
		bra	exit

init_ccs	ldx	#sd_init_cmd58
		jsr	sd_command
		tsta
		beq	init_ccs2
		ldaa	#$84
		bra	exit

init_ccs2	jsr	sdspi_read
		tab
		jsr	sdspi_read
		jsr	sdspi_read
		jsr	sdspi_read

		ldaa	#SD_CT_SD2
		andb	#$40
		beq	init_ccs2a
		oraa	#SD_CT_BLOCK
init_ccs2a	staa	SDMODE
		bra	noerr

init_mmc	ldx	#sd_init_cmd1
		ldab	#255
loop3		jsr	sd_command
		tsta
		beq	init_bsize
		jsr	sd_delay
		decb
		bne	loop3
		ldaa	#2
		bra	exit

init_bsize	ldx	#sd_init_cmd16
		jsr	sd_command
		clr	SDMODE
noerr		clra
exit		pulx
		pulb
		bra	sd_disable
		endp

sd_command	proc
		bsr	sd_disable
		bsr	sd_enable

		ldaa	0,x		; cmd
		jsr	sdspi_write
		ldaa	1,x		; arg
		jsr	sdspi_write
		ldaa	2,x		; arg
		jsr	sdspi_write
		ldaa	3,x		; arg
		jsr	sdspi_write
		ldaa	4,x		; arg
		jsr	sdspi_write
		ldaa	5,x		; CRC
		jsr	sdspi_write

		pshb
		ldab	#10
loop		jsr	sdspi_read
		cmpa	#$FF
		bne	exit
		decb
		bne	loop
exit		pulb
		rts
		endp

sd_enable	proc
		pshx
		pshb
wait		ldaa	#1
		jsr	sdspi_select
		jsr	sdspi_read
		ldx	#5000
loop		jsr	sdspi_read
		cmpa	#$FF
		beq	exit
		jsr	sd_delay
		dex
		bne	loop
		bsr	sd_disable
		ldaa	#0
exit		inca
		pulb
		pulx
		rts
		endp

sd_disable	proc
		pshb
		psha
		ldaa	#0
		jsr	sdspi_select
		jsr	sdspi_read
		pula
		pulb
		rts
		endp

;
; read sector from SD
;
; A = 0 - No error
;
; X - ptr to structure:
; ds 4 - sector
; ds 2 - buffer ptr
;
sd_read		proc
		pshx
		pshb

;
; sector * 512
;
		ldaa	#$FF
		psha
		ldaa	SDMODE
		anda	#SD_CT_BLOCK
		beq	mul512
		ldaa	3,x
		psha
		ldaa	2,x
		psha
		ldaa	1,x
		psha
		ldaa	0,x
		psha
		bra	cmd17

mul512		clra
		psha
		ldaa	3,x
		rola
		psha
		ldaa	2,x
		rola
		psha
		ldaa	1,x
		rola
		psha

cmd17		ldaa	#$51		; CMD17
		psha
		ldx	4,x		; buffer
		pshx
		tsx
		inx
		inx			; X to saved data for sd_command
		jsr	sd_command
		pulx

		tsta
		beq	next
		ldaa	#1
		bra	exit

next		ldab	#255
next1		jsr	sdspi_read
		cmpa	#$FF
		bne	next2
		jsr	sd_delay
		decb
		bne	next1
		ldaa	#2
		bra	exit
next2		cmpa	#$FE
		beq	next3
		ldaa	#3
		bra	exit
next3		bsr	rcvr
		bsr	rcvr
		jsr	sdspi_read
		jsr	sdspi_read
		ldaa	#0

exit		tsx
		ldab	#6
		abx
		txs
		bsr	sd_disable

		pulb
		pulx
		rts

rcvr		ldab	#0
rcvr1		jsr	sdspi_read
		staa	0,x
		inx
		decb
		bne	rcvr1
		rts
		endp

;
; write sector to SD
;
; A = 0 - No error
;
; X - ptr to structure:
; ds 4 - sector
; ds 2 - buffer ptr
;
sd_write	proc
		pshx
		pshb

;
; sector * 512
;
		ldaa	#$FF
		psha
		ldaa	SDMODE
		anda	#SD_CT_BLOCK
		beq	mul512
		ldaa	3,x
		psha
		ldaa	2,x
		psha
		ldaa	1,x
		psha
		ldaa	0,x
		psha
		bra	cmd24

mul512		clra
		psha
		ldaa	3,x
		rola
		psha
		ldaa	2,x
		rola
		psha
		ldaa	1,x
		rola
		psha

cmd24		ldaa	#$58		; CMD24
		psha
		ldx	4,x		; buffer
		pshx
		tsx
		inx
		inx			; X to saved data for sd_command
		jsr	sd_command
		pulx

		tsta
		beq	next
		ldaa	#1
		bra	exit

next		ldab	#255
next1		jsr	sdspi_read
		cmpa	#$FF
		beq	next2
		jsr	sd_delay
		decb
		bne	next1
		ldaa	#2
		bra	exit
next2		ldaa	#$FE
		jsr	sdspi_write
		bsr	xmit
		bsr	xmit
		jsr	sdspi_read
		jsr	sdspi_read
		jsr	sdspi_read
		anda	#$1F
		cmpa	#$05
		bne	next3
		ldaa	#0
		bra	exit
next3		ldaa	#3

exit		tsx
		ldab	#6
		abx
		txs
		jsr	sd_disable

		pulb
		pulx
		rts

xmit		ldab	#0
xmit1		ldaa	0,x
		jsr	sdspi_write
		inx
		decb
		bne	xmit1
		rts
		endp

sd_flush	proc
		jsr	sd_enable
		tsta
		bne	exit
		jsr	sd_disable
exit		rts
		endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; X * D -> XD
;
umult		proc
P		equ	0
Q		equ	2
R		equ	4
		pshx		; R
		pshx		; R
		pshx		; Q
		pshb		; P
		psha		; P
		tsx

		clrb
		clra
		std	R,x
		ldaa	P+1,x
		ldab	Q+1,x
		mul
		std	R+2,x
		ldaa	P,x
		ldab	Q+1,x
		mul
		addd	R+1,x
		std	R+1,x
		bcc	MUL002
		inc	R,x
MUL002		ldaa	P+1,x
		ldab	Q,x
		mul
		addd	R+1,x
		std	R+1,x
		bcc	MUL004
		inc	R,x
MUL004		ldaa	P,x
		ldab	Q,x
		mul
		addd	R,x
;		std	R,x
;		ldx	R+2,x
		pulx
		pulx
		pulx
		pulx
		xgdx
		jmp	rtswix
;		rts
		endp

;
; X / D -> D,X
;
udiv		proc
DIV		equ	3
QUO		equ	1
KT		equ	0

		pshb		; divisor
		psha		;
		pshx		; dividend
		ldab	#1
		pshb		; counter
		tsx

		ldd	DIV,x
		beq	error
		bmi	DIV002
DIV001		inc	KT,x
		asld
		bpl	DIV001
		std	DIV,x
DIV002		ldd	QUO,x
		clr	QUO,x
		clr	QUO+1,x
DIV003		subd	DIV,x
		bcc	DIV004
		addd	DIV,x
		clc
		bra	DIV005
DIV004		sec
DIV005		rol	QUO+1,x
		rol	QUO,x
		lsr	DIV,x
		ror	DIV+1,x
		dec	KT,x
		bne	DIV003

		pshb
		psha
		ldd	QUO,x
		pulx

		clc
		bra	okay
error		sec
okay		ins
		ins
		ins
		ins
		ins
		jmp	rtswix
;		rts
		endp

		checksum
		ds	$E000-*,$FF
