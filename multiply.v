module multiply(
	//Using Booth Multiplication
	
	input wire [31:0] M, //Multiplicand
	input wire [31:0] Q, // Multiplier
	output wire [63:0] P // Product
);

reg [31:0] A; //accumulation
reg[31:0] Q_register;
reg Q_Prev; // extra bit for pairwise checking (previous bit)
integer i; 

always @(*) 
	begin
		//initialize registers
		A = 32'b0;
		Q_register = Q;
		Q_Prev = 1'b0; 
		
		for(i=0; i<32; i=i+1)
			begin
				case({Q_register[0], Q_Prev})
					2'b00, 2'b11: //checking if it goes from 0 -> 0 or 1->1 which means nothing happens
						begin
							{A, Q_register, Q_Prev} = {A[31], A, Q_register}; //right shift
						end
					2'b01:
						begin
							A = A + M;
							{A, Q_register, Q_Prev} = {A[31], A, Q_register};
						end
					2'b10:
						begin
							A = A-M;
							{A, Q_register, Q_Prev} = {A[31], A, Q_register};
						end
				endcase
			end
	end
	
	assign P = {A, Q_register}; //Outputs product
	
endmodule	
	