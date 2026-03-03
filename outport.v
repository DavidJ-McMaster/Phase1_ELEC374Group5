module outport(
	input clr, clk, en,
	input[31:0] BusMuxOut,
	output [31:0] outport_out);

reg [31:0] temp;
	
always @(posedge clk)
begin
	if (clr)
		temp = 32'h00000000;
	else if (en)
		temp = BusMuxOut;
end

assign outport_out = temp;

endmodule
