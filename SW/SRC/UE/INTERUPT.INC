;  ----------------------------------------------------------------------------
; Common include file. Interrupt mnemonics.

; --- ASCII code mnemonics ---
KEY_cr          equ     $c0
ASCII_lf        equ     10

; --- Registers save place for interrupt drivers ---
                section 4
swi_C           ds      1               ; save place for flags
swi_B           ds      1               ; acc B
swi_A           ds      1               ; acc A
swi_x           ds      2               ; X register save place
                ends

LoMem           =       $ee1c           ; LoMem pointer (Read Write)
HiMem           =       $ee1e           ; HiMem pointer (Read Only)

; --- Interrupt Mnemonics ---
KbdTest         =       $10             ; Get Key from Keyboard (if presant)
KbdRead         =       $11             ; Get Key From KeyBoard (Scan Code)
SetVideoMode    =       $12             ; Select Video mode
GetVideoMode    =       $13             ; Get current video mode
GetCrsr         =       $14             ; Get Cursor and Video Page
GotoXY          =       $15             ;
GetChar         =       $20             ; Get Char from keyboard
GetLine         =       $21             ;
Wchar           =       $22             ; Write char
Wstr            =       $23             ; Write string
Whex            =       $25             ; Write Hex byte
WPrnChar        =       $26             ; Write char to printer
MulU            =       $28             ; Unsigned Multiplication (BA:= B * A)
DivU            =       $29             ; Unsigned Division (X:= X div B), (A:= X mod B)
Allocate        =       $2a             ; GetMemory
DeAllocate      =       $2b             ; Release
MoveMem         =       $2d             ; Move memory
GetIntVec       =       $2e             ; Get Interrupt vector
SetIntVec       =       $2f             ; Set Interrupt vector
MemAvail        =       $36             ; Memory available
Terminate       =       $38             ; Terminate program execution
Execute         =       $39             ; Execute child proccess
OSshell         =       $3a             ; без д│ми
ParmCnt         =       $3b             ; Get number of command line parameters
ParmStr         =       $3c             ; Get parameter
GetErrorText    =       $3d             ;
DosVersion      =       $41             ; Get current version of UniDos
;  ---------------------------------------------------------------------------

; --- File Support interrupts ----
OpenFile        =       $4a             ; Set A with following modes
RO_mode         =       1               ;   ReadOnly mode
WO_mode         =       2               ;   WriteOnly mode
RW_mode         =       3               ;   ReadWrite mode
GetDrive        =       $45             ; Get current active drive
CreateFile      =       $4b             ;
ReadFile        =       $4c             ;
WriteFile       =       $4d             ;
CloseFile       =       $4e             ;
DeleteFile      =       $4f             ;
SeekFile        =       $50             ; Set B with following methods
_FromBegin      =       0               ;   from the begining of file
_FromCurr       =       1               ;   from current position
_FromEnd        =       2               ;   from the end of file
FileSize        =       $51             ;
FilePos         =       $53             ; Get Current file position
FileAttrib      =       $54             ; File Attrubute
RenameFile      =       $56             ;
ReadLine        =       $57             ; Reads line from text file
CheckEof        =       $58             ;
;   ---------------------------------------------------------------------------
