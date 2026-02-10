`timescale 1ns/10ps
module DivDataPath_tb;
  
reg Zout, R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out, 
      R10out, R11out, R12out, R13out, R14out, R15out, HIout, LOout, Zhighout, Zlowout, 
      PCout, MDRout, InPortout, Cout;		
		
reg 	MARin, Zin, PCin, MDRin, IRin, Yin, HIin, LOin;
reg 	IncPC, Read, R0in, R1in, R2in, R3in, R4in, 
		R5in,R6in,R7in,R8in, R9in, R10in, R11in, R12in, 
		R13in, R14in, R15in, Zhighin, Zlowin;
		
reg clock, clear;
reg [4:0] opcode;
reg [31:0] Mdatain;
  
parameter	Default = 4'b0000, Reg_load1a = 4'b0001, Reg_load1b = 4'b0010, Reg_load2a = 4'b0011,
				Reg_load2b = 4'b0100, Reg_load3a = 4'b0101, T0 = 4'b0110, T1 = 4'b0111,
            T2 = 4'b1000, T3 = 4'b1001, T4 = 4'b1010, T5 = 4'b1011, T6 = 4'b1100, T7 = 4'b1101;
  
reg [3:0] Present_state = Default;
	
DataPath DUT(	clock, clear, Zout, R0out, R1out, R2out, R3out, R4out, 
					R5out, R6out, R7out, R8out, R9out, R10out, R11out, R12out, R13out, 
					R14out, R15out, HIout, LOout, Zhighout, Zlowout, 
					PCout, MDRout, InPortout, Cout, Zin, Yin, R0in, R1in,
					R2in, R3in, R4in, R5in, R6in, R7in, R8in, R9in, R10in,
					R11in, R12in, R13in, R14in, R15in, PCin, IRin, HIin,
					LOin, MARin, MDRin, Read, Zhighin, Zlowin, Mdatain, opcode);
	
initial
	begin
		clock=0;
		clear=0;
		forever #10 clock = ~clock;
	end

always@(posedge clock)
	begin
		case(Present_state)
			Default : Present_state = Reg_load1a;
			Reg_load1a : Present_state = Reg_load1b;
			Reg_load1b : Present_state = Reg_load2a;
			Reg_load2a : Present_state = Reg_load2b;
			Reg_load2b : Present_state = Reg_load3a;
			Reg_load3a : Present_state = T0;
			T0 : Present_state = T1;
			T1 : Present_state = T2;
			T2 : Present_state = T3;
			T3 : Present_state = T4;
			T4 : Present_state = T5;
			T5 : Present_state = T6;
			T6 : Present_state = T7;
		endcase
	end

always@(*)
	begin
		// Defaults
		
		Read<=0; MDRin<=0; MDRout<=0;
		IRin<=0;
		
		PCout<=0; PCin<=0; MARin<=0;
		
		R3in<=0; R3out<=0; R1in<=0; R1out<=0;
		
		Yin<=0;
		
		Zlowin<=0; Zlowout<=0; Zhighin<=0; Zhighout<=0;
		
		LOin<=0; HIin<=0;
		
		opcode<=5'b00000;
		Mdatain<=32'h00000000;
		
		// States
		case(Present_state)
		
			Reg_load1a:
				begin
					Read <=1;
					MDRin<=1;
					Mdatain<=32'hffffffef; // loads into MDR
				end
				
			Reg_load1b:
				begin
					Read<=0;
					MDRin<=0;
					MDRout<=1;
					R3in<=1;		// MDR writes to R3 (R3 = 0xffffffef)
				end
				
			Reg_load2a:
				begin
					MDRout<=0;
					R3in<=0;
					Read<=1;
					MDRin<=1;
					Mdatain<=32'h00000002;	// Loads value into MDR
				end
				
			Reg_load2b:
				begin
					Read<=0;
					MDRin<=0;
					MDRout<=1;
					R1in<=1;		// MDR writes to R1 (R1 = 0x00000002)
				end
				
			Reg_load3a:
				begin	
					MDRout<=0;				// PC Increments
					R1in<=0;
					PCout<=1;
					MARin<=1;
					opcode<=5'b11111;
					Zlowin<=1;
				end
				
				
			T0:
				begin
					PCout<=0;
					MARin<=0;
					opcode<=5'b00000;
					Zlowin<=0;
					
					Zlowout<=1;		// Incremented value goes back into PC
					PCin<=1;
				end
				
			T1:
				begin
					Zlowout<=0;
					PCin<=0;
					
					Read<=1;
					MDRin<=1;
					Mdatain<=32'h79880000; //IR for div r3, r1
				end
				
			T2:
				begin
					Zlowout<=0;
					PCin<=0;
					Read<=0;
					MDRin<=0;
					
					MDRout<=1;		// Moving instruction from MDR to IR (IR = div r3,r1)
					IRin<=1;
				end
				
			T3:
				begin
					MDRout<=0;
					IRin<=0;
					
					R3out<=1;	// loads r3 value into Y
					Yin<=1;
				end
				
			T4:
				begin
					R3out<=0;
					Yin<=0;
					
					R1out<=1;			// Loads R1 into bus, then Divides Y by R1 (aka r3/r1)
					opcode<=5'b01111; //opcode for Div
					Zlowin<=1;			//Stores the low 32 bit and high 32 bits
					Zhighin<=1;
				end
				
			T5:
				begin
					R1out<=0;
					opcode<=5'b00000;
					Zlowin<=0;
					Zhighin<=0;
					
					Zlowout<=1;		//Load the low 32 bits into LO
					LOin<=1;
				end
				
			T6:
				begin
					Zlowout<=0;
					LOin<=0;
					
					Zhighout<=1;	//Loads the high 32 into HI
					HIin<=1;
				end
				
			T7:
				begin
					Zhighout<=0;	//defaults everything back to 0
					HIin<=0;
				end
				
		endcase
	end
endmodule
