	include ../DEVMAP.INC
	include ../ROM/BOOTMEM.INC
	include ../ROM/BOOTROM.INC

	org $100

	ldx	#hello
	jsr	F_UART_PUTS

	ldaa	#7
	ldab	#$36
	bsr	psg_write

	ldaa	#0
	ldab	#$97
	bsr	psg_write

	ldaa	#1
	ldab	#$4
	bsr	psg_write

;	ldaa	#2
;	ldab	#100
;	bsr	psg_write

;	ldaa	#3
;	ldab	#3
;	bsr	psg_write

;	ldaa	#4
;	ldab	#200
;	bsr	psg_write

;	ldaa	#5
;	ldab	#3
;	bsr	psg_write

	ldaa	#8
	ldab	#15
	bsr	psg_write

;	ldaa	#9
;	ldab	#15
;	bsr	psg_write

;	ldaa	#10
;	ldab	#15
;	bsr	psg_write

;;
;	ldaa	#14
;	ldab	#$AA
;	bsr	psg_write
;;

exit	ldx	#bye
	jsr	F_UART_PUTS
	jmp	F_RESET

; Write to PSG
; A - Address reg
; B - Data
psg_write proc
	psha
	staa	PSG_ADDR
	stab	PSG_DATA
	pula
	rts
	endp

hello	db	$0a, $0d, 'PSG test!', $0a, $0d, 0
bye	db	$0a, $0d, 'Bye!', $0a, $0d, 0
