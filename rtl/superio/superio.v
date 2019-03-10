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
	reg	[19:0]	sys_res_delay;

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

	reg	[2:0]	clkdiv;
	always @ (posedge pixel_clk) clkdiv <= clkdiv + 1;
	wire clk2m = clkdiv[1];

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

/*
 **************************** IRQ and DMA control ****************************
 * 0 - 16 BITS IRQ ROUTER
 * ------+-------+-------+-------+-------+-------+-------+------
 * 15 14 | 13 12 | 11 10 | 09 08 | 07 06 | 05 04 | 03 02 | 01 00
 * ------+-------+-------+-------+-------+-------+-------+------
 * IRQS7 | IRQS6 | IRQS5 | IRQS4 | IRQS3 | IRQS2 | IRQS1 | IRQS0
 *
 * IRQSX - 00 - IRQ0 (by default)
 *         01 - IRQ1
 *         10 - NMI
 *         11 - RESET
 */

	wire pctrl_cs = DS7 && (ADDR[4:1] == 4'b1111); // $E6FE
	reg [7:0]  pctrl_dout;
	reg [15:0] pctrl_dat;
	
	always@(posedge E) begin
		if (pctrl_cs && RW) begin
			if (ADDR[0]) pctrl_dout <= pctrl_dat[7:0];
			else pctrl_dout <= pctrl_dat[15:8];
		end
	end
	
	always@(negedge E) begin
		if (sys_res) pctrl_dat <= 0;
		else if (pctrl_cs && !RW) begin
			if (ADDR[0]) pctrl_dat[7:0] <= DATA;
			else pctrl_dat[15:8] <= DATA;
		end
	end

/*
 *****************************************************************************
 */

	wire vpu_cs = DS0 && (ADDR[4] == 1'b1); // $E610
	wire [7:0] vpu_dout;
	wire vpu_irq;
	wire [3:0] vpu_isel = (pctrl_dat[1:0] == 2'b00) ? 4'b0001 :
						  (pctrl_dat[1:0] == 2'b01) ? 4'b0010 :
						  (pctrl_dat[1:0] == 2'b10) ? 4'b0100 :
						                              4'b1000;
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
	wire [3:0] simpleio_isel = (pctrl_dat[11:10] == 2'b00) ? 4'b0001 :
						       (pctrl_dat[11:10] == 2'b01) ? 4'b0010 :
						       (pctrl_dat[11:10] == 2'b10) ? 4'b0100 :
						                                     4'b1000;
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
		.CLK(clk2m)
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
	wire [3:0] ps2io_isel = (pctrl_dat[13:12] == 2'b00) ? 4'b0001 :
							(pctrl_dat[13:12] == 2'b01) ? 4'b0010 :
							(pctrl_dat[13:12] == 2'b10) ? 4'b0100 :
						                                  4'b1000;
	wire		ps2resreq;
	ps2io ps2io_impl(
		.clk(E),
		.rst(sys_res),
		.AD(ADDR[2:0]),
		.DI(DATA),
		.DO(ps2io_dout),
		.rw(RW),
		.cs(ps2io_cs),
		.irq(ps2io_irq),
		.resreq(ps2resreq),
		.ps2clk(PS2CLK),
		.ps2dat(PS2DAT)
	);

	wire [7:0] DOUT = simpleio_cs ? simpleio_dout	:
					  psg_cs	  ? psg_dout 		:
					  spiio_cs	  ? spiio_dout		:
					  ps2io_cs	  ? ps2io_dout		:
					  vpu_cs	  ? vpu_dout		:
					  pctrl_cs    ? pctrl_dout      :
					  8'b10100101;
	
	assign DATA = (RW & !EXTCS) ? DOUT : 8'bZZZZZZZZ;
	assign IRQ[0] = !((simpleio_irq & simpleio_isel[0]) | (vpu_irq & vpu_isel[0]) | (ps2io_irq & ps2io_isel[0]));
	assign IRQ[1] = !((simpleio_irq & simpleio_isel[1]) | (vpu_irq & vpu_isel[1]) | (ps2io_irq & ps2io_isel[1]));	assign NMI    = !((simpleio_irq & simpleio_isel[2]) | (vpu_irq & vpu_isel[2]) | (ps2io_irq & ps2io_isel[2]));
	wire softres = (simpleio_irq & simpleio_isel[3]) | (vpu_irq & vpu_isel[3]) | (ps2io_irq & ps2io_isel[3]);

	wire		resreq = softres | ps2resreq;

	always @ (posedge E or posedge resreq)
	begin
		if (resreq) begin
			sys_res <= 1;
			sys_res_delay <= 0;
		end else begin
			if (sys_res_delay[17]) begin
				sys_res <= 0;
			end else sys_res_delay <= sys_res_delay + 1;
		end
	end

	assign RESET = !sys_res;

endmodule
