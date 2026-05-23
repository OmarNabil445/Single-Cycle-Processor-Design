module ImmediateGenerator (
    input  [31:0] instruction,
    output reg [63:0] imm
);
    localparam OP_IMM    = 7'b0010011; // addi, andi, ori, xori, slli, srli
    localparam OP_LOAD   = 7'b0000011; // ld
    localparam OP_STORE  = 7'b0100011; // sd
    localparam OP_BRANCH = 7'b1100011; // beq

    wire       sign   = instruction[31];
    wire [2:0] funct3 = instruction[14:12];

    always @(*) begin
        case (instruction[6:0])

            OP_IMM, OP_LOAD: begin
                if (funct3 == 3'b001 || funct3 == 3'b101)
                    imm = {58'b0, instruction[25:20]};       // slli / srli
                else
                    imm = {{52{sign}}, instruction[31:20]};  // addi, andi, ori, xori, ld
            end

            OP_STORE:
                imm = {{52{sign}}, instruction[31:25], instruction[11:7]};

            OP_BRANCH:
                imm = {{51{sign}}, sign, instruction[7],
                        instruction[30:25], instruction[11:8], 1'b0};

            default:
                imm = 64'b0;

        endcase
    end
endmodule