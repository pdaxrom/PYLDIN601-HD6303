/*
 *
 * Pyldin-601 emulator version 3.1 for Linux,MSDOS,Win32
 * Copyright (c) Sasha Chukov & Yura Kuznetsov, 2000-2004
 *
 */

#define NOP		0x01

#define	CLC		0x0c
#define	CLI		0x0e
#define	CLV		0x0a
#define	SEC		0x0d
#define	SEI		0x0f
#define	SEV		0x0b

#define	TAP		0x06
#define	TPA		0x07

#define	TAB		0x16
#define	TBA		0x17

#define	TSX		0x30
#define	TXS		0x35

#define	DEC_idx		0x6a
#define	DEC		0x7a
#define	DECA		0x4a
#define	DECB		0x5a
#define	DES		0x34
#define	DEX		0x09

#define	INC_idx		0x6c
#define	INC		0x7c
#define	INCA		0x4c
#define	INCB		0x5c
#define	INS		0x31
#define	INX		0x08

#define	NEG_idx		0x60
#define	NEG		0x70
#define NEGA		0x40
#define	NEGB		0x50

#define	COM_idx		0x63
#define	COM		0x73
#define COMA		0x43
#define	COMB		0x53

#define CLR_idx		0x6f
#define	CLR		0x7f
#define CLRA		0x4f
#define	CLRB		0x5f

#define LDAA_imm	0x86
#define	LDAA_dir	0x96
#define	LDAA_idx	0xa6
#define	LDAA		0xb6
#define	LDAB_imm	0xc6
#define	LDAB_dir	0xd6
#define	LDAB_idx	0xe6
#define	LDAB		0xf6

#define	LDS_imm		0x8e
#define	LDS_dir		0x9e
#define	LDS_idx		0xae
#define	LDS		0xbe
#define	LDX_imm		0xce
#define	LDX_dir		0xde
#define	LDX_idx		0xee
#define	LDX		0xfe

#define	STAA_dir	0x97
#define	STAA_idx	0xa7
#define	STAA		0xb7
#define	STAB_dir	0xd7
#define	STAB_idx	0xe7
#define	STAB		0xf7

#define	STS_dir		0x9f
#define	STS_idx		0xaf
#define	STS		0xbf
#define	STX_dir		0xdf
#define	STX_idx		0xef
#define	STX		0xff

#define	ABA		0x1b

#define	ADCA_imm	0x89
#define	ADCA_dir	0x99
#define	ADCA_idx	0xa9
#define	ADCA		0xb9
#define ADCB_imm	0xc9
#define	ADCB_dir	0xd9
#define ADCB_idx	0xe9
#define	ADCB		0xf9

#define	ADDA_imm	0x8b
#define	ADDA_dir	0x9b
#define	ADDA_idx	0xab
#define	ADDA		0xbb
#define	ADDB_imm	0xcb
#define	ADDB_dir	0xdb
#define	ADDB_idx	0xeb
#define	ADDB		0xfb

#define	SBA		0x10

#define	SBCA_imm	0x82
#define	SBCA_dir	0x92
#define	SBCA_idx	0xa2
#define	SBCA		0xb2
#define	SBCB_imm	0xc2
#define	SBCB_dir	0xd2
#define	SBCB_idx	0xe2
#define	SBCB		0xf2

#define	SUBA_imm	0x80
#define	SUBA_dir	0x90
#define	SUBA_idx	0xa0
#define	SUBA		0xb0
#define	SUBB_imm	0xc0
#define	SUBB_dir	0xd0
#define	SUBB_idx	0xe0
#define	SUBB		0xf0

#define ANDA_imm	0x84
#define	ANDA_dir	0x94
#define	ANDA_idx	0xa4
#define	ANDA		0xb4
#define	ANDB_imm	0xc4
#define	ANDB_dir	0xd4
#define	ANDB_idx	0xe4
#define	ANDB		0xf4

#define	ORAA_imm	0x8a
#define	ORAA_dir	0x9a
#define	ORAA_idx	0xaa
#define	ORAA		0xba
#define	ORAB_imm	0xca
#define	ORAB_dir	0xda
#define	ORAB_idx	0xea
#define	ORAB		0xfa

#define	EORA_imm	0x88
#define	EORA_dir	0x98
#define	EORA_idx	0xa8
#define	EORA		0xb8
#define	EORB_imm	0xc8
#define	EORB_dir	0xd8
#define	EORB_idx	0xe8
#define	EORB		0xf8

#define	BITA_imm	0x85
#define	BITA_dir	0x95
#define	BITA_idx	0xa5
#define	BITA		0xb5
#define	BITB_imm	0xc5
#define	BITB_dir	0xd5
#define	BITB_idx	0xe5
#define	BITB		0xf5

#define	CBA		0x11

#define	CMPA_imm	0x81
#define	CMPA_dir	0x91
#define CMPA_idx	0xa1
#define CMPA		0xb1
#define	CMPB_imm	0xc1
#define	CMPB_dir	0xd1
#define	CMPB_idx	0xe1
#define	CMPB		0xf1

#define	CPX_imm		0x8c
#define	CPX_dir		0x9c
#define	CPX_idx		0xac
#define	CPX		0xbc

#define	TST_idx		0x6d
#define	TST		0x7d
#define	TSTA		0x4d
#define	TSTB		0x5d

#define	ASL_idx		0x68
#define	ASL		0x78
#define	ASLA		0x48
#define	ASLB		0x58

#define	ASR_idx		0x67
#define	ASR		0x77
#define	ASRA		0x47
#define	ASRB		0x57

#define	LSR_idx		0x64
#define	LSR		0x74
#define	LSRA		0x44
#define	LSRB		0x54

#define	ROL_idx		0x69
#define	ROL		0x79
#define	ROLA		0x49
#define	ROLB		0x59

#define	ROR_idx		0x66
#define	ROR		0x76
#define	RORA		0x46
#define	RORB		0x56

#define	PSHA		0x36
#define	PSHB		0x37
#define	PULA		0x32
#define	PULB		0x33

#define	JMP_idx		0x6e
#define	JMP		0x7e
#define	JSR_idx		0xad
#define	JSR		0xbd

#define	RTI		0x3b
#define	RTS		0x39

#define	BCC		0x24
#define	BCS		0x25
#define	BEQ		0x27
#define	BGE		0x2c
#define	BGT		0x2e
#define	BHI		0x22
#define	BLE		0x2f
#define	BLS		0x23
#define	BLT		0x2d
#define	BMI		0x2b
#define	BNE		0x26
#define	BPL		0x2a
#define	BRA		0x20
#define	BSR		0x8d
#define	BVC		0x28
#define	BVS		0x29

#define	DAA		0x19

#define	SWI		0x3f
#define	WAI		0x3e
