#UNIASM = ../../DEVEL/uniasm
AS03 = ../SMALL-C/as03

all: $(AS03)		\
    LOADPAGE.CMD	\
    COPYPAGE.CMD	\
    LOADBIOS.CMD	\
    TRAP.CMD		\
    XONIX.CMD		\
    HCMSSPI.PGM		\
    CHIPTUNE.CMD	\
    RAMCHK.CMD		\
    TEST.CMD		\
    MAKEBOOT.CMD	\
    SDFORMAT.CMD	\
    FLASHROM.CMD	\
    PAGEINFO.CMD

#    HELLO.CMD		\
#    INOUT.CMD
#    UNIKBD.CMD

$(UNIASM):
	make -C $(shell dirname $(UNIASM)) $(shell basename $(UNIASM))

$(AS03):
	make -C $(shell dirname $(AS03)) $(shell basename $(AS03))

.SUFFIXES: .ASM .CMD .PGM

#.ASM.CMD: ../../DEVMAP.INC
#	$(UNIASM) $< $(basename $@) $@

.ASM.CMD: ../../DEVMAP.INC ../../BOOTROM.INC
	$(AS03) -l $(basename $@).LST -o $@ $<

.ASM.PGM: ../../DEVMAP.INC ../../BOOTROM.INC
	$(AS03) -l $(basename $@).LST -o $@ $<

clean:
	rm -f *.LST *.CMD *.PGM
