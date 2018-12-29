/*
	$0 - RW Data MSB
	$1 - RW Address MSB
	$2 - RW Address LSB
	$3 - RW IRQ|IEN|VBL|XXX|GRF|CUR|I/D|AUT
	$4 - RW AutoOffset
	$5 - RW Start address MSB
	$6 - RW Start address LSB
	$7 - RW HS Offset
	$8 - RW VS Offset
	$9 - RW HSize (in chars)
	$A - RW VSize (in lines)
	$B - RW HCursor
	$C - RW VCursor
	$D - RW TTT|TTT|TTT|TTT|LLL|LLL|LLL|LLL
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
	reg			VIRQ;
	reg			VBLTrigger;
	reg			IEN;
	reg			GRF;
	reg			CUR;
	reg			ID;
	reg			AUT;

	reg			IncFlagR;
	reg			IncFlagW;
	reg			WriteOkay;

	assign irq = VIRQ;

	wire		VAData_En = (AD == 4'b0000) && cs;

	assign DO = VAData_En ? VRamDO : DO_REG;

	reg	[12:0]	VAddrStart;
	reg	[7:0]	HSOffset;
	reg	[7:0]	VSOffset;
	reg [7:0]	HSize;
	reg	[7:0]	VSize;

	always @ (posedge clk) begin
		if (rst) begin
			IncFlagR <= 0;
			WriteOkay <= 0;
			VBLTrigger <= 0;
			VIRQ <= 0;
		end else if (cs && rw) begin
			case (AD[3:0])
			4'b0000: IncFlagR <= 1;
			4'b0001: DO_REG <= {3'b000, VAddr[12:8]};
			4'b0010: DO_REG <= VAddr[7:0];
			4'b0011: begin
				DO_REG <= {VIRQ, IEN, vbl, 1'b0, GRF, CUR, ID, AUT};
				VIRQ <= 0;
				end
			4'b0100: DO_REG <= AutoOffset;
			4'b0101: DO_REG <= {3'b000, VAddrStart[12:8]};
			4'b0110: DO_REG <= VAddrStart[7:0];
			4'b0111: DO_REG <= HSOffset;
			4'b1000: DO_REG <= VSOffset;
			4'b1001: DO_REG <= HSize;
			4'b1010: DO_REG <= VSize;
			endcase
		end else if (vbl && !VBLTrigger) begin
			VBLTrigger <= 1;
			VIRQ <= IEN;
		end else if (!vbl) VBLTrigger <= 0;
		
		if (IncFlagR) IncFlagR <= 0;

		if (IncFlagW) WriteOkay <= 1;
		else WriteOkay <= 0;
	end
	
	always @ (negedge clk) begin
		if (rst) begin
			VAddr <= 0;
			IEN <= 0;
			GRF <= 0;
			CUR <= 0;
			ID <= 0;
			AUT <= 1;
			AutoOffset <= 1;
			VAddrStart <= 0;
			HSOffset <= 96;
			VSOffset <= 50;
			HSize <= 39;
			VSize <= 199;
			IncFlagW <= 0;
		end else if (cs && !rw) begin
			case (AD[3:0])
			4'b0000: begin
				VRamDI <= DI;
				IncFlagW <= 1;
				end
			4'b0001: VAddr[12:8] <= DI[4:0];
			4'b0010: VAddr[7:0] <= DI;
			4'b0011: {IEN, GRF, CUR, ID, AUT} <= {DI[6],DI[3:0]};
			4'b0100: AutoOffset <= DI;
			4'b0101: VAddrStart[12:8] <= DI[4:0];
			4'b0110: VAddrStart[7:0] <= DI;
			4'b0111: HSOffset <= DI;
			4'b1000: VSOffset <= DI;
			4'b1001: HSize <= DI;
			4'b1010: VSize <= DI;
			endcase
		end

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
	reg [12:0] VAddrOutTemp;
	
	wire TVOutEnable = (cntHS >= HSOffset) && (cntHS <= (HSOffset + (HSize << 3) + 7)) &&
					   (cntVS >= VSOffset) && (cntVS <= (VSOffset + VSize));
	
	always @ (posedge pixel_clk) begin
		if (vbl) begin
			VAddrOut <= VAddrStart;
			VAddrOutTemp <= VAddrStart;
			CharLine <= 3'b111;
		end else if (TVOutEnable) begin
			if (PixelCount == 0) begin
				ShiftReg <= GRF ? VRamData : VRomData;
				VAddrOut <= VAddrOut + 1'b1;
			end else begin
				ShiftReg <= ShiftReg << 1;
			end
			PixelCount <= PixelCount + 1'b1;
		end else begin
			if (!GRF && (cntVS >= VSOffset)) begin
				if (cntHS == 1) begin
					CharLine <= CharLine + 1'b1;
				end else if (cntHS == 511) begin
					if (CharLine == 3'b111) VAddrOutTemp <= VAddrOut;
					else VAddrOut <= VAddrOutTemp;
				end
			end
			PixelCount <= 0;
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
