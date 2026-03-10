module select_encode(
    input [31:0] IR,
    input Gra, Grb, Grc,
    input Rin, Rout,
    input BAout,

    output [15:0] R_in,
    output [15:0] R_out
);

reg [3:0] reg_sel;
reg [15:0] decode;

always @(*) begin
    if (Gra)
        reg_sel = IR[26:23]; //Ra
    else if (Grb)
        reg_sel = IR[22:19]; //Rb
    else if (Grc)
        reg_sel = IR[18:15]; //Rc
    else
        reg_sel = 4'b0000;
end

always @(*) begin
    decode = 16'b0;
    decode[reg_sel] = 1'b1;
end

assign R_in  = decode & {16{Rin}};
assign R_out = decode & {16{Rout}};

endmodule