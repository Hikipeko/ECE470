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
    input [2:0] burst_rd,
    output reg [31:0] MDATA_in,
    output reg send
    );
    reg [31:0] memory[63:0];
    reg [2:0] burst_counter;
    reg [5:0] mem_addr_rd, mem_addr_wr;
    integer i;
    initial begin
        mem_addr_rd = 0;
        mem_addr_wr = 0;
        burst_counter = 0;
        for(i=0;i<16;i=i+1) begin
            memory[i]=i;
        end
    end
    always @(negedge clk) begin
        if (write) begin
            mem_addr_wr = memAddr_wr[7:2];
            memory[mem_addr_wr] = MDATA;
        end
        if (read) begin
            mem_addr_rd = memAddr_rd[7:2];
            burst_counter = burst_rd;
            MDATA_in = memory[mem_addr_rd];
            mem_addr_rd = mem_addr_rd + 1;
            send = 1;
        end
        if (send_done) begin
            if (burst_counter > 0) begin
                send = 1;
                MDATA_in = memory[mem_addr_rd];
                mem_addr_rd = mem_addr_rd + 1;
                burst_counter = burst_counter - 1;
            end
            else begin
                send = 0;
                MDATA_in = 0;
            end
        end
    end
endmodule
