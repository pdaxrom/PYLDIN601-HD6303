;------------------------------------------------------------------------------
;  UniDOS (R) & BIOS interrupts.				 YGP mnemonics.

		.ifdef	lilith
InDOSflag	=	$28		; don't enter DOS

EquipmentBYTE	=	$29		; Equipment Byte
		.else
InDOSflag	=	$00		; don't enter DOS

EquipmentBYTE	=	$01		; Equipment Byte
		.endif
EquipKernel	=	$80		;   UniDOS kernel present
EquipGraph	=	$40		;   Graphics BIOS
EquipBASIC	=	$20		;   BASIC interpreter present
EquipYcode	=	$10		;   Ycode interpreter present
Equip_2Mhz	=	$08		;   Working on 2 Mhz
EquipShell	=	$01		;   UniDOS Shell present

		.ifdef	lilith
ComputerName	=	$ffce
BIOSdate	=	$ffde
BIOSversion	=	$ffe0
ComputerModel	=	$ffe9
_model_601      =         $00
_model_lilith601=         $40
_model_601A     =         $80
_model_601M     =         $c0
_model_601T     =         $e0

		section $2C		; save MC6800 regs
SWI_P		ds	1		;   processor status register
SWI_B		ds	1		;   register B
SWI_A		ds	1		;   register A
SWI_X		ds	2		;   register X
		ends
		.else
ComputerName	=	$ffdc
BIOSdate	=	$ffec
BIOSversion	=	$ffee
ComputerModel	=	$fff7
_model_601      =         $00
_model_601A     =         $80
_model_601M     =         $c0
_model_601T     =         $e0

		section $04		; save MC6800 regs
SWI_P		ds	1		;   processor status register
SWI_B		ds	1		;   register B
SWI_A		ds	1		;   register A
SWI_X		ds	2		;   register X
		ends
		.endif

;------------------------------ BIOS interrupts -------------------------------
_50_Hz		=	$5		; every 20 mili seconds
_1_Hz		=	$6		; interrupt (every second)
_KeyPress	=	$10		; return A = $ff if no key pressed
_ReadKey	=	$11		; get scan code of a key
_SetVideo	=	$12		; initialize Video Mode
_GetVideo	=	$13		; get video mode
_WhereXY	=	$14		; get X, Y (AB) & scr address (X)
_GotoXY 	=	$15		; Goto XY (AB)
_DiskIO 	=	$17		; direct disk access
_GetTime	=	$1c		; B,A,Xh,Xl= hour,minute,sec,hundreds
_GetDate	=	$1e		; B,A,X    = day, month, year
_GetChar	=	$20		; get char (ascii)
_GetLine	=	$21		; get asciiz string
_Wchar		=	$22		; write char
_Wstr		=	$23		; write string (ASCIIzero)
_Wcard		=	$24		; write cardinal
_Whex		=	$25		; write hex byte
_Printer	=	$26		; Printer access

_GetMem 	=	$2a		; Get Memory
_Release	=	$2b		; Release
_Resident	=	$2c		; make memory resident
_MoveMem	=	$2d		; Move memory
_GetIntVec	=	$2e		; Get Interrupt Vector
_SetIntVec	=	$2f		; Set Interrupt Vector

_CallMonitor	=	$30		;
_CallBASIC	=	$31		;

_GetLoMem	=	$35		; Allocate space on LoMem
_MemAvail	=	$36		;
_ChainIntrpt	=	$37		; chain interrupt

;------------------------------ XBIOS interrupts ------------------------------
_GetScrSize	=	$6d		; A, B -> X, Y size
_EditLine	=	$67		; X addr, B size, A<>0 show

;-------------------------- UniDOS shell interrupts ---------------------------
_Terminate	=	$38		; terminate program execution
_Execute	=	$39		; execute command line
_UniDOSshell	=	$3a		; call UniDOS shell
_ParamCount	=	$3b		; get number of parameters
_ParamStr	=	$3c		; get parameter
_GetErrText	=	$3d		; без д│ми

;-------------------------- UniDOS kernel interrupts --------------------------
_UniDOSversion	=	$41		; Get UniDOS version (returned in BA)
_Fopen		=	$4a		; open existing file
_Fcreate	=	$4b		; create new file
_Fread		=	$4c		; read from file
_Fwrite 	=	$4d		; write to file
_Fclose 	=	$4e		; close file
_Fremove	=	$4f		; remove file
_Fseek		=	$50		; seek (change file position)
_Fsize		=	$51		; get file size
_Fposition	=	$53		; get file position
_Frename	=	$56		; rename file
_Eof		=	$58		; return EOF status
_FcreateTemp	=	$6a		; create Temporary file
_FcreateNew	=	$6b		; create NEW file
_Ftruncate	=	$6c		; truncate file

;------------------------- UniDOS standard file hadles ------------------------
_StdIn		=	0		; Standard Input file	  (keyboard)
_StdOut 	=	1		; Standard Output file	  (screen)
_StdErr 	=	2		; Standard Message device (always Scr)
_StdAux 	=	3		; Standard Serial device  (null device)
_StdPrn 	=	4		; Standard Printer device (printer)

;----------------- Machine codes for some useful instructions -----------------
_cpx_		=	$8c		; cpx  #.. used for tricks
_cmpa_		=	$81		; cmpa #..
_cmpb_		=	$c1		; cmpb #..
_ldx_		=	$ce		; ldx #..
_lda_		=	$86		; lda #..
_ldb_		=	$c6		; ldb #..
_bita_		=	$85		; bita #..
_bitb_		=	$c5		; bitb #..

;------------------------------------------------------------------------------