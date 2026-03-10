module R0_register (
    input clk,
    input clr,
    input R0in,
    input BAout,
    input [31:0] BusMuxOut,
    output [31:0] BusMuxIn_R0
);

    reg [31:0] q;

    always @(posedge clk or posedge clr) begin
        if (clr)
            q <= 32'b0;
        else if (R0in)
            q <= BusMuxOut;
    end

    assign BusMuxIn_R0 = BAout ? 32'b0 : q;

endmodule