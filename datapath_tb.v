`timescale 1ns/10ps

module datapath_tb;

    // Signal Declarations
    
    // Register Output Controls
    reg PCout, Zlowout, Zhighout, MDRout;
    reg R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
    
    // Register Input Controls
    reg MARin, Zin, PCin, MDRin, IRin, Yin;
    reg IncPC, Read;
    reg R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in;
    reg HIin, LOin;
    
    // ALU Operation Signals
    reg AND, OR, ADD, SUB, MUL, DIV;
    reg SHR, SHL, ROR, ROL, NEG, NOT, SHRA;
    
    // Clock and Data
    reg Clock;
    reg [31:0] Mdatain;

    // DUT Instantiation
    DataPath DUT(
        .PCout(PCout), .Zlowout(Zlowout), .Zhighout(Zhighout), .MDRout(MDRout),
        .R0out(R0out), .R1out(R1out), .R2out(R2out), .R3out(R3out), 
        .R4out(R4out), .R5out(R5out), .R6out(R6out), .R7out(R7out),
        
        .MARin(MARin), .Zin(Zin), .PCin(PCin), .MDRin(MDRin), .IRin(IRin), .Yin(Yin),
        .IncPC(IncPC), .Read(Read),
        .R0in(R0in), .R1in(R1in), .R2in(R2in), .R3in(R3in), 
        .R4in(R4in), .R5in(R5in), .R6in(R6in), .R7in(R7in),
        .HIin(HIin), .LOin(LOin),
        
        .AND(AND), .OR(OR), .ADD(ADD), .SUB(SUB), .MUL(MUL), .DIV(DIV),
        .SHR(SHR), .SHL(SHL), .ROR(ROR), .ROL(ROL), .NEG(NEG), .NOT(NOT), .SHRA(SHRA),
        
        .Clock(Clock),
        .Mdatain(Mdatain)
    );

    // Clock Generation
    initial begin
        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    // Finite State Machine
    parameter Default = 4'b0000;
    parameter Reg_load1a = 4'b0001, Reg_load1b = 4'b0010;
    parameter Reg_load2a = 4'b0011, Reg_load2b = 4'b0100;
    parameter Reg_load3a = 4'b0101, Reg_load3b = 4'b0110;
    parameter T0 = 4'b0111, T1 = 4'b1000, T2 = 4'b1001, T3 = 4'b1010, T4 = 4'b1011, T5 = 4'b1100, T6 = 4'b1101;

    reg [3:0] Present_state = Default;

    always @(posedge Clock) begin
        case (Present_state)
            Default:    Present_state <= Reg_load1a;
            
            // Initialization Steps
            Reg_load1a: Present_state <= Reg_load1b;
            Reg_load1b: Present_state <= Reg_load2a;
            
            Reg_load2a: Present_state <= Reg_load2b;
            Reg_load2b: Present_state <= Reg_load3a;
            
            Reg_load3a: Present_state <= Reg_load3b;
            Reg_load3b: Present_state <= T0;
            
            // Instruction Execution Steps
            T0: Present_state <= T1;
            T1: Present_state <= T2;
            T2: Present_state <= T3;
            T3: Present_state <= T4;
            T4: Present_state <= T5;
            
            // Only used for MUL/DIV
            T5: Present_state <= T6; 
            T6: Present_state <= Default;
        endcase
    end

    // Control Logic
    always @(Present_state) begin
        // Reset all signals
        PCout <= 0; Zlowout <= 0; Zhighout <= 0; MDRout <= 0;
        R0out <= 0; R1out <= 0; R2out <= 0; R3out <= 0; R4out <= 0; R5out <= 0; R6out <= 0; R7out <= 0;
        
        MARin <= 0; Zin <= 0; PCin <= 0; MDRin <= 0; IRin <= 0; Yin <= 0;
        IncPC <= 0; Read <= 0; 
        R0in <= 0; R1in <= 0; R2in <= 0; R3in <= 0; R4in <= 0; R5in <= 0; R6in <= 0; R7in <= 0;
        HIin <= 0; LOin <= 0;
        
        AND <= 0; OR <= 0; ADD <= 0; SUB <= 0; MUL <= 0; DIV <= 0;
        SHR <= 0; SHL <= 0; ROR <= 0; ROL <= 0; NEG <= 0; NOT <= 0; SHRA <= 0;
        
        Mdatain <= 32'h00000000;

        case (Present_state)
            Default: begin
            end

            // Initialize Registers
            
            // Load 0x00000022 into R5
            Reg_load1a: begin
                Mdatain <= 32'h00000022;
                Read <= 1; MDRin <= 1;
            end
            Reg_load1b: begin
                MDRout <= 1; R5in <= 1; 
            end

            // Load 0x00000044 into R6
            Reg_load2a: begin
                Mdatain <= 32'h00000044;
                Read <= 1; MDRin <= 1;
            end
            Reg_load2b: begin
                MDRout <= 1; R6in <= 1; 
            end

            // Load 0x00000000 into R2
            Reg_load3a: begin
                Mdatain <= 32'h00000000;
                Read <= 1; MDRin <= 1;
            end
            Reg_load3b: begin
                MDRout <= 1; R2in <= 1; 
            end

            // Instruction Execution
            
            // Standard Fetch Cycle
            T0: begin 
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1; 
            end
            T1: begin 
                Zlowout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            T2: begin 
                MDRout <= 1; IRin <= 1; 
            end

            // Execution Cycle
            // Current Setup: ADD R2, R5, R6
            
            T3: begin 
                R5out <= 1; Yin <= 1;
            end
            
            T4: begin 
                R6out <= 1; ADD <= 1; Zin <= 1; 
                // Change ADD to SUB, AND, OR, etc. here
            end
            
            T5: begin 
                Zlowout <= 1; R2in <= 1;
                // For MUL/DIV: Zlowout <= 1; LOin <= 1;
            end

            T6: begin
               // For MUL/DIV: Zhighout <= 1; HIin <= 1;
            end

        endcase
    end
endmodule