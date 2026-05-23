// shift_left1.v
// "Shift Left 1" block in the diagram.
// Shifts the 64-bit immediate left by 1 bit.
// In RV64I B-type encoding, ImmGen already produces a value where
// bit[0]=0 and bits encode the byte offset ÷ 2, so shifting left 1
// gives the final byte offset.  branch_target = PC + (imm << 1)
// Member 4 — PC + Branch Logic Engineer

module shift_left1 (
    input  wire [63:0] in,
    output wire [63:0] out
);
    assign out = {in[62:0], 1'b0};   // logical left shift by 1
endmodule
