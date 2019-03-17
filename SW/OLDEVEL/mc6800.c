/*
 *
 * Pyldin-601 emulator version 3.1 for Linux,MSDOS,Win32
 * MC6800 core version 2
 * Copyright (c) Sasha Chukov & Yura Kuznetsov, 2000-2004
 *
 */

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>

#include "opcode.h"

#ifdef __GNUC__
#define INLINE inline
#endif

#define byte	unsigned char
#define word	unsigned short
#define dword	unsigned int

static byte app[] = {
#include APP
};

static	byte	MEM[0x10000];

static word LOMEM = 0x100 + sizeof(app);
static word HIMEM = 0xFF00;

static int ARGC;
static char **ARGV;

static FILE *fdtab[256];

static char *doserror[] = {
    "No error",
    "Invalid function number",
    "Invalid drive",
    "Disk write protected",
    "Address error",
    "Data error",		//5
    "General failure",
    "Invalid sector",
    "Reserved",
    "Invalid media type",
    "FAT error",		//10
    "Path not found",
    "Reserved",
    "Too many open files",
    "Access denied",
    "File already open",	//15
    "Invalid file handle",
    "Disk full",
    "File lost in directory",
    "Invalid name",
    "Root directory full",	//20
    "Directory exist",
    "Attempt to remove the current directory",
    "Directory not empty",
    "Bad LSEEK position",
    "Reserved",			//25
    "Not disk file",
    "Too many drivers installed",
    "Not same device",
    "File exist"
};

	//registers here
static	word	EAR;
static	word	PC;
static	word	SP;
static	word	X;
static	byte	A;
static	byte	B;
//static	byte	P;
	//flags register here
static	byte	c;
static	byte	v;
static	byte	z;
static	byte	n;
static	byte	i;
static	byte	h;

static	dword	mc6800_global_takts;

static unsigned char mpu_cycles[] = {
/*     00  01  02  03  04  05  06  07  08  09  0a  0b  0c  0d  0e  0f */
/*00*/ 02,  2, 02, 02, 02, 02,  2,  2,  4,  4,  2,  2,  2,  2,  2,  2,
/*01*/  2,  2, 02, 02, 02, 02,  2,  2, 02,  2, 02,  2, 02, 02, 02, 02,
/*02*/  4, 02,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,
/*03*/  4,  4,  4,  4,  4,  4,  4,  4, 02,  5, 02, 10, 02, 02,  9, 12,
/*04*/  2, 02, 02,  2,  2, 02,  2,  2,  2,  2,  2, 02,  2,  2, 02,  2,
/*05*/  2, 02, 02,  2,  2, 02,  2,  2,  2,  2,  2, 02,  2,  2, 02,  2,
/*06*/  7, 02, 02,  7,  7, 02,  7,  7,  7,  7,  7, 02,  7,  7,  4,  7,
/*07*/  6, 02, 02,  6,  6, 02,  6,  6,  6,  6,  6, 02,  6,  6,  3,  6,
/*08*/  2,  2,  2, 02,  2,  2,  2, 02,  2,  2,  2,  2,  3,  8,  3, 02,
/*09*/  3,  3,  3, 02,  3,  3,  3,  4,  3,  3,  3,  3,  4, 02,  4,  5,
/*0a*/  5,  5,  5, 02,  5,  5,  5,  6,  5,  5,  5,  5,  6,  8,  6,  7,
/*0b*/  4,  4,  4, 02,  4,  4,  4,  5,  4,  4,  4,  4,  5,  9,  5,  6,
/*0c*/  2,  2,  2, 02,  2,  2,  2, 02,  2,  2,  2,  2, 02, 02,  3, 02,
/*0d*/  3,  3,  3, 02,  3,  3,  3,  4,  3,  3,  3,  3, 02, 02,  4,  5,
/*0e*/  5,  5,  5, 02,  5,  5,  5,  6,  5,  5,  5,  5, 02, 02,  6,  7,
/*0f*/  4,  4,  4, 02,  4,  4,  4,  5,  4,  4,  4,  4, 02, 02,  5,  6
};

static void SWIemulator();

static int MC6800Init(byte *app, word size)
{
    mc6800_global_takts = 0;

    memset(MEM, 0, sizeof(MEM));
    memset(fdtab, 0, sizeof(fdtab));
    memcpy(&MEM[0x100], app, size);

    PC = 0x100;
    SP = HIMEM - 1;

    return 0;
}

static INLINE byte MC6800MemReadByte(word a)
{
    return MEM[a];
}

static INLINE void MC6800MemWriteByte(word a, byte d)
{
    MEM[a] = d;
}

static INLINE void TestByte(byte b)
{
    if (b == 0) 
	z = 1; 
    else 
	z = 0;
	
    if (b & 0x80) 
	n = 1; 
    else 
	n = 0;
}

static INLINE void TestWord(word w)
{
    if (w == 0) 
	z = 1; 
    else 
	z = 0;

    if (w & 0x8000) 
	n = 1; 
    else 
	n = 0;
}

static INLINE void Bcpx(word a, word b)
{
    int ans = (((a >> 8) - (b >> 8)) << 8) | ((a - b) & 255);
    //int wans = a - b;
    //int ans = wans & 0xffff;

    TestWord(ans);

    if (((a ^ b) & (a ^ ans) & 0x8000) != 0 )
	v = 1; 
    else 
	v = 0;
}

static INLINE byte Blsr(byte a)
{
    byte r = a>>1;

    v = c = a & 1;

    TestByte(r);

    return r;
}

static INLINE byte Basr(byte a)
{
    byte r = (a & 0x80) | (a>>1);

    c = a & 1;

    if (c == (r & 0x80)>>7) 
	v = 0; 
    else 
	v = 1;

    TestByte(r);

    return r;
}

static INLINE byte Basl(byte a)
{
    byte r = a<<1;

    c = (a & 0x80)>>7;

    if (c == (a & 0x40)>>6) 
	v = 0; 
    else 
	v = 1;

    TestByte(r);

    return r;
}

static INLINE byte Bror(byte a)
{
    byte r = (a>>1) | (c<<7);

    c = a & 1;

    if (c == (r & 0x80)>>7) 
	v = 0; 
    else 
	v = 1;

    TestByte(r);

    return r;
}

static INLINE byte Brol(byte a)
{
    byte r = (a<<1) | c;

    c = (a & 0x80)>>7;

    if (c == (a & 0x40)>>6) 
	v = 0; 
    else 
	v = 1;

    TestByte(r);

    return r;
}

static INLINE byte Bsub(byte o1, byte o2)
{
    int op1 = o1;
    int op2 = o2;

    int	wans = op1 - op2;
    int	ans = wans & 0xff;

    TestByte(ans);

    if ((wans & 0x100) != 0) 
	c = 1; 
    else 
	c = 0;

    if (((op1 ^ op2) & (op1 ^ ans) & 0x80) != 0 ) 
	v = 1; 
    else 
	v = 0;

    return (byte) ans;
}

static INLINE byte Bsubc(byte o1, byte o2)
{
    int op1 = o1;
    int op2 = o2;

    int	wans = op1 - op2 - (c ? 1 : 0);
    int	ans = wans & 0xff;

    TestByte(ans);

    if ((wans & 0x100) != 0) 
	c = 1; 
    else 
	c = 0;

    if (((op1 ^ op2) & (op1 ^ ans) & 0x80) != 0) 
	v = 1; 
    else 
	v = 0;

    return (byte) ans;
}

static INLINE byte Badd(byte o1, byte o2)
{
    int op1 = o1;
    int op2 = o2;

    int	wans = op1 + op2;
    int	ans = wans & 0xff;

    TestByte(ans);

    if ((wans & 0x100) != 0) 
	c = 1; 
    else 
	c = 0;
    
    if (((op1 ^ ~op2) & (op1 ^ ans) & 0x80) != 0) 
	v = 1; 
    else 
	v = 0;
    
    if ((((op1 & 0x0f) + (op2 & 0x0f)) & 0x10) != 0) 
	h = 1; 
    else 
	h = 0;
    
    return (byte) ans;
}

static INLINE byte Baddc(byte o1, byte o2)
{
    int op1 = o1;
    int op2 = o2;

    int	wans = op1 + op2 + (c ? 1 : 0);
    int	ans = wans & 0xff;

    TestByte(ans);

    if ((wans & 0x100) != 0) 
	c = 1; 
    else 
	c = 0;
    
    if (((op1 ^ ~op2) & (op1 ^ ans) & 0x80) != 0) 
	v = 1; 
    else 
	v = 0;
    
    if ((((op1 & 0x0f) + (op2 & 0x0f) + (c ? 1 : 0)) & 0x10) != 0) 
	h = 1; 
    else 
	h = 0;
    
    return (byte) ans;
}

static INLINE void Bdaa()
{
    byte	incr = 0;
    byte	carry = c;

    if (h || ((A & 0x0f) > 0x09)) 
	incr |= 0x06;
    
    if (carry || (A > 0x99)) 
	incr |= 0x60;
    
    if (A > 0x99) 
	carry = 1;
    
    A = Badd(A, incr);
    
    c = carry;
}

static INLINE byte NextByte()
{
    return MC6800MemReadByte(PC++);
}

static INLINE void FetchAddr()
{
    EAR = NextByte() << 8;
    EAR = EAR | NextByte();
}

static INLINE void Branch()
{
    if ((EAR & 0x80) == 0) 
	EAR &= 0xFF; 
    else 
	EAR |= 0xFF00;

    PC += EAR;
}

static int MC6800Step()
{
    byte oc, oh, t;
    word ofs, r16;

    int	takt = 0;

    byte opnum = MC6800MemReadByte(PC++);

    takt = mpu_cycles[opnum];

    switch (opnum) {
	case CLC:	c = 0; break;
	case CLI:	i = 0; break;
	case CLV:	v = 0; break;
	case SEC:	c = 1; break;
	case SEI:	i = 1; break;
	case SEV:	v = 1; break;
	case TPA:	A = (c?1:0)|(v?2:0)|(z?4:0)|(n?8:0)|(i?16:0)|(h?32:0)|0xc0; break;
	case TAP:	c=(A&1)!=0; v=(A&2)!=0; z=(A&4)!=0; n=(A&8)!=0; i=(A&16)!=0; h=(A&32)!=0; break;
	case TBA:	A = B; v = 0; TestByte(A); break;
	case TAB:	B = A; v = 0; TestByte(A); break;
	case TSX:	X = SP + 1; break;
	case TXS:	SP = X - 1; break;

	case DAA:	oh=h; Bdaa(); h=oh; break;

	case PSHA:	MC6800MemWriteByte(SP--, A); break;
	case PSHB:	MC6800MemWriteByte(SP--, B); break;
	case PULA:	A = MC6800MemReadByte(++SP); break;
	case PULB:	B = MC6800MemReadByte(++SP); break;

	case DEC_idx:	ofs=NextByte()+X; oc=c; MC6800MemWriteByte(ofs,Bsub(MC6800MemReadByte(ofs),1)); c=oc; break;
	case DEC:	FetchAddr(); oc=c; MC6800MemWriteByte(EAR, Bsub(MC6800MemReadByte(EAR),1)); c=oc; break;
	case DECA:	oc=c; A=Bsub(A,1); c=oc; break;
	case DECB:	oc=c; B=Bsub(B,1); c=oc; break;
	case DES:	SP--; break;
	case DEX:	X--; z = X?0:1; break;

	case INC_idx:	ofs=NextByte()+X; oh=h; oc=c; MC6800MemWriteByte(ofs,Badd(MC6800MemReadByte(ofs),1)); c=oc; h=oh; break;
	case INC:	FetchAddr(); oh=h; oc=c; MC6800MemWriteByte(EAR, Badd(MC6800MemReadByte(EAR),1)); c=oc; h=oh; break;
	case INCA:	oh=h; oc=c; A=Badd(A,1); c=oc; h=oh; break;
	case INCB:	oh=h; oc=c; B=Badd(B,1); c=oc; h=oh; break;
	case INS:	SP++; break;
	case INX:	X++; z = X?0:1; break;

	case CLR_idx:	MC6800MemWriteByte(NextByte()+X, 0); n = v = c = 0; z = 1; break;
	case CLR:	FetchAddr(); MC6800MemWriteByte(EAR, 0); n = v = c = 0; z = 1; break;
	case CLRA:	A = n = v = c = 0; z = 1; break;
	case CLRB:	B = n = v = c = 0; z = 1; break;

	case COM_idx: ofs = NextByte()+X; MC6800MemWriteByte(ofs, ~MC6800MemReadByte(ofs)); c = 1; v = 0; TestByte(MC6800MemReadByte(ofs)); break;
	case COM:	FetchAddr(); MC6800MemWriteByte(EAR, ~MC6800MemReadByte(EAR)); c = 1; v = 0; TestByte(MC6800MemReadByte(EAR)); break;
	case COMA:	A = ~A; c = 1; v = 0; TestByte(A); break;
	case COMB:	B = ~B; c = 1; v = 0; TestByte(B); break;

	case NEG_idx: ofs = NextByte()+X; MC6800MemWriteByte(ofs, Bsub(0, MC6800MemReadByte(ofs))); break;
	case NEG:	FetchAddr(); MC6800MemWriteByte(EAR, Bsub(0, MC6800MemReadByte(EAR))); break;
	case NEGA:	A = Bsub(0, A); break;
	case NEGB:	B = Bsub(0, B); break;

	case LDAA_imm: A = NextByte(); v = 0; TestByte(A); break;
	case LDAA_dir: A = MC6800MemReadByte(NextByte()); v = 0; TestByte(A); break;
	case LDAA_idx: A = MC6800MemReadByte(X + NextByte()); v = 0; TestByte(A); break;
	case LDAA:	FetchAddr(); A = MC6800MemReadByte(EAR); v = 0; TestByte(A); break;
	case LDAB_imm: B = NextByte(); v = 0; TestByte(B); break;
	case LDAB_dir: B = MC6800MemReadByte(NextByte()); v = 0; TestByte(B); break;
	case LDAB_idx: B = MC6800MemReadByte(X + NextByte()); v = 0; TestByte(B); break;
	case LDAB:	FetchAddr(); B = MC6800MemReadByte(EAR); v = 0; TestByte(B); break;

	case LDS_imm: FetchAddr(); SP = EAR; v = 0; TestWord(SP); break;
	case LDS_dir: ofs=NextByte(); SP = MC6800MemReadByte(ofs) << 8; SP |= MC6800MemReadByte(ofs + 1); v = 0; TestWord(SP); break;
	case LDS_idx: ofs=X+NextByte(); SP = MC6800MemReadByte(ofs) << 8; SP |= MC6800MemReadByte(ofs + 1); v = 0; TestWord(SP); break;
	case LDS:	FetchAddr(); SP = MC6800MemReadByte(EAR) << 8; SP |= MC6800MemReadByte(EAR + 1); v = 0; TestWord(SP); break;
	case LDX_imm: FetchAddr(); X = EAR; v = 0; TestWord(X); break;
	case LDX_dir: ofs=NextByte(); X = MC6800MemReadByte(ofs) << 8; X |= MC6800MemReadByte(ofs + 1); v = 0; TestWord(X); break;
	case LDX_idx: ofs=X+NextByte(); X=MC6800MemReadByte(ofs)<<8; X|=MC6800MemReadByte(ofs+1); v = 0; TestWord(X); break;
	case LDX:	FetchAddr(); X = MC6800MemReadByte(EAR) << 8; X |= MC6800MemReadByte(EAR + 1); v = 0; TestWord(X); break;

	case STAA_dir: MC6800MemWriteByte(NextByte(), A); v = 0; TestByte(A); break;
	case STAA_idx: MC6800MemWriteByte(X + NextByte(), A); v = 0; TestByte(A); break;
	case STAA:	FetchAddr(); MC6800MemWriteByte(EAR, A); v = 0; TestByte(A); break;
	case STAB_dir: MC6800MemWriteByte(NextByte(), B); v = 0; TestByte(B); break;
	case STAB_idx: MC6800MemWriteByte(X + NextByte(), B); v = 0; TestByte(B); break;
	case STAB:	FetchAddr(); MC6800MemWriteByte(EAR, B); v = 0; TestByte(B); break;

	case STS_dir: ofs=NextByte(); MC6800MemWriteByte(ofs,SP>>8); MC6800MemWriteByte(ofs+1, SP&0xff); v=0; TestWord(SP); break;
	case STS_idx: ofs=X+NextByte(); MC6800MemWriteByte(ofs,SP>>8); MC6800MemWriteByte(ofs+1,SP&0xff); v=0; TestWord(SP); break;
	case STS:	FetchAddr(); MC6800MemWriteByte(EAR,SP>>8); MC6800MemWriteByte(EAR+1,SP&0xff); v=0; TestWord(SP); break;
	case STX_dir: ofs=NextByte(); MC6800MemWriteByte(ofs,X>>8); MC6800MemWriteByte(ofs+1, X&0xff); v=0; TestWord(X); break;
	case STX_idx: ofs=X+NextByte(); MC6800MemWriteByte(ofs,X>>8); MC6800MemWriteByte(ofs+1,X&0xff); v=0; TestWord(X); break;
	case STX:	FetchAddr(); MC6800MemWriteByte(EAR,X>>8); MC6800MemWriteByte(EAR+1,X&0xff); v=0; TestWord(X); break;

	case ABA:	A = Badd(A, B); break;

	case ADCA_imm: A = Baddc(A, NextByte()); break;
	case ADCA_dir: A = Baddc(A, MC6800MemReadByte(NextByte())); break;
	case ADCA_idx: A = Baddc(A, MC6800MemReadByte(X + NextByte())); break;
	case ADCA:	FetchAddr(); A = Baddc(A, MC6800MemReadByte(EAR)); break;
	case ADCB_imm: B = Baddc(B, NextByte()); break;
	case ADCB_dir: B = Baddc(B, MC6800MemReadByte(NextByte())); break;
	case ADCB_idx: B = Baddc(B, MC6800MemReadByte(X + NextByte())); break;
	case ADCB:	FetchAddr(); B = Baddc(B, MC6800MemReadByte(EAR)); break;

	case ADDA_imm: A = Badd(A, NextByte()); break;
	case ADDA_dir: A = Badd(A, MC6800MemReadByte(NextByte())); break;
	case ADDA_idx: A = Badd(A, MC6800MemReadByte(X + NextByte())); break;
	case ADDA:	FetchAddr(); A = Badd(A, MC6800MemReadByte(EAR)); break;
	case ADDB_imm: B = Badd(B, NextByte()); break;
	case ADDB_dir: B = Badd(B, MC6800MemReadByte(NextByte())); break;
	case ADDB_idx: B = Badd(B, MC6800MemReadByte(X + NextByte())); break;
	case ADDB:	FetchAddr(); B = Badd(B, MC6800MemReadByte(EAR)); break;

	case SBA:	A = Bsub(A, B); break;

	case SBCA_imm: A = Bsubc(A, NextByte()); break;
	case SBCA_dir: A = Bsubc(A, MC6800MemReadByte(NextByte())); break;
	case SBCA_idx: A = Bsubc(A, MC6800MemReadByte(X + NextByte())); break;
	case SBCA:	FetchAddr(); A = Bsubc(A, MC6800MemReadByte(EAR)); break;
	case SBCB_imm: B = Bsubc(B, NextByte()); break;
	case SBCB_dir: B = Bsubc(B, MC6800MemReadByte(NextByte())); break;
	case SBCB_idx: B = Bsubc(B, MC6800MemReadByte(X + NextByte())); break;
	case SBCB:	FetchAddr(); B = Bsubc(B, MC6800MemReadByte(EAR)); break;

	case SUBA_imm: A = Bsub(A, NextByte()); break;
	case SUBA_dir: A = Bsub(A, MC6800MemReadByte(NextByte())); break;
	case SUBA_idx: A = Bsub(A, MC6800MemReadByte(X + NextByte())); break;
	case SUBA:	FetchAddr(); A = Bsub(A, MC6800MemReadByte(EAR)); break;
	case SUBB_imm: B = Bsub(B, NextByte()); break;
	case SUBB_dir: B = Bsub(B, MC6800MemReadByte(NextByte())); break;
	case SUBB_idx: B = Bsub(B, MC6800MemReadByte(X + NextByte())); break;
	case SUBB:	FetchAddr(); B = Bsub(B, MC6800MemReadByte(EAR)); break;

	case ANDA_imm: A &= NextByte(); v = 0; TestByte(A); break;
	case ANDA_dir: A &= MC6800MemReadByte(NextByte()); v = 0; TestByte(A); break;
	case ANDA_idx: A &= MC6800MemReadByte(X + NextByte()); v = 0; TestByte(A); break;
	case ANDA:	FetchAddr(); A &= MC6800MemReadByte(EAR); v = 0; TestByte(A); break;
	case ANDB_imm: B &= NextByte(); v = 0; TestByte(B); break;
	case ANDB_dir: B &= MC6800MemReadByte(NextByte()); v = 0; TestByte(B); break;
	case ANDB_idx: B &= MC6800MemReadByte(X + NextByte()); v = 0; TestByte(B); break;
	case ANDB:	FetchAddr(); B &= MC6800MemReadByte(EAR); v = 0; TestByte(B); break;

	case ORAA_imm: A |= NextByte(); v = 0; TestByte(A); break;
	case ORAA_dir: A |= MC6800MemReadByte(NextByte()); v = 0; TestByte(A); break;
	case ORAA_idx: A |= MC6800MemReadByte(X + NextByte()); v = 0; TestByte(A); break;
	case ORAA:	FetchAddr(); A |= MC6800MemReadByte(EAR); v = 0; TestByte(A); break;
	case ORAB_imm: B |= NextByte(); v = 0; TestByte(B); break;
	case ORAB_dir: B |= MC6800MemReadByte(NextByte()); v = 0; TestByte(B); break;
	case ORAB_idx: B |= MC6800MemReadByte(X + NextByte()); v = 0; TestByte(B); break;
	case ORAB:	FetchAddr(); B |= MC6800MemReadByte(EAR); v = 0; TestByte(B); break;

	case EORA_imm: A ^= NextByte(); v = 0; TestByte(A); break;
	case EORA_dir: A ^= MC6800MemReadByte(NextByte()); v = 0; TestByte(A); break;
	case EORA_idx: A ^= MC6800MemReadByte(X + NextByte()); v = 0; TestByte(A); break;
	case EORA:	FetchAddr(); A ^= MC6800MemReadByte(EAR); v = 0; TestByte(A); break;
	case EORB_imm: B ^= NextByte(); v = 0; TestByte(B); break;
	case EORB_dir: B ^= MC6800MemReadByte(NextByte()); v = 0; TestByte(B); break;
	case EORB_idx: B ^= MC6800MemReadByte(X + NextByte()); v = 0; TestByte(B); break;
	case EORB:	FetchAddr(); B ^= MC6800MemReadByte(EAR); v = 0; TestByte(B); break;

	case LSR_idx: ofs=X+NextByte(); MC6800MemWriteByte(ofs, Blsr(MC6800MemReadByte(ofs))); break;
	case LSR: FetchAddr(); MC6800MemWriteByte(EAR, Blsr(MC6800MemReadByte(EAR))); break;
	case LSRA: A = Blsr(A); break;
	case LSRB: B = Blsr(B); break;

	case ASR_idx: ofs=X+NextByte(); MC6800MemWriteByte(ofs, Basr(MC6800MemReadByte(ofs))); break;
	case ASR: FetchAddr(); MC6800MemWriteByte(EAR, Basr(MC6800MemReadByte(EAR))); break;
	case ASRA: A = Basr(A); break;
	case ASRB: B = Basr(B); break;

	case ASL_idx: ofs=X+NextByte(); MC6800MemWriteByte(ofs, Basl(MC6800MemReadByte(ofs))); break;
	case ASL: FetchAddr(); MC6800MemWriteByte(EAR, Basl(MC6800MemReadByte(EAR))); break;
	case ASLA: A = Basl(A); break;
	case ASLB: B = Basl(B); break;

	case ROR_idx: ofs=X+NextByte(); MC6800MemWriteByte(ofs, Bror(MC6800MemReadByte(ofs))); break;
	case ROR: FetchAddr(); MC6800MemWriteByte(EAR, Bror(MC6800MemReadByte(EAR))); break;
	case RORA: A = Bror(A); break;
	case RORB: B = Bror(B); break;

	case ROL_idx: ofs=X+NextByte(); MC6800MemWriteByte(ofs, Brol(MC6800MemReadByte(ofs))); break;
	case ROL: FetchAddr(); MC6800MemWriteByte(EAR, Brol(MC6800MemReadByte(EAR))); break;
	case ROLA: A = Brol(A); break;
	case ROLB: B = Brol(B); break;

	case BITA_imm: v = 0; TestByte(A & NextByte()); break;
	case BITA_dir: v = 0; TestByte(A & MC6800MemReadByte(NextByte())); break;
	case BITA_idx: v = 0; TestByte(A & MC6800MemReadByte(X + NextByte())); break;
	case BITA: FetchAddr(); v = 0; TestByte(A & MC6800MemReadByte(EAR)); break;
	case BITB_imm: v = 0; TestByte(B & NextByte()); break;
	case BITB_dir: v = 0; TestByte(B & MC6800MemReadByte(NextByte())); break;
	case BITB_idx: v = 0; TestByte(B & MC6800MemReadByte(X + NextByte())); break;
	case BITB: FetchAddr(); v = 0; TestByte(B & MC6800MemReadByte(EAR)); break;

	case CBA:	Bsub(A, B); break;

	case CMPA_imm: Bsub(A, NextByte()); break;
	case CMPA_dir: Bsub(A, MC6800MemReadByte(NextByte())); break;
	case CMPA_idx: Bsub(A, MC6800MemReadByte(X + NextByte())); break;
	case CMPA:	FetchAddr(); Bsub(A, MC6800MemReadByte(EAR)); break;
	case CMPB_imm: Bsub(B, NextByte()); break;
	case CMPB_dir: Bsub(B, MC6800MemReadByte(NextByte())); break;
	case CMPB_idx: Bsub(B, MC6800MemReadByte(X + NextByte())); break;
	case CMPB:	FetchAddr(); Bsub(B, MC6800MemReadByte(EAR)); break;

	case CPX_imm: FetchAddr(); Bcpx(X, EAR); break;
	case CPX_dir: ofs=NextByte(); r16=MC6800MemReadByte(ofs)<<8; r16|=MC6800MemReadByte(ofs+1); Bcpx(X, r16); break;
	case CPX_idx: ofs=NextByte()+X; r16=MC6800MemReadByte(ofs)<<8; r16|=MC6800MemReadByte(ofs+1); Bcpx(X, r16); break;
	case CPX: FetchAddr(); r16=MC6800MemReadByte(EAR)<<8; r16|=MC6800MemReadByte(EAR+1); Bcpx(X, r16); break;

	case TST_idx: c = v = 0; TestByte(MC6800MemReadByte(X + NextByte())); break;
	case TST:	FetchAddr(); c = v = 0; TestByte(MC6800MemReadByte(EAR)); break;
	case TSTA: c = v = 0; TestByte(A); break;
	case TSTB: c = v = 0; TestByte(B); break;

	case BCC: EAR=NextByte(); if (c==0) Branch(); break;
	case BCS: EAR=NextByte(); if (c==1) Branch(); break;
	case BEQ: EAR=NextByte(); if (z==1) Branch(); break;
	case BGE: EAR=NextByte(); if ((n^v)==0) Branch(); break;
	case BGT: EAR=NextByte(); if ((z|(n^v))==0) Branch(); break;
	case BHI: EAR=NextByte(); if ((c|z)==0) Branch(); break;
	case BLE: EAR=NextByte(); if ((z|(n^v))==1) Branch(); break;
	case BLS: EAR=NextByte(); if ((c|z)==1) Branch(); break;
	case BLT: EAR=NextByte(); if ((n^v)==1) Branch(); break;
	case BMI: EAR=NextByte(); if (n==1) Branch(); break;
	case BNE: EAR=NextByte(); if (z==0) Branch(); break;
	case BPL: EAR=NextByte(); if (n==0) Branch(); break;
	case BVC: EAR=NextByte(); if (v==0) Branch(); break;
	case BVS: EAR=NextByte(); if (v==1) Branch(); break;

	case BRA: EAR=NextByte(); Branch(); break;
	case BSR: EAR=NextByte(); MC6800MemWriteByte(SP--, PC&0xff); MC6800MemWriteByte(SP--, PC>>8); Branch(); break;

	case JMP_idx: PC = X + NextByte(); break;
	case JMP: FetchAddr(); PC = EAR; break;
	case JSR_idx: EAR = PC + 1; MC6800MemWriteByte(SP--, EAR&0xff); MC6800MemWriteByte(SP--, EAR>>8); PC=X+NextByte(); break;
	case JSR: FetchAddr(); MC6800MemWriteByte(SP--, PC&0xff); MC6800MemWriteByte(SP--, PC>>8); PC=EAR; break;

	case RTS: PC = MC6800MemReadByte(++SP)<<8; PC |= MC6800MemReadByte(++SP); break;

	case RTI:	t = MC6800MemReadByte(++SP);
	    c=(t&1)!=0; v=(t&2)!=0; z=(t&4)!=0; n=(t&8)!=0; i=(t&16)!=0; h=(t&32)!=0;
	    B = MC6800MemReadByte(++SP);
	    A = MC6800MemReadByte(++SP);
	    X = MC6800MemReadByte(++SP)<<8; X |= MC6800MemReadByte(++SP);
	    PC = MC6800MemReadByte(++SP)<<8; PC |= MC6800MemReadByte(++SP);
	    break;

	case SWI:
	    SWIemulator();
	    i = 1;
	    break;

	case WAI:
	    i = 1;
	    break;
    }

    mc6800_global_takts += takt;

    return takt;
}

static void SWIemulator()
{
    FILE *f = NULL;
    long pos, pos1;
    char *str;
    word tmp, tmp1;
    byte swin = MEM[PC++];

//    fprintf(stderr, "INT $%02X: ", swin);
//    fprintf(stderr, "A=%02X B=%02X X=%04X SP=%04X PC=%04X H=%d I=%d N=%d Z=%d V=%d C=%d\n", A, B, X, SP, PC, h, i, n, z, v, c);

    switch (swin) {
    case 0x21:
		str = fgets((char *)&MEM[X], B, stdin);
		if (str) {
		    A = strlen(str);
		} else {
		    A = 0;
		}
		return;
    case 0x22:	printf("%c", A); return;
    case 0x23:	printf("%s", &MEM[X]); return;
    case 0x24:	printf("%d", X); return;
    case 0x25:	printf("%02X", A); return;
    case 0x2A:
		tmp = SP - 0x200 - LOMEM;
		if (tmp < X + 2) {
		    X = 0;
		} else {
		    tmp1 = (((HIMEM - X) >> B) << B) - 2;
    fprintf(stderr, "Alloc ptr %04X align %d with %d bytes\n", tmp1, B, X);
		    memmove(&MEM[tmp1 - (HIMEM - SP)], &MEM[SP], HIMEM - SP);
		    SP = tmp1 - (HIMEM - SP);
		    MEM[tmp1    ] = HIMEM >> 8;
		    MEM[tmp1 + 1] = HIMEM & 0xFF;
		    HIMEM = tmp1 - 1;
		    X = tmp1 + 2;
		}
		return;
    case 0x2B:
		if (X == 0) return;
		tmp = X - 2;
		tmp1 = (MEM[tmp] << 8) | MEM[tmp + 1];
    fprintf(stderr, "Dealloc ptr %04X, new HiMem %04X\n", tmp, tmp1);
		memmove(&MEM[tmp1 - (HIMEM - SP)], &MEM[SP], HIMEM - SP);
		SP = tmp1 - (HIMEM - SP);
		X = tmp1 - X;
		HIMEM = tmp1 - 1;
		return;
    case 0x2D:
		tmp = (B << 8) | A;
		memmove((char *)&MEM[(MEM[X + 2] << 8) | MEM[X + 3]], (char *)&MEM[(MEM[X] << 8) | MEM[X + 1]], tmp);
		X = tmp;
		return;
    case 0x2F:	if (A == 0x04) return; // User interrupt (Ctrl+C), ignore
		if (A == 0x07) return; // Critical error, ignore
		break;
    case 0x35:
		tmp = SP - 0x200 - LOMEM;
		tmp1 = (B << 8) | A;
		if (tmp < tmp1) {
		    B = 0;
		    A = 0;
		    X = LOMEM;
		    return;
		}
		X = LOMEM;
		LOMEM = LOMEM + tmp1;
		return;
    case 0x36:	X = LOMEM; tmp = SP - 0x200 - LOMEM; B = tmp >> 8; A = tmp & 0xFF; return;
    case 0x38:	exit(0);
    case 0x3B:	A = ARGC; return;
    case 0x3C:	strncpy((char *)&MEM[X], ARGV[A], 80); return;
    case 0x3D:
		if (A >= sizeof(doserror) / sizeof(char *)) {
		    A = 1;
		}
		strncpy((char *)&MEM[X], doserror[A], 65);
		MEM[X + 64] = 0;
		return;
    case 0x4A:
		if ((A < 1) || (A > 3)) {
		    A = 1;
		    return;
		}
//    fprintf(stderr, "FILE %s\n", (char *)&MEM[(MEM[X] << 8) | MEM[X + 1]]);
		f = fopen((char *)&MEM[(MEM[X] << 8) | MEM[X + 1]], (A == 1) ? "r" : (A == 2) ? "w" : "r+");
		if (f) {
		    B = fileno(f);
		    if (B > sizeof(fdtab) / sizeof(FILE *)) {
			fclose(f);
			B = 0;
			A = 13;
//			fprintf(stderr, "fd > fdtab, error!\n");
//			exit(-1);
			return;
		    }
		    fdtab[B] = f;
		    A = 0;
		} else {
		    B = 0;
		    A = 19;
		}
		return;
    case 0x4B:
//    fprintf(stderr, "FILE %s\n", (char *)&MEM[(MEM[X] << 8) | MEM[X + 1]]);
		f = fopen((char *)&MEM[(MEM[X] << 8) | MEM[X + 1]], "w");
		if (f) {
		    B = fileno(f);
		    if (B > sizeof(fdtab) / sizeof(FILE *)) {
			fclose(f);
			B = 0;
			A = 13;
//			fprintf(stderr, "fd > fdtab, error!\n");
//			exit(-1);
			return;
		    }
		    fdtab[B] = f;
		    A = 0;
		} else {
		    B = 0;
		    A = 19;
		}
		return;
    case 0x4C:
//	fprintf(stderr, "read %d bytes\n", (MEM[X + 2] << 8) | MEM[X + 3]);
		if (!fdtab[A]) {
		    A = 16;
		    return;
		}
		pos = fread((char *)&MEM[(MEM[X] << 8) | MEM[X + 1]], 1, (MEM[X + 2] << 8) | MEM[X + 3], fdtab[A]);
		if (pos < 0) {
		    A = 1;
		} else {
		    X = pos;
		    A = 0;
		}
		return;
    case 0x4D:
//	fprintf(stderr, "write %d bytes\n", (MEM[X + 2] << 8) | MEM[X + 3]);
		if (!fdtab[A]) {
		    A = 16;
		    return;
		}
		pos = fwrite((char *)&MEM[(MEM[X] << 8) | MEM[X + 1]], 1, (MEM[X + 2] << 8) | MEM[X + 3], fdtab[A]);
		if (pos < 0) {
		    A = 1;
		} else {
		    X = pos;
		    A = 0;
		}
		return;
    case 0x4E:
		if (fdtab[A]) {
		    fclose(fdtab[A]);
		    fdtab[A] = NULL;
		    A = 0;
		} else {
		    A = 16;
		}
		return;
    case 0x50:
		if (!fdtab[A]) {
		    A = 16;
		    return;
		}
		pos = fseek(fdtab[A], (MEM[X] << 24) | (MEM[X + 1] << 16) | (MEM[X + 2] << 8) | MEM[X + 3], B);
		if (pos < 0) {
		    A = 24;
		} else {
		    MEM[X    ] = (pos >> 24)       ;
		    MEM[X + 1] = (pos >> 16) & 0xFF;
		    MEM[X + 2] = (pos >>  8) & 0xFF;
		    MEM[X + 3] = (pos      ) & 0xFF;
		    A = 0;
		}
		return;
    case 0x51:
		if (!fdtab[A]) {
		    A = 16;
		    return;
		}
		pos1 = ftell(fdtab[A]);
		if (pos1 >= 0) {
		    fseek(fdtab[A], 0, SEEK_END);
		    pos = ftell(fdtab[A]);
		    fseek(fdtab[A], pos1, SEEK_SET);
		    if (pos >= 0) {
			MEM[X    ] = (pos >> 24)       ;
			MEM[X + 1] = (pos >> 16) & 0xFF;
			MEM[X + 2] = (pos >>  8) & 0xFF;
			MEM[X + 3] = (pos      ) & 0xFF;
			A = 0;
			return;
		    }
		}
		A = 24;
		return;
    case 0x53:
		if (!fdtab[A]) {
		    A = 16;
		    return;
		}
		pos = ftell(fdtab[A]);
		if (pos < 0) {
		    A = 24;
		} else {
		    MEM[X    ] = (pos >> 24)       ;
		    MEM[X + 1] = (pos >> 16) & 0xFF;
		    MEM[X + 2] = (pos >>  8) & 0xFF;
		    MEM[X + 3] = (pos      ) & 0xFF;
		    A = 0;
		}
		return;
    }

    fprintf(stderr, "%04X: INT $%02X - Unimplemented!\n", PC, swin);
    fprintf(stderr, "A=%02X B=%02X X=%04X SP=%04X PC=%04X H=%d I=%d N=%d Z=%d V=%d C=%d\n", A, B, X, SP, PC, h, i, n, z, v, c);

    exit(1);
}

int main(int argc, char *argv[])
{
    ARGC = argc;
    ARGV = argv;

    MC6800Init(app, sizeof(app));

    while (1) {
//	fprintf(stderr, "%04X: %02X\n", PC, MEM[PC]);
	MC6800Step();
    }

    return 0;
}
