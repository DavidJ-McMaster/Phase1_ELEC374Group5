module con_ff(
	input [31:0] irInput,
	input [31:0] BusMuxOut,
	input CONin,
	output reg conOut);
	
	wire zero_check;
	reg eql, neql, gte, lt;
	reg value;
	// bitwise OR of all bits
	assign zero_check = ~(|BusMuxOut);
	
	always @(*) begin
	// reset before checking ir bits
		eql = 1'b0; neql = 1'b0; gte = 1'b0; lt = 1'b0;
		case(irInput[20:19])
			2'b00 : eql = 1'b1 & zero_check;
			2'b01	: neql = 1'b1 & ~(zero_check);
			2'b10 : gte = 1'b1 & ~(BusMuxOut[31]);
			2'b11 : lt = 1'b1 & (BusMuxOut[31]);
		endcase 
	
	end
	
	always @(*) begin
		if (CONin == 1) 
		begin
		conOut = eql | neql | gte | lt;
		end
	end
	
endmodule 