// cpu_top_tb.v
// Full testbench for the single-cycle RV64I processor.
// CSC311 – Intro. To Computer Architecture, SPR'26
// Nile University — ITCS School


`timescale 1ns / 1ps

module cpu_top_tb;

    reg         clk;
    reg         rst;
    wire [63:0] pc;
    wire [31:0] instruction;
    wire [63:0] alu_result;
    wire [63:0] write_data;
    wire        branch_taken;

    cpu_top DUT (
        .clk        (clk),
        .rst        (rst),
        .pc_current (pc),
        .instruction(instruction),
        .alu_result (alu_result),
        .write_data (write_data),
        .branch_taken(branch_taken)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    `define REG(n) DUT.RF.registers[n]
    `define MEM(n) DUT.DM.mem[n]

    integer pass_count;
    integer fail_count;

    task check_val;
        input [64*8-1:0] name;
        input [63:0] expected;
        input [63:0] actual;
        begin
            if (expected === actual) begin
                $display("    PASS | %-38s | exp=%0d  got=%0d",
                         name, expected, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("    FAIL | %-38s | exp=%0d  got=%0d",
                         name, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    integer i;

    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("================================================");
        $display("  Single-Cycle RISC-V Processor Testbench");
        $display("  CSC311 SPR26 — Task 5 Full CPU Integration");
        $display("================================================");

        // Reset
        rst = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;

        $display("\n  Executing and checking cycle by cycle...\n");

        // ── Cycle 1: addi x0, x0, 7 → no effect ─────────────────────
        @(posedge clk); #1;
        $display("  [Cycle 01] PC=%2d | addi x0, x0, 7  (no effect)", pc-4);
        check_val("x0 = 0 (hardwired)", 64'd0, `REG(0));

        // ── Cycle 2: addi x22, x0, -3 → x22 = -3 ────────────────────
        @(posedge clk); #1;
        $display("  [Cycle 02] PC=%2d | addi x22, x0, -3", pc-4);
        check_val("x22 = -3", 64'hFFFFFFFFFFFFFFFD, `REG(22));

        // ── Cycle 3: addi x23, x0, 2 → x23 = 2 ──────────────────────
        @(posedge clk); #1;
        $display("  [Cycle 03] PC=%2d | addi x23, x0, 2", pc-4);
        check_val("x23 = 2", 64'd2, `REG(23));

        // ── Cycle 4: add x24, x23, x23 → x24 = 4 ────────────────────
        @(posedge clk); #1;
        $display("  [Cycle 04] PC=%2d | add x24, x23, x23", pc-4);
        check_val("x24 = 4", 64'd4, `REG(24));

        // ── Cycle 5: xor x25, x24, x23 → x25 = 6 ────────────────────
        @(posedge clk); #1;
        $display("  [Cycle 05] PC=%2d | xor x25, x24, x23", pc-4);
        check_val("x25 = 6", 64'd6, `REG(25));

        // ── Cycle 6: srl x26, x25, x23 → x26 = 1 ────────────────────
        @(posedge clk); #1;
        $display("  [Cycle 06] PC=%2d | srl x26, x25, x23", pc-4);
        check_val("x26 = 1  (6 >> 2)", 64'd1, `REG(26));

        // ── Cycle 7: sub x27, x26, x26 → x27 = 0 ────────────────────
        @(posedge clk); #1;
        $display("  [Cycle 07] PC=%2d | sub x27, x26, x26", pc-4);
        check_val("x27 = 0  (1 - 1)", 64'd0, `REG(27));

        // ── Cycle 8: addi x29, x0, 88 → x29 = 88 ────────────────────
        @(posedge clk); #1;
        $display("  [Cycle 08] PC=%2d | addi x29, x0, 88", pc-4);
        check_val("x29 = 88", 64'd88, `REG(29));

        // ── Cycle 9: sd x26, 0(x29) → mem[88] = 1 ───────────────────
        @(posedge clk); #1;
        $display("  [Cycle 09] PC=%2d | sd x26, 0(x29)  MemWrite=%b",
                  pc-4, DUT.MemWrite);
        check_val("mem[88] = 1  (word_idx=11)", 64'd1, `MEM(11));

        // ── Cycle 10: ld x30, 0(x29) → x30 = 1 ──────────────────────
        @(posedge clk); #1;
        $display("  [Cycle 10] PC=%2d | ld x30, 0(x29)  MemRead=%b",
                  pc-4, DUT.MemRead);
        check_val("x30 = 1", 64'd1, `REG(30));

        // ── Cycle 11: blt x22, x23, +12 → TAKEN ─────────────────────
        // ── Cycle 11: blt x22, x23, +12 → TAKEN ─────────────────────
        $display("  [Cycle 11] PC=%2d | blt x22, x23  branch_taken=%b",
                  pc, branch_taken);
        check_val("branch_taken = 1", 64'd1, {63'd0, branch_taken});
        @(posedge clk); #1;  // branch fires, PC → L1 (addi x28=4 now executing)

        // ── Cycle 12: addi x28, x0, 4 (L1, branch target) ───────────
        $display("  [Cycle 12] PC=%2d | addi x28, x0, 4  (L1 target)",
                  pc-4);
        @(posedge clk); #1;  // ← ADD THIS: let addi x28=4 commit to the register file
        check_val("x28 = 4  (branch correct)", 64'd4, `REG(28));
        check_val("x28 != 99 (skip confirmed)", 1'b0,
                  (`REG(28) == 64'd99));

        // ── Extra cycle for write-back to settle ──────────────────────
        @(posedge clk); #1;

        // ── Final summary ─────────────────────────────────────────────
        $display("\n================================================");
        $display("  Final Expected Results");
        $display("================================================");
        $display("  x0  = %0d  (expected 0)",  `REG(0));
        $display("  x26 = %0d  (expected 1)",  `REG(26));
        $display("  x27 = %0d  (expected 0)",  `REG(27));
        $display("  x28 = %0d  (expected 4)",  `REG(28));
        $display("  x30 = %0d  (expected 1)",  `REG(30));
        $display("  mem[88] = %0d  (expected 1)", `MEM(11));

        $display("\n================================================");
        $display("  Results: %0d PASSED  |  %0d FAILED",
                 pass_count, fail_count);
        if (fail_count == 0)
            $display("  *** ALL TESTS PASSED — CPU is correct ***");
        else
            $display("  *** SOME TESTS FAILED — check above ***");
        $display("================================================");

        // Print non-zero registers
        $display("\n  Register File (non-zero values):");
        for (i = 1; i < 32; i = i + 1)
            if (`REG(i) != 64'b0)
                $display("    x%0d = %0d", i, $signed(`REG(i)));

        $finish;
    end

    initial begin
        $dumpfile("cpu_top_tb.vcd");
        $dumpvars(0, cpu_top_tb);
    end

endmodule
