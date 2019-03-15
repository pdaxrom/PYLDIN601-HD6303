;------------------------------------------------------------------------------
; Ycode Interpreter. System page usage.                     (c) 1989, 1990 YGP.

		.ifdef  PControler
SystemPage      equ     $da00           ; Ycode occupy $da00..$dbff locations
		.else
SystemPage	equ	$be00		; Ycode occupy $be00..$beff locations
		.endif

		section SystemPage
Sys_Ver 	ds	2		; Version of Ycode interpreter
Bank1page	ds	1		; ROM page number for bank 1
Bank2page	ds	1		; ROM page number for bank 2

LYCaddress	ds	2		; address of Long Ycode handler
StdAddress	ds	2		; address of Std P/F handler

NullString	=	*		; NullString = #0 = '' = 1 byte zero
LongZero	ds	4		; 4 bytes zero

IsRunning	ds	1		; ¯°®£° ¬ ²  ¢º°¢¨ «¨ ¨«¨ ±¥ link-¢ 
SegLoadFlag	ds	1		; SegLoad in progress
OSactive	ds	1		; ¨§«¥§«¨ ±¬¥ ¢ OSshell
LibHandle	ds	1		; Library FileHandle

                error   * / (SystemPage+$41)    ; ²°¿¡¢  ¤  ¡º¤¥ <= ®² $xx40

                ds      SystemPage +$40 -*      ; unused now

WorkBuff        ds      $20             ;($xx60..$xx7f) $20 = 32 bytes WorkBuff
WBsize		=	*-WorkBuff	; size of WorkBuff


SaveArea	=	* ;-------------- ² §¨ · ±² ±¥ ±¯ ±¿¢  ¯°¨ OS shell ---
SaveAreaPtr	ds	2		; ptr to ¬¿±²®²® ¤¥²® ¥ ±¯ ±¥­® ¤®«­®²®

StackDepth	ds	2		; stack depth before run
HeapBeforeRun	ds	2		; Top of Heap before running program
IOresult	ds	2		; I/O result of last I/O operation
ProgramSlot	ds	1		; ­®¬¥° ­  ±«®²  ­  ¯°®£° ¬ ² 
OldTerminate	ds	3		; Old Terminate vector

		ds	15		; unused now

SaveSWI_Area	=	*		; save of SWI area on entry
SaveSWI_AreaP	ds	1
SaveSWI_AreaB	ds	1
SaveSWI_AreaA	ds	1
SaveSWI_AreaX	ds	2 ;----------------------------------------------------

                error   * - (SystemPage+$80)    ; ²°¿¡¢  ¤  ¡º¤¥ = $xx80
SaveAreaSize	=	$20

;--------------------------------- $xx80 --------------------------------------
Statistics      ds      $10             ;($xx80..$xx8f) $10 = 16 bytes reserved
					;			 for Statistics

DebuggerInfo    ds      $10             ;($xx90..$xx9f) $10 = 16 bytes reserved
					;			   for Debugger

CRTspace        ds      $10             ;($xxa0..$xxaf) $10 = 16 bytes reserved
					;			   for CRT unit

WINspace        ds      $10             ;($xxb0..$xxbf) $10 = 16 bytes reserved
					;			   for WIN unit

RsdntLinkPtr	ds	2		; Resident programs link pointer
LibNamePtr	ds	2		; pointer to Library FileName  (ASCIIz)
BDYpathsPtr	ds	2		; pointer to BDYpaths (intrptr	ASCIIz)
OverlayBuffer	ds	2		; must be zero (or ptr to buffer)

		ds	8		; unused now

;------------------------------ $xxd0 ..$xxff ---------------------------------
                ds      2               ; ($xxd0..$xxff)  reserved for MainLoop
					;		   and MainLoop patches
RAM_code	=	*
MainLoop1	=	*
		ds	46

                error   *-(SystemPage+$100) ; SystemPage's size is EXACTLY $100
		ends;	SystemPage

;------------------------------------------------------------------------------