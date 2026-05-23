`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/22/2026 11:50:20 PM
// Design Name: 
// Module Name: control_unit_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module control_unit_tb;

reg [6:0] opcode;
reg [2:0] funct3;
reg [6:0] funct7;

wire RegWrite;
wire MemWrite;
wire MemRead;
wire ALUSrc;
wire MemToReg;
wire Branch;
wire [3:0] ALUControl;

control_unit uut (
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

initial begin

    // ADD
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;

    // SUB
    funct7 = 7'b0100000;
    #10;

    // ANDI
    opcode = 7'b0010011;
    funct3 = 3'b111;
    #10;

    // LD
    opcode = 7'b0000011;
    funct3 = 3'b011;
    #10;

    // SD
    opcode = 7'b0100011;
    #10;

    // BEQ
    opcode = 7'b1100011;
    funct3 = 3'b000;
    #10;

    $finish;

end

endmodule
