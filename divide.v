module divide(
	input wire [31:0] Q_in, //Dividend going in
	input wire [31:0] M_in, //Divisor going in
	output reg [63:0] result,
	output reg complete //checks if the division was completed
	);
reg [31:0] A; //Accumulator
reg [31:0] Q; //Quotient
reg [31:0] M; //Divisor
reg [5:0] shift_count; //amount of shifts have occured 6 bits for 32
reg [31:0] current_Q, current_M;
integer i,j; //for the loops

always @(*)
	begin
		A= 32'b0; //empty A value to start
		Q=Q_in;
		M=M_in;
		shift_count = 6'd32;
		complete = 1'b0;
		i=0;
		j=0;
		
		if(M_in[31] ==1)
			begin
				current_M = ~M+1;
				i=1;
			end
			else
				current_M = M;
		if(Q_in[31]==1)
			begin
				current_Q = ~Q+1;
				j=1;
			end
			else
				current_Q = Q;
		while(shift_count>0)
			begin
				//left shift
				A={A[30:0],current_Q[31]};
				current_Q = {current_Q[30:0], 1'b0};
				
				//subtact the divisor
				A = A-current_M;
				
				if(A[31])
				//if result is negative, restore A and set least sig bit of Q to 0
					begin
						A = A+current_M;
						current_Q[0]=1'b0;
					end
					else
						begin
							//if result is positive, set least sig bit to 1
							current_Q[0]=1'b1;
						end
				shift_count = shift_count-1;
			end
	complete = 1'b1; //flag division as completed
	if(i==1)
		current_Q = ~current_Q+1;
	if(j==1)
		begin
		current_Q = ~current_Q+1;
		A=~A+1;
		end
	result = {A,current_Q};
	end
endmodule