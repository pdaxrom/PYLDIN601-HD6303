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

		include interrup.inc
		include undocume.inc
		include globals.Y

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
		cmpb	#/RAMstart	; ���������� �������� �������
		bhi	NotHere 	; Resident > RAMstart => ���� ��
		bcs	MayHere 	; Resident < RAMstart => ���� �� � ���
		cmpa	#RAMstart	; ���������� �������� �������
		bhi	CantInstall	; Lo(Resident) > Lo(RAMstart) (Hi = Hi)

MayHere
		ldx	#RAMstart	; �������� ��� ����� � ������ ����
		stx	wrk_1		; �� �� ������� � ����. �� ����� �����-
		ldx	#ROMheader	; ������ ���� �������� ���
		stx	wrk_2
		lda	#10		; first 10 bytes match?
loop		ldx	wrk_1
		ldb	x, 0
		inx
		stx	wrk_1
		ldx	wrk_2
		xorb	x, 0
		bne	CantInstall	; �� �������� => ��� ���� �����
		inx
		stx	wrk_2
		deca
		bne	loop
		ldx	#Replaced	; ����������� ����� �� �����
		stx	WhatOccure	; �� ���� �� � �������

		ldx	#bank1addr	; �������������� � ���� ���� �� ��
		clra			; �������� CheckSum in case of
loop1		adda	x, 0
		inx
		cpx	#bank1addr + $2000
		bne	loop1
		tsta
		beq	_1_IsOK
		ldx	#Bank1Bad
		int	_Wstr
_1_IsOK
		ldx	#bank2addr
		clra
loop2		adda	x, 0
		inx
		cpx	#bank2addr + $2000
		bne	loop2
		tsta
		beq	_2_IsOK
		ldx	#Bank2Bad
		int	_Wstr
_2_IsOK
		jmp	LoadInterpreter

NotHere 	clra
GetMemLoop	ldb	#8		; Get one Page on Page Boundary
		ldx	#$100
		int	_GetMem
		cpx	#0
		beq	CantInstall	; ���� �� ������ �� �� ������
		inca
		cpx	#RAMstart
		bne	GetMemLoop
		cmpa	#$40		; �������� �� ��� ������� ������
		bcs	CantInstall
		int	_Resident
		jmp	LoadInterpreter

CantInstall	ldx	#CantMsg
		int	_Wstr
		int	_Terminate

CantMsg 	db	10, "Can't install Interpreter!", 0
Interpreters	db	10, "Interpreter's ", 0
Installed	db	' Installed', 0
Replaced	db	' Replaced', 0
Bank		db	'Bank ', 0
Name		db	'Y1.RAM', 0
Error1		db	10, 'I/O error $', 0
Error2		db	' loading file ', 0
Error3		db	' opening file ', 0
CrightMsg	db	'Ycode interpreter: RAM resident version.', 0
Bank1Bad	db	10, "Bank 1 fails check.", 7, 0
Bank2Bad	db	10, "Bank 2 fails check.", 7, 0

FreadTBL	dw	RAMstart
		dw	$2000		; ����� ���� � ����� $2000

FopenTBL	dw	Name, 0

WhatOccure	dw	Installed

LoadInterpreter proc

		jsr	LoadROMbank
		inc	Name+1		; ������ �� �������
		ldx	#RAMstart + $2000
		stx	FreadTBL
		jsr	LoadROMbank
		int	_Terminate
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
		jsr	InitROMbank
		ldx	#Interpreters
		int	_Wstr
		ldx	#Bank
		int	_Wstr
		lda	Name+1
		int	_Wchar		; write Bank No
		ldx	WhatOccure
		int	_Wstr
		lda	FileHandle
		int	_Fclose
		rts

FileHandle	db	0
		endp;	LoadROMbank

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

;------------------------------------------------------------------------------
ROMheader
		dw	$a55a		; ����� �� ���� BIOS
		db	'YGPascal'
Initialize	jmp	0		; cold init address
		jmp	0

IntrptTbl				; start of interrupt table

		END.	RAMversion
