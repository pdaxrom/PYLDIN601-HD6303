/*
	PS2 devices:
	$00 RW - Keyboard data
	$01 RW - IRQ|IEN|XXX|WRE|WRY|RDY|EXT|RLS  Keyboard config/status
	
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
	wire		key_released;
	wire		key_extended;
	wire		key_ready;
	reg			key_read;
	reg			key_ien;
	reg			key_irq;
	wire [7:0]	key_scancode;
	reg  [7:0]	key_data_in;
	reg			key_write;
	wire		key_write_ready;
	wire		key_write_error;
	
	assign irq = key_irq;

	always @ (posedge clk) begin
		if (rst) begin
			key_irq <= 0;
			key_read <= 0;
		end else if (cs && rw) begin
			case (AD[2:0])
			3'b000: begin
					DO <= key_scancode;
					key_read <= 1;
				end
			3'b001: begin
					DO <= {key_irq, key_ien, key_write, key_write_error, key_write_ready, key_ready, key_extended, key_released};
					key_irq <= 0;
				end
			endcase
		end else begin
			if (key_ien && key_ready) key_irq <= 1;
			key_read <= 0;
		end
	end

	always @(negedge clk) begin
		if (rst) begin
			key_ien <= 0;
			key_write <= 0;
		end else if (cs && !rw) begin
			case (AD[2:0])
			3'b000: begin
					key_data_in <= DI;
					key_write <= 1;
				end
			3'b001: key_ien <= DI[6];
			endcase
		end else begin
			if (key_write_ready) key_write <= 0;
		end
	end

	ps2_keyboard_interface ps2interface1(
		.clk(clk),
		.reset(rst),
		.ps2_clk(ps2clk),
		.ps2_data(ps2dat),
		.rx_extended(key_extended),
		.rx_released(key_released),
		.rx_scan_code(key_scancode),
		.rx_data_ready(key_ready),
		.rx_read(key_read),
		.tx_data(key_data_in),
		.tx_write(key_write),
		.tx_write_ack_o(key_write_ready),
		.tx_error_no_keyboard_ack(key_write_error)
	);

endmodule
