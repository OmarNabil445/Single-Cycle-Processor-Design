// pc_adder.v
// Combinational adder: PC + 4  (bottom-left adder in the diagram).
// Output feeds the PCSrc MUX (in0) and the upper branch adder (in0).
// Member 4 — PC + Branch Logic Engineer

module pc_adder (
    input  wire [63:0] pc,
    output wire [63:0] pc_plus4
);

    assign pc_plus4 = pc + 64'd4;

endmodule
