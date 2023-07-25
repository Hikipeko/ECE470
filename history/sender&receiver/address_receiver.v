`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/22 16:00:29
// Design Name: 
// Module Name: address_sender
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

module address_receiver(
    input clk,
    input send_addr,//tell receiver to start receiving
    input reset,
    input [`BANDWIDTH_WRITE_ADDRESS-1:0] addr_bus,
    output reg [`MEM_ADDR_SIZE-1:0] addr_out
    //output reg write
    );
    reg [`MEM_ADDR_SIZE+`BANDWIDTH_WRITE_ADDRESS-1:0] addr_receive_reg;
    reg [`MEM_ADDR_SIZE-1:0] ptr;
    initial begin
        addr_receive_reg = 0;
        ptr = 0;
        //write = 0;
        addr_out = 0;
    end
    always @(negedge(clk)) begin
        if (reset) begin
            addr_receive_reg = 0;
            ptr = 0;
            //write = 0;
            addr_out = 0;
        end
        else if (send_addr) begin
            if (`MEM_ADDR_SIZE-(ptr+1)*`BANDWIDTH_WRITE_ADDRESS >= 0) begin
                addr_receive_reg[(ptr*`BANDWIDTH_WRITE_ADDRESS) +: `BANDWIDTH_WRITE_ADDRESS] = addr_bus;
                ptr = ptr + 1;
            end
            else begin
                ptr = ptr;
            end
        end
        else begin
            ptr = 0;
            addr_out = addr_receive_reg[0 +: `MEM_ADDR_SIZE];
            //write = 1;
        end
    end
endmodule
