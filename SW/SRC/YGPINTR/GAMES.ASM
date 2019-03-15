;******************************************************************************
;*									      *
;*			       Ycode Interpreter			      *
;*									      *
;*				  Version 1.10				      *
;*			     (RAM resident version)			      *
;*									      *
;*			  (c) 1989 Гео░ги Пе▓░ов /YGP/			      *
;*									      *
;*		Processor:		MC6800 (СМ 601) 		      *
;*		Computer:		П║лдин 601			      *
;*		Operating System:	UniDOS (R)			      *
;*									      *
;*		Language:		MC6800 Assembler		      *
;*									      *
;*	Спе╢иални благода░но▒▓и на	О░лин  Шопов /Eagle/		      *
;*					Иво    Ненов			      *
;*									      *
;*		       А ▒║╣о и на	Вале░и Т░и┤онов /YWY/		      *
;*									      *
;******************************************************************************

		ORG	$100		; ▓ази ╖а▒▓ е .CMD file

MinRES          =       $9800           ; и▒каме да има до▒▓а▓║╖но паме▓
		include interrupts.inc
		include undocumented.inc
		include globals.Y

; ▓ова е взе▓о о▓ Y.ASM ка▓о е позак║░пено

;     Тази ╖а▒▓ о▓ ин▓е░п░е▓а▓о░а е помо╣на, използ│ва ▒е ▒амо за ▒║здаване▓о,
; ▓е▒▓ване▓о и о▓лаждане▓о на  ин▓е░п░е▓а▓о░а.	Не  ▒амо ╖е  не е н│жна,  но и
; ▓░┐бва да ▒е п░ема╡не п░и окон╖а▓елно▓о зав║░╕ване на п░од│к▓а.
;     Ин▓е░п░е▓а▓о░а ▒е ин▒▓али░а ка▓о ░езиден▓на п░ог░ама о▓ ┤ик▒и░ани┐ ад░е▒
; RAMstart и заема $4000 бай▓а м┐▒▓о (▓.е. 16 Kbytes).
;     Две▓е ╖а▒▓и на ин▓е░п░е▓а▓о░а ▒е за░ежда▓  една ▒лед д░│га в ▓ази паме▓.
; Ка▓о 1 банка ▒е за░ежда о▓ RAMstart а в▓о░а о▓ RAMstart + $2000.
;     П░и  напи▒ване▓о на  ▓ази ╖а▒▓  о▓ ин▓е░п░е▓а▓о░а е взе▓о в п░едвид,  ╖е
; ░езиден▓на▓а обла▒▓ на комп╛▓║░а  П║лдин - 601 е о▓ $ba.. наго░е,  за▓ова ▒е
; по▒▓ав┐  ад░е▒а  RAMstart = $ba00 - $4000.  Но в▒и╖ко е ▓ака напи▒ано,  ╖е е
; до▒▓а▓║╖но да ▒е ▒мени ад░е▒а RAMstart и ин▓е░п░е▓а▓о░а ╣е ▒е за░еди о▓ д░│г
; ад░е▒.

		error	bank1addr / $c000 ; ▓░┐бва да ▒ме на RAM
		error	bank2addr / $c000 ; ▓░┐бва да ▒ме на RAM

InstallYcode	proc
		ds	$11, 1		; ▒лагаме 11 NOP-а за да б║де по╖нем
		ldx	#CrightMsg	; п░ог░ама▓а о▓ ад░е▒ $111
		int	_Wstr

		lda	ResidentPtr+1	; п░ове░┐ваме дали Resident > RAMstart
		ldb	ResidentPtr
                cmpb    #/MinRES        ; ▒░авн┐ваме ▒▓а░╕и▓е бай▓ове
                bhi     LoadInterpreter ; Resident < MinRES => н┐ма паме▓
                ldx     #NoMemory
                int     _Wstr
                int     _Terminate

FreadTBL	dw	RAMstart
		dw	$2000		; в▒еки ┤айл е д║л║г $2000

FopenTBL	dw	Name, 0

LoadInterpreter proc

                ldx     #RAMstart + $4000
                stx     LoMemPtr
		jsr	LoadROMbank
		inc	Name+1		; номе░а на банка▓а
		ldx	#RAMstart + $2000
		stx	FreadTBL
		jsr	LoadROMbank
                jmp     SelectGame
		endp;	LoadInterpreter


LoadROMbank	proc

		ldx	#FopenTBL
		lda	#1
		int	_Fopen
		tsta
		beq	OKopened
		ldx	#Error1
		int	_Wstr
		int	_Whex
		ldx	#Error3
		int	_Wstr
		bra	ErrorName
OKopened	stb	FileHandle
		ldx	#FreadTBL
		tba			; set file handle
		int	_Fread
		tsta
		beq	OKreaded
		ldx	#Error1
		int	_Wstr
		int	_Whex
		ldx	#Error2
		int	_Wstr
ErrorName	ldx	#Name
		int	_Wstr
		int	_Terminate
OKreaded
		ldx	FreadTBL
                jsr     InitROMbank
		lda	FileHandle
		int	_Fclose
		rts

FileHandle	db	0
		endp;	LoadROMbank

Name		db	'Y1.RAM', 0
Error1		db	10, 'I/O error $', 0
Error2		db	' loading file ', 0
Error3		db	' opening file ', 0

; Ини╢иализа╢и┐ на ROM банка ▓ака как▓о би била ини╢иализи░ана ако бе╕е на ROM.
; import: X - start address in RAM of this ROM bank

InitROMbank	proc
		stx	wrk_		; ▒м┐▓аме ад░е▒а на ▓абли╢а▓а ▒
		lda	#16		; ин▓е░║п▓и. (StartAddress + $16)
		clrb
		adda	wrk_+1
		adcb	wrk_
		sta	wrk_1+1
		stb	wrk_1
		ldx	wrk_1

loop		lda	x
		beq	ExitLoop
		clrb
		stx	wrk_1
		ldx	x, 1
		int	_SetIntVec
		ldx	wrk_1
		inx
		inx
		inx
		bra	loop
ExitLoop
		ldx	wrk_
		jmp	x, 10		; (jsr + rts) make a cold initialize
		endp;	InitROMbank

wrk_		ds	2		; ░або▓ни п░оменливи
wrk_1		ds	2		; н┐ма▓ ни╣о об╣о ▒ Globals
wrk_2		ds	2		; на ин▓е░п░е▓а▓о░а

		endp;	InstallYcode

SelectGame      proc

MainSelect
                clrA                    ; set bw40 screen
                clrB
                int     $12
                ldx     #MainScreen
                int     _Wstr;
                lda     #10
                int     _Wchar
                ldx     #MainScr
                int     _Wstr;
                jsr     ShowGameNo
SelectLoop
                int     _KeyPress
                incA
                bne     HasKey

                clra
                clrb
                int     _GotoXY
                ldx     #MainScreen

                int     _KeyPress
                incA
                bne     HasKey

                int     _Wstr;
                jsr     ShowGameNo

WaitKey                                 ; За да не ▒е показва к│░▒о░а
                int     _KeyPress
                incA
                bne     HasKey

                ldb     #200
wait
                phb                     ; preserve Acc B
                int     _UniDOSversion  ; Get UniDOS version
                int     _UniDOSversion  ; Get again to make shure
                                        ; we don't need it, so flush it
                plB                     ;                and Acc B
                decb
                bne     wait
                bra     selectloop ;WaitKey
HasKey
                int     _ReadKey        ; вземаме ▒и коп╖е▓о
                cmpa    #$c0            ; cr
                bne     NOTcr
                jsr     RunGameNo
                jmp     MainSelect
NOTcr           cmpa    #$c1            ; left
                bne     NotLeft
prevGame        dec     GameNo
                bpl     SelectLoop
                lda     #3
                sta     GameNo
                bra     SelectLoop
NOTleft         cmpa    #$c4            ; up
                beq     prevGame
                cmpa    #$c2            ; right
                bne     NOTright
nextGame        lda     GameNo
                inca
                cmpa    #3
                bls     OKgame
                clra
OKgame          sta     GameNo
                bra     SelectLoop
NOTright        cmpa    #$c3            ; down
                beq     nextGame
                bra     WaitKey

ShowGameNo      proc
                clra
                ldb     #11
               ;ldb     #10
                int     _GotoXY
                lda     GameNo
                bne     notXO
                ldx     #XOscr
notXO           deca
                bne     notBO
                ldx     #BOscr
notBO           deca
                bne     notBC
                ldx     #BCscr
notBC           deca
                bne     notSB
                ldx     #SBscr
notSB
                int     _Wstr
                dex
                dex
                lda     x, 0
                ldb     x, 1
                int     _GotoXY
                lda     #'<'
                int     _Wchar
                dex
                dex
                lda     x, 0
                ldb     x, 1
                int     _GotoXY
                lda     #'>'
                int     _Wchar
                rts
                endp; ShowGameNo

RunGameNo       proc
                lda     GameNo
                bne     notXO
                ldx     #runXO
notXO           deca
                bne     notBO
                ldx     #runBO
notBO           deca
                bne     notBC
                ldx     #runBC
notBC           deca
                bne     notSB
                ldx     #runSB
notSB
                lda     #12
                int     _Wchar
                int     _Execute
                tsta
                beq     rts
                int     _ReadKey
rts             rts

runXO           db      'XO bw', 0
runBO           db      'BrickOut bw', 0
runBC           db      'BullCow bw', 0
runSB           db      'TheSnake bw', 0
                endp; RunGameNo

GameNo          db      0
                endp; SelectGame

MainScreen      db      '╔═[ UniPascal Games v1.10, (c) SRDL ]═╫', 10
                db      '╟                                     ╟', 10
                db      '╟         К░║▒▓╖е▓а и Н│ли╖ки         ╟', 10
                db      '╟                                     ╟', 10
                db      '╟           Т│╡ли в ▒▓ена▓а           ╟', 10
                db      '╟                                     ╟', 10
                db      '╟           Бикове и К░ави            ╟', 10
                db      '╟                                     ╟', 10
                db      '╟               Зми┐▓а                ╟', 10
                db      '╟                                     ╟',  0
MainScr         db      '╟ ┌─────────────────────────────────╧ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ └─────────────────────────────────┘ ╟', 10
                db      '╟                                     ╟', 10
                db      '╚════[ Мол┐, избе░е▓е иг░а! (', 27, '', 27, ') ]════╪',  0

                db      8, 2, 30, 2
XOscr          ;db      '╟ ┌─────────────────────────────────╧ ╟', 10
                db      '╟ ╙· · · · · · · X · X X · · · · · ·╙ ╟', 10
                db      '╟ ╙· · · · · · · X O O O O O · · · ·╙ ╟', 10
                db      '╟ ╙· · · · · · X O O O O X · · · · ·╙ ╟', 10
                db      '╟ ╙· · · · · · O · X X O · · · · · ·╙ ╟', 10
                db      '╟ ╙· · · · O X X X O X · · · · · · ·╙ ╟', 10
                db      '╟ ╙· · · · O · X O O · X · X · O · ·╙ ╟', 10
                db      '╟ ╙· · O X X X X O X O · O · X · · ·╙ ╟', 10
                db      '╟ ╙· · · · O O X X X X O · X · · · ·╙ ╟', 10
                db      '╟ ╙· · · · · · O X O O O X · · · · ·╙ ╟', 10
                db      '╟ ╙· · · · · · · · X · X · O · · · ·╙ ╟', 10
                db      '╟ ╙· · · · · · · · · O · · · · · · ·╙ ╟', 10
                db 0
               ;db      '╟ └─────────────────────────────────┘ ╟',  0

                db      8, 4, 30, 4
BOscr          ;db      '╟ ┌─────────────────────────────────╧ ╟', 10
                db      '╟ ╙                  ╨  ╨  ╨  ╨  ╨  ╙ ╟', 10
                db      '╟ ╙                  ╨  ╨  ╨  ╨  ╨  ╙ ╟', 10
                db      '╟ ╙                  ╨  ╨  ╨  ╨  ╨  ╙ ╟', 10
                db      '╟ ╙▐                 ╨  ╨  ╨  ╨  ╨  ╙ ╟', 10
                db      '╟ ╙█                 ╨  ╨  ╨  ╨  ╨  ╙ ╟', 10
                db      '╟ ╙█            ',27,'    ╨  ╨  ╨  ╨  ╨  ╙ ╟', 10
                db      '╟ ╙█                 ╨  ╨  ╨  ╨  ╨  ╙ ╟', 10
                db      '╟ ╙▐                 ╨  ╨  ╨  ╨  ╨  ╙ ╟', 10
                db      '╟ ╙                  ╨  ╨  ╨  ╨  ╨  ╙ ╟', 10
                db      '╟ ╙                  ╨  ╨  ╨  ╨  ╨  ╙ ╟', 10
                db      '╟ ╙                  ╨  ╨  ╨  ╨  ╨  ╙ ╟', 10
                db 0
               ;db      '╟ └─────────────────────────────────┘ ╟',  0

                db      8, 6, 30, 6
BCscr          ;db      '╟ ┌─────────────────────────────────╧ ╟', 10
                db      '╟ ╙╖и▒ло╙бк╙   (c) 1990   ╙ ╖и▒ло╙бк╙ ╟', 10
                db      '╟ ╙─────┼──╘     НИПЛ,    ├──────┼──╙ ╟', 10
                db      '╟ ╙1207 ╙12╙   П░ог░амно  ╙ 3617 ╙11╙ ╟', 10
                db      '╟ ╙─────┼──╘  О▒иг│░┐ване ├──────┼──╙ ╟', 10
                db      '╟ ╙3546 ╙00├──────────────╘ 4025 ╙02╙ ╟', 10
                db      '╟ ╙─────┼──╘   ░ез│л▓а▓   ├──────┼──╙ ╟', 10
                db      '╟ ╙9702 ╙30╙ ┌───╧  ┌───╧ ╙ 7654 ╙01╙ ╟', 10
                db      '╟ ╙─────┼──╘ ╙ 7 ╙  ╙ 9 ╙ ├──────┼──╙ ╟', 10
                db      '╟ ╙9701 ╙21╙ └───┘  └───┘ ╙ 6210 ╙02╙ ╟', 10
                db      '╟ ╙─────┼──╘ ░еми▓а:    5 ├──────┼──╙ ╟', 10
                db      '╟ ╙9102 ╙  ├──────────────╘ 3142 ╙40╙ ╟', 10
                db 0
               ;db      '╟ └─────────────────────────────────┘ ╟',  0

                db      8, 8, 30, 8
SBscr          ;db      '╟ ┌─────────────────────────────────╧ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ ╙             ╔═════════╫         ╙ ╟', 10
                db      '╟ ╙             ╟  ╤      ╟         ╙ ╟', 10
                db      '╟ ╙      ╔══════╪  ╤      ╚═', 27,'   ', 27, '   ╙ ╟', 10
                db      '╟ ╙      ╟         ╤                ╙ ╟', 10
                db      '╟ ╙      ╟   ╤╤╤╤╤╤╤╤╤╤╤╤╤          ╙ ╟', 10
                db      '╟ ╙      ╟         ╤                ╙ ╟', 10
                db      '╟ ╙                ╤                ╙ ╟', 10
                db      '╟ ╙                ╤                ╙ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db      '╟ ╙                                 ╙ ╟', 10
                db 0
               ;db      '╟ └─────────────────────────────────┘ ╟',  0

                error   * / RAMstart

NoMemory        db      'Н┐ма до▒▓а▓║╖но опе░а▓ивна паме▓!', 0

CrightMSG       db      ' Иг░и за мик░окомп╛▓║░ П║лдин 601/601A.', 10
                db      '      напи▒ани на езика UniPascal', 10
                db      '(c) 1990, 91 НИПЛ "П░ог░амно О▒иг│░ване"', 0

                END.    GAMES