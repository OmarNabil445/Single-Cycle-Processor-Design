// mux.v
// Three 2:1 multiplexers for the single-cycle RV64I datapath.
// All MUXes are 2:1, matching the diagram exactly.
//
//  ┌──────────────┬───────────┬──────────────────────────────────────────┐
//  │ Module       │ Control   │ Function                                 │
//  ├──────────────┼───────────┼──────────────────────────────────────────┤
//  │ mux_pcsrc    │ PCSrc     │ Top-right: PC+4  vs branch_target → PC  │
//  │ mux_alusrc   │ ALUSrc    │ Centre   : Read data 2 vs Imm → ALU B   │
//  │ mux_memtoreg │ MemtoReg  │ Right    : ALU result vs Mem data → RF  │
//  └──────────────┴───────────┴──────────────────────────────────────────┘
// Member 4 — PC + Branch Logic Engineer

// ─────────────────────────────────────────────────────────────────────────
// MUX 1 — PCSrc  (top-right of diagram)
//   sel=0 → pc_next = pc_plus4       (sequential, no branch)
//   sel=1 → pc_next = branch_target  (branch taken)
// ─────────────────────────────────────────────────────────────────────────
module mux_pcsrc (
    input  wire [63:0] pc_plus4,
    input  wire [63:0] branch_target,
    input  wire        pc_src,
    output wire [63:0] pc_next
);
    assign pc_next = pc_src ? branch_target : pc_plus4;
endmodule


// ─────────────────────────────────────────────────────────────────────────
// MUX 2 — ALUSrc  (centre of diagram)
//   sel=0 (ALUSrc=0) → alu_b = read_data2  (R-type: rs2)
//   sel=1 (ALUSrc=1) → alu_b = imm_ext     (I/S-type: immediate)
// ─────────────────────────────────────────────────────────────────────────
module mux_alusrc (
    input  wire [63:0] read_data2,
    input  wire [63:0] imm_ext,
    input  wire        alu_src,
    output wire [63:0] alu_b
);
    assign alu_b = alu_src ? imm_ext : read_data2;
endmodule


// ─────────────────────────────────────────────────────────────────────────
// MUX 3 — MemtoReg  (right side of diagram)
//   sel=0 (MemtoReg=0) → write_data = alu_result    (R/I ALU ops)
//   sel=1 (MemtoReg=1) → write_data = mem_read_data (Load)
// ─────────────────────────────────────────────────────────────────────────
module mux_memtoreg (
    input  wire [63:0] alu_result,
    input  wire [63:0] mem_read_data,
    input  wire        mem_to_reg,
    output wire [63:0] write_data
);
    assign write_data = mem_to_reg ? mem_read_data : alu_result;
endmodule
