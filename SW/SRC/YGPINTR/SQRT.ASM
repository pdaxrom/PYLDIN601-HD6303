FParea		equ	$c0		; $c0..$cf work area for FP arithmetics
WorkArea        equ     $a0             ; $a0..$bf work area
WorkAreaSz	=	$20		; Size of WorkArea

WorkBuff        =       $be40
save_exp        =       $be50           ; � ���� ���� ??

		section WorkArea	; ������� ������ � Zpage
LongWork	ds	0		; ����������� ����������
NewProc 	ds	1		; \
NewSlot 	ds	1		;  > used when calling procedure
NewLcl		ds	2		; /

wrkF		ds	4		; work for file I/O
IOwidth 	ds	2		; �������
IObuff		ds	2		;	 ����������
IOsize		ds	2		;		   ��� ������
IOfile		ds	2		;			     � �������

;---------- �� ��� ������� ������������ �� �������� � �� ����������� ----------

wrk		ds	2		; �������
wrk1		ds	2		;	 ����������
wrk2		ds	2		;		   � ����
wrk3		ds	2		;			 ��������������

Src		ds	2		; common Source pointer (SRC-2 is used)
Dest		ds	2		; common Destination pointer

tempX		ds	2		; ����������� ���-���� ������ �� �����
tempS		ds	2		; sei � cli

		error	(* - 1) / (WorkArea + WorkAreaSz)
		ends;	WorkArea
		section FParea
fp_1		ds	0		; floating point number (op1)
fp_e1		ds	1		; exponent of fp 1
long1		ds	0		; 32 bit long integer
fp_m1		ds	4		; mantissa of fp 1
fp_s1		ds	1		; sign	   of fp 1

fp_2		ds	0		; floating point number (op2)
fp_e2		ds	1		; exponent of fp 2
long2		ds	0		; 32 bit long integer
fp_m2		ds	4		; mantissa of fp 2
fp_s2		ds	1		; sign	   of fp 2

longR		ds	0		; 32 bit resulting number
mantissa	ds	4		; work mantissa for /, *

		ends; FParea

		section 0		; FP accomulator format
fp_e_		ds	1		; exponent
fp_m_		ds	4		; mantissa
fp_s_		ds	1		; sign
		ends

; function _sqrt(x: real): real;
_sqrt           proc

fp_x            =       WorkBuff
fp_parameter    =       WorkBuff+6
iteration       =       WorkBuff+12     ; ��� �� ��??

                dw      0
                ins
                ins

                jsr     pullfp_1

                lda     fp_s1
                beq     not_neg
                jmp     FP_negsqrt
not_neg         lda     fp_e1
                beq     ready_0
                suba    #127            ; ���������� ������������
                asrA                    ; ����� �� 2 signed byte
                sta     save_exp        ; save for later use
                lda     #127            ; exp = 0
                adca    #0              ; �������� ���������� �������� carry
                sta     fp_e1           ; �� ���� ����� ��������� �������
                                        ; ����� ����� 1 (1/2 .. 2)

                lda     #8+ 1; ������ �������� dec (bra save_x)
                sta     iteration
                ldx     #fp_parameter   ; �� ������� �� ���������
                jsr     save_fp1        ; newX:= (P/X + X)/2
                bra     save_x          ; � ������ 7 �� ���� ��������
                                        ; (6 is enough)

loop            ldx     #fp_parameter   ; P/X
                jsr     FdivX
                ldx     #fp_x           ; P/X + X
                jsr     FaddX
                dec     fp_e1           ; � ���� �� ����� ����� � ����� �� 2

save_x          ldx     #fp_x
                jsr     save_fp1
                dec     iteration
                bne     loop

OK_ready
                lda     save_exp
                adda    fp_e1
                ;suba    #127
                sta     fp_e1
		jsr	RoundLast
ready_0
		lda	fp_s1		; get sign
		ldb	fp_m1+0 	; get MSByte of mantissa
		aslb			; ���������� ������ ��� �� mantissa
		asla			; ���������� ����� � Carry
		lda	fp_e1
		rora			; ��������� ����� � exponent
		rorb			; � ��������� �� exponent � mantissa
		pha
		phb
		ldb	fp_m1+1
		lda	fp_m1+2
                phb
                pha
                jmp     $befe
                endp; _sqrt

; ------- Pull IEEE format Real Number from TOS -------
; TOS is a real number pull in (X)
; Uses: tempX, A, B, X registers

PullFP_2	ldx	#fp_2
		bra	PullReal_x
PullFP_1	ldx	#fp_1

PullReal_X	proc
		plb
		pla
		sta	tempX+1
		stb	tempX
		clr	x, fp_m_+3
		pla
		sta	x, fp_m_+2
		pla
		sta	x, fp_m_+1
		pla
		plb
		asla
		rolb
		stb	x, fp_e_
		beq	Is0
		rorb
		sec
		rora
Is0
		sta	x, fp_m_+0
		andb	#$80
		stb	x, fp_s_
		ldx	tempX
		jmp	x, 0		; do rts
		endp;	PullReal_X

; ------- Zero FP_1 -------
; Import:    ����
; Export:    fp_1 = 0.0 (all 6 bytes are zeroed)
; Destroyed: X & A registers

Zero_fp1	=	*
		ldx	#0		; �������� ���-������ � ���-�������
		stx	fp_1+0		; ����� �� ��������� �� 6 �����
		stx	fp_1+2
		stx	fp_1+4
		rts

OK_not_0	lda	#$7e + 16	; 16 bit integer (cardinal) number
		sta	fp_e1
		ldx	#0
		stx	fp_m1+2
		;bra	 Normalize	; ������� ��������� � ����

; ------- Normalize -------
; Imoprt:    fp_1 internal format real number (denormalized)
; Export:    fp_1 internal format real number (normalized)
; Destroyed: B, A registers

Normalize	proc
		lda	fp_m1
		bmi	FP_rts_1	; number is normalized?

		ldb	fp_e1
NormLoop	decb
		beq	Zero_fp1	; ��� underflow �� ����� 0.0
		asl	fp_m1+3
		rol	fp_m1+2
		rol	fp_m1+1
		rola	;fp_m1
		bpl	NormLoop
		sta	fp_m1
		stb	fp_e1
FP_rts_1	=	*
		rts
		endp;	Normalize

; ------- Divide Floating Point numbers -------
; Import:    fp_1 internal format real number
;	       fp_2 internal format floating point numbers  (Fdiv)
;     or:      X ptr to second fp opernad      (X)  -> fp_2 (FdivX)
; Export:    fp_1:= fp_2 / fp_1

FdivX		jsr	restore_fp2
Fdiv		proc
		lda	fp_e1		; ���� ��� �� ����� �� 0.0?
		bne	Not0
		jmp	FP_divzer	; ��� �� ��������� �� � �������
Not0
		lda	fp_e2		; ���� ��� �� ����� 0.0 �� ����
Underflow       beq     Zero_fp1        ; ��� �� ������ �� ������� 0.0
		ldb	fp_s1		; ����� � + ��� �� � ������� �����
		xorb	fp_s2		;	� - ��� �� � ��������
		stb	fp_s1
					; �� �� ���������, �� $7f �������� 2^0
		suba	fp_e1		; expR = exp2 - exp1
		bcs	E2lesE1 	; �� exp2 < exp1
		adda	#$7f		; �������� ������ �� ������������
		bcs	Overflow	; ��������� ����� ��������
		cmpa	#$ff		; $ff ���� � ��������� ����������
		bne	OKexp
Overflow	jmp	FP_over

E2lesE1 	adda	#$7f		; add zero exponent
		beq	Underflow	; ������ ����� ������� ����������
		bpl	OKexp

OKexp		sta	fp_e1		; Resulting exponent calculated

		ldx	#32		; 32 bit division
DIVloop
		lda	fp_m2+3 	; fp2 > fp1 ?
		ldb	fp_m2+2
		suba	fp_m1+3
		sbcb	fp_m1+2
		lda	fp_m2+1
		ldb	fp_m2+0
		sbca	fp_m1+1
		sbcb	fp_m1+0

		bcs	NotGRT
		sta	fp_m2+1 	; �������� ���� �� �������� � �� ������
		stb	fp_m2+0
		lda	fp_m2+3 	; ������� ������ �������� �������
		ldb	fp_m2+2 	; ���� ��� �� ��������
		suba	fp_m1+3
		sbcb	fp_m1+2
		sta	fp_m2+3
		stb	fp_m2+2
		sec
		db	$c6		; trick to jump over clc (ldb #clc)
NotGRT		clc
		rol	mantissa+3	; shift left result
		rol	mantissa+2
		rol	mantissa+1
		rol	mantissa+0
		lsr	fp_m1+0 	; shift right fp1
		ror	fp_m1+1
		ror	fp_m1+2
		ror	fp_m1+3
;               bcc     NoRound        ; �� ���� ������ ���� �������
;               lda     fp_m1+3        ; � �������� � ���������� ��
;               ora     #1             ; ������������� �������
;               sta     fp_m1+3
;NoRound
		dex
		bne	DIVloop
		clc
		ldx	mantissa
		stx	fp_m1
		ldx	mantissa+2
		stx	fp_m1+2
                jsr     InsertCarry
		jmp	Normalize	; jsr + rts
		endp;	Fdiv

; ------- Round Last byte -------
; ������������ �� ��������� ����. ��� ������ ������ �� �� ����� ������
; � �������� ������ ������� $7e ff ff ff ff 00 ��� �������� �����������
; � ����� �������� �� -1 � �� �� 0

RoundLast	proc
		lda	fp_m1+3 	; ���� ������ ��� �� ��������� ����
		bpl	NoCarry 	; � �������, �.�. ������ �� round?
		clr	fp_m1+3 	; ���������� ��������� ���� (round)
		inc	fp_m1+2 	; ��, ������ � �� ������
		bne	NoCarry
		inc	fp_m1+1
		bne	NoCarry
		inc	fp_m1+0
		bne	NoCarry
		sec
		bra	InsertCarry	; ��� ��� carry �� ������ ��� ������
NoCarry 	rts			; � ���� �� �� ����� ���� �� � �������
		endp;	RoundLast	; ���� � ������� ������� ��� 0

; ------- Add Floating Point numbers -------
; Import:    fp_1 internal format real number
;	       fp_2 internal format floating point numbers  (Fadd)
;     or:      X ptr to second fp opernad      (X)  -> fp_2 (FaddX)
; Export:    fp_1:= fp_2 + fp_1

FaddX		jsr	restore_fp2
Fadd		proc
		lda	fp_e2		; ���� ��������� ��� 0.0?
		bne	Not0
		rts			; ��, � ���� ����� �� ������.
Not0		ldb	fp_e1		; ���� ��������� 0.0?
		bne	Not00
		bra	Swap_FP 	; ��, ������ ������� fp_2 � fp_1
Not00					; � ����� �� <> 0
		lda	fp_s2		; ����������� �������
		tab
		xora	fp_s1		; ���� �� ��������
		bmi	SubSameSigns	; � �������� �����
AddSameSigns	=	*		; �� ��� �� ��� ������ �� �� � �������
		stb	fp_s1		; �����.

		jsr	Denormalize	; ����������� �� ����������
		lda	fp_m1+3 	; 32 bit integer addition
		adda	fp_m2+3
		sta	fp_m1+3
		lda	fp_m1+2
		adca	fp_m2+2
		sta	fp_m1+2
		lda	fp_m1+1
		adca	fp_m2+1
		sta	fp_m1+1
		lda	fp_m1+0
		adca	fp_m2+0
		sta	fp_m1+0
		;jmp	 InsertCarry	 ; jsr + rts ��������� �������� ���
		endp;	Fadd

; ------- Insert Carry -------
; Import: Carry = 0/1, fp_1 internal format real number
; Export: if Carry = 1 then Shift Right fp_1 and insert carry as first bit
;			    and bump exponent

InsertCarry	proc
		bcc	rts
		ror	fp_m1+0
		ror	fp_m1+1
		ror	fp_m1+2
		ror	fp_m1+3
		bcc	IncExp
		lda	#1		; ��������� ������� ��� �� �������
		ora	fp_m1+3 	; �������
		sta	fp_m1+3
IncExp		lda	fp_e1
		inca
		cmpa	#$ff
		bne	ExpOK
		jmp	FP_over
ExpOK		sta	fp_e1
rts		rts
		endp;	InsertCarry

; ------- Swap fp_1 <--> fp_2 -------

Swap_FP 	proc
		ldx	#6		; swap fp_1 and fp_2
loop		lda	x, fp_1 -1
		ldb	x, fp_2 -1
		stb	x, fp_1 -1
		sta	x, fp_2 -1
		dex
		bne	loop
		rts
		endp;	Swap_FP

; ------- Subtact Floating Point numbers -------
; Import:    fp_1 internal format real number
;	       fp_2 internal format floating point numbers  (Fsub)
;     or:      X ptr to second fp opernad      (X)  -> fp_2 (FsubX)
; Export:    fp_1:= fp_2 - fp_1

FsubX		jsr	restore_fp2
Fsub		proc
		lda	fp_e1		; ���� ����� 0.0?
		bne	Not0
		bra	Swap_FP 	; ��, ������ ������� fp_2
Not0		ldb	fp_e2		; ���� ����� �� 0.0?
		bne	Not00		; ������ ������� (-fp_1)
		lda	fp_s1		; ����� ���� ��� ������� �� fp_1
		xora	#$80		; �� � 0.0 (����� ����� ������� fp_2)
		sta	fp_s1
		rts
Not00					; � ����� �� <> 0
		lda	fp_s2		; ����������� �������
		tab
		xora	fp_s1		; ���� �� ��������
		bmi	AddSameSigns	; � �������� ����� �� (������ ��������)
SubSameSigns	=	*		; �� ��� �� ��� ������ �� �� � �������
		stb	fp_s1		; �����

		bsr	ABScmpR 	; ����������� ��� �� ����� �����
		bcc	FirstGreat	; � ��-������
		xorb	#$80		; ����� �� ��������� e ������� ������
		stb	fp_s2		; �������(fp_1) � ��-������ �� �������
		bsr	Swap_FP
FirstGreat
		bsr	Denormalize
		ldb	fp_m2+3
		subb	fp_m1+3
		stb	fp_m1+3
		ldb	fp_m2+2
		sbcb	fp_m1+2
		stb	fp_m1+2
		ldb	fp_m2+1
		sbcb	fp_m1+1
		stb	fp_m1+1
		ldb	fp_m2+0
		sbcb	fp_m1+0
		stb	fp_m1+0
		bra	Normalize0	; jsr + rts
		endp;	Fsub

; ------- Denormalize -------
; Import: fp_1, fp_2 internal format real numbers
; Export: fp_1 & fp_2 �� � ��������� �������� (��� ��-������� �� �����)
;	  ���� ������� � ��-������ ������� � ���������������.
;	  fp_e1, � fp_e2 �� �� �������, �� ��-������� �� ����� ��������
;	  � ������� � fp_e1

Denormalize	proc
		lda	fp_e1		; ���������� ����� ����������
		tab
		subb	fp_e2
		bcc	E1geqE2 	; taken if e1 >= e2
		negb			; ������ e1 < e2 �� ������ �� negate
		lda	fp_e2
		sta	fp_e1		; ������������ ����������
		ldx	#fp_m1
		bra	ShiftRight
E1geqE2 	beq	rts
		;sta	 fp_e1		; ������������ ���������� �� � ������
		ldx	#fp_m2
ShiftRight
		lda	x, 3		; ���� � ��� ��-����� ��� ��-������
ShiftLoop	lsr	x, 0
		ror	x, 1
		ror	x, 2
		rora	;x, 3
		bcc	NoCarry 	; ����������� ��� ������ �� ��
		ora	#1		; ����� �� ������� �� ������ �������
NoCarry 				; � ���� �������� ������, �?
		decb			; �� ��������, �� �������� 0.000000001
		bne	ShiftLoop	; � 10000000000000, ������?
		sta	x, 3
rts		rts
		endp;	Denormalize

; ------- Compare FP (absolute values) -------
; Import:    fp_1, fp_2 in internal real format
; Export:    Carry & Zero flag are set acording to comparison fp2 - fp1
;	     ������������ �� ����� �� ��������� ��������.
; Warning: ������ �� ���� �������� A � ����� ����

ABScmpR 	proc
		lda	fp_e2
		cmpa	fp_e1
		bne	FP_rts_2	; fp_2 - fp_1 (exponents)

		lda	fp_m2+0 	; ������������ �� �������
		cmpa	fp_m1+0 	; ����������� ���������
		bne	FP_rts_2
		lda	fp_m2+1
		cmpa	fp_m1+1
		bne	FP_rts_2
		lda	fp_m2+2
		cmpa	fp_m1+2
		bne	FP_rts_2
		lda	fp_m2+3
		cmpa	fp_m1+3
FP_rts_2	=	*
                rts
		endp;	ABScmpR

Normalize0			      =*; check for 0.0 and normalize
		lda	fp_m1+3 	; � ���� �� ��� �������� 0.0?
		ora	fp_m1+2
		ora	fp_m1+1
		ora	fp_m1+0
		bne	NotZero
		sta	fp_s1
		sta	fp_e1
rts		rts
NotZero 	jmp	Normalize

; ------- Restore FP accomulator 2 -------
; Import: X ptr to internal packed format
; Export: (X) -> fp_2

restore_fp2	proc
		lda	x, 2
		sta	fp_m2+1
		lda	x, 3
		tab
		andb	#$80		; �����
		stb	fp_s2
		ldb	x, 1		; ������ ���� � ��� ��������
		stb	fp_m2+2 	; � �� ������ X = fp_2
		ldb	x, 4		; ����������
		beq	Is0
		ora	#$80
Is0		sta	fp_m2
		lda	x, 0
		sta	fp_m2+3
		stb	fp_e2
		rts
		endp;	restore_fp2

; ------- Save FP accomulator 1 -------
; Import: X ptr to 5 byte space
; Export: fp_1 -> (X) ���� ����� �� �������� (BSex-)

save_fp1	proc
		lda	fp_e1		; ����������� ������������
		ldb	fp_m1+3 	; � ��� ���� � ��� �������� ����
		stb	x, 0		; � ����� �� ��������� �������
		sta	x, 4		; �� ������ ���� �� �� ����� � ��
		lda	fp_m1+1 	; ������ X = fp_1
		sta	x, 2
		lda	fp_m1
		ldb	fp_m1+2
		stb	x, 1
		ldb	fp_s1		; �����
		anda	#$7f
		aba			; add $80 if negative
		sta	x, 3
		rts
		endp;	save_fp1

fp_over         ldx     #msg_over
                bra     halt
fp_divzer       ldx     #msg_divzer
                bra     halt
fp_negsqrt      ldx     #msg_negsqrt

halt            int     $23
                int     $38
msg_over        db      'fp_over', 0
msg_divzer      db      'msg_divzer', 0
msg_negsqrt     db      'msg_negsqrt', 0

                public  _sqrt