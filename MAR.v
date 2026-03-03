module MAR #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 32'b0)(
	//phase 2
	input wire 								clear, clock, MARin,
	input wire [DATA_WIDTH_IN-1:0]	BusMuxOut,
	output wire [DATA_WIDTH_IN-1:0]	MARout
);
reg[DATA_WIDTH_IN-1:0]MAR_register; //holds the value from the MARin


always @(posedge clock or posedge clear)
	begin
		if(clear)
			MAR_register <= INIT;
		else if(MARin)
			MAR_register <= BusMuxOut;
	end
	
	assign MARout = MAR_register;
	
endmodule
