;------------------------------------------------------------------------------
; UniDOS (R) & BIOS undocumented futures. WARNING!!!		 YGP mnemonics.

		.ifdef  PControler
InterruptAddr	=	$dc00		; Addr of tbl with interrupt addresses
InterruptPage	=	$de80		; Addr of tbl with interrupt pages
					;   2 pages per byte (4 bit each)
IOarea		=       $df00
		.else
InterruptAddr	=	$ee00		; Addr of tbl with interrupt addresses
InterruptPage	=	$ed80		; Addr of tbl with interrupt pages
					;   2 pages per byte (4 bit each)
IOarea		=       $e600
Line_27 	=	$bfa0		; buffer for 27 line of screen
scrmode 	=	$ED12		; video mode
system_scrbase	=	$ED20		; ptr to 26-th line of text screen
		.endif


ResidentPtr	=	InterruptAddr+2*$0d	; int ($0d) Resident Pointer
LoMemPtr	=	InterruptAddr+2*$0e	; int ($0e) LoMemory Pointer
HiMemPtr	=	InterruptAddr+2*$0f	; int ($0f) HiMemory Pointer

MC6845_Addr     =       IOarea +$04     ; MC6845 address register
MC6845_Data     =       IOarea +$05     ; MC6845 data register

PIA_drA         =       IOarea +$28     ; MC6820 Data register A
PIA_drB         =       IOarea +$29     ; MC6820 Data register B
PIA_crA         =       IOarea +$2a     ; MC6820 Control register A
PIA_crB         =       IOarea +$2b     ; MC6820 Control register B

		.ifdef	lilith
ROMswitch	equ	$17		; ROM page No register
		.else
ROMswitch	equ	$e6f0		; ROM page No register
		.endif

		section 0
_Save_INT_Rtrn	ds	2		; Return to Interrupt handler
_Save_INT_Page	ds	1		; PageNo of caller's ROMpage
_Save_INT_SWI	ds	5		; Save of SWI area in ZPage
_Save_INT_PC	ds	2		; Save of PC+2
_Save_INT_Size	=	*		; size of save stack
		ends

;------------------------------------------------------------------------------