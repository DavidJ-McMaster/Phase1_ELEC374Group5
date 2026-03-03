module ALU(
	input wire [4:0]  opcode,
	input wire [31:0] YdataOut,
	input wire [31:0] BusMuxOut,
	output reg [31:0] ResultHi, 
	output reg [31:0] ResultLow	//64 bit ALU outputs
);
	wire[31:0]	AddResult;
	wire[31:0] 	SubResult;
	wire[63:0]	MultiplyResult;
	wire[63:0] 	DivideResult;
	wire 			DivDone;
	
	wire [4:0] shift_amount = BusMuxOut[4:0];
	
	
	localparam ADD 	= 5'b00000;
	localparam SUB 	= 5'b00001;
	
	localparam AND 	= 5'b00010;
	localparam OR 		= 5'b00011;
	
	localparam SHR 	= 5'b00100;
	localparam SHRA 	= 5'b00101;
	localparam SHL 	= 5'b00110;
	
	localparam ROR 	= 5'b00111;
	localparam ROL 	= 5'b01000;
	
	localparam ADDI	= 5'b01001;
	localparam ANDI 	= 5'b01010;
	localparam ORI 	= 5'b01011;
	
	localparam DIV 	= 5'b01100;
	localparam MUL 	= 5'b01101;
	localparam NEG 	= 5'b01110;
	localparam NOT 	= 5'b01111;
	
	localparam LD 		= 5'b10000;
	localparam LDI 	= 5'b10001;
	localparam ST 		= 5'b10010;
	
	localparam JAL 	= 5'b10011;
	localparam JR 		= 5'b10100;
	
	localparam BR 		= 5'b10101;
	
	localparam IN	 	= 5'b10110;
	localparam OUT 	= 5'b10111;
	localparam MFHI 	= 5'b11000;
	localparam MFLO 	= 5'b11001;
	
	localparam NOP 	= 5'b11010;
	localparam HALT 	= 5'b11011;
	
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
				AND:	ResultLow = YdataOut & BusMuxOut;
				OR:	ResultLow = YdataOut | BusMuxOut;
				
				NOT:	ResultLow = ~BusMuxOut;
				NEG:	ResultLow = ~BusMuxOut + 32'd1;
					
				ADD:	ResultLow = AddResult;
				SUB:	ResultLow = SubResult;

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
					
			// Shifts
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
					
			// Rotates
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
					
			// __ Immediate variants of already made instructions
				ADDI: ResultLow = AddResult;
				ANDI: ResultLow = YdataOut & BusMuxOut;
				ORI:	ResultLow = YdataOut | BusMuxOut;
				
		// Non-ALU focused instructions
				LD: 	ResultLow = BusMuxOut;
				ST:	ResultLow = BusMuxOut;
				BR:	ResultLow = BusMuxOut;
				JAL:	ResultLow = BusMuxOut;
		
		//Transfers or moving
				LDI:	ResultLow = BusMuxOut;
				JR:	ResultLow = BusMuxOut;
				IN:	ResultLow = BusMuxOut;
				OUT:	ResultLow = BusMuxOut;
				MFHI:	ResultLow = BusMuxOut;
				MFLO:	ResultLow = BusMuxOut;
				
			//Stop Functions
				NOP:	ResultLow = 32'd0;
				HALT: ResultLow = 32'd0;
				
				
				INC:	ResultLow = BusMuxOut +32'd1;
					
				default: 
					begin
							ResultHi	 = 32'd0;
							ResultLow = 32'd0;
					end
			endcase
		end
	endmodule
	