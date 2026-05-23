// program_counter.v
// 64-bit Program Counter with synchronous reset.
// Loads pc_next (output of PCSrc MUX) on every rising clock edge.
// Member 4 — PC + Branch Logic Engineer

module program_counter (
    input  wire        clk,
    input  wire        rst,
    input  wire [63:0] pc_next,   // From PCSrc MUX: PC+4 or branch_target
    output reg  [63:0] pc         // Current PC → Instruction Memory + adders
);

    always @(posedge clk) begin
        if (rst)
            pc <= 64'h0;   // Synchronous reset
        else
            pc <= pc_next;
    end

endmodule
