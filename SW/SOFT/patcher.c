#include <stdio.h>
#include <inttypes.h>
#include <string.h>

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
    char buff[256];
    uint32_t offset = 0x100;
    uint32_t csum_addr = 0;
    int	csum_enable = 0;

    while (fgets(buff, sizeof(buff), f)) {
	type = 0;
	if (strchr(buff, ';')) {
	    continue;
	} else if (!strncmp(buff, "OFFSET=", 7)) {
	    sscanf(buff, "OFFSET=%04X\n", &offset);
	    continue;
	} else if (!strncmp(buff, "CHECKSUM=", 9)) {
	    sscanf(buff, "CHECKSUM=%04X\n", &csum_addr);
	    csum_enable = 1;
	    continue;
	}
	sscanf(buff, "ADDR=%04X (%02X %02X %c)\n", &addr, &cmd, &byte, &type);
	if (type == 'X') {
	    //printf("%04X %02X %02X\n", addr, cmd, byte);
	    if (mem[addr + 0 - offset] != cmd ||
		mem[addr + 1 - offset] != byte) {
		fprintf(stderr, "Skip patch ADDR=%04X MEM=%04X\n", addr, byte);
	    } else {
		mem[addr + 1 - offset] += 0x28;
	    }
	} else if (type == 'P') {
	    if (mem[addr + 0 - offset] != cmd) {
		fprintf(stderr, "Skip patch ADDR=%04X\n", addr);
	    } else {
		mem[addr + 0 - offset] = byte;
	    }
	} else {
	    break;
	}
    }

    fclose(f);

    uint8_t csum;

    if (csum_enable) {
	csum = 0;
	mem[csum_addr - offset] = 0xFF;
	for (ptr = 0; ptr < len; ptr++) {
	    csum += mem[ptr];
	}
	mem[csum_addr - offset] = 0xFF ^ csum;
    }

    csum = 0;
    for (ptr = 0; ptr < len; ptr++) {
	csum += mem[ptr];
    }
    fprintf(stderr, "Checksum = %02X\n", csum);


    f = fopen(argv[3], "wb");
    if (!f) {
	fprintf(stderr, "Cannot open output file!\n");
	return 1;
    }

    fwrite(mem, 1, len, f);

    fclose(f);

    return 0;
}
