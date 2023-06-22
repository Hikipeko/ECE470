`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2023 13:49:35
// Design Name: 
// Module Name: sender
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

module sender_address(
    input clk,
    input wt,
    input reset,
    input reg [`MEM_ADDR_SIZE-1:0] write_address,
    output reg [`BANDWIDTH_WRITE_ADDRESS-1:0] write_address_bus,
    output reg send_wt
);
    reg [10:0] send_progress_reg_address;
    integer i,j;
    initial begin
        write_address_bus = 0;
        send_wt = 0;
        send_progress_reg_address = 0;
    end
    always@(posedge clk) begin
        if (reset) begin
            write_address_bus = 0;
            send_wt = 0;
            send_progress_reg_address = 0;
        end
        else begin
            if (wt) begin
                send_wt = 1;
                if (send_progress_reg_address == 0) begin
                    i = `BANDWIDTH_WRITE_DATA - (`MEM_ADDR_SIZE % `BANDWIDTH_WRITE_ADDRESS);
                    write_address_bus[i-1:0] = write_address[`MEM_ADDR_SIZE-1:`MEM_ADDR_SIZE-i];
                    send_progress_reg_address = send_progress_reg_address + 1;
                end
                else if (`MEM_ADDR_SIZE - i - (send_progress_reg_address) * `BANDWIDTH_WRITE_ADDRESS >= 0) begin
                    write_address_bus = write_address[(`MEM_ADDR_SIZE - i - 1 - ((send_progress_reg_address - 1) * `BANDWIDTH_WRITE_ADDRESS)):(`MEM_ADDR_SIZE - i - ((send_progress_reg_address) * `BANDWIDTH_WRITE_ADDRESS))];
                    send_progress_reg_address = send_progress_reg_address + 1;
                end
                else begin
                    send_progress_reg_address = 0;
                    i = `BANDWIDTH_WRITE_DATA - (`MEM_ADDR_SIZE % `BANDWIDTH_WRITE_ADDRESS);
                    write_address_bus[i-1:0] = write_address[`MEM_ADDR_SIZE-1:`MEM_ADDR_SIZE-i];
                    send_progress_reg_address = send_progress_reg_address + 1;
                end
            end
            else begin
                send_wt = 0;
                send_progress_reg_address = 0;
            end
        end
    end
endmodule
