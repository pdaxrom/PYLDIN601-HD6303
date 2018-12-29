ifneq (Microsoft, $(findstring Microsoft, $(shell uname -r)))
SCUBACMD = /opt/diamond/3.9_x64/ispfpga/bin/lin64/scuba
FOUNDRY  = /opt/diamond/3.9_x64/ispfpga
SCUBA = \
	export LD_LIBRARY_PATH="/opt/diamond/3.9_x64/tcltk/lib:/opt/diamond/3.9_x64/ispfpga/bin/lin64:/opt/diamond/3.9_x64/bin/lin64:/opt/diamond/3.9_x64/ispfpga/bin/lin64"; \
	export FOUNDRY="$(FOUNDRY)"; \
	export WSLENV="$WSLENV:FOUNDRY/l"; \
	$(SCUBACMD)
else
SCUBACMD = /mnt/Storage/Games/lscc/diamond/3.10_x64/ispfpga/bin/nt64/scuba.exe
FOUNDRY  = /mnt/Storage/Games/lscc/diamond/3.10_x64/ispfpga
SCUBA = \
	export FOUNDRY="$(FOUNDRY)"; \
	export WSLENV="$WSLENV:FOUNDRY/l"; \
	$(SCUBACMD)
endif

all: superio/vrom.v superio/vram.v superio/pll.v

vrom.mem:
	gzip -dc video.roz | hexdump -v -e '"%04_ax: " 16/1 "%02x " "\n"' > vrom.mem

superio/vrom.v: vrom.mem
	cd superio && \
	$(SCUBA) -w -n vrom -lang verilog -synth lse -bus_exp 7 -bb -arch xo2c00 -type bram -wp 00 -rp 1100 -addr_width 11 -data_width 8 -num_rows 2048 -cascade -1 -memfile ../vrom.mem -memformat orca
#	$(SCUBA) -w -n vrom -lang verilog -synth lse -bus_exp 7 -bb -arch xo2c00 -type rom -addr_width 8 -num_rows 2048 -data_width 8 -outdata UNREGISTERED -cascade -1 -resetmode SYNC -sync_reset  -memfile ROM/vrom.mem -memformat orca

superio/vram.v:
	cd superio && \
        $(SCUBA) -w -n vram -lang verilog -synth lse -bus_exp 7 -bb -arch xo2c00 -type ramdp -aaddr_width 13 -widtha 8 -baddr_width 13 -widthb 8 -anum_words 8192 -bnum_words 8192 -outdataA REGISTERED -outdataB REGISTERED -cascade -1 -resetmode SYNC -sync_reset -mem_init0 -writemodeA NORMAL -writemodeB NORMAL

superio/pll.v:
	cd superio && \
	$(SCUBA) -w -n pll -lang verilog -synth lse -arch xo2c00 -type pll -fin 12 -fclkop 24 -fclkop_tol 0.0 -fclkos 8 -fclkos_tol 0.0 -trimp 0 -phasep 0 -trimp_r -trims 0 -phases 0 -trims_r -phase_cntl STATIC -fb_mode 1

clean:
	rm -f *.mem superio/vrom.v superio/vram.v superio/pll.v
