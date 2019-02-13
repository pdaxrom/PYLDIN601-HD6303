#UNIASM = ../../DEVEL/uniasm
AS03 = ../SMALL-C/as03

all: $(AS03)		\
    ZBIOS.CMD		\
    UNIBIOS.CMD		\
    SIMPLEIO.CMD	\
    U.CMD		\
    UNIDOS.CMD		\
    HELLO.CMD

#    INOUT.CMD
#    UNIKBD.CMD

$(UNIASM):
	make -C $(shell dirname $(UNIASM)) $(shell basename $(UNIASM))

$(AS03):
	make -C $(shell dirname $(AS03)) $(shell basename $(AS03))

.SUFFIXES: .ASM .CMD

#.ASM.CMD: ../../DEVMAP.INC ../../BOOTROM.INC
#	$(UNIASM) $< $(basename $@) $@

.ASM.CMD: ../../DEVMAP.INC ../../BOOTROM.INC
	$(AS03) -l $(basename $@).LST -o $@ $<

clean:
	rm -f *.LST *.CMD
