/*
	$0 - RW Data MSB
	$1 - RW Data LSB
	$2 - RW Address MSB
	$3 - RW Address LSB
	$4 - RW IRQ|IEN|GRF|XXX|BLN|CUR|I/D|AUT
	$5 - RW AutoOffset
	$6 - RW Start address MSB
	$7 - RW Start address LSB
	$8 - RW Cursor address MSB
	$9 - RW Cursor address LSB
	$a - RW TTT|TTT|TTT|TTT|LLL|LLL|LLL|LLL
	$b - RW HS Offset
	$c - RW VS Offset
 */
module vpu (
	input wire clk,
	input wire rst,
	input wire [3:0] AD,
	input wire [7:0] DI,
	output wire [7:0] DO,
	input wire rw,
	input wire cs,
	output wire irq,
	input wire pixel_clk,
	
	output wire [1:0] tvout
);
	reg	[7:0]	DO_REG;
	reg [7:0]	VRamDI;
	wire [7:0]	VRamDO;
	
	reg	[12:0]	VAddr;
	reg	[7:0]	AutoOffset;
	reg			IEN;
	reg			GRF;
	reg			BLN;
	reg			CUR;
	reg			ID;
	reg			AUT;

	reg			IncFlagR;
	reg			IncFlagW;
	reg			ReadOkay;
	reg			WriteOkay;

	wire		VAData_En = ((AD == 4'b0000) || (AD == 4'b0001)) && cs;

	assign DO = VAData_En ? VRamDO : DO_REG;

	reg	[12:0]	VAddrStart;
	reg	[7:0]	HSOffset;
	reg	[7:0]	VSOffset;

	always @ (posedge clk) begin
		if (rst) begin
			IncFlagR <= 0;
			WriteOkay <= 0;
		end else if (cs && rw) begin
			case (AD[3:0])
			4'b0000: IncFlagR <= 1;
			4'b0001: IncFlagR <= 1;
			4'b0010: DO_REG <= {3'b000, VAddr[12:8]};
			4'b0011: DO_REG <= VAddr[7:0];
			4'b0100: DO_REG <= {1'b0, IEN, GRF, 1'b0, BLN, CUR, ID, AUT};
			4'b0101: DO_REG <= AutoOffset;
			4'b0110: DO_REG <= {3'b000, VAddrStart[12:8]};
			4'b0111: DO_REG <= VAddrStart[7:0];
			4'b1011: DO_REG <= HSOffset;
			4'b1100: DO_REG <= VSOffset;
			endcase
		end
		
		if (ReadOkay) IncFlagR <= 0;

		if (IncFlagW) WriteOkay <= 1;
		else WriteOkay <= 0;
	end
	
	always @ (negedge clk) begin
		if (rst) begin
			VAddr <= 0;
			IEN <= 0;
			GRF <= 0;
			BLN <= 0;
			CUR <= 0;
			ID <= 0;
			AUT <= 1;
			AutoOffset <= 1;
			VAddrStart <= 0;
			HSOffset <= 80;
			VSOffset <= 50;
			
			IncFlagW <= 0;
			ReadOkay <= 0;
		end else if (cs && !rw) begin
			case (AD[3:0])
			4'b0000: begin
				VRamDI <= DI;
				IncFlagW <= 1;
				end
			4'b0001: begin
				VRamDI <= DI;
				IncFlagW <= 1;
				end
			4'b0010: VAddr[12:8] <= DI[4:0];
			4'b0011: VAddr[7:0] <= DI;
			4'b0100: {IEN, GRF, BLN, CUR, ID, AUT} <= {DI[6:5],DI[3:0]};
			4'b0101: AutoOffset <= DI;
			4'b0110: VAddrStart[12:8] <= DI[4:0];
			4'b0111: VAddrStart[7:0] <= DI;
			4'b1011: HSOffset <= DI;
			4'b1100: VSOffset <= DI;
			endcase
		end

		if (IncFlagR) ReadOkay <= 1;
		else ReadOkay <= 0;

		if (IncFlagR || (IncFlagW && WriteOkay)) begin
			IncFlagW <= 0;
			if (AUT) begin
				if (ID) VAddr <= VAddr - AutoOffset;
				else  VAddr <= VAddr + AutoOffset;
			end
		end
	end

	reg [12:0] VAddrOut;

	reg [2:0] PixelCount;
	reg [7:0] ShiftReg;
	wire [7:0] VRamData;
	wire [7:0] VRomData;
	
	wire [8:0] cntHS;
	wire [8:0] cntVS;
	reg [2:0] CharLine;
	
	wire TVOutEnable = (cntHS >= HSOffset) && (cntHS <= HSOffset + 319) &&
					   (cntVS >= VSOffset) && (cntVS <= VSOffset + 199);
	
	always @ (posedge pixel_clk) begin
		if (vbl) begin
			VAddrOut <= VAddrStart;
			CharLine <= 3'b111;
		end else if (hsync) begin
			if ((cntHS == 1) && (cntVS >= VSOffset)) CharLine <= CharLine + 1'b1;
			PixelCount <= 0;
		end else if (TVOutEnable) begin
			if (PixelCount == 0) begin
				ShiftReg <= GRF ? VRamData : VRomData;
				//ShiftReg <= 8'b10101010;
				VAddrOut <= VAddrOut + 1'b1;
			end else begin
				ShiftReg <= ShiftReg << 1;
			end
			PixelCount <= PixelCount + 1'b1;
		end
	end

//	wire cursor_dis = ~(cfg_reg[1] && (cntVS >= cursor_sline) && (cntVS <= cursor_eline) && (cursor_pos == vcache_out_cnt));

	assign tvout[1] = (vbl || ~TVOutEnable) ? 1'b0:
					  ShiftReg[7];
//					  (cursor_dis) ? shift_reg[7]:
//					  (cfg_reg[0]) ? ~shift_reg[7]:
//					  1'b1;
	assign tvout[0] = out_sync;

	tvout tvout_impl (
		.pixel_clk(pixel_clk),
		.rst(rst),
		.cntHS(cntHS),
		.cntVS(cntVS),
		.vbl(vbl),
		.hsync(hsync),
		.out_sync(out_sync)
	);
	
	vram vram1(
		.DataInA(VRamDI),
		.AddressA(VAddr),
		.ClockA(clk),
		.ClockEnA(1'b1),
		.WrA(IncFlagW),
		.ResetA(rst),
		.QA(VRamDO),
		
		.DataInB(8'b00000000),
		.AddressB(VAddrOut),
		.ClockB(pixel_clk),
		.ClockEnB(1'b1),
		.WrB(1'b0),
		.ResetB(rst),
		.QB(VRamData)
	);
	
	vrom vrom1 (
		.Address({VRamData[6:0], VRamData[7], CharLine}),
		.OutClock(pixel_clk),
		.OutClockEn(1'b1),
		.Reset(rst),
		.Q(VRomData)
	);
	
endmodule
