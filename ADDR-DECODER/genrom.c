#include <stdio.h>

#define B(b) (b?1:0)

#define ROM_WIDTH	16

#define A15		(1 << 0)
#define A14		(1 << 1)
#define A13		(1 << 2)
#define A12		(1 << 3)
#define A11		(1 << 4)
#define A10		(1 << 5)
#define A9		(1 << 6)
#define A8		(1 << 7)
#define PAGE_A13	(1 << 8)
#define PAGE_A14	(1 << 9)
#define PAGE_A15	(1 << 10)
#define PAGE_A16	(1 << 11)
#define PAGE_A17	(1 << 12)
#define PAGE_FN1	(1 << 13)
#define PAGE_FN2	(1 << 14)
#define PAGE_FN3	(1 << 15)

#define EXTCS		(1 << 0)
#define RAMCS		(1 << 1)
#define ROMCS		(1 << 2)
#define MEM_A13		(1 << 3)
#define MEM_A14		(1 << 4)
#define MEM_A15		(1 << 5)
#define MEM_A16		(1 << 6)

int main(int argc, char *argv[])
{
    unsigned char rom[1 << ROM_WIDTH];
    unsigned int i;
    int oldout = 0;

    FILE *outf = fopen(argv[1], "wb");
    if (!outf) {
	fprintf(stderr, "Can't open output file!\n");
	return 1;
    }

    for (i = 0; i < sizeof(rom); i++) {
	unsigned char out = 0;

	/* PAGE 0xC000 0xD000 */
	if ((i & A15) && (i & A14) && !(i & A13)) {
	    if (i & PAGE_A17) {
		out |= EXTCS; // EXTCS = 1, RAMCS = 0, ROMCS = 0
		fprintf(stderr, "PROM> ");
	    } else {
		out |= (RAMCS | ROMCS | EXTCS); // EXTCS = 1, RAMCS = 1, ROMCS = 1
		fprintf(stderr, "PRAM> ");
	    }
	    out |= (((i & PAGE_A16) ? MEM_A16 : 0) |
		    ((i & PAGE_A15) ? MEM_A15 : 0) |
		    ((i & PAGE_A14) ? MEM_A14 : 0) |
		    ((i & PAGE_A13) ? MEM_A13 : 0));
	} else {
	    /* BIOS 0xF000 */
	    if ((i & A15) && (i & A14) && (i & A13) && (i & A12)) {
		out |= EXTCS; // EXTCS = 1, RAMCS = 0, ROMCS = 0
		fprintf(stderr, " ROM> ");
	    } else 
	    /* EXT 0xE600 */
	    if ((i & A15) && (i & A14) && (i & A13) && !(i & A12) &&
		!(i & A11) && (i & A10) && (i & A9) && !(i & A8)) {
		out |= ROMCS; // EXTCS = 0, RAMCS = 0, ROMCS = 1
		fprintf(stderr, " EXT> ");
	    } else {
		/* RAM */
		out |= (RAMCS | ROMCS | EXTCS); // EXTCS=1, RAMCS = 1, ROMCS = 1
		fprintf(stderr, " RAM> ");
	    }

	    out |= (((i & A15) ? MEM_A15 : 0) |
		    ((i & A14) ? MEM_A14 : 0) |
		    ((i & A13) ? MEM_A13 : 0));
	}

//	if (oldout != out) {
	    fprintf(stderr, "%d %d %d %d %d | %d %d %d %d %d %d %d %d X X X X X X X X - EXTCS=%d RAMCS=%d ROMCS=%d A16=%d A15=%d A14=%d A13=%d\n",
		B(i&PAGE_A17), B(i&PAGE_A16), B(i&PAGE_A15), B(i&PAGE_A14), B(i&PAGE_A13),
		B(i&A15), B(i&A14), B(i&A13), B(i&A12), B(i&A11), B(i&A10), B(i&A9), B(i&A8),
		B(out&EXTCS), B(out&RAMCS), B(out&ROMCS), B(out&MEM_A16), B(out&MEM_A15), B(out&MEM_A14), B(out&MEM_A13));
//	    oldout = out;
//	}
	rom[i] = out;
    }

    fwrite(rom, 1, sizeof(rom), outf);
    fclose(outf);
    return 0;
}
