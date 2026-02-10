`timescale 1ns/10ps
module AndOrDatapath_tb;

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

  // ==== state machine  ====
  parameter  Default    = 4'b0000,
             Reg_load1a = 4'b0001,
             Reg_load1b = 4'b0010,
             Reg_load2a = 4'b0011,
             Reg_load2b = 4'b0100,
             T0         = 4'b0101,
             T1         = 4'b0110,
             T2         = 4'b0111,
             T3         = 4'b1000,
             T4         = 4'b1001,
             T5         = 4'b1010;

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
    clear = 1'b0;   
    clock = 1'b0;
    repeat (200) #10 clock = ~clock;
  end

  // === run AND first, then OR once ===
  reg do_or   = 1'b0;  // 0=AND run, 1=OR run
  reg ran_and = 1'b0;  

  always @(posedge clock) begin
    if (Present_state == T5 && !ran_and) begin
      do_or   <= 1'b1;  // switch to OR for the second run
      ran_and <= 1'b1;
    end
  end

  // === state advance ===
  always @(posedge clock) begin
    case (Present_state)
      Default:    Present_state <= Reg_load1a;
      Reg_load1a: Present_state <= Reg_load1b;
      Reg_load1b: Present_state <= Reg_load2a;
      Reg_load2a: Present_state <= Reg_load2b;
      Reg_load2b: Present_state <= T0;
      T0:         Present_state <= T1;
      T1:         Present_state <= T2;
      T2:         Present_state <= T3;
      T3:         Present_state <= T4;
      T4:         Present_state <= T5;

      // After first T5 (AND), go back to T0 to run OR once.
      // After second T5 (OR), hold.
      T5:         Present_state <= (ran_and ? T5 : T0);

      default:    Present_state <= Default;
    endcase
  end

  // === set control signal to 0 ===
  task deassert_all;
    begin
      // bus drivers
      Zout=0; R0out=0; R1out=0; R2out=0; R3out=0; R4out=0; R5out=0; R6out=0; R7out=0;
      R8out=0; R9out=0; R10out=0; R11out=0; R12out=0; R13out=0; R14out=0; R15out=0;
      HIout=0; LOout=0; Zhighout=0; Zlowout=0; PCout=0; MDRout=0; inportout=0; Cout=0;

      // latches / controls
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
      Default: begin
        
      end

      // Load R5 = 0x22
      Reg_load1a: begin
        Read    = 1;
        MDRin   = 1;
        Mdatain = 32'h00000022;
      end
      Reg_load1b: begin
        MDRout = 1;
        R5in   = 1;
      end

      // Load R6 = 0x24
      Reg_load2a: begin
        Read    = 1;
        MDRin   = 1;
        Mdatain = 32'h00000024;
      end
      Reg_load2b: begin
        MDRout = 1;
        R6in   = 1;
      end

      // T0: PCout, MARin, IncPC, Zin
      T0: begin
        PCout = 1;
        MARin = 1;
        IncPC = 1;
        Zin   = 1;
      end

      // T1: Zlowout, PCin, Read, Mdatain[31..0], MDRin
      T1: begin
		  PCout = 0;
        MARin = 0;
        IncPC = 0;
        Zin   = 0;
		
        Zlowout = 1;
        PCin    = 1;
        Read    = 1;
        MDRin   = 1;

        // AND R2,R5,R6 instruction word: 32'h312B0000
        // OR  R2,R5,R6 instruction word: 32'h292B0000
        Mdatain  = (do_or) ? 32'h292B0000 : 32'h312B0000;
      end

      // T2: MDRout, IRin
      T2: begin
		  Zlowout = 0;
        PCin    = 0;
        Read    = 0;
        MDRin   = 0;
		  
        MDRout = 1;
        IRin   = 1;
      end

      // T3: R5out, Yin
      T3: begin
		  MDRout = 0;
        IRin   = 0;
		  
        R5out = 1;
        Yin   = 1;
      end

      // T4: R6out, AND/OR, Zin
      T4: begin
		  R5out = 0;
        Yin   = 0;
		
        R6out = 1;
        Zin   = 1;

        // ALU op select: AND=00101, OR=00110
        opcode = (do_or) ? 5'b00110 : 5'b00101;
      end

      // T5: Zlowout, R2in
      T5: begin
		  R6out = 0;
        Zin   = 0;
		
        Zlowout = 1;
        R2in    = 1;
      end
    endcase
  end

endmodule
