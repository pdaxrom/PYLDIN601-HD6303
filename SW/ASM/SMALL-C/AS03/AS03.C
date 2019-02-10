/* as03.c  - MC6801/HD6303 assembler */
/* 10-Feb-2019  v0.1  - A.Chukov     */

/* as65.c  -  MOS Technology 6502 assembler */
/* 11-Apr-1989  v0.70 - A.J.Travis */
/* 22-Jun-1991  v0.71 - J.G.Harston
 *   system-specifics removed to local.h
 *   uses '/' instead of '_' in filenames
 *   main() ends with exit(0);
 */

/*
 * implementation dependant pathnames, and i/o modes
 */

#define MNEMTAB "mnemtab"		/* opcode mnemonics */
#define OPTAB   "optab"			/* opcode table */
#define IO_W    "w"			/* binary write mode */
#define ILLEGAL    0			/* 0 - no opcode */

#define NULL 0

#define FILE int

/*
 * boolean constants
 */
#define TRUE        1
#define FALSE       0
#define ERROR      -1
#define SAME        0

/*
 * symbol table parameters
 */
#define LINESIZE   80
#define HASHSIZE  257
#define SYMSIZE 10000

#define NEXTPTR     0
#define VALUE       2
#define NAME        4
#define BYTE      256

/*
 * 6800 addressing modes
 */
#define OPFLAG	0
#define INHERIT	1
#define IMMED	2
#define DIRECT	3
#define EXTEND	4
#define IND_X	5
#define REL	6
#define NMODES	7

/*
 * 6502 addressing modes
 */
#define IMPLIED     0
#define ACCUM       1
/*#define IMMED       2 */
/*#define DIRECT      3 */
#define DIRECT_X    4
#define DIRECT_Y    5
#define ABS         6
#define ABS_X       7
#define ABS_Y       8
/*#define IND_X       9 */
#define IND_Y      10
/*#define REL        11 */
#define INDIRECT   12
/*#define NMODES     13 */
/*#define NCODES     56 */

/*
 * global variables
 */
char obj[LINESIZE];			/* object code output buffer */
char ibuf[LINESIZE];			/* input buffer */
char sbuf[LINESIZE];			/* symbol buffer */
char symtab[SYMSIZE];			/* symbol table */
char *ofile;				/* output file */
char *endsym;				/* end of symbol table */
char *start;				/* start of symbol table */
char *freeptr;				/* next free location in hash chain */
char *ip;				/* input buffer pointer */
char * loc;				/* location counter */
char * origin;			/* assembly origin */
char * _text;			/* start of text segment */
char * _data;			/* start of data segment */
char * _end;				/* end of program */
char * textsz;			/* size of text segment */
char * datasz;			/* size of data segment */
int hashtab[HASHSIZE];			/* hash table */
FILE *in;				/* input stream */
FILE *in2;				/* second input stream */
FILE *out;				/* output stream */
int endflag;				/* .end pseudo-op flag */
int list;				/* produce assembler listing */
int pass;				/* pass 1/2 */
int nbytes;				/* number of bytes in obj[] */
int errcnt;				/* error count */
int nset;				/* number of setloc pseudo-ops */

main(argc, argv)
int argc;
int *argv[];
{
	int file;			/* source file no. */
	char *ifile;

	in = NULL;
	in2 = NULL;
	out = NULL;
	ifile = NULL;
	ofile = "a.out";		/* default output file name */
	list = FALSE;			/* default no listing */

	if (argc < 2)
	    usage();

	--argc;
	argv++;
	while (argc > 0) {
	    if (strcmp(argv[0], "-l") == SAME)
		list++;
	    else if (strcmp(argv[0], "-o") == SAME) {
		if (argc < 2)
		    usage();
		else {
		    ofile = argv[1];
		    --argc;
		    argv++;
		}
	    } else break;
	    --argc;
	    argv++;
	}

	if (argc == 0)
	    usage();

	ifile = argv[0];

	if ((out = fopen(ofile, IO_W)) == NULL) {
		printf("as03: Cannot open %s\n", ofile);
		fatal(-1);
	}

	endsym = symtab + SYMSIZE;
	inithash();
	prehash();

	pass = 1;
	while(pass < 3) {
	    errcnt = 0;
	    nset = 0;
	    loc = 0;
	    origin = 0;
	    endflag = FALSE;

	    if ((in = fopen(ifile, "r")) == NULL) {
		printf("as03: Cannot open %s\n", ifile);
		exit();
	    }
	    doasm();
	    fclose(in);

	    pass++;
	}

	fclose(out);
	dumpsym();

	/* print size of text and data areas if C 'segment' symbols present */
	if ((hashfind("~eot") != NULL) & (hashfind("~eod") != NULL)) {
		_text = origin;
		_data = lookup("~eot");
		_end = lookup("~eod");
		textsz = _data - _text;
		datasz = _end - _data;
		printf("%u = %u+%u ", textsz + datasz, textsz, datasz);
		printf("(0x%04x, 0x%04x, 0x%04x)\n", _text, _data, _end);
	}
	if (errcnt)
		printf("as03: %d errors\n", errcnt);
	exit(0);
}

/*
 * report correct usage and exit
 */
usage()
{
	printf("usage: as03 [-l] [-o outfile] file\n");
	fatal(-1);
}

/*
 * assemble one pass
 */
doasm()
{
	int mem;

	*ibuf = 0;
	while (1) {
		if (inline_() == NULL) {
		    if (in2) {
			fclose(in);
			in = in2;
			in2 = NULL;
			continue;
		    } else
			break;
		}
		mem = loc;
		nbytes = 0;
		assem();
		if (pass == 2)
			output(mem);
		loc = loc + nbytes;
		if (endflag)
			break;
	}
}

/*
 * input line
 * ----------
 * ignore full line comments and empty lines
 */
inline_()
{
	int c;
	char *p;

	while ((p = fgets(ibuf, LINESIZE, in)) != NULL) {
		if (*p == ';') {
			if (pass == 1 | list == FALSE)
				continue;
			else
				printf("                %s", p);
		}
		else if (*p == 10) /* '\n' */
			continue;
		else
			break;
	}
	ip = p;

	/* force upper case */

	while (c = toupper(*p)) {
		if (c == ';')
			break;
		else if (c == '"' | c == 0x27) {
			while (*++p)
				if (*p == c)
					break;
		}
		else
			*p++ = c;	
	}

	return(ip);
}

/*
 * assemble one line
 */
assem()
{
	if (sym(sbuf)) {
		if (qlabel())
			return;
		else if (qmnem())
			return;
	}

	if (*ip == 10)
		return;
	else if (match(';'))
		return;
	else
		error("symbol/pseudo-op required");
}

/*
 * prehash mnemonics into symbol table
 * -----------------------------------
 * check current directory first for data files
 */
prehash()
{
	char *p, *ps;
	int n;

	ps = memtabl;
	n = 0;
	while (*ps) {
		p = ps;
		while (*p++ != 10) /* '\n' */
			;
		*--p = 0; /* '\0' */
		install(ps, opcodes + n++ * NMODES);
		ps = p + 1;
	}

	install("ORG",	org   | 0x8000);
	install("DS",	fillb | 0x8000);
	install("DB",	byte  | 0x8000);
	install("DW",	dbyte | 0x8000);
	install("END",	psend | 0x8000);
	install("TEXT",	text  | 0x8000);
	install("INCLUDE",file| 0x8000);

	start = freeptr;
}

/*
 * check for labelled statement
 * ----------------------------
 * Exit status indicates whether
 * processing of line is complete
 */
qlabel()
{
	if (pass == 1)
		return(putlab());
	else
		return(getlab());
}

/*
 * put new label in symbol table
 * -----------------------------
 * 6502 Mnemonics are reserved symbols.
 * Exit status indicates whether
 * processing of line is complete
 */
putlab()
{
	char *tag;

	if ((tag = hashfind(sbuf)) == NULL) {
		if (match('=')) {
			install(sbuf, exp_());
			return(TRUE);
		}
		if (ip[0] == 'E' & ip[1] == 'Q' & ip[2] == 'U' &
		    (ip[3] == ' ' | ip[3] == 9)) {
			ip = ip + 3;
			install(sbuf, exp_());
			return(TRUE);
		} else {
			install(sbuf, loc);
			return(FALSE);
		}
	}
	else if (tag < start) {
		mnem(tag);
		return(TRUE);
	}
	else {
		error("label redefined");
		return(FALSE);
	}
}

/*
 * update labels on second pass
 * ----------------------------
 * Exit status indicates that
 * processing of line is complete
 */
getlab()
{
	char *tag;

	if ((tag = hashfind(sbuf)) >= start) {
		if (match('='))	{	
			mputw(tag + VALUE, exp_());
			return(TRUE);
		}
		if (ip[0] == 'E' & ip[1] == 'Q' & ip[2] == 'U' &
		    (ip[3] == ' ' | ip[3] == 9)) {
			ip = ip + 3;
			mputw(tag + VALUE, exp_());
			return(TRUE);
		} else {
			mputw(tag + VALUE, loc);
			return(FALSE);
		}
	}
	else {
		mnem(tag);
		return(TRUE);
	}
}

/*
 * Check for mnemonic
 * ------------------
 * Exit status indicates whether
 * processing of line is complete
 */
qmnem()
{
	char *tag, *savp;

	savp = ip;
	if (sym(sbuf) == 0)
		return(FALSE);
	else if ((tag = hashfind(sbuf)) < start) {
		mnem(tag);
		return(TRUE);
	}
	else {
		ip = savp;
		return(FALSE);
	}
}

/*
 * process mnemonic
 */
mnem(tag)
char *tag;
{
	char *p;
	int mode;

	p = mgetw(tag + VALUE);

	if (p & 0x8000) {
		nbytes = 0;
		p = p & 0x7FFF;
		#asm
		DB	20 ; PUSHR1
		DB	30 ; JSRSP
		#endasm
		return;
	}

	if ((obj[0] = p[INHERIT]) != ILLEGAL) {
		nbytes = 1;
		return;
	}
	else {
		if ((obj[0] = p[REL]) != ILLEGAL) {
			relative();
			return;
		}
		else {
			mode = getmode(p[OPFLAG]);
			if ((obj[0] = p[mode]) != ILLEGAL)
				return;
			else if (pass == 1)
				return;
			else
				error("illegal address mode");
		}
	}
}

/*
 * get address mode of opcode
 */
getmode(flag)
int flag;
{
	int oper;

	if (match('#'))
		return(immediate(flag));
	else if (*ip == 'X' & isalnum(ip[1]) == 0) {
	    return(indexed(0));
	}
/*
	else if (match('('))
		return(indirect());
	else if (*ip == 'a' & isalnum(ip[1]) == 0)
		return(accum());
	else
 */
	oper = exp_();
	if (match(','))
		return(indexed(oper));
	else if (oper >= 0 & oper < BYTE)
		return(direct(oper));
	else
		return(extended(oper));
}

/*
 * data immediately after opcode
 */
immediate(flag)
int flag;
{
	int val;
	val = exp_();
	if (flag & 1) {
	    nbytes = 3;
	    obj[1] = val >> 8;
	    obj[2] = val & 0xFF;
	} else {
	    nbytes = 2;
	    obj[1] = val & 0xFF;
	}
	return(IMMED);
}

/*
 * register indexed address modes
 */
indexed(oper)
int oper;
{
	if (match('X'))
		return(xindex(oper));
	else
		error("'X' expected");
}

/*
 * index register X
 */
xindex(oper)
int oper;
{
	if (oper >= 0 & oper < BYTE) {
		nbytes = 2;
		obj[1] = oper & 0xFF;
		return(DIRECT);
	}
	else
		error("offset must be 0..255");
}

/*
 * direct (zero page) address
 */
direct(oper)
int oper;
{
	nbytes = 2;
	obj[1] = oper & 0xFF;
	return(DIRECT);
}

/*
 * 16-bit extended address
 */
extended(oper)
int oper;
{
	nbytes = 3;
	obj[1] = oper >> 8;
	obj[2] = oper & 0xFF;
	return(EXTEND);
}

/*
 * program counter relative
 */
relative()
{
	int offset;

	nbytes = 2;
	offset = exp_() - loc - 2;
	if (offset < -128 | offset > 127) {
		if (pass == 1)
			offset = 0;
		else
			error("branch out of range");
	}
	obj[1] = offset;
	return(REL);
}

/*
 * set location counter
 */
org()
{
	loc = exp_();
	if (nset++ == 0)
		origin = loc;
}

/*
 * fill (reserve) bytes
 */
fillb()
{
	int count,fill;
	nbytes = 0;
	fill = 0;
	count = exp_();
	if (match(','))
	    fill = exp_() & 0xFF;
	while(count--)
	    obj[nbytes++] = fill;
}

/*
 * initialise memory byte
 */
byte()
{
	nbytes = 0;
	while(nbytes < LINESIZE) {
		obj[nbytes++] = exp_() & 0xFF;
		if (match(',') == 0)
			break;
	}
}

/*
 * initialise memory word, high byte first
 */
dbyte()
{
	int word;

	nbytes = 0;
	while(nbytes < LINESIZE) {
		word = exp_();
		obj[nbytes++] = word >> 8;
		obj[nbytes++] = word & 0xFF;
		if (match(',') == 0)
			break;
	}
}

/*
 * enter ASCII text
 */
text()
{
	char delim;			/* string delimeter */

	skip();
	delim = *ip++;			/* first non-blank is delimeter */
	nbytes = 0;
	while(nbytes < LINESIZE & *ip != delim & *ip != 10) /* '\n' */
		obj[nbytes++] = *ip++;
	ip++;				/* skip trailing delimeter */
}

/*
 * switch input to new source file
 */
file()
{
	char *bp;

	if (in2) {
	    printf("as03: Cannot nest include files\n");
	    fatal(-1);
	}

	in2 = in;

	skip();
	bp = sbuf;
	while (*ip != ' ' & *ip != 10) /* '\n' */
		*bp++ = *ip++;
	*bp = 0; /* '\0' */
	if ((in = fopen(sbuf, "r")) == NULL) {
		printf("as03: Cannot open %s\n", sbuf);
		fatal(-1);
	}
}

psend()
{
	endflag = TRUE;
}

/*
 * evaluate expression
 * -------------------
 * '<' returns low byte of expression
 * '>' returns high byte
 */
exp_()
{
	if (match('<'))
		return(expression() & 0xFF);
	else if (match('>'))
		return(expression() >> 8);
	else
		return(expression());
}

/*
 * evaluate infix expression
 * -------------------------
 * operator precedence is left to right
 */
expression()
{
	int n;

	n = operand();
	while (*ip) {
		if (match('+'))
			n = n + operand();
		else if (match('-'))
			n = n - operand();
		else if (match('*'))
			n = n * operand();
		else if (match('/'))
			n = n / operand();
		else
			break;
	}
	return(n);
}

/*
 * return arithmetic operand
 */
operand()
{
	char symbol[LINESIZE];

	if (sym(symbol))
		return(lookup(symbol));
	else if (match('$'))
		return(hexnum());
	else if (match('@'))
		return(octal());
	else if (match('%'))
		return(binary());
	else if (match(0x27)) /* '\'' */
		return(character());
	else if (match('*'))
		return(loc);
	else if (isdigit(*ip))
		return(decimal());
	else {
		error("illegal expression");
		return(ILLEGAL);
	}
}

/*
 * look up name in symbol table
 */
lookup(name)
char *name;
{
	char *tag;

	tag = hashfind(name);
	if (pass == 2) {
		if (tag == 0)
			error("symbol undefined");
		else if (tag < start)
			error("illegal symbol");
	}
	if (tag == 0)
		return(0xEAEA);
	else
		return(mgetw(tag + VALUE));
}

/*
 * hexadecimal constant $n
 */
hexnum()
{
	int n;

	if (isxdigit(*ip) == 0)
		return(ERROR);
	else {
		n = 0;
		while (isxdigit(*ip))
			n = n * 16 + toint(*ip++);
		return(n);
	}
}

/*
 * convert char to 'weight' of hex digit
 */
toint(c)
char c;
{
	if (isdigit(c))
		return(c - '0');
	else if (isxdigit(c)) {
		if (isupper(c))
			return(c - 'A' + 10);
		if (islower(c))
			return(c - 'a' + 10);
	}
	else
		return(ERROR);
}

/*
 * decimal constant n
 */
decimal()
{
	int n;

	if (isdigit(*ip) == 0)
		return(ERROR);
	else {
		n = 0;
		while (isdigit(*ip))
			n = n * 10 + *ip++ - '0';
		return(n);
	}
}

/*
 * octal constant @n
 */
octal()
{
	int n;

	if (*ip < '0' | *ip > '7')
		return(ERROR);
	else {
		n = 0;
		while (*ip >= '0' & *ip <= '7')
			n = n * 8 + *ip++ - '0';
		return(n);
	}
}

/*
 * binary constant %n
 */
binary()
{
	int n;

	if (*ip != '0' & *ip != '1')
		return(ERROR);
	else {
		n = 0;
		while (*ip == '0' | *ip == '1')
			n = n * 2 + *ip++ - '0';
		return(n);
	}
}

/*
 * character constant 'c'
 */
character()
{
	char c;

	c = *ip++;
	if (*ip == 0x27) /* '\'' */
		ip++;			/* discard optional trailing ' */
	return(c);
}

/*
 * get next symbol
 * ---------------
 * copy alpha prefixed alphanumeric string from input buffer
 * accepts underline and tilde as alpha prefix
 * returns length of string
 */
sym(p)
char *p;
{
	char *bp;

	skip();
	bp = p;

	if (isalpha(*ip) | *ip == '_' | *ip == '~') {
		*bp++ = *ip++;
		while (isalnum(*ip) | *ip == '_')
			*bp++ = *ip++;
		*bp = 0; /* '\0' */
	}
	return(bp - p);
}

/*
 * skip white space on input
 */
skip()
{
	while (*ip == ' ' | *ip == 9)
		ip++;
}

/*
 * match literal with input buffer
 */
match(c)
char c;
{
	skip();

	if (*ip != c) return(FALSE);

	ip++;
	return(TRUE);
}

/*
 * output assembly listing and object code
 */
output(mem)
int mem;
{
	int n, byte;

	if (list) {
		n = 0;
		while (n < nbytes) {
			printf("%04x  ", mem + n);
			byte = 0;
			while (byte < 3) {
				if (n < nbytes)
					printf("%02x ", obj[n++] & 0xFF);
				else
					printf("   ");
				byte++;
			}
			if (n < 4)
				printf(" %s", ibuf);
			else
				printf("\n");
			/* if (n >= nbytes) break; */
		}
	}
	n = 0;
	while (n < nbytes) {
		putc(obj[n++], out);
	}
}

/*
 * print error message
 * -------------------
 * use stdout, so errors appear in listing
 */
error(message)
char *message;
{
	printf("\n*****: %s", ibuf);
	printf("error: %s\n", message);
	if (++errcnt > 5) {
		printf("as03: too many errors, assembly aborted\n");
		fatal(-1);
	}
}

/*
 * tidy up files and exit on fatal error
 */
fatal(stat)
int stat;				/* exit status */
{
	if (in != NULL)
		fclose(in);
	if (out != NULL)
		fclose(out);
	exit(stat);
}

/*
 * initialise empty hash table
 */
inithash()
{
	int i;

	freeptr = symtab;
	i = 0;
	while (i < HASHSIZE)
		hashtab[i++] = NULL;
}

/*
 * hashing algorithm
 * -----------------
 * returns value in range 0 to HASHSIZE - 1
 * for best results HASHSIZE should be a prime
 */
hash(name)
char *name;
{
	int h;

	h = 0;
	while (*name)
		h = (3 * h + *name++) % HASHSIZE;
	return(h);
}

/*
 * install new symbol
 */
install(name, val)
char *name;
int val;
{
	int len, h;
	char *p;

	len = strlen(name) + 5;
	if (freeptr + len > endsym) {
		printf("symbol table full\n");
		fatal(-1);
	}
	h = hash(name);
	p = freeptr;
	mputw(p + NEXTPTR, hashtab[h]);
	hashtab[h] = p;
	mputw(p + VALUE, val);
	strcpy(p + NAME, name);
	freeptr = p + len;
}

/*
 * find symbol using hash + chain
 */
hashfind(name)
char *name;
{
	char *tag;

	tag = hashtab[hash(name)];
	while (tag) {
		if (strcmp(tag + NAME, name) == SAME)
			break;
		else
			tag = mgetw(tag + NEXTPTR);
	}
	return(tag);
}

/*
 * put word into memory
 */
mputw(p, val)
int *p;
int val;
{
	*p = val;
}

/*
 * get word from memory
 */
mgetw(p)
int *p;
{
	return(*p);
}

/*
 * dump symbol table
 * -----------------
 * symbols prefixed by tilde are local, and
 * are not written to the global symbol file
 */
dumpsym()
{
	char *p;
	FILE *out;

	if (freeptr == start)
		return;
	if ((out = fopen("out.sym", "w")) == NULL) {
		printf("as03: Cannot open g/out\n");
		fatal(-1);
	}
	p = start;
	while (p < freeptr) {
/*		if (*(p + NAME) != '~')
			fprintf(out, "%s =$%04x\n", p + NAME, mgetw(p + VALUE));
 */
		if (list)
			printf("%s =$%04x\n", p + NAME, mgetw(p + VALUE));
		p = p + strlen(p + NAME) + 5;
	}
	fclose(out);
}

/*
 *
 *
 *
 *
 *
 *
 */

isxdigit(c) char c;
{
	return (isdigit(c) | ((c >= 'A') & (c <= 'F')) | ((c >= 'a') & (c <= 'f')));
}

#define stdout 1

/*
 * utoi -- convert unsigned decimal string to integer nbr
 *	        returns field size, else ERR on error
 */
utoi(decstr, nbr)
char *decstr ;
int *nbr;
{
	int t, d ;

	d = 0 ;
	*nbr = 0 ;
	while ( *decstr >= '0' & *decstr <= '9' ) {
		t = *nbr ;
		t = (10*t) + (*decstr++ - '0') ;
		if ( t >= 0 & *nbr < 0 )
			return -1 ;
		++d ;
		*nbr = t ;
	}
	return d ;
}

/*
 * itod -- convert nbr to signed decimal string of width sz
 *	       right adjusted, blank filled ; returns str
 *
 *	      if sz > 0 terminate with null byte
 *	      if sz  =  0 find end of string
 *	      if sz < 0 use last byte for data
 */
itod(nbr, str, sz)
int nbr ;
char str[] ;
int sz ;
{
	char sgn ;

	if ( nbr < 0 ) {
		nbr = -nbr ;
		sgn = '-' ;
	}
	else
		sgn = ' ' ;
	if ( sz > 0 )
		str[--sz] = NULL ;
	else if ( sz < 0 )
			sz = -sz ;
		else
			while ( str[sz] != NULL )
				++sz ;
	while ( sz ) {
		str[--sz] = nbr % 10 + '0' ;
		nbr = nbr / 10;
		if ( nbr == 0 )
			break ;
	}
	if ( sz )
		str[--sz] = sgn ;
	while ( sz > 0 )
		str[--sz] = ' ' ;
	return str ;
}


/*
 * itou -- convert nbr to unsigned decimal string of width sz
 *	       right adjusted, blank filled ; returns str
 *
 *	      if sz > 0 terminate with null byte
 *	      if sz  =  0 find end of string
 *	      if sz < 0 use last byte for data
 */
itou(nbr, str, sz)
int nbr ;
char str[] ;
int sz ;
{
	int lowbit ;

	if ( sz > 0 )
		str[--sz] = NULL ;
	else if ( sz < 0 )
			sz = -sz ;
		else
			while ( str[sz] != NULL )
				++sz ;
	while ( sz ) {
		lowbit = nbr & 1 ;
		nbr = (nbr >> 1) & 0x7fff ;  /* divide by 2 */
		str[--sz] = ( (nbr%5) << 1 ) + lowbit + '0' ;
		nbr = nbr / 5;
		if ( nbr == 0 )
			break ;
	}
	while ( sz )
		str[--sz] = ' ' ;
	return str ;
}


/*
 * itox -- converts nbr to hex string of length sz
 *	       right adjusted and blank filled, returns str
 *
 *	      if sz > 0 terminate with null byte
 *	      if sz  =  0 find end of string
 *	      if sz < 0 use last byte for data
 */
itox(nbr, str, sz)
int nbr ;
char str[] ;
int sz ;
{
	int digit, offset ;

	if ( sz > 0 )
		str[--sz] = NULL ;
	else if ( sz < 0 )
		sz = -sz ;
	else
		while ( str[sz] != NULL )
			++sz ;
	while ( sz ) {
		digit = nbr & 15 ;
		nbr = ( nbr >> 4 ) & 0xfff ;
		if ( digit < 10 )
			offset = 48 ;
		else
			offset = 55 ;
		str[--sz] = digit + offset ;
		if ( nbr == 0 )
			break ;
	}
	while ( sz )
		str[--sz] = ' ' ;
	return str ;
}

/*
** printf(controlstring, arg, arg, ...) -- formatted print
**        operates as described by Kernighan & Ritchie
**        only d, x, c, s, and u specs are supported.
*/
printf(argc) int argc;
{
  int  width, prec, preclen, len, *nxtarg;
  char *ctl, *cx, c, right, str[7], *sptr, pad;
  int i;
#asm       /* fetch arg count from primary reg first */
    DB	22	;EXG1
#endasm
  nxtarg = &argc + (i - (1 << 1));
  ctl = *nxtarg;
  while(c=*ctl++) {
    if (c==0x5c) {
	c=*ctl++;
	if (c == 'n') {cout(10, stdout); continue;}
	if (c == 'r') {cout(13, stdout); continue;}
	if (c == 't') {cout(9, stdout); continue;}
	cout(c, stdout);
	continue;
    }
    if(c!='%') {cout(c, stdout); continue;}
    if(*ctl=='%') {cout(*ctl++, stdout); continue;}
    cx=ctl;
    if(*cx=='-') {right=0; ++cx;} else right=1;
    if(*cx=='0') {pad='0'; ++cx;} else pad=' ';
    if((i=utoi(cx, &width)) >= 0) cx=cx+i; else continue;
    if(*cx=='.') {
      if((preclen=utoi(++cx, &prec)) >= 0) cx=cx+preclen;
      else continue;
      }
    else preclen=0;
    sptr=str; c=*cx++; i=*(--nxtarg);
    if(c=='d') itod(i, str, 7);
    else if(c=='x') itox(i, str, 7);
    else if(c=='c') {str[0]=i; str[1]=NULL;}
    else if(c=='s') sptr=i;
    else if(c=='u') itou(i, str, 7);
    else continue;
    ctl=cx; /* accept conversion spec */
    if(c!='s') while(*sptr==' ') ++sptr;
    len=-1; while(sptr[++len]); /* get length */
    if((c=='s')&(len>prec)&(preclen>0)) len=prec;
    if(right) while(((width--)-len)>0) cout(pad, stdout);
    while(len) {cout(*sptr++, stdout); --len; --width;}
    while(((width--)-len)>0) cout(pad, stdout);
    }
}

cout(c, fd) char c; int fd; {
/*  if(putc(c, fd)==EOF) xout(); */
  putchar(c);
}

fgets(s, size, stream)
char *s;
int size;
FILE *stream;
{
    char *p;
    int len;
    int c;

    p = s;

    len = 0;
    while (len < size - 1) {
	c = getc(stream);
	if (c < 0) break;
	*p++ = c;
	if (c == 10) {
	    *p = 0;
	    return s;
	}
	len++;
    }
    *p = 0;
    if (p == s) return NULL;
    return s;
}

fread(ptr, size, nmb, stream)
char *ptr;
int size;
int nmb;
FILE *stream;
{
    int total;
    int c;
    int len;
    len = 0;
    total = size * nmb;
    while (len < total) {
	c = getc(stream);
	if (c < 0) break;
	*ptr++ = c;
	len++;
    }
    return len;
}

#include OPCODES.ASM
