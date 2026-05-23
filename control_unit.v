`timescale 1ns / 1ps

module control_unit(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg RegWrite,
    output reg MemWrite,
    output reg MemRead,
    output reg ALUSrc,
    output reg MemToReg,
    output reg Branch,

    output reg [3:0] ALUControl
);

always @(*) begin

    
    RegWrite = 0;
    MemWrite = 0;
    MemRead  = 0;
    ALUSrc   = 0;
    MemToReg = 0;
    Branch   = 0;
    ALUControl = 4'b0000;

    case(opcode)

        
        7'b0110011: begin
            RegWrite = 1;

            case(funct3)

                3'b000: begin
                    if(funct7 == 7'b0000000)
                        ALUControl = 4'b0000; // --> ADD
                    else if(funct7 == 7'b0100000)
                        ALUControl = 4'b0001; //  --> SUB
                end

                3'b111:
                    ALUControl = 4'b0010; // AND

                3'b110:
                    ALUControl = 4'b0011; // OR

                3'b100:
                    ALUControl = 4'b0100; // XOR

                3'b001:
                    ALUControl = 4'b0101; // SLL

                3'b101:
                    ALUControl = 4'b0110; // SRL
            endcase
        end

        // I-Type
        7'b0010011: begin
            RegWrite = 1;
            ALUSrc = 1;

            case(funct3)

                3'b000:
                    ALUControl = 4'b0000; // ADDI

                3'b111:
                    ALUControl = 4'b0010; // ANDI

                3'b110:
                    ALUControl = 4'b0011; // ORI

                3'b100:
                    ALUControl = 4'b0100; // XORI

                3'b001:
                    ALUControl = 4'b0101; // SLLI

                3'b101:
                    ALUControl = 4'b0110; // SRLI
            endcase
        end

        // LD
        7'b0000011: begin
            RegWrite = 1;
            MemRead = 1;
            MemToReg = 1;
            ALUSrc = 1;
            ALUControl = 4'b0000;
        end

        // SD
        7'b0100011: begin
            MemWrite = 1;
            ALUSrc = 1;
            ALUControl = 4'b0000;
        end

        // Branch
        7'b1100011: begin
            Branch = 1;

            case(funct3)

                3'b000:
                    ALUControl = 4'b0001; // BEQ uses SUB

                3'b100:
                    ALUControl = 4'b0111; // BLT uses SLT

            endcase
        end

    endcase
end

endmodule
