`timescale 1ns/10ps
module out_tb;

reg clock, clear;
reg R0out, R1out, R2out, R3out, R4out,  R5out,  R6out,  R7out;
reg R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
reg HIout, LOout, Zhighout, Zlowout, PCout, MDRout, InPortout, Cout;
reg Zin, Yin, Zhighin, Zlowin;
reg R0in,  R1in,  R2in,  R3in,  R4in,  R5in,  R6in,  R7in;
reg R8in,  R9in,  R10in, R11in, R12in, R13in, R14in, R15in;
reg PCin, IRin, HIin, LOin, MARin, MDRin, Read, Write;
reg [4:0] opcode;
reg CONin, Out_Portin, strobe;
reg [31:0] In_Data;

wire CON;
wire [31:0] Out_Port;

DataPath DUT(
    .clock(clock), .clear(clear),
    .R0out(R0out),   .R1out(R1out),   .R2out(R2out),   .R3out(R3out),
    .R4out(R4out),   .R5out(R5out),   .R6out(R6out),   .R7out(R7out),
    .R8out(R8out),   .R9out(R9out),   .R10out(R10out), .R11out(R11out),
    .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out),
    .HIout(HIout),   .LOout(LOout),   .Zhighout(Zhighout), .Zlowout(Zlowout),
    .PCout(PCout),   .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout),
    .Zin(Zin), .Yin(Yin), .Zhighin(Zhighin), .Zlowin(Zlowin),
    .R0in(R0in),   .R1in(R1in),   .R2in(R2in),   .R3in(R3in),
    .R4in(R4in),   .R5in(R5in),   .R6in(R6in),   .R7in(R7in),
    .R8in(R8in),   .R9in(R9in),   .R10in(R10in), .R11in(R11in),
    .R12in(R12in), .R13in(R13in), .R14in(R14in), .R15in(R15in),
    .PCin(PCin), .IRin(IRin), .HIin(HIin), .LOin(LOin),
    .MARin(MARin), .MDRin(MDRin), .Read(Read), .Write(Write),
    .opcode(opcode),
    .CONin(CONin), .Out_Portin(Out_Portin),
    .strobe(strobe), .In_Data(In_Data),
    .CON(CON), .Out_Port(Out_Port)
);

initial clock = 0;
always #10 clock = ~clock;

task reset_signals;
begin
    R0out=0;  R1out=0;  R2out=0;  R3out=0;  R4out=0;  R5out=0;  R6out=0;  R7out=0;
    R8out=0;  R9out=0;  R10out=0; R11out=0; R12out=0; R13out=0; R14out=0; R15out=0;
    HIout=0;  LOout=0;  Zhighout=0; Zlowout=0; PCout=0; MDRout=0; InPortout=0; Cout=0;
    Zin=0; Yin=0; Zhighin=0; Zlowin=0;
    R0in=0;  R1in=0;  R2in=0;  R3in=0;  R4in=0;  R5in=0;  R6in=0;  R7in=0;
    R8in=0;  R9in=0;  R10in=0; R11in=0; R12in=0; R13in=0; R14in=0; R15in=0;
    PCin=0; IRin=0; HIin=0; LOin=0; MARin=0; MDRin=0; Read=0; Write=0;
    opcode=5'b11111; CONin=0; Out_Portin=0; strobe=0; In_Data=0;
end
endtask

initial begin
    clear = 1;
    reset_signals;
    #25 clear = 0;

    // R7
    DUT.R7.BusMuxIn = 32'hABCD1234;
    #5;

    // T3: R7out, Out_Portin
    @(negedge clock); reset_signals;
    R7out = 1; Out_Portin = 1;
    @(negedge clock);
    R7out = 0; Out_Portin = 0;

    #5;
    $display("out R7: Out_Port=%h (expect ABCD1234)", Out_Port);
    $stop;
end

endmodule