/*
	PS2 devices:
	$00 RW - Keyboard data
	$01 RW - IRQ|IEN|RDY|BSY|TOU|XXX|XXX|XXX  Keyboard config/status
	
 */
 
module ps2io (
	input wire	clk,
	input wire	rst,
	input wire	[2:0] AD,
	input wire	[7:0] DI,
	output reg	[7:0] DO,
	input wire	rw,
	input wire	cs,
	output wire	irq,
	
	inout		ps2clk,
	inout		ps2dat
);
	wire		istrobe;
	wire [7:0]	ibyte;
	reg			oreq;
	reg [7:0]	obyte;
	wire		oack;
	wire		timeout;

	reg			key_irq;
	reg			key_ien;
	reg			key_ready;
	reg			key_ready_f;
	reg [7:0]	key_code;
	reg			key_busy;

	assign irq = key_irq;

	always @ (posedge clk) begin //posedge istrobe or posedge rst or posedge key_ready_f) begin
		if (rst) begin
			key_ready <= 0;
		end else if (istrobe) begin
			key_code <= ibyte;
			key_ready <= 1;
		end else if (key_ready_f) begin
			key_ready <= 0;
		end
	end

	always @ (posedge clk) begin
		if (rst) begin
			key_irq <= 0;
			key_ready_f <= 0;
		end else if (cs && rw) begin
			case (AD[2:0])
			3'b000: begin
					DO <= key_code;
					key_ready_f <= 1;
				end
			3'b001: begin
					DO <= {key_irq, key_ien, key_ready, key_busy, timeout, 1'b0, 1'b0, 1'b0};
					key_irq <= 0;
				end
			endcase
		end else begin
			if (key_ien && key_ready) key_irq <= 1;
			if (!key_ready) key_ready_f <= 0;
		end
	end

	reg			write_f;

	always @(posedge clk or posedge rst or posedge write_f or posedge oack) begin
		if (rst) begin
			oreq <= 0;
			key_busy <= 0;
		end else if (write_f) begin
			oreq <= 1;
			key_busy <= 1;
		end else if (oack) key_busy <= 0;
		else oreq <= 0;
	end

	always @(negedge clk) begin
		if (rst) begin
			key_ien <= 0;
			write_f <= 0;
		end else if (cs && !rw) begin
			case (AD[2:0])
			3'b000: begin
					obyte <= DI;
					write_f <= 1;
				end
			3'b001: key_ien <= DI[6];
			endcase
		end else begin
			write_f <= 0;
		end
	end

	ps2 ps2keyboard(
		.sysclk(clk),
		.reset(rst),
		.ps2dat(ps2dat),
		.ps2clk(ps2clk),
		.istrobe(istrobe),
		.ibyte(ibyte),
		.oreq(oreq),
		.obyte(obyte),
		.oack(oack),
		.timeout(timeout)
	);
endmodule
