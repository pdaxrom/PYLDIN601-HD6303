/*
	PS2 devices:
	$00 RW - Keyboard data
	$01 RW - IRQ|IEN|RDY|BSY|TOU| E1| E0|REL  Keyboard config/status
	
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
	output	reg	resreq,
	
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
	reg			key_release;
	reg			key_e0;
	reg			key_e1;
	
	reg	[2:0]	res_state;

	assign irq = key_irq;
 
	always @ (posedge clk) begin //posedge istrobe or posedge rst or posedge key_ready_f) begin
		if (rst) begin
			key_ready <= 0;
			key_release <= 0;
			key_e0 <= 0;
			key_e1 <= 0;

			res_state <= 0;
			resreq <= 0;
		end else if (istrobe) begin
			key_code <= ibyte;
			key_ready <= 1;
			
			if (ibyte == 8'hF0) begin				key_release <= 1;
			end
			
			if (ibyte == 8'hE0) begin
				key_e0 <= 1;
			end
			
			if (ibyte == 8'hE1) begin
				key_e1 <= 1;
			end

			if (ibyte == 8'h14 && res_state == 3'b000) res_state <= 3'b001;
			else if (ibyte == 8'h11 && res_state == 3'b001) res_state <= 3'b010;
			else if (ibyte == 8'hE0 && res_state == 3'b010) res_state <= 3'b011;
			else if (ibyte == 8'h11 && res_state == 3'b011) res_state <= 3'b100;
			else if (ibyte == 8'hE0 && res_state == 3'b100) res_state <= 3'b101;
			else if (ibyte == 8'h71 && res_state == 3'b101) begin
				res_state <= 3'b110;
				resreq <= 1;
			end else res_state <= 0;
		end else if (key_ready_f) begin
			key_ready <= 0;
			if (key_code != 8'hF0) begin
				key_release <= 0;
				if (key_code != 8'hE0) begin
					key_e0 <= 0;
				end
				if (key_code != 8'hE1) begin
					key_e1 <= 0;
				end
			end
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
					DO <= {key_irq, key_ien, key_ready, key_busy, timeout, key_e1, key_e0, key_release};
					key_irq <= 0;
				end
			endcase
		end else begin
			if (key_ien && key_ready &&
				(key_code != 8'b11110000) &&
				(key_code[7:1] != 7'b1110000)
				) key_irq <= 1;
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
