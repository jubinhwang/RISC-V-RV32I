`timescale 1ns / 1ps

module tb_RV32I();

    logic clk = 0, reset = 1;

    RV32I_TOP dut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        #30;
        reset = 0;
        #10000;
        $stop;
    end

endmodule
