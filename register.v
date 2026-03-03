module register #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 32'b0)(
	
	input clear, clock, enable,
	input wire [DATA_WIDTH_IN-1:0]BusMuxOut,
	output reg [DATA_WIDTH_OUT-1:0]BusMuxIn
);


always @ (posedge clock or posedge clear)
	begin
		if(clear)
			begin
				BusMuxIn<= INIT;
			end
		else if (enable)
			begin
				BusMuxIn<=BusMuxOut[DATA_WIDTH_IN-1:0];
			end
	end
endmodule