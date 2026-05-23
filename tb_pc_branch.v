// tb_pc_branch.v
// Testbench for Member 4 — PC + Branch Logic modules:
//   program_counter, pc_adder, shift_left1, branch_adder,
//   mux_pcsrc, mux_alusrc, mux_memtoreg
//
// Diagram wiring (this version):
//   branch_target = PC + (imm << 1)      <-- PC dot, Shift Left 1
//   pc_next       = PCSrc ? branch_target : pc_plus4
//
// Test groups:
//   T1  — Sequential PC advance (3 cycles, PCSrc=0)
//   T2  — Branch taken   : forward  branch (positive imm)
//   T3  — Branch not-taken: PCSrc=0, sequential
//   T4  — Branch taken   : backward branch (negative imm)
//   T5  — Branch not-taken after backward setup
//   T6  — Synchronous reset
//   T7  — mux_alusrc  (ALUSrc=0 → rs2, ALUSrc=1 → imm)
//   T8  — mux_memtoreg (MemtoReg=0 → ALU, MemtoReg=1 → Mem)
//   T9  — shift_left1  (several values)
//   T10 — branch_adder (PC + imm_shifted)

`timescale 1ns/1ps

module tb_pc_branch;

    // ── Clock ──────────────────────────────────────────────────────────────
    reg clk, rst;
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Signals ────────────────────────────────────────────────────────────
    wire [63:0] pc;
    wire [63:0] pc_plus4;
    wire [63:0] imm_shifted;
    wire [63:0] branch_target;
    wire [63:0] pc_next;

    reg         pc_src;
    reg  [63:0] imm;

    // ALUSrc MUX
    reg  [63:0] read_data2, imm_ext;
    reg         alu_src;
    wire [63:0] alu_b;

    // MemtoReg MUX
    reg  [63:0] alu_result, mem_read_data;
    reg         mem_to_reg;
    wire [63:0] write_data;

    // ── Instantiations ─────────────────────────────────────────────────────
    program_counter PC_REG (
        .clk(clk), .rst(rst), .pc_next(pc_next), .pc(pc)
    );

    pc_adder ADDER4 (
        .pc(pc), .pc_plus4(pc_plus4)
    );

    shift_left1 SL1 (
        .in(imm), .out(imm_shifted)
    );

    // branch_adder: takes PC directly (not PC+4), as shown in diagram
    branch_adder BADDER (
        .pc(pc), .imm_shifted(imm_shifted), .branch_target(branch_target)
    );

    mux_pcsrc MUX_PC (
        .pc_plus4(pc_plus4), .branch_target(branch_target),
        .pc_src(pc_src), .pc_next(pc_next)
    );

    mux_alusrc MUX_ALU (
        .read_data2(read_data2), .imm_ext(imm_ext),
        .alu_src(alu_src), .alu_b(alu_b)
    );

    mux_memtoreg MUX_WB (
        .alu_result(alu_result), .mem_read_data(mem_read_data),
        .mem_to_reg(mem_to_reg), .write_data(write_data)
    );

    // ── Pass/fail ──────────────────────────────────────────────────────────
    integer pass_count;
    integer fail_count;
    initial begin pass_count = 0; fail_count = 0; end

    task check_val;
        input [64*8-1:0] name;
        input [63:0] expected;
        input [63:0] actual;
        begin
            if (expected === actual) begin
                $display("  PASS | %-40s | exp=%0d  got=%0d", name, expected, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL | %-40s | exp=%0d  got=%0d", name, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ── Stimulus ───────────────────────────────────────────────────────────
    initial begin
        $display("================================================");
        $display("  Member 4 — PC + Branch Logic Testbench");
        $display("  Diagram: branch_target = PC + (imm << 1)");
        $display("================================================");

        rst=1; pc_src=0; alu_src=0; mem_to_reg=0;
        imm=0; read_data2=0; imm_ext=0; alu_result=0; mem_read_data=0;

        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;

        // ══ T1: Sequential advance ════════════════════════════════════════
        $display("\n[T1] Sequential PC advance (PCSrc=0)");
        pc_src=0; imm=0;
        @(posedge clk); #1; check_val("PC cycle 1 = 4",  64'd4,  pc);
        @(posedge clk); #1; check_val("PC cycle 2 = 8",  64'd8,  pc);
        @(posedge clk); #1; check_val("PC cycle 3 = 12", 64'd12, pc);

        // ══ T2: Branch taken, forward ════════════════════════════════════
        // PC=12, imm=10 → imm_shifted=20 → branch_target=12+20=32
        $display("\n[T2] Branch taken (forward): PC=12, imm=10");
        imm=64'd10; pc_src=1; #1;
        check_val("imm_shifted = 10<<1 = 20",    64'd20, imm_shifted);
        check_val("branch_target = 12+20 = 32",  64'd32, branch_target);
        @(posedge clk); #1;
        check_val("PC jumps to 32",              64'd32, pc);

        // ══ T3: Branch not-taken ═════════════════════════════════════════
        // PC=32, PCSrc=0 → PC+4=36
        $display("\n[T3] Branch not-taken: PC=32");
        pc_src=0;
        @(posedge clk); #1;
        check_val("PC advances to 36",           64'd36, pc);

        // ══ T4: Branch taken, backward ═══════════════════════════════════
        // PC=36, imm=-6 (0xFFFF...FFFA) → imm_shifted=-12
        // branch_target = 36 + (-12) = 24
        $display("\n[T4] Branch taken (backward): PC=36, imm=-6");
        imm=64'hFFFFFFFFFFFFFFFA; pc_src=1; #1;
        // imm_shifted = -6 << 1 = -12 = 0xFFFFFFFFFFFFFFF4
        check_val("branch_target = 36-12 = 24",  64'd24, branch_target);
        @(posedge clk); #1;
        check_val("PC jumps backward to 24",     64'd24, pc);

        // ══ T5: Branch not-taken ═════════════════════════════════════════
        // PC=24 → PC+4=28
        $display("\n[T5] Branch not-taken: PC=24");
        pc_src=0;
        @(posedge clk); #1;
        check_val("PC advances to 28",           64'd28, pc);

        // ══ T6: Synchronous reset ═════════════════════════════════════════
        $display("\n[T6] Synchronous reset");
        rst=1; @(posedge clk); #1;
        check_val("PC reset to 0",               64'd0, pc);
        rst=0;

        // ══ T7: mux_alusrc ════════════════════════════════════════════════
        $display("\n[T7] mux_alusrc");
        read_data2=64'hABCD; imm_ext=64'h1234;
        alu_src=0; #1;
        check_val("ALUSrc=0: alu_b = read_data2 (0xABCD)", 64'hABCD, alu_b);
        alu_src=1; #1;
        check_val("ALUSrc=1: alu_b = imm_ext    (0x1234)", 64'h1234, alu_b);

        // ══ T8: mux_memtoreg ══════════════════════════════════════════════
        $display("\n[T8] mux_memtoreg");
        alu_result=64'hDEAD; mem_read_data=64'hBEEF;
        mem_to_reg=0; #1;
        check_val("MemtoReg=0: write = alu_result (0xDEAD)",    64'hDEAD, write_data);
        mem_to_reg=1; #1;
        check_val("MemtoReg=1: write = mem_read   (0xBEEF)",    64'hBEEF, write_data);

        // ══ T9: shift_left1 ═══════════════════════════════════════════════
        $display("\n[T9] shift_left1");
        imm=64'd1;   #1; check_val("1   << 1 = 2",   64'd2,   imm_shifted);
        imm=64'd8;   #1; check_val("8   << 1 = 16",  64'd16,  imm_shifted);
        imm=64'd100; #1; check_val("100 << 1 = 200", 64'd200, imm_shifted);

        // ══ T10: branch_adder (PC=0 after reset) ══════════════════════════
        $display("\n[T10] branch_adder: branch_target = PC + (imm<<1)");
        // PC is 0 after reset (T6), then advanced once in T9 loops → actually
        // PC advanced 1 cycle in T6 clean: let's reset again cleanly.
        pc_src=0; imm=0;
        rst=1; @(posedge clk); #1; rst=0;
        // PC=0 now
        imm=64'd12; #1;  // imm_shifted=24, branch_target=0+24=24
        check_val("PC=0, imm=12: branch_target=24", 64'd24, branch_target);
        @(posedge clk); #1;  // PC advances to 4 (pc_src=0)
        imm=64'd5; #1;   // imm_shifted=10, branch_target=4+10=14
        check_val("PC=4, imm=5:  branch_target=14", 64'd14, branch_target);

        // ══ Summary ═══════════════════════════════════════════════════════
        $display("\n================================================");
        $display("  Results: %0d PASSED,  %0d FAILED", pass_count, fail_count);
        $display("================================================");
        $finish;
    end

    initial begin
        $dumpfile("tb_pc_branch.vcd");
        $dumpvars(0, tb_pc_branch);
    end

endmodule
