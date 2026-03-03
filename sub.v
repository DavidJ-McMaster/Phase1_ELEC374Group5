module sub(A,B,Result);

input[31:0] A, B;
output[31:0] Result;

reg[31:0] Result;
reg[32:0] LocalCarry; //extra bit for positive/negative
reg[31:0] Local_B;

integer i;

always@(*)
	begin
		Local_B = ~B + 32'd1; // flip bits and add one to recieve negative B
		LocalCarry = 33'd0;
		
		for(i=0;i<32;i=i+1)
		begin

			Result[i] = A[i]^Local_B[i]^LocalCarry[i]; //XOR the current A, B, and the carry from previous (will update carry)
			LocalCarry[i+1] = (A[i]  &  Local_B[i]) | (LocalCarry[i] & (A[i] ^ Local_B[i]));
			
		end
	end
endmodule
