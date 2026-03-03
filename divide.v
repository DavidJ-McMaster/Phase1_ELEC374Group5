module divide(
	input wire signed [31:0] Q_in, //Dividend going in
	input wire signed [31:0] M_in, //Divisor going in
	output reg signed [63:0] result,
	output reg complete //checks if the division was completed
	);
	
reg signed [31:0] A; //Accumulator
reg signed [31:0] current_Q, current_M;

integer k; //amount of shifts have occured 6 bits for 32
reg negQ, negA;


always @(*)
	begin
		result 	   = 64'sd0;
		complete    = 1'b0;
		
		if(M_in == 32'sd0)
			begin
				result = 64'sd0;
				complete = 1'b1;
			end
			
			else
				begin
					negQ = Q_in[31] ^ M_in[31];
					negA = Q_in[31];
					
					current_Q = Q_in[31] ? (~Q_in + 32'sd1) : Q_in; //checks if Q_in 32nd bit = negative 1, convert to positive using two's compliment
					current_M = M_in[31] ? (~M_in + 32'sd1) : M_in;
					
					A = 32'sd0;
					
					
					for(k = 0; k < 32; k = k +1)
						begin
							A			 = {A[30:0], current_Q[31]};
							current_Q = {current_Q[30:0], 1'b0};
							
							A 			 =  A - current_M;
							
							if (A < 0)
								begin
									A = A + current_M;
									current_Q[0] = 1'b0;
								end
								
							else
								begin
									current_Q[0] = 1'b1;
								end
						end
								
						
					if(negQ)
						current_Q = ~current_Q + 32'sd1;
					if(negA)
						A 			 = ~A + 32'sd1;
							
					result 		 = {A, current_Q}; // {remainder, quotient}
					complete 	 = 1'b1;
					
				end
		end
					
					
endmodule
