module RegisterFile (
    input         clk,
    input         RegWrite,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,
    input  [63:0] writeData,
    output [63:0] readData1,
    output [63:0] readData2
);
    reg [63:0] registers [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 64'b0;
    end

    // Asynchronous read — x0 always returns zero
    assign readData1 = (rs1 == 0) ? 64'b0 : registers[rs1];
    assign readData2 = (rs2 == 0) ? 64'b0 : registers[rs2];

    // Synchronous write — x0 is read-only
    always @(posedge clk) begin
        if (RegWrite && rd != 0)
            registers[rd] <= writeData;
    end
endmodule