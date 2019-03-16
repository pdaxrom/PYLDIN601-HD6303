#UNIASM = ../../DEVEL/uniasm
UNIAS = ../SMALL-C/unias

all: $(UNIAS)		\
    LOADPAGE.CMD	\
    COPYPAGE.CMD	\
    LOADBIOS.CMD	\
    TRAP.PGM		\
    XONIX.CMD		\
    HCMSSPI.PGM		\
    CHIPTUNE.CMD	\
    RAMCHK.CMD		\
    RAMTEST.CMD		\
    TEST.CMD		\
    MAKEBOOT.CMD	\
    SDFORMAT.CMD	\
    FLASHROM.CMD	\
    FLASHBIOS.CMD	\
    PAGEINFO.CMD	\
    IRQTEST.CMD		\
    VPUGRF.CMD		\
    P601EGRF.PGM	\
    BPT.PGM

#    HELLO.CMD		\
#    INOUT.CMD
#    UNIKBD.CMD

$(UNIASM):
	make -C $(shell dirname $(UNIASM)) $(shell basename $(UNIASM))

$(UNIAS):
	make -C $(shell dirname $(UNIAS)) $(shell basename $(UNIAS))

.SUFFIXES: .ASM .CMD .PGM

#.ASM.CMD: ../../DEVMAP.INC
#	$(UNIASM) $< $(basename $@) $@

.ASM.CMD: ../../DEVMAP.INC ../../BOOTROM.INC
	$(UNIAS) -l $(basename $@).LST -o $@ $<

.ASM.PGM: ../../DEVMAP.INC ../../BOOTROM.INC
	$(UNIAS) -l $(basename $@).LST -o $@ $<

clean:
	rm -f *.LST *.CMD *.PGM
