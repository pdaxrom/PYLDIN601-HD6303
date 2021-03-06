#asm

memtabl
	DB	"ABA", 10
	DB	"ABX", 10
	DB	"ADCA", 10
	DB	"ADCB", 10
	DB	"ADDA", 10
	DB	"ADDB", 10
	DB	"ADDD", 10
	DB	"ANDA", 10
	DB	"ANDB", 10
	DB	"ASL", 10
	DB	"ASLA", 10
	DB	"ASLB", 10
	DB	"ASLD", 10
	DB	"ASR", 10
	DB	"ASRA", 10
	DB	"ASRB", 10
	DB	"BCC", 10
	DB	"BCS", 10
	DB	"BEQ", 10
	DB	"BGE", 10
	DB	"BGT", 10
	DB	"BHI", 10
	DB	"BHS", 10
	DB	"BITA", 10
	DB	"BITB", 10
	DB	"BLE", 10
	DB	"BLO", 10
	DB	"BLS", 10
	DB	"BLT", 10
	DB	"BMI", 10
	DB	"BNE", 10
	DB	"BPL", 10
	DB	"BRA", 10
	DB	"BRN", 10
	DB	"BSR", 10
	DB	"BVC", 10
	DB	"BVS", 10
	DB	"CBA", 10
	DB	"CLC", 10
	DB	"CLI", 10
	DB	"CLR", 10
	DB	"CLRA", 10
	DB	"CLRB", 10
	DB	"CLV", 10
	DB	"CMPA", 10
	DB	"CMPB", 10
	DB	"COM", 10
	DB	"COMA", 10
	DB	"COMB", 10
	DB	"CPX", 10
	DB	"DAA", 10
	DB	"DEC", 10
	DB	"DECA", 10
	DB	"DECB", 10
	DB	"DES", 10
	DB	"DEX", 10
	DB	"EORA", 10
	DB	"XORA", 10
	DB	"EORB", 10
	DB	"XORB", 10
	DB	"INC", 10
	DB	"INCA", 10
	DB	"INCB", 10
	DB	"INS", 10
	DB	"INT", 10
	DB	"INX", 10
	DB	"JMP", 10
	DB	"JSR", 10
	DB	"LDAA", 10
	DB	"LDA", 10
	DB	"LDAB", 10
	DB	"LDB", 10
	DB	"LDD", 10
	DB	"LDS", 10
	DB	"LDX", 10
	DB	"LSL", 10
	DB	"LSLA", 10
	DB	"LSLB", 10
	DB	"LSLD", 10
	DB	"LSR", 10
	DB	"LSRA", 10
	DB	"LSRB", 10
	DB	"LSRD", 10
	DB	"MUL", 10
	DB	"NEG", 10
	DB	"NEGA", 10
	DB	"NEGB", 10
	DB	"NOP", 10
	DB	"ORAA", 10
	DB	"ORA", 10
	DB	"ORAB", 10
	DB	"ORB", 10
	DB	"PSHA", 10
	DB	"PHA", 10
	DB	"PSHB", 10
	DB	"PHB", 10
	DB	"PSHX", 10
	DB	"PULA", 10
	DB	"PLA", 10
	DB	"PULB", 10
	DB	"PLB", 10
	DB	"PULX", 10
	DB	"ROL", 10
	DB	"ROLA", 10
	DB	"ROLB", 10
	DB	"ROR", 10
	DB	"RORA", 10
	DB	"RORB", 10
	DB	"RTI", 10
	DB	"RTS", 10
	DB	"SBA", 10
	DB	"SBCA", 10
	DB	"SBCB", 10
	DB	"SEC", 10
	DB	"SEI", 10
	DB	"SEV", 10
	DB	"SLP", 10
	DB	"STAA", 10
	DB	"STA", 10
	DB	"STAB", 10
	DB	"STB", 10
	DB	"STD", 10
	DB	"STS", 10
	DB	"STX", 10
	DB	"SUBA", 10
	DB	"SUBB", 10
	DB	"SUBD", 10
	DB	"SWI", 10
	DB	"TAB", 10
	DB	"TAP", 10
	DB	"TBA", 10
	DB	"TPA", 10
	DB	"TST", 10
	DB	"TSTA", 10
	DB	"TSTB", 10
	DB	"TSX", 10
	DB	"TXS", 10
	DB	"WAI", 10
	DB	"XGDX", 10
	DB	"AIM", 10
	DB	"OIM", 10
	DB	"EIM", 10
	DB	"TIM", 10
	DB	"BCLR", 10
	DB	"BSET", 10
	DB	"BTGL", 10
	DB	"BTST", 10
	DB	0
opcodes
	DB	$00, $1B, $00, $00, $00, $00, $00	;ABA
	DB	$00, $3A, $00, $00, $00, $00, $00	;ABX
	DB	$00, $00, $89, $99, $B9, $A9, $00	;ADCA
	DB	$00, $00, $C9, $D9, $F9, $E9, $00	;ADCB
	DB	$00, $00, $8B, $9B, $BB, $AB, $00	;ADDA
	DB	$00, $00, $CB, $DB, $FB, $EB, $00	;ADDB
	DB	$01, $00, $C3, $D3, $F3, $E3, $00	;ADDD
	DB	$00, $00, $84, $94, $B4, $A4, $00	;ANDA
	DB	$00, $00, $C4, $D4, $F4, $E4, $00	;ANDB
	DB	$00, $00, $00, $00, $78, $68, $00	;ASL
	DB	$00, $48, $00, $00, $00, $00, $00	;ASLA
	DB	$00, $58, $00, $00, $00, $00, $00	;ASLB
	DB	$00, $05, $00, $00, $00, $00, $00	;ASLD
	DB	$00, $00, $00, $00, $77, $67, $00	;ASR
	DB	$00, $47, $00, $00, $00, $00, $00	;ASRA
	DB	$00, $57, $00, $00, $00, $00, $00	;ASRB
	DB	$00, $00, $00, $00, $00, $00, $24	;BCC
	DB	$00, $00, $00, $00, $00, $00, $25	;BCS
	DB	$00, $00, $00, $00, $00, $00, $27	;BEQ
	DB	$00, $00, $00, $00, $00, $00, $2C	;BGE
	DB	$00, $00, $00, $00, $00, $00, $2E	;BGT
	DB	$00, $00, $00, $00, $00, $00, $22	;BHI
	DB	$00, $00, $00, $00, $00, $00, $24	;BHS
	DB	$00, $00, $85, $95, $B5, $A5, $00	;BITA
	DB	$00, $00, $C5, $D5, $F5, $E5, $00	;BITB
	DB	$00, $00, $00, $00, $00, $00, $2F	;BLE
	DB	$00, $00, $00, $00, $00, $00, $25	;BLO
	DB	$00, $00, $00, $00, $00, $00, $23	;BLS
	DB	$00, $00, $00, $00, $00, $00, $2D	;BLT
	DB	$00, $00, $00, $00, $00, $00, $2B	;BMI
	DB	$00, $00, $00, $00, $00, $00, $26	;BNE
	DB	$00, $00, $00, $00, $00, $00, $2A	;BPL
	DB	$00, $00, $00, $00, $00, $00, $20	;BRA
	DB	$00, $00, $00, $00, $00, $00, $21	;BRN
	DB	$00, $00, $00, $00, $00, $00, $8D	;BSR
	DB	$00, $00, $00, $00, $00, $00, $28	;BVC
	DB	$00, $00, $00, $00, $00, $00, $29	;BVS
	DB	$00, $11, $00, $00, $00, $00, $00	;CBA
	DB	$00, $0C, $00, $00, $00, $00, $00	;CLC
	DB	$00, $0E, $00, $00, $00, $00, $00	;CLI
	DB	$00, $00, $00, $00, $7F, $6F, $00	;CLR
	DB	$00, $4F, $00, $00, $00, $00, $00	;CLRA
	DB	$00, $5F, $00, $00, $00, $00, $00	;CLRB
	DB	$00, $0A, $00, $00, $00, $00, $00	;CLV
	DB	$00, $00, $81, $91, $B1, $A1, $00	;CMPA
	DB	$00, $00, $C1, $D1, $F1, $E1, $00	;CMPB
	DB	$00, $00, $00, $00, $73, $63, $00	;COM
	DB	$00, $43, $00, $00, $00, $00, $00	;COMA
	DB	$00, $53, $00, $00, $00, $00, $00	;COMB
	DB	$01, $00, $8C, $9C, $BC, $AC, $00	;CPX
	DB	$00, $19, $00, $00, $00, $00, $00	;DAA
	DB	$00, $00, $00, $00, $7A, $6A, $00	;DEC
	DB	$00, $4A, $00, $00, $00, $00, $00	;DECA
	DB	$00, $5A, $00, $00, $00, $00, $00	;DECB
	DB	$00, $34, $00, $00, $00, $00, $00	;DES
	DB	$00, $09, $00, $00, $00, $00, $00	;DEX
	DB	$00, $00, $88, $98, $B8, $A8, $00	;EORA
	DB	$00, $00, $88, $98, $B8, $A8, $00	;XORA
	DB	$00, $00, $C8, $D8, $F8, $E8, $00	;EORB
	DB	$00, $00, $C8, $D8, $F8, $E8, $00	;XORB
	DB	$00, $00, $00, $00, $7C, $6C, $00	;INC
	DB	$00, $4C, $00, $00, $00, $00, $00	;INCA
	DB	$00, $5C, $00, $00, $00, $00, $00	;INCB
	DB	$00, $31, $00, $00, $00, $00, $00	;INS
	DB	$00, $00, $00, $3F, $00, $00, $00	;INT
	DB	$00, $08, $00, $00, $00, $00, $00	;INX
	DB	$00, $00, $00, $00, $7E, $6E, $00	;JMP
	DB	$00, $00, $00, $9D, $BD, $AD, $00	;JSR
	DB	$00, $00, $86, $96, $B6, $A6, $00	;LDAA
	DB	$00, $00, $86, $96, $B6, $A6, $00	;LDA
	DB	$00, $00, $C6, $D6, $F6, $E6, $00	;LDAB
	DB	$00, $00, $C6, $D6, $F6, $E6, $00	;LDB
	DB	$01, $00, $CC, $DC, $FC, $EC, $00	;LDD
	DB	$01, $00, $8E, $9E, $BE, $AE, $00	;LDS
	DB	$01, $00, $CE, $DE, $FE, $EE, $00	;LDX
	DB	$00, $00, $00, $00, $78, $68, $00	;LSL
	DB	$00, $48, $00, $00, $00, $00, $00	;LSLA
	DB	$00, $58, $00, $00, $00, $00, $00	;LSLB
	DB	$00, $05, $00, $00, $00, $00, $00	;LSLD
	DB	$00, $00, $00, $00, $74, $64, $00	;LSR
	DB	$00, $44, $00, $00, $00, $00, $00	;LSRA
	DB	$00, $54, $00, $00, $00, $00, $00	;LSRB
	DB	$00, $04, $00, $00, $00, $00, $00	;LSRD
	DB	$00, $3D, $00, $00, $00, $00, $00	;MUL
	DB	$00, $00, $00, $00, $70, $60, $00	;NEG
	DB	$00, $40, $00, $00, $00, $00, $00	;NEGA
	DB	$00, $50, $00, $00, $00, $00, $00	;NEGB
	DB	$00, $01, $00, $00, $00, $00, $00	;NOP
	DB	$00, $00, $8A, $9A, $BA, $AA, $00	;ORAA
	DB	$00, $00, $8A, $9A, $BA, $AA, $00	;ORA
	DB	$00, $00, $CA, $DA, $FA, $EA, $00	;ORAB
	DB	$00, $00, $CA, $DA, $FA, $EA, $00	;ORB
	DB	$00, $36, $00, $00, $00, $00, $00	;PSHA
	DB	$00, $36, $00, $00, $00, $00, $00	;PHA
	DB	$00, $37, $00, $00, $00, $00, $00	;PSHB
	DB	$00, $37, $00, $00, $00, $00, $00	;PHB
	DB	$00, $3C, $00, $00, $00, $00, $00	;PSHX
	DB	$00, $32, $00, $00, $00, $00, $00	;PULA
	DB	$00, $32, $00, $00, $00, $00, $00	;PLA
	DB	$00, $33, $00, $00, $00, $00, $00	;PULB
	DB	$00, $33, $00, $00, $00, $00, $00	;PLB
	DB	$00, $38, $00, $00, $00, $00, $00	;PULX
	DB	$00, $00, $00, $00, $79, $69, $00	;ROL
	DB	$00, $49, $00, $00, $00, $00, $00	;ROLA
	DB	$00, $59, $00, $00, $00, $00, $00	;ROLB
	DB	$00, $00, $00, $00, $76, $66, $00	;ROR
	DB	$00, $46, $00, $00, $00, $00, $00	;RORA
	DB	$00, $56, $00, $00, $00, $00, $00	;RORB
	DB	$00, $3B, $00, $00, $00, $00, $00	;RTI
	DB	$00, $39, $00, $00, $00, $00, $00	;RTS
	DB	$00, $10, $00, $00, $00, $00, $00	;SBA
	DB	$00, $00, $82, $92, $B2, $A2, $00	;SBCA
	DB	$00, $00, $C2, $D2, $F2, $E2, $00	;SBCB
	DB	$00, $0D, $00, $00, $00, $00, $00	;SEC
	DB	$00, $0F, $00, $00, $00, $00, $00	;SEI
	DB	$00, $0B, $00, $00, $00, $00, $00	;SEV
	DB	$00, $1A, $00, $00, $00, $00, $00	;SLP
	DB	$00, $00, $00, $97, $B7, $A7, $00	;STAA
	DB	$00, $00, $00, $97, $B7, $A7, $00	;STA
	DB	$00, $00, $00, $D7, $F7, $E7, $00	;STAB
	DB	$00, $00, $00, $D7, $F7, $E7, $00	;STB
	DB	$00, $00, $00, $DD, $FD, $ED, $00	;STD
	DB	$00, $00, $00, $9F, $BF, $AF, $00	;STS
	DB	$00, $00, $00, $DF, $FF, $EF, $00	;STX
	DB	$00, $00, $80, $90, $B0, $A0, $00	;SUBA
	DB	$00, $00, $C0, $D0, $F0, $E0, $00	;SUBB
	DB	$01, $00, $83, $93, $B3, $A3, $00	;SUBD
	DB	$00, $3F, $00, $00, $00, $00, $00	;SWI
	DB	$00, $16, $00, $00, $00, $00, $00	;TAB
	DB	$00, $06, $00, $00, $00, $00, $00	;TAP
	DB	$00, $17, $00, $00, $00, $00, $00	;TBA
	DB	$00, $07, $00, $00, $00, $00, $00	;TPA
	DB	$00, $00, $00, $00, $7D, $6D, $00	;TST
	DB	$00, $4D, $00, $00, $00, $00, $00	;TSTA
	DB	$00, $5D, $00, $00, $00, $00, $00	;TSTB
	DB	$00, $30, $00, $00, $00, $00, $00	;TSX
	DB	$00, $35, $00, $00, $00, $00, $00	;TXS
	DB	$00, $3E, $00, $00, $00, $00, $00	;WAI
	DB	$00, $18, $00, $00, $00, $00, $00	;XGDX
	DB	$80, $00, $00, $71, $00, $61, $00	;AIM
	DB	$80, $00, $00, $72, $00, $62, $00	;OIM
	DB	$80, $00, $00, $75, $00, $65, $00	;EIM
	DB	$80, $00, $00, $7B, $00, $6B, $00	;TIM
	DB	$A0, $00, $00, $71, $00, $61, $00	;BCLR
	DB	$C0, $00, $00, $72, $00, $62, $00	;BSET
	DB	$C0, $00, $00, $75, $00, $65, $00	;BTGL
	DB	$C0, $00, $00, $7B, $00, $6B, $00	;BTST

#endasm
