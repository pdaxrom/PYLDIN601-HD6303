UNIASM = ../../DEVEL/uniasm

all: $(UNIASM)		\
    ZBIOS.CMD		\
    UNIBIOS.CMD		\
    HELLO.CMD		\
    INOUT.CMD

$(UNIASM):
	make -C $(shell dirname $(UNIASM)) $(shell basename $(UNIASM))

.SUFFIXES: .ASM .CMD

.ASM.CMD: ../../DEVMAP.INC ../../BOOTROM.INC
	$(UNIASM) $< $(basename $@) $@

clean:
	rm -f *.LST *.CMD
