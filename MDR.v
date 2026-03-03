module MDR #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 32'b0)(
	input wire 								clear, clock, MDRin, read,
	input wire [DATA_WIDTH_IN-1:0]	BusMuxOut,
	input wire [DATA_WIDTH_IN-1:0]	Mdatain,
	output wire [DATA_WIDTH_OUT-1:0]	BusMuxInMDR
);
wire [DATA_WIDTH_IN-1:0]MDMux = read ? Mdatain : BusMuxOut; //holds the output from the Mux from the diagram, if read = 0, BusMuxOut, if = 1 Mdatain
reg[DATA_WIDTH_IN-1:0]MDR_register; //holds the value from the MDR


always @(posedge clock or posedge clear)
	begin
		if(clear)
			MDR_register <= INIT;
		else if(MDRin)
			MDR_register <= MDMux;
	end
	
	assign BusMuxInMDR = MDR_register[DATA_WIDTH_OUT-1:0];
	
endmodule
