module superio (
	output			RESET,
	output			NMI,
	output	[1:0]	IRQ,
	input			EXTCS,
	input			ROMCS,
	input			E,
	input			RW,
	input	[7:0]	ADDR,
	inout	[7:0]	DATA,

	inout			PS2CLK,
	inout			PS2DAT,

	output	[1:0]	NSS,
	output			MSCK,
	input			MISO,
	output			MOSI,

	output			BLANK,
	output			RS,
	
	output			PWM,
	
	output	[1:0]	TVOUT,

	input			pclk,
	
	input	[3:0]	keys,
	input	[3:0]	switches,
	
	output	[8:0]	seg_led_h,
	output	[8:0]	seg_led_l,
	output	[2:0]	rgb1,
	output	[2:0]	rgb2,
	output	[7:0]	leds
);
	parameter PCLK_CLOCK = 12000000;
	parameter LED_REFRESH_CLOCK = 50;
	
	parameter LED_DIV_PERIOD = (PCLK_CLOCK / LED_REFRESH_CLOCK) / 2;

	reg			sys_res;
	reg	[3:0]	sys_res_delay = 4'b1000;

	reg		[1:0]	led_anode;
	reg		[24:0]	led_cnt;

	always @ (posedge pclk)
	begin
		if (sys_res) led_anode <= 2'b01;
		else begin
			if (led_cnt == (LED_DIV_PERIOD - 1)) begin
				led_anode <= ~led_anode;
				led_cnt <= 0;
			end else led_cnt <= led_cnt + 1'b1;
		end
	end

	assign seg_led_h[8] = led_anode[1];
	assign seg_led_l[8] = led_anode[0];

	wire audio_clk;
	wire pixel_clk;

	pll pll1 (
		.CLKI(pclk),
		.CLKOP(audio_clk),
		.CLKOS(pixel_clk)
	);

	always @ (posedge E or negedge keys[3])
	begin
		if (!keys[3]) begin
			sys_res <= 1;
			sys_res_delay <= 4'b1000;
		end else begin
			if (sys_res_delay == 4'b0000) begin
				sys_res <= 0;
			end else sys_res_delay <= sys_res_delay - 4'b0001;
		end
	end

	assign RESET = ~sys_res;

	/*
		Mapping IO
	 */

	wire DS0 = !EXTCS && (ADDR[7:5] == 3'b000); // $E600
	wire DS1 = !EXTCS && (ADDR[7:5] == 3'b001); // $E620
	wire DS2 = !EXTCS && (ADDR[7:5] == 3'b010); // $E640
	wire DS3 = !EXTCS && (ADDR[7:5] == 3'b011); // $E660
	wire DS4 = !EXTCS && (ADDR[7:5] == 3'b100); // $E680
	wire DS5 = !EXTCS && (ADDR[7:5] == 3'b101); // $E6A0
	wire DS6 = !EXTCS && (ADDR[7:5] == 3'b110); // $E6C0
	wire DS7 = !EXTCS && (ADDR[7:5] == 3'b111); // $E6E0
	
	wire vpu_cs = DS0;
	wire [7:0] vpu_dout;
	wire vpu_irq;
	vpu vpu1 (
		.clk(E),
		.rst(sys_res),
		.AD(ADDR[3:0]),
		.DI(DATA),
		.DO(vpu_dout),
		.rw(RW),
		.cs(vpu_cs),
		.irq(vpu_irq),
		.pixel_clk(pixel_clk),
		.tvout(TVOUT)
	);
	
	wire simpleio_cs = DS5 && (ADDR[4] == 1'b0); // $E6A0
	wire [7:0] simpleio_dout;
	wire simpleio_irq;
	simpleio simpleio1 (
		.clk(E),
		.rst(sys_res),
		.AD(ADDR[3:0]),
		.DI(DATA),
		.DO(simpleio_dout),
		.rw(RW),
		.cs(simpleio_cs),
		.irq(simpleio_irq),
		.clk_in(pclk),
		.leds(leds),
		.led7hi(seg_led_h[7:0]),
		.led7lo(seg_led_l[7:0]),
		.rgb1(rgb1),
		.rgb2(rgb2),
		.switches(switches),
		.keys(keys)
	);
	
	wire psg_cs = DS5 && (ADDR[4] == 1'b1); // $E6B0
	wire [7:0] psg_dout;
	wire [7:0] PSGAOut;
	
	wire psg_bdir = psg_cs && !RW;
	wire psg_bc1 = psg_cs && ADDR[0];
	YM2149 psg1 (
		.I_DA(DATA),
		.O_DA(psg_dout),
		.I_A9_L(1'b0),
		.I_A8(1'b1),
		.I_BDIR(psg_bdir),
		.I_BC2(1'b1),
		.I_BC1(psg_bc1),
		.I_SEL_L(1'b1),
		.O_AUDIO(PSGAOut),
		.ENA(1'b1),
		.RESET_L(~sys_res),
		.CLK(E)
	);
	
	sigma_delta_dac dac1(
		.DACout(PWM),
		.DACin(PSGAOut),
		.CLK(audio_clk),
		.RESET(sys_res)
	);
	wire spiio_cs = DS6 && (ADDR[4:3] == 2'b00); // $E6C0
	wire [7:0] spiio_dout;
	spiio spi_impl(
		.clk(E),
		.rst(sys_res),
		.AD(ADDR[2:0]),
		.DI(DATA),
		.DO(spiio_dout),
		.rw(RW),
		.cs(spiio_cs),
		
		.clk_in(E),
		
		.mosi(MOSI),
		.msck(MSCK),
		.miso(MISO),
		.mss(NSS),
		.pout({BLANK, RS})
	);

	wire ps2io_cs = DS6 && (ADDR[4:3] == 2'b10); // $E6D0
	wire [7:0] ps2io_dout;
	wire ps2io_irq;
	ps2io ps2io_impl(
		.clk(E),
		.rst(sys_res),
		.AD(ADDR[2:0]),
		.DI(DATA),
		.DO(ps2io_dout),
		.rw(RW),
		.cs(ps2io_cs),
		.irq(ps2io_irq),
		.ps2clk(PS2CLK),
		.ps2dat(PS2DAT)
	);

	wire [7:0] DOUT = simpleio_cs ? simpleio_dout	:
					  psg_cs	  ? psg_dout 		:
					  spiio_cs	  ? spiio_dout		:
					  ps2io_cs	  ? ps2io_dout		:
					  vpu_cs	  ? vpu_dout		:
					  8'b10100101;
	
	assign DATA = (RW & !EXTCS) ? DOUT : 8'bZZZZZZZZ;
	
	assign IRQ[0] = !(simpleio_irq | vpu_irq | ps2io_irq);
	assign IRQ[1] = 1;
	assign NMI = 1;
endmodule
