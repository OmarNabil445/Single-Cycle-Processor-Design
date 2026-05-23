module alu (
    input  [63:0] a,          //(Read Data 1 from register file)
    input  [63:0] b,          // (Read Data 2 OR sign-extended immediate)
    input  [3:0]  alu_ctrl,   // Operation select
    output reg [63:0] result, // result of a op b
    output zero               // 1 if result == 0
);

    assign zero = (result == 64'b0);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b;          // ADD
            4'b0001: result = a - b;          // SUB
            4'b0010: result = a & b;          // AND
            4'b0011: result = a | b;          // OR
            4'b0100: result = a ^ b;          // XOR
            4'b0101: result = a << b[5:0];    // SLL
            4'b0110: result = a >> b[5:0];    // SRL
            4'b0111: result = ($signed(a) < $signed(b)) ? 64'd1 : 64'd0; // SLT (for blt)
            default: result = 64'b0;
        endcase
    end

endmodule
