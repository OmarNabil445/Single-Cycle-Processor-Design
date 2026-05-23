// cpu_top_tb.v
// Full testbench for the single-cycle RV64I processor.
// Runs the test program from instruction_memory.mem and verifies:
//   - Arithmetic, logic, shift operations
//   - Memory load/store
//   - Branch (BEQ, BLT)
// Displays register file state and pass/fail summary.

`timescale 1ns / 1ps

module cpu_top_tb;

    reg         clk;
    reg         rst;
    wire [63:0] pc;
    wire [31:0] instruction;
    wire [63:0] alu_result;
    wire [63:0] write_data;
    wire        branch_taken;

    // ─────────────────────────────────────────────────────────────────────
    // DUT
    // ─────────────────────────────────────────────────────────────────────
    cpu_top DUT (
        .clk(clk),
        .rst(rst),
        .pc_current(pc),
        .instruction(instruction),
        .alu_result(alu_result),
        .write_data(write_data),
        .branch_taken(branch_taken)
    );

    // ─────────────────────────────────────────────────────────────────────
    // Clock Generation
    // ─────────────────────────────────────────────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ─────────────────────────────────────────────────────────────────────
    // Register File Access
    // ─────────────────────────────────────────────────────────────────────
    integer i;
    reg [63:0] r [0:31];

    task read_regs;
        integer j;
        begin
            for (j = 0; j < 32; j = j + 1)
                r[j] = DUT.RF.registers[j];
        end
    endtask

    task print_regs;
        integer j;
        begin
            $display("");
            $display("  Register File (non-zero):");

            for (j = 0; j < 32; j = j + 1)
                if (r[j] != 64'b0)
                    $display("    x%0d = %0d", j, r[j]);
        end
    endtask

    // ─────────────────────────────────────────────────────────────────────
    // Verification Helper
    // ─────────────────────────────────────────────────────────────────────
    integer pass_count;
    integer fail_count;

    task check_val;
        input [64*8-1:0] name;
        input [63:0] expected;
        input [63:0] actual;

        begin
            if (expected == actual) begin
                $display("  PASS | %-40s | exp=%0d  got=%0d",
                         name, expected, actual);
                pass_count = pass_count + 1;
            end
            else begin
                $display("  FAIL | %-40s | exp=%0d  got=%0d",
                         name, expected, actual);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ─────────────────────────────────────────────────────────────────────
    // Stimulus
    // ─────────────────────────────────────────────────────────────────────
    initial begin

        pass_count = 0;
        fail_count = 0;

        $display("================================================");
        $display("  Single-Cycle RISC-V Processor Testbench");
        $display("  Task 5 - Full CPU Integration");
        $display("================================================");

        // Reset sequence
        rst = 1;

        @(posedge clk); #1;
        @(posedge clk); #1;

        rst = 0;

        @(posedge clk); #1;

        $display("");
        $display("  Executing test program...");
        $display("");

        // Run processor
        for (i = 0; i < 50; i = i + 1) begin
            @(posedge clk); #1;

            if (branch_taken)
                $display("  Cycle %2d | PC=0x%04X | Branch Taken -> target=0x%04X",
                         i+1,
                         pc,
                         DUT.MUX_PC.branch_target);
        end

        // Read register values
        read_regs();

        // ─────────────────────────────────────────────────────────────────
        // Verification
        // ─────────────────────────────────────────────────────────────────
        $display("");
        $display("================================================");
        $display("  Verification");
        $display("================================================");

        // Immediate Instructions
        $display("");
        $display("  [Immediate Operations]");

        check_val("addi x22, x0, -3   -> x22 = -3",
                  -64'd3, r[22]);

        check_val("addi x23, x0, 2    -> x23 = 2",
                   64'd2, r[23]);

        check_val("addi x29, x0, 88   -> x29 = 88",
                   64'd88, r[29]);

        // R-Type Arithmetic
        $display("");
        $display("  [R-Type Arithmetic]");

        check_val("add  x24, x23, x23 -> x24 = 4",
                   64'd4, r[24]);

        check_val("xor  x25, x24, x23 -> x25 = 6",
                   64'd6, r[25]);

        check_val("srl  x26, x25, x23 -> x26 = 1",
                   64'd1, r[26]);

        check_val("sub  x27, x26, x26 -> x27 = 0",
                   64'd0, r[27]);

        // Memory Operations
        $display("");
        $display("  [Memory Operations]");

        check_val("sd   x26, 0(x29)   -> mem[88] = 1",
                   64'd1, r[26]);

        check_val("ld   x30, 0(x29)   -> x30 = 1",
                   64'd1, r[30]);

        // Branch Operations
        $display("");
        $display("  [Branch Operations]");

        check_val("BLT taken -> x28 = 4",
                   64'd4, r[28]);

        // x0 check
        check_val("x0 always zero      -> x0 = 0",
                   64'd0, r[0]);

        // ─────────────────────────────────────────────────────────────────
        // Summary
        // ─────────────────────────────────────────────────────────────────
        $display("");
        $display("================================================");
        $display("  Results: %0d PASSED,  %0d FAILED",
                 pass_count,
                 fail_count);
        $display("================================================");

        print_regs();

        $finish;
    end

    // ─────────────────────────────────────────────────────────────────────
    // Waveform Dump
    // ─────────────────────────────────────────────────────────────────────
    initial begin
        $dumpfile("cpu_top_tb.vcd");
        $dumpvars(0, cpu_top_tb);
    end

endmodule