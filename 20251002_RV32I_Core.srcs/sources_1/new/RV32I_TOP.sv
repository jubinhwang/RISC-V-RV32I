`timescale 1ns / 1ps
module RV32I_TOP (
    input logic clk,
    input logic reset
);
    logic [31:0] instr_code, instr_rAddr;
    logic [31:0] dWdata, dAddr, dRdata;
    logic d_wr_en;
    logic [1:0] addr_offset;

    RV32I_Core U_RV32I_CPU (.*);
    instr_mem U_Instr_Mem (.*);
    data_mem U_Data_Mem (.*);

endmodule

module RV32I_Core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_code,
    input  logic [31:0] dRdata,
    input  logic [ 1:0] addr_offset,
    output logic [31:0] instr_rAddr,
    output logic        d_wr_en,
    output logic [31:0] dAddr,
    output logic [31:0] dWdata
);

    logic [3:0] alu_controls;
    logic reg_wr_en, aluSrcMuxSEl, branch, jalr, jal;
    logic [2:0] RegWdataSel;
    logic [2:0] LwModeSel;

    control_unit U_Control_Unit (.*);
    datapath U_Data_Path (.*);
endmodule
