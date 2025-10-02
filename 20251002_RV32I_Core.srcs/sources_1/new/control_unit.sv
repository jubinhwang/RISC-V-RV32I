`timescale 1ns / 1ps

`include "define.sv"

module control_unit (
    input  logic [31:0] instr_code,
    output logic [ 3:0] alu_controls,
    output logic        aluSrcMuxSEl,
    output logic        reg_wr_en,
    output logic        d_wr_en,
    output logic [ 2:0] RegWdataSel,
    output logic [ 2:0] LwModeSel,
    output logic        branch,
    output logic        jalr,
    output logic        jal
);

    wire  [6:0] funct7 = instr_code[31:25];
    wire  [2:0] funct3 = instr_code[14:12];
    wire  [6:0] opcode = instr_code[6:0];

    logic [8:0] controls;

    assign {RegWdataSel, aluSrcMuxSEl, reg_wr_en, d_wr_en, branch,jalr, jal} = controls;
    assign LwModeSel = funct3;

    always_comb begin
        case (opcode)
            // RegWdataSel[2],RegWdataSel[1],RegWdataSel[0] aluSrcMuxSel, reg_wr_en, d_wr_en, branch, jalr, jal
            `OP_R_TYPE:     controls = 9'b0000_1000_0;  // R-type
            `OP_S_TYPE:     controls = 9'b0001_0100_0;  // S-type
            `OP_IL_TYPE:    controls = 9'b0011_1000_0;  // I-type
            `OP_I_TYPE:     controls = 9'b0001_1000_0;  // I-type
            `OP_B_TYPE:     controls = 9'b0000_0010_0;
            `OP_LUI_TYPE:   controls = 9'b0101_1000_0;
            `OP_AUIPC_TYPE: controls = 9'b0110_1010_0;
            `OP_JALR_TYPE:  controls = 9'b1000_1001_1;
            `OP_JAL_TYPE:   controls = 9'b1000_1000_1;
            default:        controls = 9'b0000_0000_0;
        endcase
    end

    always_comb begin
        case (opcode)
            `OP_R_TYPE:     alu_controls = {funct7[5], funct3};  // R-type
            `OP_S_TYPE:     alu_controls = `ADD;  // S-type
            `OP_IL_TYPE:    alu_controls = `ADD;  // IL-type
            `OP_I_TYPE: begin
                if (funct3 == 3'b000) alu_controls = {1'b0, funct3};  // I-type
                else alu_controls = {funct7[5], funct3};
            end
            `OP_B_TYPE:     alu_controls = {1'b0, funct3};
            `OP_LUI_TYPE:   alu_controls = 4'b0000;
            `OP_AUIPC_TYPE: alu_controls = 4'b0000;
            `OP_JALR_TYPE:  alu_controls = 4'b0000;
            `OP_JAL_TYPE:   alu_controls = 4'b0000;
            default:        alu_controls = 4'bx;
        endcase
    end


endmodule
