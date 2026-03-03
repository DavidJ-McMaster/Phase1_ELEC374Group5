module ALU(
	input wire [4:0]  opcode,
	input wire [31:0] YdataOut,
	input wire [31:0] BusMuxOut,
	output reg [31:0] ResultHi, 
	output reg [31:0] ResultLow	//64 bit ALU outputs
);
	wire[31:0] AddResult;
	wire[31:0] SubResult;
	wire[63:0] MultiplyResult;
	wire[63:0] DivideResult;
	wire DivDone;
	
	wire [4:0] shift_amount = BusMuxOut[4:0];
	
	localparam AND 	= 5'b00101;
	localparam OR 		= 5'b00110;
	localparam ADD 	= 5'b00011;
	localparam SUB 	= 5'b00100;
	localparam MUL 	= 5'b10000;
	localparam DIV 	= 5'b01111;
	localparam SHR 	= 5'b01001;
	localparam SHRA 	= 5'b01010;
	localparam SHL 	= 5'b01011;
	localparam ROR		= 5'b00111;
	localparam ROL 	= 5'b01000;
	localparam NEG 	= 5'b10001;
	localparam NOT 	= 5'b10010;
	localparam INC 	= 5'b11111;
	
	add add_instance(
		.A(YdataOut),
		.B(BusMuxOut),
		.Result(AddResult)
	);
	
	sub sub_instance(
		.A(YdataOut),
		.B(BusMuxOut),
		.Result(SubResult)
	);
	
	multiply mul_instance(
		.M($signed(YdataOut)),
		.Q($signed(BusMuxOut)),
		.P(MultiplyResult)
	);
	
	divide div_instance(
		.Q_in(YdataOut),
		.M_in(BusMuxOut),
		.result(DivideResult),
		.complete(DivDone)
	);
	
	integer i;
	reg [31:0] temp;
	
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
						ResultLow = AddResult;
					end
				SUB:
					begin
						ResultLow = SubResult;
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
						temp = YdataOut;	// Using temp so that it shows the before and after
						for (i = 0; i < shift_amount; i = i + 1)
							temp = temp >> 1;
						ResultLow = temp;
					end
				SHL:
					begin
						temp = YdataOut;
						for (i = 0; i < shift_amount; i = i + 1)
							temp = temp << 1;
						ResultLow = temp;
					end
				SHRA:
					begin 
						temp = YdataOut;
						for (i = 0; i < shift_amount; i = i + 1)
							temp = $signed(temp) >>> 1;
						ResultLow = temp;
					end
				ROR:
					begin
						temp = YdataOut;
						for (i = 0; i < shift_amount; i = i + 1)
							temp = {temp[0], temp[31:1]};   // rotate right by 1 LSB to MSB
						ResultLow = temp;
					end
				ROL:
					begin
						temp = YdataOut;
						for (i = 0; i < shift_amount; i = i + 1)
							temp = {temp[30:0], temp[31]};  // rotate left by 1
						ResultLow = temp;
					end
				INC:
					begin
						ResultLow = BusMuxOut +32'd1;
					end
				default: 
					begin
							ResultHi	 = 32'd0;
							ResultLow = 32'd0;
					end
			endcase
		end
	endmodule
	