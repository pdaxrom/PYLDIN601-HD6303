#UNIASM = ../../DEVEL/uniasm
UNIAS = ../SMALL-C/unias

all: $(UNIAS)		\
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

$(UNIAS):
	make -C $(shell dirname $(UNIAS)) $(shell basename $(UNIAS))

.SUFFIXES: .ASM .CMD

#.ASM.CMD: ../../DEVMAP.INC ../../BOOTROM.INC
#	$(UNIASM) $< $(basename $@) $@

.ASM.CMD: ../../DEVMAP.INC ../../BOOTROM.INC
	$(UNIAS) -l $(basename $@).LST -o $@ $<

clean:
	rm -f *.LST *.CMD
