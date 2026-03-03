module RAM (
	input 	wire 				clk, 
	input 	wire 				read, 
	input 	wire 				write, 
	input 	wire [31:0] 	datain, 
	input 	wire [8:0] 		address, 
	output 	reg [31:0] 	dataout
	);


reg [31:0] memory[0:511];

always @ (posedge clk)
	begin
		if (write)
			memory[address] <= datain;
	end
always @(*)
	begin
		if (read)
			dataout <= memory[address];
	end
	
endmodule
