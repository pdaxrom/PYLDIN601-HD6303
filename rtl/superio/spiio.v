/*
	SD card interface
	
	$0    RW - DATA HIGH BYTE
	$1    RW - DATA LOW BYTE
	$2    RW - RDY|XXX|SSM|16B|XXX|XXX|SS1|SS0
	$3    RW - PRESCALER
	$4    RW - XXX|XXX|XXX|XXX|XXX|XXX|BLN|RS
	RDY - R- - IO ready
	SSM - RW - SS0 manual control
	16B - RW - 16 bit mode
	SS0 - RW - select SPI device 0
	SS1 - RW - select SPI device 1
*/
module spiio (
	input wire clk,
	input wire rst,
	input wire [2:0] AD,
	input wire [7:0] DI,
	output reg [7:0] DO,
	input wire rw,
	input wire cs,
//	output wire irq,

	input wire clk_in,

	output wire mosi,
	output reg msck,
	input wire miso,
	output wire [1:0] mss,
	
	output wire [1:0] pout
);
	reg cfg_ssm;
	reg cfg_16b;
	reg [1:0] cfg_ss;
	reg [1:0] int_mss;

	reg [15:0] rx_data;
	reg [15:0] tx_data;
	reg [7:0] prescaler;

	reg [1:0] reg_out;

	wire start;
	reg  start_hi;
	reg  start_lo;
	
	reg [15:0] shifted_tx_data;
	reg [4:0] bit_counter;
	reg [7:0] scale_counter;
	assign pout = reg_out;

	wire data_ready = ((bit_counter == 0) && (!msck))?1'b1:1'b0;

	always @ (posedge clk) begin
		if (!rst && cs && rw) begin
			case (AD[2:0])
			3'b000: DO <= rx_data[15:8];
			3'b001: DO <= rx_data[7:0];
			3'b010: DO <= {data_ready, 1'b0, cfg_ssm, cfg_16b, 1'b0, 1'b0, cfg_ss};
			3'b011: DO <= prescaler;
			3'b100: DO <= { 6'b0, reg_out };
			endcase
		end
	end

	always @ (negedge clk) begin
		if (rst) begin
			cfg_ssm <= 0;
			cfg_16b <= 0;
			cfg_ss <= 2'b11;
			tx_data <= 16'b1111111111111111;
			prescaler <= 0;
			start_hi <= 0;
			start_lo <= 0;
			reg_out <= 0;
		end else begin
			if (cs && !rw) begin
					case (AD[2:0])
					3'b000: begin
							tx_data[15:8] <= DI;
							start_hi <= 1'b1;
						end
					3'b001: begin
							tx_data[7:0] <= DI;
							start_lo <= 1'b1;
						end
					3'b010: begin
							cfg_ssm <= DI[5];
							cfg_16b <= DI[4];
							cfg_ss <= DI[1:0];
						end
					3'b011: prescaler <= DI;
					3'b100: reg_out <= DI[1:0];
					endcase
			end else begin
				if (!data_ready) begin
					start_hi <= 1'b0;
					start_lo <= 1'b0;
				end
			end
		end
	end

	assign start = (cfg_16b ? start_hi : 1'b1) & start_lo;

	assign mss = cfg_ssm ? cfg_ss : int_mss;

	assign mosi = ((bit_counter == 0) && (!msck)) ? 1'b1 :
					cfg_16b ? shifted_tx_data[15] :
					shifted_tx_data[7];

	always @ (posedge clk_in) begin
		if (rst) begin
			msck <= 0;
			int_mss <= 2'b11;
			rx_data <= 16'b1111111111111111;
			scale_counter <= 0;
		end else if (start) begin
			shifted_tx_data <= tx_data;
			bit_counter <= cfg_16b ? 16 : 8;
			int_mss <= cfg_ss;
		end else begin
			if (bit_counter != 0) begin
				if (scale_counter == prescaler) begin
					scale_counter <= 0;
					msck <= ~msck;
					if (msck) begin
//						shifted_tx_data <= cfg_16b ? {shifted_tx_data[14:0], 1'b1} : {shifted_tx_data[6:0], 1'b1};
//						rx_data <= cfg_16b ? {rx_data[14:0], miso} : {rx_data[6:0], miso};
						shifted_tx_data <= {shifted_tx_data[14:0], 1'b1};
						rx_data <= {rx_data[14:0], miso};
						bit_counter <= bit_counter - 1'b1;
					end
				end else scale_counter <= scale_counter + 1'b1;
			end else begin
				msck <= 0;
				int_mss <= 2'b11;
			end
		end
	end

endmodule
