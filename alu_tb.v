`timescale 1ns / 1ps  // time unit / time precision

module alu_tb;
    reg [63:0] a;
    reg [63:0] b;
    reg [3:0] alu_ctrl;
    wire [63:0] result;
    wire zero;
    
    alu uut(
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );
    
    integer pass = 0;
    integer fail = 0;
    
    task check;
        input[63:0] exp_result;
        input exp_zero;
        
        begin
            if (result == exp_result && zero == exp_zero) begin
                pass = pass + 1;
                $display("Test Passed!");
                $display("result = %0d \t zero flag = %b\n", result, zero);
                end
            else begin
                fail = fail + 1;
                $display("Test Failed!");
                $display("result = %0d (expected %0d)", result, exp_result);
                $display("zero flag = %b (expected %b)\n", zero, exp_zero);
                end
            end
        endtask
                
    
initial begin
    a = 0; b = 0; alu_ctrl = 0;
    #50;
    
    $display("-----------------------");
    $display("ALU Testbench");
    $display("-----------------------\n");


    // ctrl = 0000 (Addition)
    alu_ctrl = 4'b0000;
    a = 64'd5; b = 64'd3;   // 5 + 3 = 8
    #10;
    $display("Addition: %0d + %0d = %0d", a, b, result);
    check(64'd8, 1'b0);
   
    
    // ctrl = 0001 (Subtraction)
    alu_ctrl = 4'b0001;
    a = 64'd5; b = 64'd3;   // 5 - 3 = 2
    #10;
    $display("Subtraction: %0d - %0d = %0d", a, b, result);
    check(64'd2, 1'b0);
    
    a = 64'd5; b = 64'd5;   // 5 - 5 = 0
    #10;
    $display("Subtraction: %0d - %0d = %0d", a, b, result);
    check(64'd0, 1'b1);
    
    
    // ctrl = 0010 (AND)
    alu_ctrl = 4'b0010;
    a = 64'd10; b = 64'd7;   // 10 & 7 = 2
    #10;
    $display("AND: %0d & %0d = %0d", a, b, result);
    check(64'd2, 1'b0);
    
    a = 64'd10; b = 64'd5;   // 10 & 5 = 0
    #10;
    $display("AND: %0d & %0d = %0d", a, b, result);
    check(64'd0, 1'b1);
    
    
    // ctrl = 0011 (OR)
    alu_ctrl = 4'b0011;
    a = 64'd10; b = 64'd5;   // 10 | 5 = 15
    #10;
    $display("OR: %0d | %0d = %0d", a, b, result);
    check(64'd15, 1'b0);
  
    
    // ctrl = 0100 (XOR)
    alu_ctrl = 4'b0100;
    a = 64'd10; b = 64'd7;   // 10 ^ 7 = 13
    #10;
    $display("XOR: %0d ^ %0d = %0d", a, b, result);
    check(64'd13, 1'b0);
    
    a = 64'd10; b = 64'd10;   // 10 ^ 10 = 0
    #10;
    $display("XOR: %0d ^ %0d = %0d", a, b, result);
    check(64'd0, 1'b1);
    
    
    // ctrl = 0101 (Left Shift SLL)
    alu_ctrl = 4'b0101;
    a = 64'd10; b = 64'd2;   // 10 << 2 = 40
    #10;
    $display("Left Shift: %0d << %0d = %0d", a, b, result);
    check(64'd40, 1'b0);

    
    // ctrl = 0110 (Right Shift SRL)
    alu_ctrl = 4'b0110;
    a = 64'd10; b = 64'd2;   // 10 >> 2 = 2
    #10;
    $display("Right Shift: %0d >> %0d = %0d", a, b, result);
    check(64'd2, 1'b0);
    
    a = 64'd10; b = 64'd4;   // 10 >> 4 = 0
    #10;
    $display("Right Shift: %0d >> %0d = %0d", a, b, result);
    check(64'd0, 1'b1);
  
    
    // ctrl = 0111 (Set Less Than SLT)
    alu_ctrl = 4'b0111;
    a = 64'd4; b = 64'd10;   // 4 < 10?: 1
    #10;
    $display("Set Less Than: %0d < %0d? = %0d", a, b, result);
    check(64'd1, 1'b0);
    
    a = 64'd10; b = 64'd4;   // 10 < 4?: 0
    #10;
    $display("Set Less Than: %0d < %0d? = %0d", a, b, result);
    check(64'd0, 1'b1);
    
    a = -64'd4; b = 64'd10;   // -4 < 10?: 1
    #10;
    $display("Set Less Than: %0d < %0d? = %0d", $signed(a), b, result);
    check(64'd1, 1'b0);
  
    
    $display("-----------------------");
    $display("Number of Passed Tests: %0d", pass);
    $display("Number of Failed Tests: %0d", fail);
    $display("Accuracy = %.1f%%", (pass * 1.0) / (pass+fail) * 100);
    
    
    $finish;
    end
endmodule
