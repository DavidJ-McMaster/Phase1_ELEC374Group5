module ALU(
	input wire clear, clock,
	input wire [4:0] opcode,
	input wire [31:0] YdataOut,
	input wire [31:0] BusMuxOut,
	output reg [31:0] ResultHi, ResultLow	//64 bit ALU outputs
);
	wire[63:0] AddResult, SubResult, MultiplyResult, DivideResult;
	
	wire [4:0] shift_amount = BusMuxOut[4:0];
	
	localparam AND = 5'b00101;
	localparam OR =  5'b00110;
	localparam ADD = 5'b00011;
	localparam SUB = 5'b00100;
	localparam MUL = 5'b10000;
	localparam DIV = 5'b01111;
	localparam SHR = 5'b01001;
	localparam SHRA = 5'b01010;
	localparam SHL = 5'b01011;
	localparam ROR = 5'b00111;
	localparam ROL = 5'b01000;
	localparam NEG = 5'b10001;
	localparam NOT = 5'b10010;
	localparam INC = 5'b11111;
	
	always @(*)
		begin
			//set intial states
			ResultHi = 32'd0;
			ResultLow = 32'b0;
			
			case(opcode)
				AND:
					begin
						ResultLow = YdataOut & BusMuxOut;
					end
				OR:
					begin
						ResultLow = YdataOut | BusMuxOut;
					end
				NOT:
					begin
						ResultLow = ~BusMuxOut;
					end
				NEG:
					begin
						ResultLow = ~BusMuxOut + 32'd1;
					end
				ADD:
					begin
						ResultLow = AddResult[31:0];
					end
				SUB:
					begin
						ResultLow = SubResult[31:0];
					end
				MUL:
					begin
						ResultHi = MultiplyResult[63:32];
						ResultLow = MultiplyResult[31:0];
					end
				DIV:
					begin
						ResultHi = DivideResult[63:32];
						ResultLow = DivideResult[31:0];
					end
				SHR:
					begin
						ResultLow = YdataOut>>shift_amount;
					end
				SHL:
					begin
						ResultLow = YdataOut<<shift_amount;
					end
				SHRA:
					begin
						ResultLow = $signed(YdataOut)>>>shift_amount;
					end
				ROR:
					begin
						ResultLow = (shift_amount==0)? YdataOut:(YdataOut>>shift_amount)|(YdataOut<<(32-shift_amount));
					end
				ROL:
					begin
						ResultLow = (shift_amount==0)? YdataOut:(YdataOut<<shift_amount)|(YdataOut>>(32-shift_amount));
					end
				INC:
					begin
						ResultLow = BusMuxOut+32'h00000001;
						ResultHi = 32'h0;
					end
			endcase
		end
	
	add add(
		.A(YdataOut),
		.B(BusMuxOut),
		.Result(AddResult)
	);
	
	sub sub(
		.A(YdataOut),
		.B(BusMuxOut),
		.Result(SubResult)
	);
	
	multiply mul(
		.M(YdataOut),
		.Q(BusMuxOut),
		.P(MultiplyResult)
	);
	
	divide div(
		.Q_in(YdataOut),
		.M_in(BusMuxOut),
		.result(DivideResult)
	);
	endmodule
	