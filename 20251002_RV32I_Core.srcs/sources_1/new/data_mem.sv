// `timescale 1ns / 1ps

// module data_mem (
//     input  logic        clk,
//     input  logic        d_wr_en,
//     input  logic [31:0] dAddr,
//     input  logic [31:0] dWdata,
//     input  logic [31:0] instr_code,
//     output logic [31:0] dRdata
// );

//     logic [31:0] data_mem[0:15];
//     wire [2:0] funct3 = instr_code[14:12];

//     initial begin
//         for (int i = 0; i < 16; i++) begin
//             data_mem[i] = i + 32'h8765_4321;
//         end
//     end

//     always_ff @(posedge clk) begin
//         if (d_wr_en) begin
//             case (funct3)
//                 3'b001:  data_mem[dAddr][15:0] <= dWdata[15:0];
//                 3'b000:  data_mem[dAddr][7:0] <= dWdata[7:0];
//                 3'b010:  data_mem[dAddr] <= dWdata;
//                 default: data_mem[dAddr] <= dWdata;
//             endcase
//         end
//     end

//     assign dRdata = data_mem[dAddr];

// endmodule

`timescale 1ns / 1ps

module data_mem (
    input  logic        clk,
    input  logic        d_wr_en,
    input  logic [31:0] dAddr,
    input  logic [31:0] dWdata,
    input  logic [31:0] instr_code,
    output logic [31:0] dRdata,
    output logic [1:0] addr_offset
);

    logic [31:0] data_mem[0:15];
    
    wire [2:0] funct3      = instr_code[14:12];
    wire [3:0] word_addr   = dAddr[5:2];
    wire [1:0] byte_offset = dAddr[1:0];


    //initial begin
    //    for (int i = 0; i < 16; i++) begin
    //        data_mem[i] = i + 32'h8765_4321;
    //    end
    //end

    always_ff @(posedge clk) begin
        if (d_wr_en) begin
            case (funct3)
                3'b010: data_mem[word_addr] <= dWdata; // sw
                3'b001: begin // sh
                    if (byte_offset[1] == 1'b0)
                        data_mem[word_addr][15:0] <= dWdata[15:0];
                    else
                        data_mem[word_addr][31:16] <= dWdata[15:0];
                end
                3'b000: begin // sb
                    case (byte_offset)
                        2'b00: data_mem[word_addr][7:0]   <= dWdata[7:0];
                        2'b01: data_mem[word_addr][15:8]  <= dWdata[7:0];
                        2'b10: data_mem[word_addr][23:16] <= dWdata[7:0];
                        2'b11: data_mem[word_addr][31:24] <= dWdata[7:0];
                    endcase
                end
            endcase
        end
    end

    assign dRdata = data_mem[word_addr];
    assign addr_offset = byte_offset;
endmodule