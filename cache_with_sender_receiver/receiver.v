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
    input send,//tell receiver to start receiving
    input reset,
    input write_in,
    input [`BANDWIDTH_WRITE_ADDRESS-1:0] bus,
    output reg [`MEM_ADDR_SIZE-1:0] addr_out,
    output reg [`WORD_SIZE_BIT-1:0] data_out,
    output reg write,
    output reg read
    );
    reg [`WORD_SIZE_BIT + `MEM_ADDR_SIZE+`BANDWIDTH_WRITE_ADDRESS-1:0] receive_reg;
    reg [`WORD_SIZE_BIT + `MEM_ADDR_SIZE - 1:0] ptr;
    reg write_counter;
    initial begin
        receive_reg = 0;
        ptr = 0;
        write = 0;
        read = 0;
        addr_out = 0;
        data_out = 0;
        write_counter = 0;
    end
    always @(negedge(clk)) begin
        write = 0;
        read = 0;
        if (reset) begin
            receive_reg = 0;
            ptr = 0;
            write = 0;
            read = 0;
            addr_out = 0;
            data_out = 0;
            write_counter = 0;
        end
        else if (send) begin
        // receive data from sender
            if (`WORD_SIZE_BIT + `MEM_ADDR_SIZE-(ptr+1)*`BANDWIDTH_WRITE_ADDRESS >= 0 || ptr == 0) begin
                receive_reg[(ptr*`BANDWIDTH_WRITE_ADDRESS) +: `BANDWIDTH_WRITE_ADDRESS] = bus;
                ptr = ptr + 1;
                write_counter = 1;
            end
            else begin
                ptr = ptr;
            end
        end
        else begin
        // divide receiving data into address and data
            ptr = 0;
            addr_out = receive_reg[`WORD_SIZE_BIT +: `MEM_ADDR_SIZE];
            data_out = receive_reg[0 +: `WORD_SIZE_BIT];
            write = write_counter && write_in;
            read = write_counter && (!write_in);
            write_counter = 0;
        end
    end
endmodule
