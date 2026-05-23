module tb_RegisterFile;

    reg clk;
    reg RegWrite;
    reg  [4:0]  rs1, rs2, rd;
    reg  [63:0] writeData;
    wire [63:0] readData1, readData2;

    RegisterFile uut (
        .clk(clk), .RegWrite(RegWrite),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .writeData(writeData),
        .readData1(readData1), .readData2(readData2)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; RegWrite = 0;
        rs1 = 0; rs2 = 0; rd = 0; writeData = 0;

        // Test 1: write 25 into x1, read back
        #10; RegWrite = 1; rd = 5'd1; writeData = 64'd25;
        #10; rs1 = 5'd1;
        #10; $display("RF | x1 = %0d (expected 25)", readData1);

        // Test 2: write 100 into x2, read back
        rd = 5'd2; writeData = 64'd100;
        #10; rs1 = 5'd2;
        #10; $display("RF | x2 = %0d (expected 100)", readData1);

        // Test 3: x0 must stay zero
        rd = 5'd0; writeData = 64'd999;
        #10; rs1 = 5'd0;
        #10; $display("RF | x0 = %0d (expected 0)", readData1);

        // Test 4: read two registers at once
        rs1 = 5'd1; rs2 = 5'd2;
        #10; $display("RF | x1 = %0d, x2 = %0d (expected 25, 100)",
                       readData1, readData2);

        #20; $finish;
    end
endmodule
