`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2023 17:04:00
// Design Name: 
// Module Name: receiver
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
`include"sys_defs.vh"

module receiver(
    input clk,
    input send_data,//tell receiver to start receiving
    input reset,
    input [`BANDWIDTH_WRITE_DATA-1:0] data_bus,
    output reg [`WORD_SIZE_BIT-1:0] data_out,
    output reg write_data
    );
    reg [`WORD_SIZE_BIT-1:0] data_receive_reg;
    reg [`WORD_SIZE_BIT-1:0] ptr;
    initial begin
        data_receive_reg = 0;
        ptr = 0;
        write_data = 0;
        data_out = 0;
    end
    always @(negedge(clk)) begin
        if (send_data) begin
            if (`WORD_SIZE_BIT-(ptr+1)*`BANDWIDTH_WRITE_DATA >= 0) begin
                data_receive_reg[(`WORD_SIZE_BIT-(ptr+1)*`BANDWIDTH_WRITE_DATA) +: `BANDWIDTH_WRITE_DATA] = data_bus;
                ptr = ptr + 1;
            end
            else begin
                ptr = ptr;
            end
        end
        else begin
            ptr = 0;
            data_out = data_receive_reg;
            write_data = 1;
        end
    end
endmodule
