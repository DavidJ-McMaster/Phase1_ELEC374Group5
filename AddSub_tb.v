`timescale 1ns/10ps
module AddSub_tb;

  // ===== outputs =====
  reg Zout;
  reg R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out,
      R10out, R11out, R12out, R13out, R14out, R15out;
  reg HIout, LOout, Zhighout, Zlowout, PCout, MDRout, inportout, Cout;

  // ===== inputs =====
  reg MARin, Zin, PCin, MDRin, IRin, Yin, HIin, LOin;
  reg IncPC, Read;
  reg R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, R8in, R9in,
      R10in, R11in, R12in, R13in, R14in, R15in;
  reg ZhighIn, ZlowIn;

  reg clock, clear;
  reg [4:0]  opcode;
  reg [31:0] Mdatain;

  // ===== state machine =====
  parameter  Default    = 4'b0000,
             Reg_load1a = 4'b0001,
             Reg_load1b = 4'b0010,
             Reg_load2a = 4'b0011,
             Reg_load2b = 4'b0100,

             // ADD instruction (T0..T5)
             T0_add     = 4'b0101,
             T1_add     = 4'b0110,
             T2_add     = 4'b0111,
             T3_add     = 4'b1000,
             T4_add     = 4'b1001,
             T5_add     = 4'b1010,

             // SUB instruction (T0..T5)
             T0_sub     = 4'b1011,
             T1_sub     = 4'b1100,
             T2_sub     = 4'b1101,
             T3_sub     = 4'b1110,
             T4_sub     = 4'b1111;

  reg [3:0] Present_state = Default;

  // ===== DUT =====
  DataPath DUT(
    clock, clear,
    Zout,
    R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out, R9out,
    R10out, R11out, R12out, R13out, R14out, R15out,
    HIout, LOout, Zhighout, Zlowout,
    PCout, MDRout, inportout, Cout,
    Zin, Yin,
    R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in,
    PCin, IRin, HIin, LOin, MARin, MDRin, Read, ZhighIn, ZlowIn,
    Mdatain, opcode
  );

  // ===== clock =====
  initial begin
    clear = 1'b0;  
    clock = 1'b0;
    forever #10 clock = ~clock;
  end

  reg do_sub = 1'b0;
  reg ran_add = 1'b0;

  always @(posedge clock) begin
    if (Present_state == T5_add && !ran_add) begin
      do_sub  <= 1'b1;
      ran_add <= 1'b1;
    end
  end

  // ===== next state =====
  always @(posedge clock) begin
    case (Present_state)
      Default:    Present_state <= Reg_load1a;
      Reg_load1a: Present_state <= Reg_load1b;
      Reg_load1b: Present_state <= Reg_load2a;
      Reg_load2a: Present_state <= Reg_load2b;
      Reg_load2b: Present_state <= T0_add;

      // ADD sequence
      T0_add:     Present_state <= T1_add;
      T1_add:     Present_state <= T2_add;
      T2_add:     Present_state <= T3_add;
      T3_add:     Present_state <= T4_add;
      T4_add:     Present_state <= T5_add;

      T5_add:     Present_state <= (ran_add ? T0_sub : T0_add);

      // SUB sequence
      T0_sub:     Present_state <= T1_sub;
      T1_sub:     Present_state <= T2_sub;
      T2_sub:     Present_state <= T3_sub;
      T3_sub:     Present_state <= T4_sub;

      // hold after SUB
      T4_sub:     Present_state <= T4_sub;

      default:    Present_state <= Default;
    endcase
  end

  // ===== resets control signal to 0 every cycle =====
  task deassert_all;
    begin
      PCout=0; Zlowout=0; MDRout=0; MARin=0; PCin=0; MDRin=0; IRin=0; Yin=0; Zin=0;
      IncPC=0; Read=0;

      R0out=0; R1out=0; R2out=0; R3out=0; R4out=0; R5out=0; R6out=0; R7out=0;
      R8out=0; R9out=0; R10out=0; R11out=0; R12out=0; R13out=0; R14out=0; R15out=0;

      R0in=0; R1in=0; R2in=0; R3in=0; R4in=0; R5in=0; R6in=0; R7in=0;
      R8in=0; R9in=0; R10in=0; R11in=0; R12in=0; R13in=0; R14in=0; R15in=0;

      HIout=0; LOout=0; HIin=0; LOin=0;
      Zhighout=0; ZhighIn=0; ZlowIn=0; Zout=0; inportout=0; Cout=0;

      opcode=5'b00000;
      Mdatain=32'h00000000;
    end
  endtask

  // ===== outputs per state =====
  always @(*) begin
    deassert_all();

    case (Present_state)

      // Load R5 = 0x22 via MDR
      Reg_load1a: begin
        Read    = 1;
        MDRin   = 1;
        Mdatain = 32'h00000022;
      end
      Reg_load1b: begin
        MDRout = 1;
        R5in   = 1;
      end

      // Load R6 = 0x24 via MDR
      Reg_load2a: begin
        Read    = 1;
        MDRin   = 1;
        Mdatain = 32'h00000024;
      end
      Reg_load2b: begin
        MDRout = 1;
        R6in   = 1;
      end

      // ========= ADD R2,R5,R6 =========
      // T0: PCout, MARin, IncPC, Zin
      T0_add: begin
        PCout = 1; MARin = 1; IncPC = 1; Zin = 1;
      end

      // T1: Zlowout, PCin, Read, Mdatain[31..0], MDRin
      T1_add: begin
		  PCout = 0; MARin = 0; IncPC = 0; Zin = 0;
        Zlowout = 1; PCin = 1; Read = 1; MDRin = 1;
        Mdatain = 32'h192B0000; // add R2,R5,R6 (R-format encoding)
      end

      // T2: MDRout, IRin
      T2_add: begin
		 Zlowout = 0; PCin = 0; Read = 0; MDRin = 0;
        MDRout = 1; IRin = 1;
      end

      // T3: R5out, Yin
      T3_add: begin
		  MDRout = 0; IRin = 0;
        R5out = 1; Yin = 1;
      end

      // T4: R6out, ADD, Zin  
      T4_add: begin
		  R5out = 0; Yin = 0;
        R6out = 1; Zin = 1;
        opcode = 5'b00011; // ADD opcode
      end

      // T5: Zlowout, R2in
      T5_add: begin
		  R6out = 0; Zin = 0;
        Zlowout = 1; R2in = 1;
      end

      // ========= SUB R2,R5,R6 =========
      T0_sub: begin
        PCout = 1; MARin = 1; IncPC = 1; Zin = 1;
      end

      T1_sub: begin
		  PCout = 0; MARin = 0; IncPC = 0; Zin = 0;
        Zlowout = 1; PCin = 1; Read = 1; MDRin = 1;
        Mdatain = 32'h292B0000; // sub R2,R5,R6 
      end

      T2_sub: begin
		  Zlowout = 0; PCin = 0; Read = 0; MDRin = 0;
        MDRout = 1; IRin = 1;
      end

      T3_sub: begin
		  MDRout = 0; IRin = 0;
        R5out = 1; Yin = 1;
      end

      T4_sub: begin
		  R5out = 0; Yin = 0;
        R6out = 1; Zin = 1;
        opcode = 5'b00100; // SUB opcode
      end

    endcase
  end

endmodule
