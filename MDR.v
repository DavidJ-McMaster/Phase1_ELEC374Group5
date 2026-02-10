module MDR #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 32'b0)(
	input wire clear, clock, MDRin, read,
	input wire [DATA_WIDTH_IN-1:0]BusMuxOut, Mdatain,
	output wire [DATA_WIDTH_IN-1:0]BusMuxInMDR
);
reg[DATA_WIDTH_IN-1:0]MDMux; //holds the output from the Mux from the diagram
reg[DATA_WIDTH_IN-1:0]MDR_register; //holds the value from the MDR

always @(*)
	begin	
		case(read)
			1'b0: MDMux = BusMuxOut;
			1'b1: MDMux = Mdatain;
			default: MDMux = 32'b0;
		endcase
	end
	
always @(posedge clock or posedge clear)
	begin
		if(clear)
			MDR_register <= INIT;
		else if(MDRin)
			MDR_register <= MDMux;
	end
	assign BusMuxInMDR = MDR_register;
endmodule
