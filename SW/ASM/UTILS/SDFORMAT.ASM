		org	$100

fat12sec	section	$0B
sectorsz	ds	2
clustersz	ds	1
reservsz	ds	2
fatnum		ds	1
dirsz		ds	2
sectnum		ds	2
mediadesc	ds	1
fatsz		ds	2
tracksz		ds	2
headnum		ds	2
		ends

		ldx	#text1
		int	$23
		int	$20
		int	$22
		cmpa	#'A'
		bcs	drverror
		cmpa	#'Z'
		bhi	drverror
		suba	#'A'
		staa	drive

		ldx	#areyou
		int	$23
		int	$20
		cmpa	#'Y'
		bne	exit
		bra	format

drverror	ldx	#texterdrv
		bra	showerror

format		ldx	#newline
		int	$23

		ldx	#bootsec
		ldab	x,reservsz
		ldaa	x,reservsz+1
		pshb
		psha
		ldaa	x,fatnum
		pulx
fatloop		psha
		pshx
		bsr	fatformat
		ldx	#newline
		int	$23
		pulx
		xgdx
		ldx	#bootsec
		addb	x,fatsz
		adca	x,fatsz+1
		xgdx
		pula
		deca
		bne	fatloop

		bsr	dirformat

		ldx	#bootsec
		stx	param
		ldx	#0
		stx	param+3

		ldx	#param
		ldaa	#2
		int	$40
		tsta
		bne	error

		ldx	#textok
		int	$23

exit		rts

error		ldx	#texterror
showerror	int	$23
		rts

fatformat	proc
		stx	param+3

		pshx

		ldx	#buffer
		stx	param

clrbuf		clr	x
		inx
		cpx	#buffer+512
		bne	clrbuf

		ldx	#bootsec
		ldab	x,fatsz
		ldaa	x,fatsz+1
		xgdx

		bsr	clearsectors

		ldx	#newline
		int	$23

		pulx

		stx	param+3

		ldaa	#$F0
		staa	buffer
		ldd	#$FFFF
		stx	buffer+1

		ldx	#param
		ldaa	#2
		int	$40
		tsta
		bne	error

		rts
		endp

dirformat	proc
		stx	param+3

		ldx	#buffer
		stx	param

clrbuf		clr	x
		inx
		cpx	#buffer+512
		bne	clrbuf

		ldx	#bootsec
		ldab	x,dirsz
		ldaa	x,dirsz+1
		ldx	#32
		int	$EE
		xgdx
		ldd	#512
		int	$EF
		xgdx
		bsr	clearsectors

		rts
		endp

clearsectors	proc
loop		pshx
		ldx	param+3
		pshx
		ldx	#sectorno
		int	$23
		pulx
		int	$24
		ldx	#param
		ldaa	#2
		int	$40
		tsta
		bne	error
		ldx	param+3
		inx
		stx	param+3
		pulx
		dex
		bne	loop
		rts
		endp

text1		db	'SD Format utility v1.0',10
		db	'(c) sashz <sashz@pdaXrom.org>, 2019',10
		db	'Boot disk (A-Z)? ',0
newline		db	10,0
texterdrv	db	10,'Drive error',10,0
texterror	db	10,'Error',10,0
textok		db	10,'Completed',10,0

areyou		db	10,'Are you sure(Y/N)? ',0

sectorno	db	13,'Sector: ',0

param		dw	buffer
drive		db	0
		dw	0

bootsec		db	  $EB,$4B,$90,$55,$6E,$69,$44,$4F,$53,$20,$20,$00,$02,$08,$01,$00
		db	  $02,$00,$02,$90,$7E,$F8,$0C,$00,$51,$00,$02,$00,$00,$00,$00,$00
		db	  $00,$00,$00,$00,$00,$00,$29,$C5,$56,$C4,$11,$55,$6E,$69,$44,$4F
		db	  $53,$20,$20,$20,$20,$20,$46,$41,$54,$31,$32,$20,$20,$20,$00,$00
		db	  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$E9,$B0,$00
		db	  $BD,$01,$B3,$FF,$01,$AA,$CE,$00,$00,$FF,$01,$AC,$86,$01,$CE,$01
		db	  $AA,$3F,$4A,$4D,$26,$32,$F7,$01,$B2,$17,$CE,$01,$AE,$3F,$51,$FE
		db	  $01,$AE,$26,$24,$FE,$01,$B0,$FF,$01,$AC,$CE,$10,$00,$FF,$01,$AA
		db	  $B6,$01,$B2,$CE,$01,$AA,$3F,$4C,$4D,$26,$0D,$BC,$01,$B0,$26,$08
		db	  $B6,$01,$B2,$3F,$4E,$7E,$10,$00,$CE,$02,$60,$3F,$23,$3F,$20,$7F
		db	  $E6,$C0,$FE,$FF,$FE,$01,$01,$01,$6E,$00,$00,$00,$00,$00,$00,$00
		db	  $00,$00,$00,$CE,$00,$00,$3F,$41,$4D,$26,$07,$C1,$02,$26,$03,$7F
		db	  $EB,$BD,$CE,$02,$AA,$39,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db	  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db	  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db	  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db	  $0E,$1F,$BE,$60,$7D,$FC,$AC,$0A,$C0,$74,$06,$B4,$0E,$CD,$10,$EB
		db	  $F5,$33,$C0,$CD,$16,$CD,$19,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db	  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db	  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db	  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db	  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db	  $0D,$0A,$0A,$4E,$6F,$6E,$2D,$53,$79,$73,$74,$65,$6D,$20,$64,$69
		db	  $73,$6B,$20,$6F,$72,$20,$64,$69,$73,$6B,$20,$65,$72,$72,$6F,$72
		db	  $0D,$0A,$52,$65,$70,$6C,$61,$63,$65,$20,$61,$6E,$64,$20,$73,$74
		db	  $72,$69,$6B,$65,$20,$61,$6E,$79,$20,$6B,$65,$79,$20,$77,$68,$65
		db	  $6E,$20,$72,$65,$61,$64,$79,$0D,$0A,$00,$55,$4E,$49,$44,$4F,$53
		db	  $2E,$43,$4D,$44,$00,$00,$00,$00
		db	  'SDFormat Utility'
		db	  '  Version 1.0   '
		db	  '(C) sashz <sashz'
		db	  '@pdaXrom.org>, 2'
		db	  '019 '
		db	  $00,$00,$A5,$5A

buffer		ds	512,0
