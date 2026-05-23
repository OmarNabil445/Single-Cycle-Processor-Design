// cpu_top.v
// Top-level integration of the single-cycle RV64I processor.
// Implements the complete single-cycle RISC-V datapath.

module cpu_top (
    input  wire        clk,
    input  wire        rst,

    output wire [63:0] pc_current,
    output wire [31:0] instruction,
    output wire [63:0] alu_result,
    output wire [63:0] write_data,
    output wire        branch_taken
);

    // ─────────────────────────────────────────────────────────────────────
    // Instruction Fields
    // ─────────────────────────────────────────────────────────────────────
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd  = instruction[11:7];

    // ─────────────────────────────────────────────────────────────────────
    // Internal Datapath Signals
    // ─────────────────────────────────────────────────────────────────────
    wire [63:0] pc_next;
    wire [63:0] pc_plus4;

    wire [63:0] imm_ext;
    wire [63:0] branch_target;

    wire [63:0] read_data1;
    wire [63:0] read_data2;

    wire [63:0] alu_b;

    wire [63:0] mem_read_data;
    wire [63:0] write_data_internal;

    wire zero;

    // ─────────────────────────────────────────────────────────────────────
    // Control Signals
    // ─────────────────────────────────────────────────────────────────────
    wire RegWrite;
    wire MemWrite;
    wire MemRead;
    wire ALUSrc;
    wire MemToReg;
    wire Branch;

    wire [3:0] ALUControl;

    // ─────────────────────────────────────────────────────────────────────
    // Branch Decision Logic
    // ─────────────────────────────────────────────────────────────────────
    assign branch_taken =
        Branch &&
        (
            ((funct3 == 3'b000) && zero) ||                 // BEQ
            ((funct3 == 3'b100) && (alu_result == 64'd1))  // BLT
        );

    // ─────────────────────────────────────────────────────────────────────
    // Program Counter
    // ─────────────────────────────────────────────────────────────────────
    program_counter PC (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc_current)
    );

    // ─────────────────────────────────────────────────────────────────────
    // PC + 4
    // ─────────────────────────────────────────────────────────────────────
    pc_adder PC_ADD (
        .pc(pc_current),
        .pc_plus4(pc_plus4)
    );

    // ─────────────────────────────────────────────────────────────────────
    // Instruction Memory
    // ─────────────────────────────────────────────────────────────────────
    instruction_memory IM (
        .pc(pc_current),
        .instruction(instruction)
    );

    // ─────────────────────────────────────────────────────────────────────
    // Control Unit
    // ─────────────────────────────────────────────────────────────────────
    control_unit CTRL (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),

        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ALUSrc(ALUSrc),
        .MemToReg(MemToReg),
        .Branch(Branch),
        .ALUControl(ALUControl)
    );

    // ─────────────────────────────────────────────────────────────────────
    // Register File
    // ─────────────────────────────────────────────────────────────────────
    RegisterFile RF (
        .clk(clk),
        .RegWrite(RegWrite),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .writeData(write_data_internal),

        .readData1(read_data1),
        .readData2(read_data2)
    );

    // ─────────────────────────────────────────────────────────────────────
    // Immediate Generator
    // ─────────────────────────────────────────────────────────────────────
    ImmediateGenerator IMM_GEN (
        .instruction(instruction),
        .imm(imm_ext)
    );

    // ─────────────────────────────────────────────────────────────────────
    // Branch Target Adder
    // FIXED: removed extra shift_left1
    // ─────────────────────────────────────────────────────────────────────
    assign branch_target = pc_current + imm_ext;

    // ─────────────────────────────────────────────────────────────────────
    // ALU Source MUX
    // ─────────────────────────────────────────────────────────────────────
    mux_alusrc MUX_ALU (
        .read_data2(read_data2),
        .imm_ext(imm_ext),
        .alu_src(ALUSrc),
        .alu_b(alu_b)
    );

    // ─────────────────────────────────────────────────────────────────────
    // ALU
    // ─────────────────────────────────────────────────────────────────────
    alu ALU (
        .a(read_data1),
        .b(alu_b),

        .alu_ctrl(ALUControl),

        .result(alu_result),
        .zero(zero)
    );

    // ─────────────────────────────────────────────────────────────────────
    // Data Memory
    // ─────────────────────────────────────────────────────────────────────
    data_memory DM (
        .clk(clk),
        .rst(rst),

        .MemRead(MemRead),
        .MemWrite(MemWrite),

        .address(alu_result),
        .write_data(read_data2),

        .read_data(mem_read_data)
    );

    // ─────────────────────────────────────────────────────────────────────
    // Writeback MUX
    // ─────────────────────────────────────────────────────────────────────
    mux_memtoreg MUX_WB (
        .alu_result(alu_result),
        .mem_read_data(mem_read_data),

        .mem_to_reg(MemToReg),

        .write_data(write_data_internal)
    );

    // ─────────────────────────────────────────────────────────────────────
    // PC Source MUX
    // ─────────────────────────────────────────────────────────────────────
    mux_pcsrc MUX_PC (
        .pc_plus4(pc_plus4),
        .branch_target(branch_target),

        .pc_src(branch_taken),

        .pc_next(pc_next)
    );

    // ─────────────────────────────────────────────────────────────────────
    // Output Connections
    // ─────────────────────────────────────────────────────────────────────
    assign write_data = write_data_internal;

endmodule