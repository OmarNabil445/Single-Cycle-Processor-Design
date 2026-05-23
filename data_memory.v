// data_memory.v
// 64-bit data memory for ld/sd in single-cycle RV64I processor.
// Word-addressed RAM: index = address[63:3] (8-byte aligned)
// Synchronous write on posedge clk, asynchronous read.

module data_memory (
    input  wire        clk,
    input  wire        rst,
    input  wire        MemRead,
    input  wire        MemWrite,
    input  wire [63:0] address,         // Byte address from ALU (8-byte aligned)
    input  wire [63:0] write_data,      // Data to store (from read_data2)
    output reg  [63:0] read_data        // Data to read (to MemtoReg MUX)
);

    reg [63:0] mem [0:1023];            // 1024 x 64-bit = 8 KB data memory
    integer i;

    wire [9:0] word_index;              // 10-bit word index from byte address

    assign word_index = address[12:3];  // 8-byte aligned, top 10 bits

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 1024; i = i + 1)
                mem[i] <= 64'b0;
        end else if (MemWrite) begin
            mem[word_index] <= write_data;
        end
    end

    always @(*) begin
        if (MemRead)
            read_data = mem[word_index];
        else
            read_data = 64'b0;
    end

endmodule
