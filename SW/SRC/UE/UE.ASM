;****************************************************************
;*__________UniED V 1.11___ 23 Sep 1991_________________________*
;* alt correction by YGP (see file USER.UE) 			*
;****************************************************************
;-
                org     $100
; Constants:
;
MaxLineSize     =       250     ; maximum line size
Step            =       8       ; left / right screen adjust step

swia            =       6

                section $80
minx            ds      2
maxx            ds      2
curx            ds      2

HasMsg          ds      1
MaxLineLen      ds      1
MaxLineLen1     ds      1
position        ds      1
Yposition       ds      1
min_pos         ds      1
max_pos         ds      1

a1              ds      1
X1              ds      2
X2              ds      2
tmps            ds      2

TopFile         ds      2
TopMsg          ds      2
BottomFile      ds      2
BottomMsg       ds      2
CurLine1        ds      2
CurLine2        ds      2
ScrStart        ds      2
LineNo          ds      2

; -----------------------------------------

ScreenCols      ds      1
ScreenLines     ds      1
MsgLine         ds      1

_MATCH          =       1
_NO_MATCH       =       2
_PART_MATCH     =       3

_CMD_CHAR       =       31
_BLINK_RATE     =       $f
ScreenOn        ds      1
RunDown         ds      1
FirstBackGnd    ds      1
CmdPtr          ds      1
CmdBuf          ds      4
Cpos            ds      2
CofsHi          ds      1
Cofs            ds      1
CmdLen          ds      1
MatchRes        ds      1
UpdateScreen    ds      1 ; When 0 then update


; --- Environment block ---
Environment
InsState        ds      1
MakeBacks       ds      1
LMarg           ds      1
RMarg           ds      1
PMarg           ds      1
ConfirmKey      ds      1
Extension       ds      3
EnvironEnd
TabsArray       ds      2
                error   * / $100
                ends

                include interupt.inc
                include Tokens.ue       ; Command identification codes
                include Init.ue         ; Intitialize editor
                include Screen.ue       ; Screen oriented routines
                include Windows.ue      ; Window oriented I/O
                include User.ue         ; User oriented commands
                include Prepare.ue      ; Line preparation procedures
                include LineCmds.ue     ; Line oriented commands
                include Commands.ue     ; Processing of commands
                include Margins.ue      ; Processing of commands
                include Marks.ue        ; Mark support unit
                include Block.ue        ; Block oriented commands
                include Reflow.ue       ; Justify and reflow commands
                include Finds.ue        ; Find and replace operations
                include FileIO.ue       ; File read/write
                include Shedule.ue      ; Main command dispatcher
                include Header.ue       ; Header
                include CmdScan.ue      ; Command sequense interpreter
;;              include Debug.ue        ;

CmdListSize
CmdList         =       *+2
                END
