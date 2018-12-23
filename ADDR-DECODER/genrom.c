#include <stdio.h>

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

#define DEFAULT_OUT	RAMCS | ROMCS | EXTCS

int main(int argc, char *argv[])
{
    unsigned char rom[1 << ROM_WIDTH];
    unsigned int i;

    FILE *outf = fopen(argv[1], "wb");
    if (!outf) {
	fprintf(stderr, "Can't open output file!\n");
	return 1;
    }

    for (i = 0; i < sizeof(rom); i++) {
	unsigned char out = DEFAULT_OUT;

	/* BIOS 0xF000 */
	if ((i & A15) && (i & A14) && (i & A13) && (i & A12)) out ^= (RAMCS | ROMCS);

	/* EXT 0xE600 */
	if ((i & A15) && (i & A14) && (i & A13) && !(i & A12) &&
	    !(i & A11) && (i & A10) && (i & A9) && !(i & A8)) out ^= (RAMCS | EXTCS);

	/* PAGE 0xC000 0xD000 */
	if ((i & A15) && (i & A14) && !(i & A13)) {
	    if (i & PAGE_A17) out ^= (RAMCS | ROMCS);
	    out |= (((i & PAGE_A16) ? MEM_A16 : 0) |
		    ((i & PAGE_A15) ? MEM_A15 : 0) |
		    ((i & PAGE_A14) ? MEM_A14 : 0) |
		    ((i & PAGE_A13) ? MEM_A13 : 0));
	}

	rom[i] = out;
    }

    fwrite(rom, 1, sizeof(rom), outf);
    fclose(outf);
    return 0;
}
