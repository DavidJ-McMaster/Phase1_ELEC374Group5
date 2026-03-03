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
				24'h800000: select = 5'd0;   // R0out
            24'h400000: select = 5'd1;   // R1out
            24'h200000: select = 5'd2;   // R2out
            24'h100000: select = 5'd3;   // R3out
            24'h080000: select = 5'd4;   // R4out
            24'h040000: select = 5'd5;   // R5out
            24'h020000: select = 5'd6;   // R6out
            24'h010000: select = 5'd7;   // R7out
            24'h008000: select = 5'd8;   // R8out
            24'h004000: select = 5'd9;   // R9out
            24'h002000: select = 5'd10;  // R10out
            24'h001000: select = 5'd11;  // R11out
            24'h000800: select = 5'd12;  // R12out
            24'h000400: select = 5'd13;  // R13out
            24'h000200: select = 5'd14;  // R14out
            24'h000100: select = 5'd15;  // R15out
            24'h000080: select = 5'd16;  // HIout
            24'h000040: select = 5'd17;  // LOout
            24'h000020: select = 5'd18;  // Zhighout
            24'h000010: select = 5'd19;  // Zlowout
            24'h000008: select = 5'd20;  // PCout
            24'h000004: select = 5'd21;  // MDRout
            24'h000002: select = 5'd22;  // InPortOut
            24'h000001: select = 5'd23;  // Cout (C sign-extended)
            default:    select = 5'd31;   // safe default (NONE)
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
			default: result = 32'd0; // Default = NONE
		endcase
	end
	
	assign BusMuxOut = result;
	
endmodule
			