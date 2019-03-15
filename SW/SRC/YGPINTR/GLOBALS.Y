;------------------------------------------------------------------------------
; Ycode Interpreter. Global equates.			    (c) 1989, 1990 YGP.


Version 	=	1
Flavour         =       67

Yregisters	equ	$80		; $80..$9f reserved.
WorkArea        equ     $a0             ; $a0..$bf work area
FParea		equ	$c0		; $c0..$cf work area for FP arithmetics

YregistersSz	=	$20		; Size of Yregisters
WorkAreaSz	=	$20		; Size of WorkArea

		.ifdef  PControler
rom_address	=	$e000
		.else
rom_address	=	$c000
		.endif

		.ifdef ROMversion
bank1addr        equ     rom_address
bank2addr        equ     rom_address
		.else
		 .ifNdef Games
RAMstart          equ     $b000 - $4000   ; ¢¨¦ Y.ASM ¯® ¢º¯°®± 
		 .else
RAMstart          equ     $1800           ; ¢¨¦ GAMES.ASM ¯® ¢º¯°®± 
		 .endif
bank1addr        equ     RAMstart
bank2addr        equ     RAMstart+$2000
		.endif

LoTable 	equ	bank1addr + $100
HiTable 	equ	bank1addr + $200


;--------------------------- Interpreter's registers --------------------------

		section Yregisters	; Main Ymachine registers
ModQueue	ds	2		; ±º¹®²®  ¬  ®² ¬®¤³«·¥­¶ /³­¨²·¥­¶ 
SegQueue	ds	2		; °¥¤¨·ª  ®² ¢±¨·ª¨²¥ ¬³ ±¥£¬¥­²¨
FreeQueue	ds	2		; ptr to Free list queue
SlotCnt 	ds	1		; ¡°®¿· ­  ±«®²®¢¥²¥
ZeroYregs				; ®² ²³ª ­ ² ²ºª ¢±¨·ª® ±¥ ­³«¨° 
LexLev		ds	1		; Current Lexical Level

			    ; ----------  ‚­¨¬ ­¨¥ !!! °¥¤  ¥ ª ª²® ¢ MarkStack
stat		ds	2   ;		; Static link (ARP of LexLev-1 proc)
ipc		ds	2   ;		; Interpreter's Program Counter
ProcNo		ds	1   ;		; ProcNo of current procedure
SlotNo		ds	1   ;		; SlotNo of current segment
lcl		ds	2   ;		; Pointer to local variables
			    ; ---------- Š° © ­  ¢­¨¬ ­¨¥²®!

gbl		ds	2		; Pointer to global variables
MS		ds	2		; MarkStack pointer
ATptr		ds	2		; Attribute Table
Cpool		ds	2		; Address of ConstPool
Pdict		ds	2		; pointer to Proc dictionary
SegPtr		ds	2		; ptr to current SegInfo
GblSegPtr	ds	2		; ptr to current Global segment
StdVarsPtr	ds	2		; Standard variables

		error	(* - 1) / (Yregisters + YregistersSz)
		ends;	Yregisters

		section WorkArea	;  ¡®²­  ®¡« ±² ¢ Zpage
LongWork	ds	0		;  °¨²¬¥²¨·­¨ ¨­±²°³ª¶¨¨
NewProc 	ds	1		; \
NewSlot 	ds	1		;  > used when calling procedure
NewLcl		ds	2		; /

wrkF		ds	4		; work for file I/O
IOwidth 	ds	2		; ° ¡®²­¨
IObuff		ds	2		;	 ¯°®¬¥­«¨¢¨
IOsize		ds	2		;		   ¯°¨ ° ¡®² 
IOfile		ds	2		;			     ± ´ ©«®¢¥

;---------- Ž² ²³ª ­ ² ²ºª ¯°®¬¥­«¨¢¨²¥ ±  ¤®±²º¯­¨ ¨ §  ¯®²°¥¡¨²¥«¿ ----------

wrk		ds	2		; ° ¡®²­¨
wrk1		ds	2		;	 ¯°®¬¥­«¨¢¨
wrk2		ds	2		;		   ± ®¡¹®
wrk3		ds	2		;			 ¯°¥¤­ §­ ·¥­¨¥

Src		ds	2		; common Source pointer (SRC-2 is used)
Dest		ds	2		; common Destination pointer

tempX		ds	2		; ¨§¯®«§³¢ ­¨ ­ ©-¢¥·¥ ª®£ ²® ±¥ ª §¢ 
tempS		ds	2		; sei ¨ cli

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

;--------------------------- Mark Stack information ---------------------------

		section 0 ;------------- ‚­¨¬ ­¨¥!!! °¥¤  ±º¢¯ ¤ 
					;    ± ²®§¨ ®² Yregisters
MSstat		ds	2		; static link pointer
MSipc		ds	2		; ipc of a caller
MSpno		ds	1		; ProcNo of a caller
MSsno		ds	1		; SlotNo of a caller
MSlcl		ds	2		; locals of a caller
MSsp		ds	2		; SP of a caller (depth not address)
MSsz		equ	*
		ends;	MarkStack info


;----------------------- Attribute Table of a Procedure -----------------------

		section 0
AT_pno		ds	1		; ProcNo: 0 - asm, 1..255 - pascal
AT_lex		ds	1		; Lexical level of a proc
AT_dsize	ds	2		; Data size of a procedure   (in bytes)
AT_psize	ds	2		; parameter size of a procedure (bytes)
AT_exit 	ds	2		; exit IPC
AT_size 	equ	*
		ends;	Attribute table


;------------------ Module & Segment handling data structures -----------------

		section 0	      ; ModInfo entry
ModName 	ds	8		; Module name		\
ModVersion	ds	2		; Version of module	 \ from disk
ModDate 	ds	2		; Date of compilation	 /
ModTime 	ds	2		; Time of compilation	/
ModNext 	ds	2		; ptr to next module entry
ModMainSlot	ds	1		; SlotNo of main segment
ModInfoSz	=	*		; size of data structure
		ends;		      ModInfo entry

		section 0	      ; SegInfo entry
SegName 	ds	8		; self evident
SegStart	ds	2		; start block (Bsex-)
SegSlotNo	ds	1		; Slot on which segment is linked
SegFhandle	ds	1		; File handle
SegNext 	ds	2		; All segs are linked by this field
SegGbl		ds	2		; Globals (if not main ptr to main)
SegPdict	ds	2		; proc dictionary ptr
SegCpool	ds	2		; const pool ptr
SegNloads	ds	2		; Number of usage of this slot.
SegLM		ds	2		; LoMem save (¨¬  ¯®-¤®¡º° ­ ·¨­)
SegNinits	ds	1		; ­ ©-¬­®£® 255 ±¥£¬¥­²  £® init-¢ ²
SegFlags	ds	1		; flags: %ABCDEFGH
					;   A - main segment.
					;   B - initialized (if main)
					;   C - in initialize (if main)
                                        ;   D - unused
                                        ;   EFGH - n = block size (2ü), ¤¥¬¥ª
                                        ;   0 -> 1, 1 -> 2, ... 9 -> 512
SegSlotDict	=	*		; Ž² ²³ª ­ ² ²ºª § ¯®·¢  SlotDict
					; main segments only
SegInfoSz	=	*
		ends;		      SegInfo entry


;------------------------ Globals of the Standard unit ------------------------

		section 0	      ; Standard vars pointed at by StdVarsPtr
FileStdInput	ds	8 * 2		; Input: text;
FileStdOutput	ds	8 * 2		; Output: text;
FileStdMessage	ds	8 * 2		; Message: text;
FileStdAuxilary ds	8 * 2		; Auxilary: text;
FileStdPrinter	ds	8 * 2		; Printer: text;
DefaultIn	ds	2		; Default Input File;
DefaultOut	ds	2		; Default Output File;
RandSeed	ds	4		; RandSeed: LongInt;
SpecialFlags	ds	1		; Special Flags %abcdefgh
					;   a=1 - no RTError message at all
					;   b=1 - no RTError message when err 1
					;   h=1 - NIL  ª® ­¿¬  ¯ ¬¥² (getmem)
RTEno		ds	1		; RunTimeError No
StdVarsSize	=	*		; must be <= 255
		error	* / 256
		ends		      ; Standard vars


;------------------- $a0..$a7 reserved for Ycode interpreter ------------------

_CallYcode	=	$a0		; execute Ycode file

_ExitYcode	=	$a1		; terminate pascal program

_ExecProc	=	$a2		; execute Procedure (B=Slot, A=Proc)

_LoadSlot	=	$a3		; load Slot in memory (B = SlotNo)

                ;       $a4
                ;       $a5

_RunTimeError	=	$a6		; Run Time Error
					;   import: A - Run Time Error No
_RTErrorMsg	=	$a7		; Run Time Error Message
					;   import: A - Run Time Error No

;-------- $a8..$af reserved for Interpreter <-> Debugger communication --------

_DbgActivate	=	$a8		; Activate Debugger
					;   import: X = Ptr to Modules
_DbgDebug	=	$a9		; Break point in interpreter.
					;   Assembly Language BreakPoint
_DbgBreak	=	$aa		; Break point (User BreakPoint)
					;   import: X  - No (0..65535)
		;	$ab
		;	$ac

_DbgPFcall	=	$ad		; Call to Procedure/Function
					;   A - ProcNo, B - SlotNo.
_DbgPFrtrn	=	$ae		; Return from Procedure/Function
_DbgPFexit	=	$af		; Exit from Procedure/Function

; $b0..$b8 interrupts are used to communicate between ROM page1 & ROMpage2
; don't use them outside Ycode interpreter

_prepareFP	=	$b0
_mply10addA	=	$b1
_fp_10_pwr	=	$b2
_haltpgm	=	$b3

                ;       $b4
                ;       $b5

_NewOSshell     =       $b6
_NewExecute	=	$b7

; $b8..$bf unused interrupts (but reserved for Ycode interpreter)
; In Super Programmable controler they are used from UniCRT & UniWIN

;------------------------------------------------------------------------------