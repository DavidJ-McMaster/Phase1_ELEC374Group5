`timescale 1ns/10ps
module shl_tb;
    reg R0In, R1In, R2In, R3In, R4In, R5In, R6In, R7In, R8In, R9In, R10In, R11In, R12In, R13In, R14In, R15In;
    reg R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
    reg MARIn, MDRIn, Read, MDRout;
    reg HIIn, LOIn, RZHiIn, RZLoIn, RYIn;
    reg HIout, LOout, ZHiOut, ZLoOut;
    reg IRIn, PCout, IncPC, PCIn;
    reg clock, clear;
    reg AND, OR, ADD, SUB, MUL, DIV, SHR, SHL, ROR, ROL, NEG, NOT, SHRA;
    reg [31:0] Mdatain;

    parameter Default = 4'b0000, Reg_load1a = 4'b0001, Reg_load1b = 4'b0010, 
              Reg_load2a = 4'b0011, Reg_load2b = 4'b0100, 
              Reg_load3a = 4'b0101, Reg_load3b = 4'b0110, 
              T0 = 4'b0111, T1 = 4'b1000, T2 = 4'b1001, T3 = 4'b1010, T4 = 4'b1011, T5 = 4'b1100;
              
    reg [3:0] Present_state = Default;

    DataPath DUT(
        .PCout(PCout), .Zlowout(ZLoOut), .Zhighout(ZHiOut), .MDRout(MDRout),
        .R0out(R0out), .R1out(R1out), .R2out(R2out), .R3out(R3out), 
        .R4out(R4out), .R5out(R5out), .R6out(R6out), .R7out(R7out),
        .MARin(MARIn), .Zin(RZLoIn), .PCin(PCIn), .MDRin(MDRIn), .IRin(IRIn), .Yin(RYIn),
        .IncPC(IncPC), .Read(Read),
        .R0in(R0In), .R1in(R1In), .R2in(R2In), .R3in(R3In), 
        .R4in(R4In), .R5in(R5In), .R6in(R6In), .R7in(R7In),
        .HIin(HIIn), .LOin(LOIn),
        .AND(AND), .OR(OR), .ADD(ADD), .SUB(SUB), .MUL(MUL), .DIV(DIV),
        .SHR(SHR), .SHL(SHL), .ROR(ROR), .ROL(ROL), .NEG(NEG), .NOT(NOT), .SHRA(SHRA),
        .Clock(clock), .Mdatain(Mdatain)
    );

    initial begin clock = 0; forever #10 clock = ~clock; end

    always @(posedge clock) begin
        case (Present_state)
            Default: Present_state = Reg_load1a;
            Reg_load1a: Present_state = Reg_load1b;
            Reg_load1b: Present_state = Reg_load2a;
            Reg_load2a: Present_state = Reg_load2b;
            Reg_load2b: Present_state = Reg_load3a;
            Reg_load3a: Present_state = Reg_load3b;
            Reg_load3b: Present_state = T0;
            T0: Present_state = T1;
            T1: Present_state = T2;
            T2: Present_state = T3;
            T3: Present_state = T4;
            T4: Present_state = T5;
            T5: Present_state = Default;
        endcase
    end

    always @(Present_state) begin
        PCout <= 0; ZLoOut <= 0; ZHiOut <= 0; MDRout <= 0;
        R0out <= 0; R1out <= 0; R2out <= 0; R3out <= 0; R4out <= 0; R5out <= 0; R6out <= 0; R7out <= 0;
        R8out <= 0; R9out <= 0; R10out <= 0; R11out <= 0; R12out <= 0; R13out <= 0; R14out <= 0; R15out <= 0;
        MARIn <= 0; RZLoIn <= 0; PCIn <= 0; MDRIn <= 0; IRIn <= 0; RYIn <= 0;
        IncPC <= 0; Read <= 0; 
        R0In <= 0; R1In <= 0; R2In <= 0; R3In <= 0; R4In <= 0; R5In <= 0; R6In <= 0; R7In <= 0;
        R8In <= 0; R9In <= 0; R10In <= 0; R11In <= 0; R12In <= 0; R13In <= 0; R14In <= 0; R15In <= 0;
        HIIn <= 0; LOIn <= 0; RZHiIn <= 0;
        AND <= 0; OR <= 0; ADD <= 0; SUB <= 0; MUL <= 0; DIV <= 0;
        SHR <= 0; SHL <= 0; ROR <= 0; ROL <= 0; NEG <= 0; NOT <= 0; SHRA <= 0;
        Mdatain <= 32'h00000000; clear <= 0;

        case (Present_state)
            Default: begin end
            Reg_load1a: begin Mdatain <= 32'hF0000008; Read <= 1; MDRIn <= 1; #20 Read <= 0; MDRIn <= 0; end
            Reg_load1b: begin MDRout <= 1; R0In <= 1; #20 MDRout <= 0; R0In <= 0; end
            Reg_load2a: begin Mdatain <= 32'h00000004; Read <= 1; MDRIn <= 1; #20 Read <= 0; MDRIn <= 0; end
            Reg_load2b: begin MDRout <= 1; R4In <= 1; #20 MDRout <= 0; R4In <= 0; end
            Reg_load3a: begin Mdatain <= 32'h00000000; Read <= 1; MDRIn <= 1; #20 Read <= 0; MDRIn <= 0; end
            Reg_load3b: begin end
            T0: begin PCout <= 1; MARIn <= 1; IncPC <= 1; RZLoIn <= 1; #20 PCout <= 0; MARIn <= 0; IncPC <= 0; RZLoIn <= 0; end
            T1: begin ZLoOut <= 1; PCIn <= 1; Read <= 1; MDRIn <= 1; Mdatain <= 32'h5b820000; #20 ZLoOut <= 0; PCIn <= 0; Read <= 0; MDRIn <= 0; end
            T2: begin MDRout <= 1; IRIn <= 1; #20 MDRout <= 0; IRIn <= 0; end
            T3: begin R0out <= 1; RYIn <= 1; #20 R0out <= 0; RYIn <= 0; end
            T4: begin 
                R4out <= 1; 
                SHL <= 1; 
                RZLoIn <= 1; 
                #20 R4out <= 0; SHL <= 0; RZLoIn <= 0; 
            end
            T5: begin ZLoOut <= 1; R7In <= 1; #20 ZLoOut <= 0; R7In <= 0; end
        endcase
    end
endmodule