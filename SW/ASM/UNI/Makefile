UNIASM = ../../DEVEL/uniasm

all: $(UNIASM)		\
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

.SUFFIXES: .ASM .CMD

.ASM.CMD: ../../DEVMAP.INC ../../BOOTROM.INC
	$(UNIASM) $< $(basename $@) $@

clean:
	rm -f *.LST *.CMD
