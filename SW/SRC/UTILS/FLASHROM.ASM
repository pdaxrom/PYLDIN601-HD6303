;
; ROM FLASHER
;
; 10000 - ???
; 12000 - ???
; 14000 - UniBIOS
; 16000 - YGPASCAL 0
; 18000 - UniDOS
; 1A000 - YGPASCAL 1
; 1C000 - ???
; 1F000 - BIOS
;

putc		equ	$F003		;text screen write char

		include ../../DEVMAP.INC

		org $100

		sei

		ldx	#hello
		int	$23

; Setup page port (P6)
;	ldaa	#0
;	staa	REG_PORT6
;	ldaa	#$FF
;	staa	REG_DDRP6

		ldx	#code
		int	$23

		jsr	readid

		int	$25
		tba
		int	$25

		jsr	askfname
		jsr	askpage

		pshx
		pshb

		ldx	#rwquest
		int	$23

		int	$20
		int	$22

		cmpa	#'W'
		beq	gowrite
		cmpa	#'R'
		beq	readonly
		pulb
		pulx
		ldx	#txtexit
		int	$23
		bra	exit

gowrite		ldx	#rebootq
		int	$23
		int	$20
		int	$22
		staa	freboot

		ldx	#txtwrite
		int	$23
		jsr	readfile
		pulb
		pulx
		tsta
		bne	error

		jsr	addrtopage

		ldx	#wrdata
		std	0,x

		ldd	#rombuf
		std	2,x

		ldd	#$2000		; length
		lsrd
		lsrd
		lsrd
		lsrd
		lsrd
		lsrd
		lsrd
		stab	4,x

		jsr	writerom

		ldx	#nl
		jsr	putstr

		ldaa	freboot
		cmpa	#'Y'
		bne	exit
		jmp	$F006

readonly	ldx	#txtread
		int	$23

		pulb
		pulx

		jsr	addrtopage

		pshb
		psha
		int	$25
		tba
		int	$25
		ldx	#nl
		int	$23

		pulx
		sei
		ldaa	MEMPAGE_SEL
		psha
		xgdx
		jsr	setrompage
		ldx	#rombuf
		jsr	wintoram

		pula
		staa	MEMPAGE_SEL

		jsr	writefile
		tsta
		bne	error

exit		rts

error		ldx	#txterror
		int	$23
		rts
;		jmp	F_RESET

; Write command
; X - ADDR
; A - CMD
writecmd	proc
		pshx
		xgdx
		psha
		lsra
		lsra
		lsra
		lsra
		lsra
		oraa	#MEMPAGE_ROM
		pshb
		tab
		ldaa	MEMPAGE_SEL
		anda	#MEMPAGE_FMASK
		aba
		pulb
		staa	MEMPAGE_SEL
		pula
		anda	#$1F
		addd	#$C000
		xgdx
		staa	0,x
		pulx
		rts
		endp

delay		proc
		pshx
		ldx	#2000
loop		dex
		bne	loop
		pulx
		rts
		endp

readid		proc
		sei
		pshx
		ldaa	MEMPAGE_SEL
		psha

		ldx	#$5555
		ldaa	#$AA
		jsr	writecmd

		ldx	#$2AAA
		ldaa	#$55
		jsr	writecmd

		ldx	#$5555
		ldaa	#$90
		jsr	writecmd

		jsr	delay

		ldaa	MEMPAGE_SEL
		anda	#MEMPAGE_FMASK
		oraa	#MEMPAGE_ROM
		staa	MEMPAGE_SEL

		ldaa	$C000
		ldab	$C001
		pshb
		psha

		ldx	#$5555
		ldaa	#$AA
		jsr	writecmd

		ldx	#$2AAA
		ldaa	#$55
		jsr	writecmd

		ldx	#$5555
		ldaa	#$F0
		jsr	writecmd

		jsr	delay

		pulx

		pula
		staa	MEMPAGE_SEL

		xgdx
		pulx
		rts
		endp

; Write sector
; X - ptr
;
; ptr dw sector
; ptr dw buffer
;
writesec	proc
		pshb
		ldab	MEMPAGE_SEL
		pshb
		pshx
		ldx	#$5555
		ldaa	#$AA
		jsr	writecmd

		ldx	#$2AAA
		ldaa	#$55
		jsr	writecmd

		ldx	#$5555
		ldaa	#$A0
		jsr	writecmd
		pulx
		pshx
		ldd	0,x
		bsr	setrompage
		sts	tmps
		lds	2,x
		des
		xgdx
		ldab	#128
loop		pula
		staa	0,x
		inx
		decb
		bne	loop
		lds	tmps
		dex
waitfinish	cmpa	0,x
		bne	waitfinish
		clra
		bra	exit
error		ldaa	#1
exit		pulx
		pulb
		stab	MEMPAGE_SEL
		pulb
		rts
		endp

; Set rom page and return address
; IN:
; D - rom page
; OUT:
; D - address
setrompage	proc
		lsld
		lsld
		psha
		pshb
		anda	#$0F
		bita	#$08
		beq	next
		oraa	#$10
next		oraa	#MEMPAGE_ROM
		tab
		ldaa	MEMPAGE_SEL
		anda	#MEMPAGE_FMASK
		aba
		staa	MEMPAGE_SEL
		pulb
		pula
		lsld
		lsld
		lsld
		lsld
		lsld
		anda	#$1F
		addd	#$C000
		rts
		endp

; Address to rom page
; In:
; BX - Address
; Out:
; D - rom page
addrtopage	proc
		lsrb
		xgdx
		rora
		rorb
		lsrd
		lsrd
		lsrd
		lsrd
		lsrd
		lsrd
		rts
		endp

; X - addr
wintoram	proc
		psha
		pshb
		pshx
		xgdx
		addd	#$2000
		xgdx
		sts	tmps
		txs
		ldx	#$DFFF
loop		ldaa	0,x
		psha
		dex
		cpx	#$BFFF
		bne	loop
		lds	tmps
		pulx
		pulb
		pula
		rts
		endp

; Write ROM
;
; X - write data
;  DW PAGE
;  DW SRC_ADDR
;  DB NUMPAGES
;
writerom	proc
		pshb
		pshx
loop		ldd	0,x
		bsr	printwrsec
		ldaa	4,x
		bsr	printwrtot
		tst	4,x
		beq	exit
		sei
		jsr	writesec
		ldd	0,x
		addd	#1
		std	0,x
		ldd	2,x
		addd	#128
		std	2,x
		dec	4,x
		bra	loop
exit		clra
		pulx
		pulb
		rts
		endp

printwrsec	proc
		pshx
		psha
		pshb
		ldx	#txtwritesec
		jsr	putstr
		jsr	puthex
		tba
		jsr	puthex
		pulb
		pula
		pulx
		rts
		endp

printwrtot	proc
		pshx
		ldx	#txtwritetotal
		jsr	putstr
		jsr	puthex
		pulx
		rts
		endp

;
; IN:
; A - page
; OUT:
; D - 32-16 bits ADDR
; X - 15-0  bits ADDR
rom2addr	proc
		tab
		clra
		lsrb
		rora
		lsrb
		rora
		lsrb
		rora
		xgdx
		ldab	#1
		clra
		rts
		endp

askpage		proc
		ldx	#txtpagename
		int	$23
		int	$20
		int	$22
		cmpa	#'0'
		bcs	error
		cmpa	#'6'
		bhi	error
		suba	#'0'
		bra	rom2addr
error		ldx	#txtpageerr
		int	$23
		bra	askpage
		endp

askfname	proc
		ldx	#txtromname
		int	$23
		ldx	#filename
		clr	0,x
		ldab	#40
		int	$21
		rts
		endp

readfile	proc
		ldx	#filename
		stx	ftable
		ldx	#0
		stx	ftable+2
		ldaa	#1
		ldx     #ftable
		int	$4A
		tsta
		bne	error1

		tba
		pshb
		psha
		ldx	#ftable
		ldd	#rombuf
		std	0,x
		ldd	#$2000
		std	2,x
		pula
		int	$4C
		pulb
		tsta
		bne	error2
		cpx	#$2000
		bne	wrongrom

		tba
		int	$4E
		rts
error1		ldx	#txtcantopen
errorx		int	$23
		rts
error2		ldx	#txtrderr
		bra	errorx
wrongrom	pshx
		ldx	#txtwrongrom
		int	$23
		pulx
		int	$24
		ldaa	#$ff
		rts
txtwrongrom	db	10, 'Wrong ROM size!', 10, 'Expected 8192, but read ', 0
txtcantopen	db	10, 'Cannot open file!', 0
txtrderr	db	10, 'File read error!', 0
		endp

writefile	proc
		ldx	#filename
		stx	ftable
		ldx	#0
		stx	ftable+2
		ldaa	#0
		ldx     #ftable
		int	$4B
		tsta
		bne	error1

		tba
		pshb
		psha
		ldx	#ftable
		ldd	#rombuf
		std	0,x
		ldd	#$2000
		std	2,x
		pula
		int	$4D
		pulb
		tsta
		bne	error2
		cpx	#$2000
		bne	wrongrom

		tba
		int	$4E
		rts
error1		ldx	#txtcantopen
errorx		int	$23
		rts
error2		ldx	#txtwrerr
		bra	errorx
wrongrom	pshx
		ldx	#txtwrongrom
		int	$23
		pulx
		int	$24
		ldaa	#$ff
		rts
txtwrongrom	db	10, 'Cannot write ROM file!', 10, 'Expected 8192, but written ', 0
txtcantopen	db	10, 'Cannot open file!', 0
txtwrerr	db	10, 'File write error!', 0
		endp

putstr		proc
		pshx
loop		ldaa	0,x
		beq	exit
		jsr	putc
		inx
		bra	loop
exit		pulx
		rts
		endp

puthex		proc
		psha
		bsr	prhex2
		pula
		rts
prhex2		psha
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
prhexz		jsr	putc
		rts
		endp

hello		db	10, 'FLASHROM Utility version 1.0'
		db	10, '(c) sashz <sashz@pdaXrom.org>, 2018-2019', 10, 0
code		db	10, 'Flash Manufacture/Device code ', 0
nl		db	10, 0
txtwritesec	db	10, 'Write sector ', 0
txtwritetotal	db	', Total ', 0
txtromname	db	10, 'ROM name? ',0
txtpagename	db	10, 'Page (0-6)? ', 0
txtpageerr	db	10, 'Wrong page!', 10, 'Type again or press CTRL+C to exit.', 0

rwquest		db	10, 'Write(W) Read(R)? ', 0

rebootq		db	10, 'Reboot after flashing (Y/N)? ', 0

txterror	db	10, 'Error!', 10, 0

txtexit		db	10, 'Nothing to do, exit.', 10, 0

txtread		db	10, '*** READ  ROM ***', 10, 0
txtwrite	db	10, '*** WRITE ROM ***', 10, 0

freboot		db	0

filename	ds	41

ftable		dw	0
		dw	0

tmps		dw	0

wrdata		dw	0
		dw	0
		db	0

mancode		db	0
devcode		db	0

rombuf		ds	$2000
