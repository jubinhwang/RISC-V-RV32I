`timescale 1ns / 1ps

`include "define.sv"

module datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_code,
    input  logic [ 3:0] alu_controls,
    input  logic        reg_wr_en,
    input  logic        aluSrcMuxSEl,
    input  logic [ 2:0] RegWdataSel,
    input  logic [ 2:0] LwModeSel,
    input  logic        branch,
    input  logic        jal,
    input  logic        jalr,
    input  logic [ 1:0] addr_offset,
    input  logic [31:0] dRdata,
    output logic [31:0] instr_rAddr,
    output logic [31:0] dAddr,
    output logic [31:0] dWdata
);

    logic [31:0] w_regfile_rd1, w_regfile_rd2;
    logic [31:0] w_imm_ext, w_aluSrcMux_out, w_pc_Muxout, w_pc_Next;
    logic [31:0] w_RegWdataOut;
    logic [31:0] w_Mux_Jarl_Out, w_add_PcNExt_immExt, w_add_PcNext_4;
    logic [31:0] w_alu_result, w_Lw2mux, w_AuipcData, w_JalAddPcData;
    logic pc_MuxSel, b_taken;

    assign dAddr = w_alu_result;
    assign dWdata = w_regfile_rd2;

    assign pc_MuxSel = (jal | (branch & b_taken));

    mux_2x1 U_Mux_Jarl (
        .sel(jalr),
        .x0 (instr_rAddr),    // 0 : PcNext  
        .x1 (w_regfile_rd1),  // 1: RS1
        .y  (w_Mux_Jarl_Out)  // to ALU pc_data
    );

    Auipc_adder AUI_PC_ADD (
        .imm_Ext  (w_imm_ext),
        .pc_data  (w_Mux_Jarl_Out),
        .AuipcData(w_add_PcNExt_immExt)
    );

    pc_adder U_PC_ADDER (
        .a  (32'd4),
        .b  (instr_rAddr),
        .sum(w_add_PcNext_4)
    );

    mux_2x1 U_PC_Mux (
        .sel(pc_MuxSel),
        .x0 (w_add_PcNext_4),       // 0 : 4  
        .x1 (w_add_PcNExt_immExt),  // 1: imm_ext
        .y  (w_pc_Muxout)           // to ALU R2
    );

    program_counter U_PC (
        .clk    (clk),
        .reset  (reset),
        .pc_Next(w_pc_Muxout),
        .pc     (instr_rAddr)
    );

    register_file U_REG_FILE (
        .clk      (clk),
        .RA1      (instr_code[19:15]),  // read address 1
        .RA2      (instr_code[24:20]),  // read address 2
        .WA       (instr_code[11:7]),   // write address
        .reg_wr_en(reg_wr_en),          // write enable
        .WData    (w_RegWdataOut),      // write data
        .RD1      (w_regfile_rd1),      // read data 1
        .RD2      (w_regfile_rd2)       // read data 2
    );

    mux_5x1 U_RegWdataMux (
        .sel(RegWdataSel),
        .alu_result(w_alu_result),
        .Lw2mux(w_Lw2mux),
        .LuiData(w_imm_ext),
        .AuipcData(w_add_PcNExt_immExt),
        .JalAddPcData(w_add_PcNext_4),
        .wData(w_RegWdataOut)
    );

    ALU U_ALU (
        .a           (w_regfile_rd1),
        .b           (w_aluSrcMux_out),
        .alu_controls(alu_controls),
        .alu_result  (w_alu_result),
        .b_taken     (b_taken)
    );

    extend U_Extend (
        .instr_code(instr_code),
        .imm_Ext(w_imm_ext)
    );

    mux_2x1 U_AluSrcMux (
        .sel(aluSrcMuxSEl),
        .x0 (w_regfile_rd2),   // sel = 0 regFile R2
        .x1 (w_imm_ext),   // sel = 1 imm[31:0]
        .y  (w_aluSrcMux_out)     // to ALU R2
    );

    //lw_mode_sel U_LwModeSel (
    //    .dRdata(dRdata),
    //    .LwModeSel(LwModeSel),
    //    .dLwData(w_Lw2mux)
    //);

    load_data_processor U_Load_Data_processor (
        .dRdata_raw(dRdata),
        .addr_offset(addr_offset),
        .LwModeSel(LwModeSel),
        .dLwData(w_Lw2mux)
    );
endmodule

module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] pc_Next,
    output logic [31:0] pc
);

    register U_PC_REG (
        .clk(clk),
        .reset(reset),
        .d(pc_Next),
        .q(pc)
    );
endmodule

module register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    output logic [31:0] q
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end

endmodule

module register_file (
    input  logic        clk,
    input  logic [ 4:0] RA1,        // read address 1
    input  logic [ 4:0] RA2,        // read address 2
    input  logic [ 4:0] WA,         // write address
    input  logic        reg_wr_en,  // write enable
    input  logic [31:0] WData,      // write data
    output logic [31:0] RD1,        // read data 1
    output logic [31:0] RD2         // read data 2
);

    logic [31:0] reg_file[0:31];  // 32bit 32개.

    initial begin
        for (int i = 0; i < 32; i++) begin
            reg_file[i] = i;
        end
        // reg_file[0] = 32'd0;
        // reg_file[1] = 32'd1;
        // reg_file[2] = 32'd2;
        // reg_file[3] = 32'd3;
        // reg_file[4] = 32'd4;
        // reg_file[5] = 32'd5;
        // reg_file[6] = 32'b6;
        // reg_file[7] = 32'd7;
        // reg_file[8] = 32'd8;
        // reg_file[9] = 32'd9;
    end

    always_ff @(posedge clk) begin
        if (reg_wr_en) begin
            reg_file[WA] <= WData;
        end
    end

    // register address = 0 is zero to return
    assign RD1 = (RA1 != 0) ? reg_file[RA1] : 0;
    assign RD2 = (RA2 != 0) ? reg_file[RA2] : 0;

endmodule

module ALU (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [ 3:0] alu_controls,
    output logic [31:0] alu_result,
    output logic        b_taken
);

    always_comb begin
        case (alu_controls)
            `ADD:    alu_result = a + b;
            `SUB:    alu_result = a - b;
            `SLL:    alu_result = a << b[4:0];  // max 32bit shift
            `SRL:    alu_result = a >> b[4:0];  // 0으로 extend
            `SRA:    alu_result = $signed(a) >>> b[4:0];  //[31] signed bit
            `SLT:    alu_result = $signed(a) < $signed(b) ? 32'h1 : 32'h0;
            `SLTU:   alu_result = a < b ? 32'h1 : 32'h0;  // unsigned SLT
            `XOR:    alu_result = a ^ b;  // xor
            `OR:     alu_result = a | b;  // or
            `AND:    alu_result = a & b;  // and
            default: alu_result = 32'bx;
        endcase
    end

    always_comb begin
        case (alu_controls[2:0])
            `BEQ: b_taken = ($signed(a) == $signed(b)) ? 1 : 0;
            `BNE: b_taken = ($signed(a) != $signed(b)) ? 1 : 0;
            `BLT: b_taken = ($signed(a) < $signed(b)) ? 1 : 0;
            `BGE: b_taken = ($signed(a) >= $signed(b)) ? 1 : 0;
            `BLTU: b_taken = ($unsigned(a) < $unsigned(b)) ? 1 : 0;
            `BGEU: b_taken = ($unsigned(a) >= $unsigned(b)) ? 1 : 0;
            default: b_taken = 1'b0;
        endcase
    end

endmodule

module extend (
    input  logic [31:0] instr_code,
    output logic [31:0] imm_Ext
);

    wire [6:0] opcode = instr_code[6:0];
    wire [2:0] funct3 = instr_code[14:12];


    always_comb begin
        case (opcode)
            `OP_R_TYPE: imm_Ext = 32'bx;
            // 20 literal 1'b0, imm[11:5] 7bit, imm[4:0] 5bit
            `OP_S_TYPE:
            imm_Ext = {
                {20{instr_code[31]}}, instr_code[31:25], instr_code[11:7]
            };
            `OP_IL_TYPE: imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};
            `OP_I_TYPE: imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};
            `OP_B_TYPE:
            imm_Ext = {
                {20{instr_code[31]}},
                instr_code[7],
                instr_code[30:25],
                instr_code[11:8],
                1'b0
            };
            `OP_LUI_TYPE: imm_Ext = {instr_code[31:12], {12{1'b0}}};
            `OP_AUIPC_TYPE: imm_Ext = {instr_code[31:12], {12{1'b0}}};
            `OP_JALR_TYPE: imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};
            `OP_JAL_TYPE:
            imm_Ext = {
                {12{instr_code[31]}},
                {instr_code[19:12]},
                {instr_code[20]},
                {instr_code[30:21]},
                1'b0
            };
            default: imm_Ext = 32'bx;
        endcase
    end
endmodule

module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] x0,   // sel = 0 regFile R2
    input  logic [31:0] x1,   // sel = 1 imm[31:0]
    output logic [31:0] y     // to ALU R2
);

    assign y = sel ? x1 : x0;

endmodule

// module lw_mode_sel (
//     input  logic [31:0] dRdata,
//     input  logic [ 2:0] LwModeSel,
//     output logic [31:0] dLwData
// );

//     always_comb begin
//         case (LwModeSel)
//             3'b000:  dLwData = {{24{dRdata[7]}}, dRdata[7:0]};
//             3'b001:  dLwData = {{16{dRdata[15]}}, dRdata[15:0]};
//             3'b010:  dLwData = dRdata;
//             3'b100:  dLwData = {{24{1'b0}}, dRdata[7:0]};
//             3'b101:  dLwData = {{16{1'b0}}, dRdata[15:0]};
//             default: dLwData = dRdata;
//         endcase
//     end
// endmodule

module load_data_processor (
    input  logic [31:0] dRdata_raw,
    input  logic [1:0]  addr_offset,
    input  logic [2:0]  LwModeSel, // funct3와 동일
    output logic [31:0] dLwData
);

    always_comb begin
        dLwData = dRdata_raw;

        case (LwModeSel)
            3'b000: begin
                logic [7:0] temp_byte;
                case (addr_offset)
                    2'b00:   temp_byte = dRdata_raw[7:0];
                    2'b01:   temp_byte = dRdata_raw[15:8];
                    2'b10:   temp_byte = dRdata_raw[23:16];
                    2'b11:   temp_byte = dRdata_raw[31:24];
                    default: temp_byte = dRdata_raw[31:24];
                endcase
                dLwData = {{24{temp_byte[7]}}, temp_byte};
            end
            
            3'b001: begin
                logic [15:0] temp_half;
                if (addr_offset[1] == 1'b0)
                    temp_half = dRdata_raw[15:0];
                else
                    temp_half = dRdata_raw[31:16];
                dLwData = {{16{temp_half[15]}}, temp_half};
            end
            
            3'b010: dLwData = dRdata_raw;
            
            3'b100: begin
                case (addr_offset)
                    2'b00:   dLwData = {24'b0, dRdata_raw[7:0]};
                    2'b01:   dLwData = {24'b0, dRdata_raw[15:8]};
                    2'b10:   dLwData = {24'b0, dRdata_raw[23:16]};
                    2'b11:   dLwData = {24'b0, dRdata_raw[31:24]};
                    default: dLwData = {24'b0, dRdata_raw[31:24]};
                endcase
            end

            3'b101: begin
                if (addr_offset[1] == 1'b0)
                    dLwData = {16'b0, dRdata_raw[15:0]};
                else
                    dLwData = {16'b0, dRdata_raw[31:16]};
            end

            default: dLwData = dRdata_raw; 
        endcase
    end

endmodule


module pc_adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] sum
);
    assign sum = a + b;
endmodule

module mux_5x1 (
    input  logic [ 2:0] sel,
    input  logic [31:0] alu_result,
    input  logic [31:0] Lw2mux,
    input  logic [31:0] LuiData,
    input  logic [31:0] AuipcData,
    input  logic [31:0] JalAddPcData,
    output logic [31:0] wData
);

    always_comb begin
        case (sel)
            3'b000:  wData = alu_result;
            3'b001:  wData = Lw2mux;
            3'b010:  wData = LuiData;
            3'b011:  wData = AuipcData;
            3'b100:  wData = JalAddPcData;
            default: wData = alu_result;
        endcase
    end

endmodule

module Auipc_adder (
    input  logic [31:0] imm_Ext,
    input  logic [31:0] pc_data,
    output logic [31:0] AuipcData
);
    assign AuipcData = pc_data + imm_Ext;
endmodule
