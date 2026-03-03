module multiply(
	//Using Booth Multiplication
	
	input  wire  signed[31:0] M, //Multiplicand
	input  wire  signed[31:0] Q, // Multiplier
	output wire signed[63:0] P // Product
);

reg signed [31:0] A; //accumulation
reg signed [31:0] Q_register;
reg Q_Prev; // extra bit for pairwise checking (previous bit)
integer i; 

always @(*) 
	begin
		//initialize registers
		A = 32'sd0;
		Q_register = Q;
		Q_Prev = 1'b0; 
		
		for(i=0; i<32; i=i+1)
			begin
				case({Q_register[0], Q_Prev})
				
					2'b01: A = A + M;
					2'b10: A = A - M;
					default: ;
						
				endcase
				{A, Q_register, Q_Prev} = $signed({A,Q_register, Q_Prev}) >>> 1 ; 
			end
	end
	
	assign P = {A, Q_register}; //Outputs product
	
endmodule	
	