;******************************************************************************
;*									      *
;*			       Ycode Interpreter			      *
;*									      *
;*				  Version 1.10				      *
;*			 (Check RAM resident version)			      *
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
;     ���� �������� � �������� ������� �� ����������� � RAM.

		error	bank1addr / $c000 ; ������ �� ��� �� RAM
		error	bank2addr / $c000 ; ������ �� ��� �� RAM

CheckYcode	proc
		ds	$11, 1		; ������� 11 NOP-� �� �� ���� ������
		ldx	#CrightMsg	; ���������� �� ����� $111
		int	_Wstr

		lda	ResidentPtr+1	; ����������� ���� Resident > RAMstart
		ldb	ResidentPtr
		cmpb	#/RAMstart	; ���������� �������� �������
		bhi	NotHere 	; Resident > RAMstart => ���� ��
		bcs	MayHere 	; Resident < RAMstart => ���� �� � ���
		cmpa	#RAMstart	; ���������� �������� �������
		bhi	NotHere 	; Lo(Resident) > Lo(RAMstart) (Hi = Hi)

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
		bne	NoInterpreter	; �� �������� => ��� ���� �����
		inx
		stx	wrk_2
		deca
		bne	loop

		ldx	#bank1addr
		clra
loop1		adda	x, 0
		inx
		cpx	#bank1addr + $2000
		bne	loop1
		ldx	#Bank1OK
		tsta
		beq	print_1
		ldx	#Bank1Bad
print_1 	int	_Wstr

		ldx	#bank2addr
		clra
loop2		adda	x, 0
		inx
		cpx	#bank2addr + $2000
		bne	loop2
		ldx	#Bank2OK
		tsta
		beq	print_2
		ldx	#Bank2Bad
print_2 	int	_Wstr
		int	_Terminate

NotHere 	ldx	#NoInterpreter
		int	_Wstr
		int	_Terminate

CrightMsg	db	'CheckSum for Ycode interpreter', 0
NoInterpreter	db	"Interpreter not in memory!", 0
Bank1OK 	db	10, "Bank 1 is OK.", 0
Bank2OK 	db	10, "Bank 2 is OK.", 0
Bank1Bad	db	10, "Bank 1 fails check.", 0
Bank2Bad	db	10, "Bank 2 fails check.", 0

wrk_		ds	2
wrk_1		ds	2
wrk_2		ds	2
		endp;	CheckYcode

;------------------------------------------------------------------------------
ROMheader
		dw	$a55a		; ����� �� ���� BIOS
		db	'YGPascal'
		jmp	0		; cold inti address
		jmp	0
		END.	Check Interpreter
