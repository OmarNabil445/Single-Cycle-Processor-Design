module tb_ImmediateGenerator;

    reg  [31:0] instruction;
    wire [63:0] imm;

    ImmediateGenerator uut (
        .instruction(instruction),
        .imm(imm)
    );

    initial begin
        // Test 1: addi x1, x0, 5
        instruction = 32'b00000000010100000000000010010011;
        #10; $display("IG | ADDI imm = %0d (expected 5)", imm);

        // Test 2: slli x4, x9, 3
        instruction = 32'b00000000001101001001001000010011;
        #10; $display("IG | SLLI imm = %0d (expected 3)", imm);

        // Test 3: sd x1, 0(x0)
        instruction = 32'b00000000000100000011000000100011;
        #10; $display("IG | SD   imm = %0d (expected 0)", imm);

        // Test 4: beq x1, x1, +8
        instruction = 32'b00000000000100001000010001100011;
        #10; $display("IG | BEQ  imm = %0d (expected 8)", imm);

        #20; $finish;
    end
endmodule