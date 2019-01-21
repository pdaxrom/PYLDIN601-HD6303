#include <stdio.h>
#include <inttypes.h>

unsigned char mem[65536];

int main(int argc, char *argv[])
{
    int len;

    FILE *f = fopen(argv[1], "rb");
    if (!f) {
	fprintf(stderr, "Cannot open input file!\n");
	return 1;
    }

    len = fread(mem, 1, sizeof(mem), f);
    fclose(f);

    int ptr = 0;

    while (ptr < len - 1) {
	if (((mem[ptr] >= 0x90) && (mem[ptr] <= 0x9F)) ||
	    ((mem[ptr] >= 0xD0) && (mem[ptr] <= 0xDF))) {
	    if (mem[ptr] != 0x9D &&	// JSR
		mem[ptr] != 0x93 &&	// SUBD
		mem[ptr] != 0xD3 &&	// ADDD
		mem[ptr] != 0xDC &&	// LDD
		mem[ptr] != 0xDD	// STD
		) {

		    if (mem[ptr + 1] < 0x28) {
			printf("ADDR=%04X MEM=%02X (%02X %02X X)\n", ptr + 0x100, mem[ptr + 1], mem[ptr], mem[ptr + 1]);
		    }
		    ptr += 1;
		}
	}
	ptr += 1;
    }

    f = fopen(argv[2], "rb");
    if (!f) {
	fprintf(stderr, "Cannot open patch file!\n");
	return 1;
    }

    uint32_t addr;
    uint32_t cmd, byte;
    char type;

    while (fscanf(f, "ADDR=%04X (%02X %02X %c)\n", &addr, &cmd, &byte, &type) > 0) {
	if (type == 'X') {
	    //printf("%04X %02X %02X\n", addr, cmd, byte);
	    if (mem[addr + 0 - 0x100] != cmd ||
		mem[addr + 1 - 0x100] != byte) {
		fprintf(stderr, "Skip patch ADDR=%04X MEM=%04X\n", addr, byte);
	    } else {
		mem[addr + 1 - 0x100] += 0x28;
	    }
	} else if (type == 'P') {
	    if (mem[addr + 0 - 0x100] != cmd) {
		fprintf(stderr, "Skip patch ADDR=%04X\n", addr);
	    } else {
		mem[addr + 0 - 0x100] = byte;
	    }
	} else {
	    break;
	}
    }

    fclose(f);

    f = fopen(argv[3], "wb");
    if (!f) {
	fprintf(stderr, "Cannot open output file!\n");
	return 1;
    }

    fwrite(mem, 1, len, f);

    fclose(f);

    return 0;
}
