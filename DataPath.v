module DataPath(
//PHASE 2 DATAPATH

	input wire clock, clear,
	input wire Zout, R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out, 
	input wire HIout, LOout, Zhighout, Zlowout, PCout, MDRout, InPortout, Cout,
				  
	input wire Zin, Yin, 
	
	input wire R0in, R1in, R2in, R3in, R4in, R5in,R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in, 
				  
	input wire PCin, IRin, HIin, LOin, MARin, MDRin, Read, Write,
	input wire Zhighin, Zlowin,
	
	//input wire [31:0] Mdatain,
	input wire [4:0] opcode,
	
	//input CON FF
	input wire CONin,
	input wire Out_Portin,
	input wire strobe,
	input wire [31:0] In_Data,
	output wire CON,
	output wire [31:0] Out_Port
);


wire [31:0] BusMuxOut; 
wire [31:0] IRdataOut, YdataOut, MARdataOut;

wire [31:0] BusMuxInR0, BusMuxInR1,BusMuxInR2, BusMuxInR3, BusMuxInR4; 
wire [31:0] BusMuxInR5, BusMuxInR6,BusMuxInR7, BusMuxInR8, BusMuxInR9; 
wire [31:0] BusMuxInR10, BusMuxInR11,BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15; 

wire [31:0] BusMuxInPC,BusMuxInHI, BusMuxInLO, BusMuxInMDR, BusMuxInZhigh, BusMuxInZlow; 
wire [31:0] BusMuxInCsignExtend, BusMuxInInPort;



//Devices
register R0(clear, clock, R0in, BusMuxOut, BusMuxInR0);
register R1(clear, clock, R1in, BusMuxOut, BusMuxInR1);
register R2(clear, clock, R2in, BusMuxOut, BusMuxInR2);
register R3(clear, clock, R3in, BusMuxOut, BusMuxInR3);
register R4(clear, clock, R4in, BusMuxOut, BusMuxInR4);
register R5(clear, clock, R5in, BusMuxOut, BusMuxInR5);
register R6(clear, clock, R6in, BusMuxOut, BusMuxInR6);
register R7(clear, clock, R7in, BusMuxOut, BusMuxInR7);
register R8(clear, clock, R8in, BusMuxOut, BusMuxInR8);
register R9(clear, clock, R9in, BusMuxOut, BusMuxInR9);
register R10(clear, clock, R10in, BusMuxOut, BusMuxInR10);
register R11(clear, clock, R11in, BusMuxOut, BusMuxInR11);
register R12(clear, clock, R12in, BusMuxOut, BusMuxInR12);
register R13(clear, clock, R13in, BusMuxOut, BusMuxInR13);
register R14(clear, clock, R14in, BusMuxOut, BusMuxInR14);
register R15(clear, clock, R15in, BusMuxOut, BusMuxInR15);

register PC(clear, clock, PCin, BusMuxOut, BusMuxInPC);
register IR(clear, clock, IRin, BusMuxOut, IRdataOut);
register Y(clear, clock, Yin, BusMuxOut, YdataOut);
register MAR(clear, clock, MARin, BusMuxOut, MARdataOut);
register HI(clear, clock, HIin, BusMuxOut, BusMuxInHI);
register LO(clear, clock, LOin, BusMuxOut, BusMuxInLO);

wire [8:0] RAM_address = MARdataOut[8:0];
wire [31:0] RAM_dataOut;

MDR MDR_Instance(	
						clear, 
						clock, 
						MDRin, 
						Read, 
						BusMuxOut, 
						RAM_dataOut, 
						BusMuxInMDR);
						
RAM RAM_Instance(
						clock,
						Read,
						Write,
						BusMuxInMDR,
						RAM_address,
						RAM_dataOut);

wire[31:0] ALU_HI, ALU_LO;
ALU ALU_Instance(opcode, YdataOut, BusMuxOut, ALU_HI, ALU_LO);

reg [63:0] Zreg;
assign BusMuxInZlow  = Zreg[31:0];
assign BusMuxInZhigh = Zreg[63:32];

always @(posedge clock or posedge clear)
	begin
		if(clear)
			Zreg <= 64'd0;
		else
			begin
				if (Zin)
					Zreg <= {ALU_HI, ALU_LO};
				if (Zhighin)
					Zreg[63:32] <= {ALU_HI};
				if (Zlowin)
					Zreg[31:0] <= {ALU_LO};
			end
	end

inport inport_inst (
    .clr(clear),
    .clk(clock),
    .strobe(strobe),
    .InputIn(In_Data),
    .inport_out(BusMuxInInPort)
);

outport outport_inst (
    .clr(clear),
    .clk(clock),
    .en(Out_Portin),
    .BusMuxOut(BusMuxOut),
    .outport_out(Out_Port)
);

con_ff con_ff_inst (
    .irInput(IRdataOut),
    .BusMuxOut(BusMuxOut),
    .CONin(CONin),
    .conOut(CON)
);

//Bus
Bus bus_instance(	BusMuxOut, 
						BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, 
						BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7, 
						BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11, 
						BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15,
			
						BusMuxInHI, BusMuxInLO, BusMuxInZhigh, BusMuxInZlow, 
						BusMuxInPC, BusMuxInMDR, BusMuxInInPort, BusMuxInCsignExtend,
			
						R0out, R1out, R2out, R3out, R4out, R5out, 
						R6out, R7out, R8out, R9out, 
						R10out, R11out, R12out, R13out, R14out, R15out, 
						
						HIout, LOout, Zhighout, Zlowout, 
						PCout, MDRout, InPortout, Cout
);


endmodule