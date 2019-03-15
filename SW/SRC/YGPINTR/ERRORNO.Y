;------------------------------------------------------------------------------
; Ycode Interpreter. Run Time & I/O Error Numbers.	    (c) 1989, 1990 YGP.


;------------------------------ Run Time Errors -------------------------------

MemFull_	=	1   ; $01 ; Memory full (stack overflow)
IOerror_	=	2   ; $02 ; Input/Output error
DivByZero_	=	3   ; $03 ; Division (modulo) by zero
s2long_ 	=	4   ; $04 ; string too long
Large255_	=	5   ; $05 ; try to bulid a set with too
SetBoundsErr_	=	6   ; $06 ; try to bulid a lo > hi bounds
StrIndx_	=	7   ; $07 ; bad string indexing  [1..255]
ErrLoBound_	=	8   ; $08 ; range check on lo bound fail
ErrHiBound_	=	9   ; $09 ; range check on hi bound fail

DisposeError_	=	32  ; $20 ; Dispose error

;FP_under_	 =	 64  ; $40 ; Floating Point underflow not reported
FP_over_	=	65  ; $41 ; Floating Point overflow
FP_invalid_	=	66  ; $42 ; invalid Floating Point operation
FP_divzer_	=	67  ; $43 ; Division by zero (floating point)
FP_int_ovr_	=	68  ; $44 ; Integer overflow (FP convertion)
FP_sqrt_neg_    =       69  ; $45 ; Sqrt from negative value (i.e. sqrt(-1))

; Possible Fatal Errors (envirounment dependent)
FatalErrors	=	208 ; $d0
FatalMemory_	=	208 ; $d0 ; No memory to run program
FatalIOerr_	=	209 ; $d1 ; Error when reading program
NoCodeSegment_	=	210 ; $d2 ; Module has no code segment
SegmentLost_	=	211 ; $d3 ; error disk changed or ...
VersionError_	=	212 ; $d4 ; Different version
WszBsexError_	=	213 ; $d5 ; Word size or byte sex differ
BadReturn_	=	214 ; $d6 ; return to/from unexisting procedure
NoLanguage_	=	215 ; $d7 ; Unknown language (Not Pascal)
RecursiveUnits_ =	216 ; $d8 ; Recursive initialize of units
InvalidLibrary_ =	217 ; $d9 ; Invalid format of Library code file
InvalidBDY_	=	218 ; $da ; Invalid format of BDY code file
CantFindBDY_	=	219 ; $db ; Interpreter can not find unit's body
InvalidBlockSz_ =       220 ; $dc ; Invalid Block size (not a power of 2)

; Impossible errors (if compiler, interpreter and code (no disk errors) are OK)
ImpossibleErrs	=	240 ; $f0
BADmemfull_	=	242 ; $f2 ; MemFull but can't continue
OverlayASM_	=	243 ; $f3 ; Assembly language procedure is overlay
RelocateErr_	=	244 ; $f4 ; Relocation table contains EXTERNAL items
ProcNumErr_	=	245 ; $f5 ; Proc No not match with Attr Table
NoDictionary_	=	246 ; $f6 ; No proc dictionary
RecursiveLoad_	=	247 ; $f7 ; recursive call to LoadSlot
StdSegInfo_	=	248 ; $f8 ; Try to get segment info of Std
BadIreturn_	=	249 ; $f9 ; Ireturn from a non unit body
NoSlot_ 	=	250 ; $fa ; slot not found
ErrorClosed_	=	251 ; $fb ; overlay from closed file
Segs2many_	=	252 ; $fc ; Too many segments
BadInterm_	=	253 ; $fd ; ▓в║░де гол┐м intermediate byte
CantProcess_	=	254 ; $fe ; в▒е о╣е не мога да об▒л│жа
UnImp_		=	255 ; $ff ; Unimplemented instruction

;------------------------------------------------------------------------------