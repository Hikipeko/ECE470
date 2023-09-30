`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.09.2023 18:20:58
// Design Name: 
// Module Name: mem
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


module mem(
    input clk,
    input send_done,
    input [7:0] memAddr_rd,
    input [7:0] memAddr_wr,
    input [31:0] MDATA,
    input write,
    input read,
    output reg [31:0] MDATA_in,
    output reg send
    );
    reg [31:0] memory[63:0];
    integer i;
    initial begin
      for(i=0;i<16;i=i+1)
      begin
        memory[i]=i;
      end
    end
    always @(negedge clk) begin
        if (write) begin
            memory[memAddr_wr[7:2]] <= MDATA;
        end
        if (read) begin
            MDATA_in <= memory[memAddr_rd[7:2]];
            send <= 1;
        end
        if (send_done) begin
            send <= 0;
            MDATA_in <= 0;
        end
    end
endmodule
