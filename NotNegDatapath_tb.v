`timescale 1ns/10ps
module NotNegDatapath_tb;

  // === control signals ===
  reg Zout, R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out,
      R10out, R11out, R12out, R13out, R14out, R15out, HIout, LOout, Zhighout, Zlowout,
      PCout, MDRout, inportout, Cout;

  reg MARin, Zin, PCin, MDRin, IRin, Yin, HIin, LOin;
  reg IncPC, Read, R0in, R1in, R2in, R3in, R4in,
      R5in, R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in, ZhighIn, ZlowIn;

  reg clock, clear;
  reg [4:0]  opcode;
  reg [31:0] Mdatain;

  // ==== state machine ====
  parameter  Default    = 4'b0000,
             Reg_load1a = 4'b0001,
             Reg_load1b = 4'b0010,

             // NEG sequence (T0..T4)
             T0_neg     = 4'b0011,
             T1_neg     = 4'b0100,
             T2_neg     = 4'b0101,
             T3_neg     = 4'b0110,
             T4_neg     = 4'b0111,

             // NOT sequence (T0..T4)
             T0_not     = 4'b1000,
             T1_not     = 4'b1001,
             T2_not     = 4'b1010,
             T3_not     = 4'b1011,
             T4_not     = 4'b1100,

             Done       = 4'b1101;

  reg [3:0] Present_state = Default;

  // ===== DUT =====
  DataPath DUT(
    clock, clear,
    Zout, R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out,
    R10out, R11out, R12out, R13out, R14out, R15out, HIout, LOout, Zhighout, Zlowout,
    PCout, MDRout, inportout, Cout,

    Zin, Yin, R0in, R1in, R2in, R3in, R4in, R5in,
    R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in,
    R15in, PCin, IRin, HIin, LOin, MARin, MDRin, Read, ZhighIn, ZlowIn,

    Mdatain, opcode
  );

  // === clock ===
  initial begin
    clock = 0;
    forever #10 clock = ~clock;
  end

  // === reset ===
  initial begin 
    clear = 1;
    #25;            // small delay
    clear = 0;
  end

  // === state advance ===
  always @(posedge clock)
    begin
      case (Present_state)
        Default    : Present_state <= Reg_load1a;
        Reg_load1a : Present_state <= Reg_load1b;
        Reg_load1b : Present_state <= T0_neg;

        // NEG
        T0_neg     : Present_state <= T1_neg;
        T1_neg     : Present_state <= T2_neg;
        T2_neg     : Present_state <= T3_neg;
        T3_neg     : Present_state <= T4_neg;
        T4_neg     : Present_state <= T0_not;

        // NOT
        T0_not     : Present_state <= T1_not;
        T1_not     : Present_state <= T2_not;
        T2_not     : Present_state <= T3_not;
        T3_not     : Present_state <= T4_not;
        T4_not     : Present_state <= Done;

        Done       : Present_state <= Done;
        default    : Present_state <= Default;
      endcase
    end

  // === set control signal to 0 every cycle ===
  task deassert_all;
    begin
      // bus drivers
      Zout=0; R0out=0; R1out=0; R2out=0; R3out=0; R4out=0; R5out=0; R6out=0; R7out=0;
      R8out=0; R9out=0; R10out=0; R11out=0; R12out=0; R13out=0; R14out=0; R15out=0;
      HIout=0; LOout=0; Zhighout=0; Zlowout=0; PCout=0; MDRout=0; inportout=0; Cout=0;

      MARin=0; Zin=0; PCin=0; MDRin=0; IRin=0; Yin=0; HIin=0; LOin=0;
      IncPC=0; Read=0;
      R0in=0; R1in=0; R2in=0; R3in=0; R4in=0; R5in=0; R6in=0; R7in=0;
      R8in=0; R9in=0; R10in=0; R11in=0; R12in=0; R13in=0; R14in=0; R15in=0;
      ZhighIn=0; ZlowIn=0;

      opcode=5'b00000;
      Mdatain=32'h00000000;
    end
  endtask

  // === state actions ===
  always @(*) begin
    deassert_all();

    case (Present_state)

      // Load R7 = 0x00000024 (source operand)
      Reg_load1a:
        begin
          Read    = 1;
          MDRin   = 1;
          Mdatain = 32'h00000024; // loads into MDR
        end

      Reg_load1b:
        begin
          MDRout = 1;
          R7in   = 1;   // MDR writes to R7 (R7 = 0x00000024)
        end

      // ========= NEG R4, R7 =========

      // T0: PCout, MARin, IncPC, Zin
      T0_neg:
        begin
          PCout = 1;
          MARin = 1;
          IncPC = 1;
          Zin   = 1;
        end

      // T1: Zlowout, PCin, Read, Mdatain[31..0], MDRin
      T1_neg:
        begin
          Zlowout = 1;
          PCin    = 1;
          Read    = 1;
          MDRin   = 1;
          Mdatain = 32'h72380000; // neg R4, R7
        end

      // T2: MDRout, IRin
      T2_neg:
        begin
          MDRout = 1;
          IRin   = 1;
        end

      // T3: R7out, NEG, Zin
      T3_neg:
        begin
          R7out  = 1;
          Zin    = 1;
          opcode = 5'b10001; // NEG (ALU control)
        end

      // T4: Zlowout, R4in
      T4_neg:
        begin
          Zlowout = 1;
          R4in    = 1;
        end

      // ========= NOT R4, R7 =========

      // T0: PCout, MARin, IncPC, Zin
      T0_not:
        begin
          PCout = 1;
          MARin = 1;
          IncPC = 1;
          Zin   = 1;
        end

      // T1: Zlowout, PCin, Read, Mdatain[31..0], MDRin
      T1_not:
        begin
          Zlowout = 1;
          PCin    = 1;
          Read    = 1;
          MDRin   = 1;
          Mdatain = 32'h7A380000; // not R4, R7
        end

      // T2: MDRout, IRin
      T2_not:
        begin
          MDRout = 1;
          IRin   = 1;
        end

      // T3: R7out, NOT, Zin
      T3_not:
        begin
          R7out  = 1;
          Zin    = 1;
          opcode = 5'b10010; // NOT (ALU control)
        end

      // T4: Zlowout, R4in
      T4_not:
        begin
          Zlowout = 1;
          R4in    = 1;
        end

      Done:
        begin
        end

    endcase
  end

endmodule