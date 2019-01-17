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

		org	$100

		sei

		ldx	#hello
		jsr	F_PUTSTR

		jsr	sd_init
		tsta
		bne	no_sd_boot
		ldx	#txt_sd
		jsr	F_PUTSTR

		ldx	#read_sec
		jsr	sd_read


no_sd_boot	jsr	F_PUTHEX
		ldaa	sdmode
		jsr	F_PUTHEX

		ldx	#nl
		jsr	F_PUTSTR

		jmp	F_RESET

hello	db	'Hello, SDCARD!'
nl	db	10, 13, 0

txt_sd	db	'SD Card inited!', 10, 13, 0

sdmode	db	0

read_sec db	$00,$00,$00,$00
	dw	read_buf
read_sec2 db	$00,$00,$00,$01
	dw	read_buf2

write_sec db	$00,$00,$00,$01
	dw	read_buf
write_sec2 db	$00,$00,$00,$00
	dw	read_buf2

read_buf  equ $1000
read_buf2 equ $1200

;
; Select spi device
; A 1 Enable / 0 Disable
sdspi_select proc
	tsta
	beq	disable
	ldaa	SPI_CONFIG
	anda	#$FF^SPI_SS1
	staa	SPI_CONFIG
	bra	okay
disable	ldaa	SPI_CONFIG
	oraa	#SPI_SS1
	staa	SPI_CONFIG
okay	rts
	endp

sdspi_write proc
	global	sdspi_read
	staa	SPI_DATA+1
loop	ldaa	SPI_STATUS
	bita	#SPI_READY
	beq	loop
	ldaa	SPI_DATA+1
	rts
sdspi_read ldaa	#$FF
	bra	sdspi_write
	endp

sd_delay proc
	pshx
	ldx	#4000
loop	dex
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
sd_init	proc
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
loop	jsr	sdspi_read
	decb
	bne	loop

	ldx	#sd_init_cmd0
	ldab	#10
loop1	jsr	sd_command
	cmpa	#$01
	beq	init_sdver
	bsr	sd_delay
	decb
	bne	loop1
	ldaa	#1
	jmp	exit

init_sdver ldx	#sd_init_cmd8
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

init_sdv2 ldab	#$FF
loop2	ldx	#sd_init_cmd55
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

init_ccs ldx	#sd_init_cmd58
	jsr	sd_command
	tsta
	beq	init_ccs2
	ldaa	#$84
	bra	exit

init_ccs2 jsr	sdspi_read
	tab
	jsr	sdspi_read
	jsr	sdspi_read
	jsr	sdspi_read

	ldaa	#SD_CT_SD2
	andb	#$40
	beq	init_ccs2a
	oraa	#SD_CT_BLOCK
init_ccs2a staa	SDMODE
	bra	noerr

init_mmc ldx	#sd_init_cmd1
	ldab	#255
loop3	jsr	sd_command
	tsta
	beq	init_bsize
	jsr	sd_delay
	decb
	bne	loop3
	ldaa	#2
	bra	exit

init_bsize ldx	#sd_init_cmd16
	jsr	sd_command
	clr	SDMODE
noerr	clra
exit	pulx
	pulb
	bra	sd_disable
	endp

sd_command proc
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
loop	jsr	sdspi_read
	cmpa	#$FF
	bne	exit
	decb
	bne	loop
exit	pulb
	rts
	endp

sd_enable proc
	pshx
	pshb
wait	ldaa	#1
	jsr	sdspi_select
	jsr	sdspi_read
	ldx	#5000
loop	jsr	sdspi_read
	cmpa	#$FF
	beq	exit
	jsr	sd_delay
	dex
	bne	loop
	bsr	sd_disable
	ldaa	#0
exit	inca
	pulb
	pulx
	rts
	endp

sd_disable proc
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
sd_read proc
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

mul512	clra
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

cmd17	ldaa	#$51		; CMD17
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

next	ldab	#255
next1	jsr	sdspi_read
	cmpa	#$FF
	bne	next2
	jsr	sd_delay
	decb
	bne	next1
	ldaa	#2
	bra	exit
next2	cmpa	#$FE
	beq	next3
	ldaa	#3
	bra	exit
next3	bsr	rcvr
	bsr	rcvr
	jsr	sdspi_read
	jsr	sdspi_read
	ldaa	#0

exit	tsx
	ldab	#6
	abx
	txs
	bsr	sd_disable

	pulb
	pulx
	rts

rcvr	ldab	#0
rcvr1	jsr	sdspi_read
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
sd_write proc
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

mul512	clra
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

cmd24	ldaa	#$58		; CMD24
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

next	ldab	#255
next1	jsr	sdspi_read
	cmpa	#$FF
	beq	next2
	jsr	sd_delay
	decb
	bne	next1
	ldaa	#2
	bra	exit
next2	ldaa	#$FE
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
next3	ldaa	#3

exit	tsx
	ldab	#6
	abx
	txs
	jsr	sd_disable

	pulb
	pulx
	rts

xmit	ldab	#0
xmit1	ldaa	0,x
	jsr	sdspi_write
	inx
	decb
	bne	xmit1
	rts
	endp

sd_flush proc
	jsr	sd_enable
	tsta
	bne	exit
	jsr	sd_disable
exit	rts
	endp
