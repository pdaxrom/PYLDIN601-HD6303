UNIASM = ../../generic/src/DEVEL/uniasm

all: $(UNIASM)		\
    UART.CMD		\
    RAMCHK.CMD		\
    RAMTEST.CMD		\
    MICROBASIC.CMD	\
    MON.BIN		\
    SIMPLEIO.CMD	\
    IRQTEST.CMD		\
    HCMSSPI.CMD		\
    VPU.CMD		\
    VPUGRF.CMD		\
    VPUTXT.CMD		\
    VIRQTEST.CMD	\
    PSGDEMO.CMD		\
    CHIPTUNE.CMD

$(UNIASM):
	make -C $(shell dirname $(UNIASM)) $(shell basename $(UNIASM))

.SUFFIXES: .ASM .CMD

.ASM.CMD: ../DEVMAP.INC ../BOOTROM.INC
	$(UNIASM) $< $(basename $@) $@

MON.BIN: 6303MON.CMD
	dd if=/dev/zero ibs=1k count=128 | tr "\000" "\377" >MON.BIN
	dd if=6303MON.CMD of=MON.BIN conv=notrunc bs=1 seek=$$((0xF000))


clean:
	rm -f *.LST *.CMD ymstreamer *.BIN
