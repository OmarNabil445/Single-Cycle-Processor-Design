// instruction_memory.v
// Preloaded 32-bit instruction memory for RV64I single-cycle processor.
// Word-aligned addressing: instruction = memory[pc[11:2]]
// Initialized via $readmemh from "instruction_memory.mem"
// 1024 entries x 32-bit = 4 KB

module instruction_memory (
    input  wire [63:0] pc,              // Current program counter
    output wire [31:0] instruction       // 32-bit fetched instruction
);

    reg [31:0] mem [0:1023];            // 1024 x 32-bit = 4 KB
    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'h00000013;      // NOP: addi x0, x0, 0
        $readmemh("D:/Codes/Vivado/Single-Cycle RISC-V Processor Design Final/Single-Cycle RISC-V Processor Design Final.sim/sim_1/behav/xsim/instruction_memory.mem", mem);
    end

    assign instruction = mem[pc[11:2]];

endmodule
