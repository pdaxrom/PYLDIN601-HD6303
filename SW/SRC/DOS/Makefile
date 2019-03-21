UASM  = ../../OLDEVEL/uasm
ULINK = ../../OLDEVEL/ulink

all: $(UASM) $(ULINK)	\
	DOSEDIT.PGM	\
	VDISK.PGM

$(UASM):
	make -C $(shell dirname $(UASM)) $(shell basename $(UASM))

$(ULINK):
	make -C $(shell dirname $(ULINK)) $(shell basename $(ULINK))

.SUFFIXES: .601 .CMD .PGM

.601.CMD:
	$(UASM) $< $@

.601.PGM:
	@zz=$<;echo $${zz/.*};\
	$(UASM) $${zz/.*}
	@zz=$<;echo $${zz/.*};\
	$(ULINK) $${zz/.*}

clean:
	rm -f *.LST *.CMD *.PGM *.OBJ
