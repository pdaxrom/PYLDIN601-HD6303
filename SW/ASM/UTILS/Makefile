UNIASM = ../../DEVEL/uniasm

all: $(UNIASM)		\
    LOADPAGE.CMD	\
    COPYPAGE.CMD	\
    LOADBIOS.CMD	\
    TRAP.CMD		\
    XONIX.CMD		\
    TEST.CMD

#    HELLO.CMD		\
#    INOUT.CMD
#    UNIKBD.CMD

$(UNIASM):
	make -C $(shell dirname $(UNIASM)) $(shell basename $(UNIASM))

.SUFFIXES: .ASM .CMD

.ASM.CMD: ../../DEVMAP.INC
	$(UNIASM) $< $(basename $@) $@

clean:
	rm -f *.LST *.CMD
