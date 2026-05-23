# Generate instruction_memory.mem for RISC-V test program
# Each line: 32-bit hex instruction

def r_type(funct7, rs2, rs1, funct3, rd, opcode):
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def i_type(imm12, rs1, funct3, rd, opcode):
    return ((imm12 & 0xFFF) << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def s_type(imm12, rs2, rs1, funct3, opcode):
    imm_11_5 = (imm12 >> 5) & 0x7F
    imm_4_0 = imm12 & 0x1F
    return (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode

def b_type(imm13, rs2, rs1, funct3, opcode):
    # B-type: imm[12|10:5|4:1|11]
    b12 = (imm13 >> 12) & 1
    b10_5 = (imm13 >> 5) & 0x3F
    b4_1 = (imm13 >> 1) & 0xF
    b11 = (imm13 >> 11) & 1
    return (b12 << 31) | (b10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (b4_1 << 8) | (b11 << 7) | opcode

OP_I = 0x13   # 0010011
OP_R = 0x33   # 0110011
OP_L = 0x03   # 0000011
OP_S = 0x23   # 0100011
OP_B = 0x63   # 1100011

ADD = 0
SUB = 1
AND = 2
OR  = 3
XOR = 4
SLL = 5
SRL = 6

# Test program
prog = []
# addr 0x00: addi x1, x0, 10      # x1 = 10
prog.append(i_type(10, 0, 0, 1, OP_I))
# addr 0x04: addi x2, x0, 5       # x2 = 5
prog.append(i_type(5, 0, 0, 2, OP_I))
# addr 0x08: add x3, x1, x2       # x3 = 10+5 = 15
prog.append(r_type(0, 2, 1, ADD, 3, OP_R))
# addr 0x0C: sub x4, x1, x2       # x4 = 10-5 = 5
prog.append(r_type(0x20, 2, 1, SUB, 4, OP_R))
# addr 0x10: and x5, x1, x3       # x5 = 10&15 = 10
prog.append(r_type(0, 3, 1, AND, 5, OP_R))
# addr 0x14: or x6, x1, x2        # x6 = 10|5 = 15
prog.append(r_type(0, 2, 1, OR, 6, OP_R))
# addr 0x18: xor x7, x1, x2       # x7 = 10^5 = 15
prog.append(r_type(0, 2, 1, XOR, 7, OP_R))
# addr 0x1C: sll x8, x1, x2       # x8 = 10<<5 = 320
prog.append(r_type(0, 2, 1, SLL, 8, OP_R))
# addr 0x20: srl x9, x8, x2       # x9 = 320>>5 = 10
prog.append(r_type(0, 2, 8, SRL, 9, OP_R))
# addr 0x24: addi x10, x1, 7      # x10 = 10+7 = 17
prog.append(i_type(7, 1, 0, 10, OP_I))
# addr 0x28: andi x11, x1, 0xF    # x11 = 10&15 = 10
prog.append(i_type(0xF, 1, 7, 11, OP_I))
# addr 0x2C: ori x12, x1, 0xF     # x12 = 10|15 = 15
prog.append(i_type(0xF, 1, 6, 12, OP_I))
# addr 0x30: xori x13, x1, 0xFF   # x13 = 10^255 = 245
prog.append(i_type(0xFF, 1, 4, 13, OP_I))
# addr 0x34: slli x14, x1, 1      # x14 = 10<<1 = 20
prog.append(i_type(1, 1, 1, 14, OP_I))
# addr 0x38: srli x15, x14, 1     # x15 = 20>>1 = 10
prog.append(i_type(1, 14, 5, 15, OP_I))
# addr 0x3C: sd x1, 0(x0)         # mem[0] = 10
prog.append(s_type(0, 1, 0, 3, OP_S))
# addr 0x40: sd x3, 8(x0)         # mem[8] = 15
prog.append(s_type(8, 3, 0, 3, OP_S))
# addr 0x44: ld x16, 0(x0)        # x16 = mem[0] = 10
prog.append(i_type(0, 0, 3, 16, OP_L))
# addr 0x48: ld x17, 8(x0)        # x17 = mem[8] = 15
prog.append(i_type(8, 0, 3, 17, OP_L))
# addr 0x4C: addi x18, x0, 15     # x18 = 15
prog.append(i_type(15, 0, 0, 18, OP_I))
# addr 0x50: beq x17, x18, +20     # if 15==15, skip to 0x64 (20 bytes, imm << 1)
#                                   # branch_offset=20 bytes => halfword_imm=10
prog.append(b_type(10, 18, 17, 0, OP_B))
# addr 0x54: (skipped)
prog.append(i_type(1, 0, 0, 19, OP_I))
# addr 0x58: (skipped)
prog.append(i_type(2, 0, 0, 19, OP_I))
# addr 0x5C: (skipped)
prog.append(i_type(3, 0, 0, 19, OP_I))
# addr 0x60: (skipped)
prog.append(i_type(4, 0, 0, 19, OP_I))
# addr 0x64: addi x20, x0, 5      # x20 = 5
prog.append(i_type(5, 0, 0, 20, OP_I))
# addr 0x68: blt x2, x1, +16      # if 5<10, skip to 0x78 (16 bytes, imm << 1)
#                                   # branch_offset=16 bytes => halfword_imm=8
prog.append(b_type(8, 1, 2, 4, OP_B))
# addr 0x6C: (skipped)
prog.append(i_type(6, 0, 0, 21, OP_I))
# addr 0x70: (skipped)
prog.append(i_type(7, 0, 0, 21, OP_I))
# addr 0x74: (skipped)
prog.append(i_type(8, 0, 0, 21, OP_I))
# addr 0x78: addi x22, x0, 999    # x22 = 999 (end marker)
prog.append(i_type(999, 0, 0, 22, OP_I))

# Print as hex .mem file
for i, instr in enumerate(prog):
    print(f"{instr:08X}")

print(f"\n// Total instructions: {len(prog)}", file=__import__('sys').stderr)
