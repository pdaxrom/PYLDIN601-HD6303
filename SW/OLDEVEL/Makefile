all: uniasm unilib unilink 6800

.SUFFIXES: .pas .ASM .OBJ .EXP .INC

.pas:
	fpc -g -gl $<

#CLIB.EXP: CLIB.INC
#	./exportsym.sh $< > $@

.INC.EXP:
	./exportsym.sh $< > $@

.INC.H:
	./exporthdr.sh ../$< > $@

CLIB.OBJ: CLIB.EXP

LIBROM.OBJ: LIBROM.EXP

.ASM.OBJ:
	./uniasm $< $(basename $@) $@

BOOTROM.H: ../BOOTROM.INC
	./exporthdr.sh $< > $@

DEVMAP.H: ../DEVMAP.INC
	./exporthdr.sh $< > $@

clean:
	rm -f *.o uniasm unilib unilink 6800 *.EXP *.OBJ *.LST DEVMAP.H BOOTROM.H
