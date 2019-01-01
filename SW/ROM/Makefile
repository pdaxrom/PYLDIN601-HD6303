UNIASM = ../DEVEL/uniasm

all: $(UNIASM) bootloader rom.bin

$(UNIASM):
	make -C $(shell dirname $(UNIASM)) $(shell basename $(UNIASM))

rom.bin: $(UNIASM)
	cp ../../generic/src/ROM/BOOTROM.INC .
	cp ../../generic/src/ROM/BOOTMEM.INC .
	sed -i -e 's/$FF00/$FE00/' BOOTMEM.INC
	cpp -P -traditional -DHD6303Y ../../generic/src/ROM/ROM.ASM > ROM.S
	$(UNIASM) ROM.S ROM.LST ROM.CMD
	dd if=/dev/zero ibs=1k count=128 | tr "\000" "\377" >rom.bin
	dd if=ROM.CMD of=rom.bin conv=notrunc bs=1 seek=$$((0x1fe00))

bootloader: ../../generic/src/ROM/bootloader.c
	$(CC) $^ -o $@ -Wall -O2 -g

clean:
	rm -f rom.bin *.LST *.CMD *.o *.mem bootloader *.SYS *.CMD *.ERR *.S BOOTROM.INC BOOTMEM.INC
