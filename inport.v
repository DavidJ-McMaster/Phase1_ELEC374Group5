module inport(
	input clr, clk, strobe,
	input[31:0] InputIn,
	output [31:0] inport_out);

reg [31:0] temp;
	
always @(posedge clk)
begin
	if (clr)
		temp = 32'h00000000;
	else if (strobe)
		temp = InputIn;
end

assign inport_out = temp;
 
endmodule
