module Bus(
	output wire [31:0] BusMuxOut,
	
	//32:1 Multiplexer
	input [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, BusMuxInR4, BusMuxInR5,
	input [31:0] BusMuxInR6, BusMuxInR7, BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11, 
	input [31:0] BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15,
	input [31:0] BusMuxInHI, BusMuxInLO, BusMuxInZhigh, BusMuxInZlow, BusMuxInPC, BusMuxInMDR,
	input [31:0] BusMuxIninport, BusMuxIncSignExtended,
	
	//32:5 Encoder					
	input R0out, R1out, R2out, R3out, R4out, R5out, R6out, 
	input R7out, R8out, R9out, R10out, R11out,
	input	R12out, R13out, R14out, R15out, HIout, LOout, 
	input	Zhighout, Zlowout, PCout, MDRout, InPortOut, Cout
);

reg[31:0] 	result;
reg[4:0] 	select;
reg[23:0] 	state_sel;

always @(*) 
	begin
		state_sel = {R0out, R1out, R2out, R3out, R4out, R5out, 
						R6out, R7out, R8out, R9out, R10out, R11out,
						R12out, R13out, R14out, R15out, HIout, 
						LOout, Zhighout, Zlowout, PCout, MDRout, 
						InPortOut, Cout};
					
			case(state_sel)
				32'h00000001: select = 5'd23;
				32'h00000002: select = 5'd22;
				32'h00000004: select = 5'd21;
				32'h00000008: select = 5'd20;
				32'h00000010: select = 5'd19;
				32'h00000020: select = 5'd18;
				32'h00000040: select = 5'd17;
				32'h00000080: select = 5'd16;
				32'h00000100: select = 5'd15;
				32'h00000200: select = 5'd14;
				32'h00000400: select = 5'd13;
				32'h00000800: select = 5'd12;
				32'h00001000: select = 5'd11;
				32'h00002000: select = 5'd10;
				32'h00004000: select = 5'd9;
				32'h00008000: select = 5'd8;
				32'h00010000: select = 5'd7;
				32'h00020000: select = 5'd6;
				32'h00040000: select = 5'd5;
				32'h00080000: select = 5'd4;
				32'h00100000: select = 5'd3;
				32'h00200000: select = 5'd2;
				32'h00400000: select = 5'd1;
				32'h00800000: select = 5'd0;
			endcase
	end
	
always @(*) 
	begin
		case(select)
			5'd0: result = BusMuxInR0;
			5'd1: result = BusMuxInR1;
			5'd2: result = BusMuxInR2;
			5'd3: result = BusMuxInR3;
			5'd4: result = BusMuxInR4;
			5'd5: result = BusMuxInR5;
			5'd6: result = BusMuxInR6;
			5'd7: result = BusMuxInR7;
			5'd8: result = BusMuxInR8;
			5'd9: result = BusMuxInR9;
			5'd10: result = BusMuxInR10;
			5'd11: result = BusMuxInR11;
			5'd12: result = BusMuxInR12;
			5'd13: result = BusMuxInR13;
			5'd14: result = BusMuxInR14;
			5'd15: result = BusMuxInR15;
			5'd16: result = BusMuxInHI;
			5'd17: result = BusMuxInLO;
			5'd18: result = BusMuxInZhigh;
			5'd19: result = BusMuxInZlow;
			5'd20: result = BusMuxInPC;
			5'd21: result = BusMuxInMDR;
			5'd22: result = BusMuxIninport;
			5'd23: result = BusMuxIncSignExtended;
		endcase
	end
assign BusMuxOut = result;
endmodule
			