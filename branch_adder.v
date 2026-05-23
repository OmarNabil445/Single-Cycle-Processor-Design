// branch_adder.v
// Upper "Add" block in the diagram.
//   branch_target = PC + (imm << 1)
// The left input wire comes directly from the PC output dot (NOT from PC+4).
// Member 4 — PC + Branch Logic Engineer

module branch_adder (
    input  wire [63:0] pc,            // Current PC (from the dot on the PC wire)
    input  wire [63:0] imm_shifted,   // imm << 1, from Shift Left 1 block
    output wire [63:0] branch_target
);
    assign branch_target = pc + imm_shifted;
endmodule
