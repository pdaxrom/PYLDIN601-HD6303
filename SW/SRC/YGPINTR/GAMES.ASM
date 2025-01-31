;******************************************************************************
;*									      *
;*			       Ycode Interpreter			      *
;*									      *
;*				  Version 1.10				      *
;*			     (RAM resident version)			      *
;*									      *
;*			  (c) 1989 ������ ������ /YGP/			      *
;*									      *
;*		Processor:		MC6800 (�� 601) 		      *
;*		Computer:		������ 601			      *
;*		Operating System:	UniDOS (R)			      *
;*									      *
;*		Language:		MC6800 Assembler		      *
;*									      *
;*	��������� ������������� ��	�����  ����� /Eagle/		      *
;*					���    �����			      *
;*									      *
;*		       � ���� � ��	������ �������� /YWY/		      *
;*									      *
;******************************************************************************

		ORG	$100		; ���� ���� � .CMD file

MinRES          =       $9800           ; ������ �� ��� ���������� �����
		include interrupts.inc
		include undocumented.inc
		include globals.Y

; ���� � ����� �� Y.ASM ���� � �����������

;     ���� ���� �� �������������� � �������, ��������� �� ���� �� �����������,
; ���������� � ����������� ��  ��������������.	��  ���� ��  �� � �����,  �� �
; ������ �� �� �������� ��� ������������� ���������� �� ��������.
;     �������������� �� ��������� ���� ���������� �������� �� ���������� �����
; RAMstart � ����� $4000 ����� ����� (�.�. 16 Kbytes).
;     ����� ����� �� �������������� �� ��������  ���� ���� ����� � ���� �����.
; ���� 1 ����� �� ������� �� RAMstart � ����� �� RAMstart + $2000.
;     ���  ����������� ��  ���� ����  �� �������������� � ����� � �������,  ��
; ������������ ������ �� ���������  ������ - 601 � �� $ba.. ������,  ������ ��
; �������  ������  RAMstart = $ba00 - $4000.  �� ������ � ���� ��������,  �� �
; ���������� �� �� ����� ������ RAMstart � �������������� �� �� ������ �� ����
; �����.

		error	bank1addr / $c000 ; ������ �� ��� �� RAM
		error	bank2addr / $c000 ; ������ �� ��� �� RAM

InstallYcode	proc
		ds	$11, 1		; ������� 11 NOP-� �� �� ���� ������
		ldx	#CrightMsg	; ���������� �� ����� $111
		int	_Wstr

		lda	ResidentPtr+1	; ����������� ���� Resident > RAMstart
		ldb	ResidentPtr
                cmpb    #/MinRES        ; ���������� �������� �������
                bhi     LoadInterpreter ; Resident < MinRES => ���� �����
                ldx     #NoMemory
                int     _Wstr
                int     _Terminate

FreadTBL	dw	RAMstart
		dw	$2000		; ����� ���� � ����� $2000

FopenTBL	dw	Name, 0

LoadInterpreter proc

                ldx     #RAMstart + $4000
                stx     LoMemPtr
		jsr	LoadROMbank
		inc	Name+1		; ������ �� �������
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

; ������������� �� ROM ����� ���� ����� �� ���� �������������� ��� ���� �� ROM.
; import: X - start address in RAM of this ROM bank

InitROMbank	proc
		stx	wrk_		; ������� ������ �� ��������� �
		lda	#16		; ���������. (StartAddress + $16)
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

wrk_		ds	2		; ������� ����������
wrk_1		ds	2		; ����� ���� ���� � Globals
wrk_2		ds	2		; �� ��������������

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

WaitKey                                 ; �� �� �� �� ������� �������
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
                int     _ReadKey        ; ������� �� �������
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

MainScreen      db      '��[ UniPascal Games v1.10, (c) SRDL ]��', 10
                db      '�                                     �', 10
                db      '�         ��������� � �������         �', 10
                db      '�                                     �', 10
                db      '�           ����� � �������           �', 10
                db      '�                                     �', 10
                db      '�           ������ � �����            �', 10
                db      '�                                     �', 10
                db      '�               ������                �', 10
                db      '�                                     �',  0
MainScr         db      '� ����������������������������������� �', 10
                db      '� �                                 � �', 10
                db      '� �                                 � �', 10
                db      '� �                                 � �', 10
                db      '� �                                 � �', 10
                db      '� �                                 � �', 10
                db      '� �                                 � �', 10
                db      '� �                                 � �', 10
                db      '� �                                 � �', 10
                db      '� �                                 � �', 10
                db      '� �                                 � �', 10
                db      '� �                                 � �', 10
                db      '� ����������������������������������� �', 10
                db      '�                                     �', 10
                db      '�����[ ����, �������� ����! (', 27, '', 27, ') ]�����',  0

                db      8, 2, 30, 2
XOscr          ;db      '� ����������������������������������� �', 10
                db      '� �� � � � � � � X � X X � � � � � �� �', 10
                db      '� �� � � � � � � X O O O O O � � � �� �', 10
                db      '� �� � � � � � X O O O O X � � � � �� �', 10
                db      '� �� � � � � � O � X X O � � � � � �� �', 10
                db      '� �� � � � O X X X O X � � � � � � �� �', 10
                db      '� �� � � � O � X O O � X � X � O � �� �', 10
                db      '� �� � O X X X X O X O � O � X � � �� �', 10
                db      '� �� � � � O O X X X X O � X � � � �� �', 10
                db      '� �� � � � � � O X O O O X � � � � �� �', 10
                db      '� �� � � � � � � � X � X � O � � � �� �', 10
                db      '� �� � � � � � � � � O � � � � � � �� �', 10
                db 0
               ;db      '� ����������������������������������� �',  0

                db      8, 4, 30, 4
BOscr          ;db      '� ����������������������������������� �', 10
                db      '� �                  �  �  �  �  �  � �', 10
                db      '� �                  �  �  �  �  �  � �', 10
                db      '� �                  �  �  �  �  �  � �', 10
                db      '� ��                 �  �  �  �  �  � �', 10
                db      '� ��                 �  �  �  �  �  � �', 10
                db      '� ��            ',27,'    �  �  �  �  �  � �', 10
                db      '� ��                 �  �  �  �  �  � �', 10
                db      '� ��                 �  �  �  �  �  � �', 10
                db      '� �                  �  �  �  �  �  � �', 10
                db      '� �                  �  �  �  �  �  � �', 10
                db      '� �                  �  �  �  �  �  � �', 10
                db 0
               ;db      '� ����������������������������������� �',  0

                db      8, 6, 30, 6
BCscr          ;db      '� ����������������������������������� �', 10
                db      '� ӷ����ӡ��   (c) 1990   � �����ӡ�� �', 10
                db      '� ����������     ����,    ����������� �', 10
                db      '� �1207 �12�   ���������  � 3617 �11� �', 10
                db      '� ����������  ����������� ����������� �', 10
                db      '� �3546 �00���������������� 4025 �02� �', 10
                db      '� ����������   ��������   ����������� �', 10
                db      '� �9702 �30� �����  ����� � 7654 �01� �', 10
                db      '� ���������� � 7 �  � 9 � ����������� �', 10
                db      '� �9701 �21� �����  ����� � 6210 �02� �', 10
                db      '� ���������� ������:    5 ����������� �', 10
                db      '� �9102 �  ���������������� 3142 �40� �', 10
                db 0
               ;db      '� ����������������������������������� �',  0

                db      8, 8, 30, 8
SBscr          ;db      '� ����������������������������������� �', 10
                db      '� �                                 � �', 10
                db      '� �             �����������         � �', 10
                db      '� �             �  �      �         � �', 10
                db      '� �      ��������  �      ��', 27,'   ', 27, '   � �', 10
                db      '� �      �         �                � �', 10
                db      '� �      �   �������������          � �', 10
                db      '� �      �         �                � �', 10
                db      '� �                �                � �', 10
                db      '� �                �                � �', 10
                db      '� �                                 � �', 10
                db      '� �                                 � �', 10
                db 0
               ;db      '� ����������������������������������� �',  0

                error   * / RAMstart

NoMemory        db      '���� ���������� ���������� �����!', 0

CrightMSG       db      ' ���� �� ������������� ������ 601/601A.', 10
                db      '      �������� �� ����� UniPascal', 10
                db      '(c) 1990, 91 ���� "��������� ����������"', 0

                END.    GAMES