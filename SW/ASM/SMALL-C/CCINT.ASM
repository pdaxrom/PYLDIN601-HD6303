 ORG $100
; NAM SMALL-C INTERPRETER
; OPT NOP,NOG
;
;   LAST UPDATE   9-SEP-82
;
 JMP BEGIN ;START THE INTERPRETER

;  AN INDIRECT CALL TABLE
 NOP ;PUT ON A BOUNDARY OF 4
 DB 86
 JMP fclose+1
 DB 86
 JMP fopen+1
 DB 86
 JMP getc+1
 DB 86
 JMP getchar+1
 DB 86
 JMP gets+1
 DB 86
 JMP putc+1
 DB 86
 JMP putchar+1
 DB 86
 JMP puts+1
 NOP
 JMP RTSC
 DB 86
 JMP isalpha+1
 DB 86
 JMP isdigit+1
 DB 86 
 JMP isalnum+1
 DB 86
 JMP islower+1
 DB 86
 JMP isupper+1
 DB 86
 JMP isspace+1
 DB 86
 JMP toupper+1
 DB 86
 JMP tolower+1
 DB 86
 JMP strclr+1
 DB 86
 JMP strlen+1
 DB 86
 JMP strcpy+1
 DB 86
 JMP strcat+1
 DB 86
 JMP strcmp+1
 DS 4*4 ;ROOM FOR 4 MORE

; LIB FLEXPTRS

NFILES EQU 4	; MAX NO OF DISK FILES OPEN AT ONCE
PC DS 2		; PSEUDO PROGRAM COUNTER
R1A DS 1	; WORKING 16 BIT
R1B DS 1	; --REGISTER
DFLAG DB NFILES-1 ; DIVIDE ROUTINE FLAG
STEMP DS 2	; TEMP STORAGE FOR STACK POINTER
X1TMP DS 2	; TEMP STORAGE FOR X REG
X2TMP DS 2	; ... DITTO ...
FCBPTR DS 2	; POINTER INTO FCB TABLE
FCBTBL DW $F000	; TABLE OF FCB POINTERS FIXME
 DS NFILES*2	; ROOM FOR THE REST



;**************************************************

BEGIN
; LDX #FCBTBL+2	; POINT TO FCB ADDRESSES
; LDAA #NFILES-1
; STAA DFLAG		;   INIT COUNTER
; LDAA $AC2B		; GET TOP OF MEMORY
; LDAB $AC2C

;BLOOP SUBB #$40		; SUBTR 320 (SIZE OF FCB)
; SBCA #1
; STAA 0,X		; SAVE FCB ADDRESS
; INX
; STAB 0,X
; INX
; DEC DFLAG		; DONE ???
; BNE BLOOP

; CLR 0,X		; MARK END OF TABLE
; CLR 1,X
; STAA STEMP		; TOP OF STACK AREA
; STAB STEMP+1
; LDX STEMP
; TXS			; STACK POINTER

; LDX #FCBTBL		; POINT TO TABLE OF FCB ADDRESSES
;Init
; STX FCBPTR
; LDX 0,X		; GET FCB ADDRESS
; BEQ Initend		; QUIT IF END OF TABLE
; CLR 2,X		; MARK AS NOT IN USE
; LDX FCBPTR
; INX
; INX
; BRA Init

Initend LDX #$800
 BRA NEXT2		; START THE INTERPRETATION

;*************************************************************
;
;  THE HEART OF THE INTERPRETER--- NEXT INSTRUCTION FETCHER.
;
BUMP2	LDX PC			; GET PROG COUNTER
BUMP2A	INX			; INCR BY 2
	INX
	BRA NEXT1		; FETCH NEXT INSTRUCTION

NEXT	LDX PC
NEXT1	STD R1A			; SAVE THE WORK REGISTER
NEXT2	LDAB 0,X		; GET THE PSEUDO-INSTRUCTION

; staa $88
; stab $89
; stx  $8a
; xgdx
;; int $25
; jsr  $f317
; tba
;; int $25
; jsr  $f317
;
; ldx $8a
; ldaa #' '
;; int $22
; jsr $f676
; ldaa 0,x
;; int $25
; jsr  $f317
;
; ldaa #' '
;; int $22
; jsr  $f676
;
; tsx
; xgdx
;; int $25
; jsr  $f317
; tba
;; int $25
; jsr  $f317
;
; ldaa #' '
;; int $22
; jsr  $f676
;
; ldaa R1A
;; int $25
; jsr  $f317
; ldaa R1B
;; int $25
; jsr  $f317
;
; ldaa #10
;; int $22
; jsr  $f676
; ldaa #13
;; int $22
; jsr  $f676
; ldx  $8a
; ldab $89
; ldaa $88

	INX			;  (B CONTAINS A TABLE OFFSET)
	STX PC			; SAVE NEW PC
	LDX	#JTABLE
	ABX
	LDX	0,X
	LDD R1A			; RESTORE
	JMP 0,X			; GO EXECUTE THE PSEUDO-INSTR.

;*************************************************************
;                  THE JUMP TABLE                            *
;*************************************************************

 DS $200-*		;  MUST START ON A PAGE BOUNDARY

JTABLE DW LD1IM		; #0
 DW LD1SOFF		; #1
 DW LD1			; #2
 DW LDB1		; #3
 DW LD1R		; #4
 DW LDB1R		; #5
 DW ST1			; #6
 DW STB1		; #7
 DW ST1SP		; #8
 DW STB1SP		; #9
 DW PUSHR1		; #10
 DW EXG1		; #11
 DW JMPL		; #12
 DW BRZL		; #13
 DW JSRL		; #14
 DW JSRSP		; #15
 DW RTSC		; #16
 DW MODSP		; #17
 DW DBL1		; #18
 DW ADDS		; #19
 DW SUBFST		; #20
 DW MUL1		; #21
 DW DIV1		; #22
 DW MOD			; #23
 DW ORS			; #24
 DW XORS		; #25
 DW ANDS		; #26
 DW ASRS		; #27
 DW ASLS		; #28
 DW NEGR		; #29
 DW NOTR		; #30
 DW INCR		; #31
 DW DECR		; #32
 DW ZEQ			; #33
 DW ZNE			; #34
 DW ZLT			; #35
 DW ZLE			; #36
 DW ZGT			; #37
 DW ZGE			; #38
 DW ULT			; #39
 DW ULE			; #40
 DW UGT			; #41
 DW UGE			; #42
 DW ASMC		; #43

;************************************************************
;-------------------------
; #0 LOAD REG WITH IMMED. VALUE
LD1IM LDX PC
 LDD 0,X
 JMP BUMP2A

;-------------------------
; #1 LOAD STACK ADDRESS + OFFSET INTO REG
LD1SOFF STS R1A		; SAVE STACK VALUE
 LDX PC
 LDD 0,X		; GET OFFSET VALUE
 ADDD R1A
 ADDD #1		; ADD OFFSET + 1
 JMP BUMP2A

;-------------------------
; #2  LOAD WORD @ ADDRESS
LD1 LDX PC
 LDX 0,X		; GET ADDRESS
 LDD 0,X		; GET WORD
 JMP BUMP2

;-------------------------
; #3  LOAD BYTE @ ADDRESS
LDB1 LDX PC
 LDX 0,X		; GET ADDRESS
 CLRA
 LDAB 0,X		; GET BYTE
 BPL LDB1A
 COMA			; SIGN EXTEND
LDB1A JMP BUMP2

;-------------------------
; #4  LOAD WORD INDIRECT (ADDR IN REG)
LD1R LDX R1A		; GET ADDRESS
 LDD 0,X		; GET WORD
 JMP NEXT

;-------------------------
; #5  LOAD BYTE INDIRECT (ADDR IN REG)
LDB1R LDX R1A
 CLRA
 LDAB 0,X		; GET BYTE
 BPL LDB1RA
 COMA
LDB1RA JMP NEXT

;-------------------------
; #6  STORE WORD @ ADDRESS
ST1 LDX PC
 LDX 0,X		; GET ADDRESS
 STD 0,X		; STORE WORD
 JMP BUMP2

;-------------------------
; #7  STORE BYTE @ ADDRESS
STB1 LDX PC
 LDX 0,X		; GET ADDR
 STAB 0,X		; STORE BYTE
 JMP BUMP2

;-------------------------
; #8  STORE WORD @ ADDRESS ON STACK
ST1SP TSX		; STACK TO INDEX
 LDX 0,X		; GET ADDRESS
 STD 0,X		; STORE WORD
 INS
 INS			; POP STACK
 JMP NEXT

;-------------------------
; #9  STORE BYTE @ ADDRESS ON STACK
STB1SP TSX
 LDX 0,X
 STAB 0,X		; STORE BYTE
 INS			; POP ...
 INS
 JMP NEXT

;-------------------------
; #10  PUSH WORD ON STACK
PUSHR1 PSHB
 PSHA
 LDX PC
 JMP NEXT2

;-------------------------
; #11  SWAP REG AND TOP OF STACK
EXG1 TSX
 LDX 0,X		; GET VALUE ON STACK
 STX R1A		; SAVE
 INS
 INS
 PSHB
 PSHA			; REG ON STACK
 LDD R1A		; NEW REG
 LDX PC
 JMP NEXT2

;-------------------------
; #12  JUMP TO LABEL
JMPL LDX PC
JMP1 LDX 0,X		; GET ADDRESS (NEW PC)
 JMP NEXT2

;-------------------------
; #13  JUMP TO LABEL IF FALSE
BRZL ORAA R1B		; SET FLAGS
 BEQ JMPL		; IF REG=0 -- JUMP
 JMP BUMP2		; ELSE, PROCEED

;-------------------------
; #14  CALL TO LABEL
JSRL LDX PC
 INX			; ADJUST RETURN
 INX			; -- ADDRESS
 DES
 STS *+5		; *** SELF MODIFYING CODE ***
 DES
 STX $FFFF		; PUSH RETURN ADDRESS
 BRA JMPL

;-------------------------
; #15  CALL TO TOP OF STACK
JSRSP TSX		; POINT TO STACK
 LDX 0,X		; GET ADDRESS (NEW PC)
 INS			; POP
 INS
 LDD PC
 PSHB
 PSHA
 JMP NEXT2

;-------------------------
; #16  RETURN TO CALLER
RTSC TSX
 LDX 0,X		; GET ADDRESS
 INS			; POP
 INS
 JMP NEXT1

;-------------------------
; #17  MODIFY THE STACK POINTER
MODSP LDX PC
 LDD 0,X		; GET VALUE
 STS STEMP
 ADDD STEMP		; ADD STACK POINTER
 STD STEMP
 LDS STEMP		; NEW STACK POINTER
 LDD R1A		; RESTORE REGISTER
 JMP BUMP2A

;---------------------------
; #18  DOUBLE THE PRIMARY REGISTER
DBL1 ASLB
 ROLA
 JMP NEXT

;---------------------------
; #19  ADD REG AND TOP OF STACK (THEN POP)
ADDS TSX
 ADDD 0,X		; DO THE ADD
 JMP POPS		; POP & RETURN

;---------------------------
; #20  SUBTRACT REG FROM TOP OF STACK
SUBFST PULA		; GET VALUE OFF STACK
 PULB
 SUBD R1A		; SUBTRACK REGISTER
 JMP NEXT

;---------------------------
; #21  MULTIPLY TOP OF STACK BY REG (RESULT IN REG)
MUL1 PSHB
 PSHA			; REG ON STACK
 LDAA #16
 PSHA			; SET COUNTER
 CLRA
 CLRB
 TSX			; POINT TO DATA

M2 ROR 3,X		; SHIFT MULTIPLIER
 ROR 4,X
 DEC 0,X		; DONE ?
 BMI M4
 BCC M3
 ADDD 1,X

M3 RORA
 RORB			; SHIFT RESULT
 BRA M2			; AND LOOP

M4 INS			; CLEAN STACK
 INS
 INS
 PULA			; GET RESULT
 PULB
 JMP NEXT

;-----------------------------
; #22  DIVIDE THE TOP OF STACK BY REG --- RESULT IN REG.
DIV1 BSR BDIV		; DO THE BASIC DIVIDE
 LDAA DFLAG		; GET SIGN FLAG
 ANDA #1		; MASK OFF BIT ZERO
 PULA			; GET RESULT
 PULB
 BEQ DIV1R

DIV1N BSR NEGATE	; NEGATE THE VALUE IN A,B

DIV1R JMP NEXT

;-----------------------------
; #23  DIVIDE TOP OF STACK BY REG --- REMAINDER IN REG
MOD BSR BDIV
 INS			; CLEAN STACK
 INS
 PSHA			; TEMP SAVE
 LDAA DFLAG		; GET SIGN FLAG
 BPL MOD1
 COMA

MOD1 ANDA #1		; MASK OFF BIT 0
 PULA
 BNE DIV1N		; IF BIT 0 SET, NEGATE

 JMP NEXT

;****************************************************
;   BASIC 16 BIT DIVIDE ROUTINE
; ENTER WITH: DIVIDEND ON STACK
;             DIVISOR IN A,B
; EXIT WITH:  QUOTIENT ON STACK
;             REMAINDER IN A,B
;             SIGN FLAG IN DFLAG
;
BDIV CLR DFLAG
 TSTA			; CHECK DIVISOR SIGN
 BPL BDIV1

 INC DFLAG		; ADJUST SIGN FLAG
 BSR NEGATE		; TAKE ABSOLUTE VALUE

BDIV1 PSHB		; FORCE ON STACK
 PSHA
 LDAA #17		; BIT COUNTER
 PSHA
 TSX			; POINT TO DATA
 LDAA 5,X		; CHECK SIGN
 BPL BDIV2		; -- OF DIVIDEND

 COM DFLAG		; ADJUST FLAG
 LDAB 6,X
 BSR NEGATE
 STD  5,X

BDIV2 CLRA
 CLRB

; MAIN DIVIDE LOOP (UNSIGNED)

UDIV1 CMPA 1,X
 BHI UDIV3
 BCS UDIV2
 CMPB 2,X
 BCC UDIV3

UDIV2 CLC
 BRA UDIV4

UDIV3 SUBD 1,X
 SEC

UDIV4 ROL 6,X
 ROL 5,X
 DEC 0,X
 BEQ UDIV5

 ROLB
 ROLA
 BCC UDIV1
 BRA UDIV3

UDIV5 INS
 INS
 INS
 RTS

;----------------------------------------
; NEGATE THE VALUE IN A,B
NEGATE COMA
 COMB
 ADDD #1
 RTS

;----------------------------------
; #24  INCLUSIVE OR THE TOP OF STACK AND REG.
ORS TSX
 ORAA 0,X
 ORAB 1,X
POPS INS		; POP THE STACK
 INS
 JMP NEXT

;----------------------------------
; #25  EXCLUSIVE OR ......
XORS TSX
 EORA 0,X
 EORB 1,X
 BRA POPS

;----------------------------------
; #26  AND .........
ANDS TSX
 ANDA 0,X
 ANDB 1,X
 BRA POPS

;----------------------------------
; #27  ARITH. SHIFT RIGHT THE TOP OF STACK
ASRS TSX
 ANDB #$1F		; MAX REASONABLE SHIFT
 BEQ ASRS2

ASRS1 ASR 0,X
 ROR 1,X
 DECB
 BNE ASRS1

ASRS2 PULA		; GET THE RESULT
 PULB
 JMP NEXT

;--------------------------------
; #28  ARITH. SHIFT LEFT THE TOP OF STACK
ASLS TSX
 ANDB #$1F
 BEQ ASRS2

ASLS1 ASL 1,X
 ROL 0,X
 DECB
 BNE ASLS1

 BRA ASRS2

;--------------------------------
; #29  NEGATE THE REGISTER
NEGR BSR NEGATE
 JMP NEXT

;--------------------------------
; #30  COMPLEMENT THE REGISTER
NOTR COMA
 COMB
 JMP NEXT

;--------------------------------
; #31  ADD 1 TO REG
INCR ADDD #1
 JMP NEXT

;--------------------------------
; #32 SUBTRACT 1 FROM REG
DECR SUBD #1
 JMP NEXT

;****************************************************
;
;   BASIC COMPARE INSTRUCTION SUBROUTINE
;   Compare the top of Stack to Register and set Condition codes
;
;  Signed compare -- Carry reflects the sign of difference
;         (set means: top of stack < A,B )
;
SCMP TSX
 LDD 2,X		; GET TOP OF STACK
 SUBD R1A		; SET CONDITION FLAGS
 BPL STCMP1		; SKIP IF PLUS

 STAB R1B		; TEMP SAVE
 ORAA R1B		; SET/RESET ZERO FLAG
 SEC			; AND SET CARRY
 RTS

STCMP1 STAB R1B
 ORAA R1B
 CLC			; CLEAR THE CARRY
 RTS
;
;  Unsigned compare, Carry set if top of stack < A,B
;
BCMP TSX
 LDD 2,X		; GET TOP OF STACK
 CMPA R1A		; CHECK TOP BYTE
 BNE BCMP1
 CMPB R1B
BCMP1 RTS

;-------------------------------
; #33  TEST FOR EQUALITY
ZEQ BSR BCMP
 BEQ TRUE
 BRA FALSE

;-------------------------------
; #34  TEST FOR NOT-EQUAL
ZNE BSR BCMP
 BNE TRUE
 BRA FALSE

;-------------------------------
; #35  TEST FOR LESS THAN
ZLT BSR SCMP
 BCS TRUE
 BRA FALSE

;-------------------------------
; #36  TEST FOR LESS THAN OR EQUAL
ZLE BSR SCMP
 BLS TRUE
 BRA FALSE

;-------------------------------
; #37  TEST FOR GREATER THAN
ZGT BSR SCMP
 BHI TRUE
 BRA FALSE

;-------------------------------
; #38  TEST FOR GREATER THAN OR EQUAL
ZGE BSR SCMP
 BCC TRUE
 BRA FALSE

;-------------------------------
; #39 TEST FOR LESS THAN (UNSIGNED)
ULT BSR BCMP
 BCS TRUE
 BRA FALSE

;-------------------------------
; #40  TEST FOR LESS THAN OR EQUAL (UNSIGNED)
ULE BSR BCMP
 BLS TRUE
 BRA FALSE

;-------------------------------
; #41  TEST FOR GREATER THAN (UNSIGNED)
UGT BSR BCMP
 BHI TRUE
 BRA FALSE

;------------------------------
; #42  TEST FOR GREATER THAN OR EQUAL (UNSIGNED)
UGE BSR BCMP
 BCC TRUE

FALSE CLRB		; RETURN FALSE
 BRA TRUE1

TRUE LDAB #1		; RETURN TRUE

TRUE1 CLRA
 JMP POPS		; POP STACK AND PROCEED

;-------------------------------------
; #43  SWITCH TO EXECUTABLE (ASSEMBLY) CODE
ASMC LDX PC		; POINT TO CODE
 JMP 0,X		; GO EXECUTE IT

;**********************************************************
;
;        RUN-TIME SUBROUTINE LIBRARY
;
;**********************************************************

;   fopen(file-name, "type")
;   Open a File..........
fopen DB 86		; SWITCH TO INLINE CODE
 LDX #FCBTBL-2		; POINT TO FCB ADDRESSES TABLE

NXTFIL INX
 INX
 STX FCBPTR		; SAVE POINTER
 LDX 0,X		; GET FCB ADDRESS
 BEQ NOFILE
 TST 2,X		; BUSY ?
 BEQ GODOIT		; NO,
 LDX FCBPTR		; ELSE, NEXT IN LINE
 BRA NXTFIL

NOFILE LDX #FMSG	; POINT TO MESSAGE
; JSR PSTRNG		; PRINT IT
; JMP WARMS		; --AND BACK TO FLEX

GODOIT STX R1A		; SAVE FCB ADDRESS
 TSX
 LDX 4,X		; POINT TO FILE NAME
 STX $AC14		; SAVE IN LINE BUFFER POINTER
 LDX R1A		; GET FCB POINTER
; JSR GETFIL		; GET FILE SPEC
 BCS FERROR		; REPORT IF ERROR
 TSX
 LDX 2,X		; POINT TO MODE
 LDAA #1
 LDAB #'w'		; OPEN FOR WRITE
 CMPB 0,X		;  -- ????
 BEQ OWRITE		; YES,

;  DEFAULT TO OPEN FOR READ

 LDX R1A		; POINT TO FCB
 STAA 0,X		; STORE IN FCB
; JSR FMS		; DO THE OPEN
 BEQ FEXIT

FERROR; JSR RPTERR	; REPORT THE TYPE OF ERROR
; JSR FMSCLS		; CLOSE ALL OPEN FILES
; JMP WARMS		; RETURN TO FLEX

; OK, OPEN FOR WRITE

OWRITE LDAA #2		; CODE FOR WRITE
 LDX R1A		; GET FCB ADDRESS
 STAA 0,X
; JSR FMS		; TRY AN OPEN
 BEQ FEXIT		; IF SUCCESSFULL--DONE

 LDAA 1,X		; GET ERROR STATUS
 CMPA #3		; ALREADY EXISTS ?
 BNE FERROR		; NO--SOME OTHER ERROR

 LDAA #12		; DELETE THE EXISTING FILE
 STAA 0,X
; JSR FMS
 BNE FERROR
 LDAA 36,X		; FIX NAME
 STAA 4,X
 BRA OWRITE

FEXIT TSX
 LDX 2,X		; POINT TO MODE AGAIN
 LDAB 1,X		; GET OPTIONAL CHAR
 CMPB #'u'		; UNCOMPRESSED (BINARY) ???
 BNE FEXIT1		; NO, SO SKIP

 LDAB #$FF
 LDX R1A
 STAB 59,X		; SET FLAG IN FCB

FEXIT1 LDAA R1A	; RETURN THE FCB POINTER
 LDAB R1B

 JMP RTSC		; RETURN TO INTERPRETER

;-------------------------------------------------

;  fclose(unit)
;  CLOSE A FILE
fclose DB 86		; SWITCH TO IN-LINE
 TSX
 LDX 2,X		; POINT TO FCB
 LDAA #4		; CLOSE CODE
 STAA 0,X
; JSR FMS		; DO THE CLOSE
 BNE FERROR
 CLRA
 LDAB #1		; OK CODE
 JMP RTSC		; RETURN TO INTERPRETER....

;--------------------------------------------------

;  getc(unit)  read a byte from file
;        return a char, else a -1 if EOF

getc DB 86
 TSX
 LDX 2,X		; POINT TO FCB
; JSR FMS		; GET BYTE
 BEQ CHOK

 LDAA 1,X		; GET ERROR
 CMPA #8		; EOF ?
 BNE FERROR

 LDAA #$FF		; LOAD EOF INDICATOR

CHOK TAB		;  COPY CHAR IN A
CHOK1 CLRA
 TSTB
 BPL GETC1

 COMA			;  SIGN EXTEND

GETC1 JMP RTSC

;----------------------------------------------

;  putc(c,unit)   write to file

putc DB 86
 TSX
 LDAA 5,X		; GET CHAR
 LDX 2,X		; GET FCB ADDR
 PSHA			; SAVE CHAR
; JSR FMS
 BNE FERROR
 PULB			; GET CHAR
 BRA CHOK1

;-----------------------------------------------
FMSG DB 'NO MORE FILES MAY BE OPENED.', 10, 0
;-----------------------------------------------

;   getchar()    get a char from standard input

getchar DB 86
 int $20

 CMPA #$1A		; COMPARE TO CNTRL-Z (EOF)
 BNE CHOK		; NO
 LDAB #$FF		; YES...
 BRA CHOK1		; RETURN -1

;-----------------------------------------------

;   putchar(c)   write a char to standard output

putchar DB 86
 TSX
 LDAA 3,X		; GET THE CHAR
 PSHA			; SAVE CHAR
 int $22
 PULB			; RESTORE CHAR
 BRA CHOK1

;----------------------------------------------

;   gets(buffer)  get a char string into buffer

gets DB 86
 TSX
 LDX 2,X GET START OF BUFFER
 LDAB #40		; max buffer size
 int $21
 CLRA
 TSX
 STD 2,X
 JMP RTSC

;----------------------------------------------
;  puts(string)  print a string on the terminal
puts DB 86
 TSX
 LDX 2,X		; GET STRING ADDRESS
 int $23
 JMP RTSC

;----------------------------------------------
;
;
;       Test if given char is alpha     *
; isalpha(c)
;       char c;
; {     c=c&127;
;       return(((c>='a')&(c<='z'))|
;               ((c>='A')&(c<='Z'))|
;               (c='_'));
; }
;
isalpha DB      86	; switch to assembly
        TSX
        LDAB    3,X	;     get char
        BSR     alPHA
        JMP     RTSC
;
;---------------------------------------------
;       Test if given char is numeric   *
;
; isdigit(c)
;       char c;
; {     c=c&127;
;       return((c>='0')&(c<='9'));
; }
;
isdigit DB      86
        TSX
        LDAB    3,X
        BSR     nuMERIC
        JMP     RTSC
;
;----------------------------------------------
;       Test if given char is alphanumeric      *
;
; isalnum(c)
;       char c;
; {     return((alpha(c)|(numeric(c)));
; }
;
isalnum DB      86
        TSX
        LDAB    3,X     ;get char
        BSR     alPHA   ;check if alpha
        TSX
        PSHB            ;save result
        LDAB    3,X     ;get char again
        BSR     nuMERIC ;check if decimal
        TSX
        ORAB    0,X     ;fix flag
        INS             ;clean stack
        JMP     RTSC
;
;
alPHA   CLRA
        ANDB   #$7F
        CMPB   #'a'
        BLT     alPHA1
        CMPB   #'z'
        BLE     alYES
alPHA1  CMPB   #'A'
        BLT     alPHA2
        CMPB   #'Z'
        BLE     alYES
alPHA2  CMPB   #'_'
        BEQ     alYES
;
alNO    CLRB
        RTS
;
alYES   LDAB   #1
        RTS
;
;
nuMERIC CLRA
        ANDB   #$7F
        CMPB   #'0'
        BLT     alNO
        CMPB   #'9'
        BLE     alYES
        BRA     alNO
;
;-----------------------------------------------
;  islower(c)
;       char c;        returns TRUE if c is lower case alpha,
;                        FALSE otherwise.
;
islower DB 86		; SWITCH TO IN-LINE
 TSX
 LDAB 3,X		; GET CHAR
 ANDB #$7F
 CLRA
 CMPB #'a'
 BLT ISNO
 CMPB #'z'
 BLE ISYES
;
ISNO CLRB
 JMP RTSC		;    RETURN FALSE
;
ISYES LDAB #1
 JMP RTSC		; RETURN TRUE
;
;----------------------------------------------
;  isupper(c)
;      char c;      return TRUE if c is upper case alpha.
;
isupper DB 86
 TSX
 LDAB 3,X
 ANDB #$7F
 CLRA
 CMPB #'A'
 BLT ISNO
 CMPB #'Z'
 BLE ISYES
 BRA ISNO
;
;-----------------------------------------------
;  isspace(c)
;      char c;       return TRUE if a "white space" char
;
isspace DB 86
 TSX
 LDAB 3,X		; GET CHAR
 ANDB #$7F
 CLRA
 CMPB #' '		;  SPACE ?
 BEQ ISYES
 CMPB #$0D		;  CR ???
 BEQ ISYES
 CMPB #$0A		;  LF ???
 BEQ ISYES
 CMPB #$09		;  HOR TAB ???
 BEQ ISYES
 BRA ISNO
;
;----------------------------------------------
;  toupper(c)
;      char c;   make c an upper case char if lower
;                          case alpha
;
toupper DB 86
 TSX
 LDD 2,X
 BNE TOUPP1		;  SKIP IF MSB'S NOT ZERO
 CMPB #'a'
 BLT TOUPP1
 CMPB #'z'
 BGT TOUPP1
 SUBB #$20		;  CONVERT TO UPPER CASE
TOUPP1 JMP RTSC
;
;---------------------------------------------
;  tolower(c)
;      char c;   convert to lower case if upper case alpha.
;
tolower DB 86
 TSX
 LDD 2,X
 BNE TOLOW1
 CMPB #'A'
 BLT TOLOW1
 CMPB #'Z'
 BGT TOLOW1
 ADDB #$20		; CONVERT TO LOWER CASE
TOLOW1 JMP RTSC
;
;---------------------------------------------
;  strclr(s,n)
;      char *s;  int n;  clear a string of n bytes.
;
strclr DB 86
 TSX
 LDD  2,X		; GET LENGTH OF STRING
 LDX  4,X		; POINT TO STRING
SCLR1 CLR 0,X
 INX
 SUBD #1
 BNE SCLR1
SCLR3 JMP RTSC
;
;-----------------------------------------------
;  return the length of a string
;
; strlen(s)
;       char *s;
; {     char *t;
;       t=s;
;       while (*s) s++;
;       return (s-t);
; }
;
strlen  DB     86
        TSX
        LDX     2,X	; point to string
        CLRA            ; preset counter
        CLRB
;
strlLP  TST     0,X     ; look for NULL
        BEQ     strlRT  ; found !!
        INX
        ADDD   #1	; bump counter
        BRA     strlLP
;
strlRT  JMP     RTSC
;
;------------------------------------------------
;  strcpy(s1,s2)
;      char *s1, *s2;    copy s2 into s1.
;
strcpy DB 86
 TSX
 LDX 4,X		; POINT TO S1
 STX X1TMP		; SAVE POINTER
 TSX
 LDX 2,X		; POINT TO S2

SCPY1 LDAB 0,X
 INX
 STX X2TMP
 LDX X1TMP
 STAB 0,X
 BEQ SCLR3		;  END OF STRING ???
 INX
 STX X1TMP
 LDX X2TMP
 BRA SCPY1
;
;------------------------------------------------
;  strcat(s1,s2)
;      char *s1, *s2;   s2 is concatenated onto s1.
;
strcat DB 86
 TSX
 LDX 2,X
 STX X2TMP		; SAVE POINTER TO S2
 TSX
 LDX 4,X		; POINT TO S1

SCAT1 TST 0,X		; LOOK FOR END OF STRING
 BEQ SCAT2
 INX
 BRA SCAT1

SCAT2 STX X1TMP		; SAVE POINTER
 LDX X2TMP
 LDAB 0,X
 INX
 STX X2TMP
 LDX X1TMP
 STAB 0,X
 BEQ SCAT3
 INX
 BRA SCAT2

SCAT3 JMP RTSC
;
;--------------------------------------------
;  strcmp(s1,s2)
;        char *s1, *s2;       returns:   0  if s1 = s2
;                                       <0  if s1 < s2
;                                       >0  if s1 > s2
;
strcmp DB 86
 TSX
 LDX 2,X		; POINT TO S2
 STX X2TMP
 TSX
 LDX 4,X		; POINT TO S1

SCMP1 LDAA 0,X		; GET S1 CHAR
 BEQ SCMP3
 INX
 STX X1TMP
 LDX X2TMP
 LDAB 0,X
 BEQ SCMP2
 SBA			; COMPARE BY SUBTRACTING
 BNE SCMP3
 INX
 STX X2TMP
 LDX X1TMP
 BRA SCMP1

SCMP2 CLRA

SCMP3 TAB
 BMI SCMP4
 CLRA
 JMP RTSC

SCMP4 LDAA #$FF		; SIGN EXTEND
 JMP RTSC
;
;
;****************************************************
;
HERE EQU *		;   END OF INTERPRETER
; 
; END
