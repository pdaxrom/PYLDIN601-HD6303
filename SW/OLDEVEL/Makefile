all: uniasm unilib unilink 6800 uasm ulink

CFLAGS = -g -Ofast

uasm: mc6800.c UASM.MEM
	$(CC) -o $@ mc6800.c -DAPP=\"UASM.MEM\" -Wall $(CFLAGS)

ulink: mc6800.c ULINK.MEM
	$(CC) -o $@ mc6800.c -DAPP=\"ULINK.MEM\" -Wall $(CFLAGS)

UASM.MEM: UASM.CMD

ULINK.MEM: ULINK.CMD

#.SUFFIXES: .ASM .CMD .PGM .MEM

.SUFFIXES: .pas .CMD .MEM

.CMD.MEM:
	hexdump -v -e '"\t" 16/1 "0x%02x, " "\n"' $< | sed 's/0x  ,//g' > $@

.pas:
	fpc -g -gl $<

clean:
	rm -f *.o uniasm unilib unilink 6800 uasm ulink *.MEM
