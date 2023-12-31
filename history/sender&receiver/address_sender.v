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

module address_sender(
    input clk,
    input send,//tells sender to start sending
    input reset,
    input [`MEM_ADDR_SIZE-1:0] addr_in,
    output reg [`BANDWIDTH_WRITE_ADDRESS-1:0] addr_bus,
    output reg send_addr, // to receiver module, 1 tells the receiver to start receiving
    output reg done_addr // to buffer or memory, 1 to indicate transmission finishs.
);
    reg [10:0] send_progress;
    reg [`MEM_ADDR_SIZE-1:0] address_in;
    integer i,j;
    initial begin
        addr_bus = 0;
        send_addr = 0;
        done_addr = 0;
        send_progress = 0;
        address_in = 0;
    end
    always@(addr_in)begin
        address_in = addr_in;
    end
    always@(posedge clk) begin
        if (reset) begin
            addr_bus = 0;
            send_addr = 0;
            done_addr = 0;
            send_progress = 0;
            address_in = 0;
        end
        else begin
            if (send) begin
                if($signed(`MEM_ADDR_SIZE-(send_progress+1)*`BANDWIDTH_WRITE_ADDRESS) >= 0) begin
                    send_addr = 1;
                    addr_bus = address_in[(send_progress*`BANDWIDTH_WRITE_ADDRESS) +: `BANDWIDTH_WRITE_ADDRESS];
                    send_progress = send_progress + 1;
                    done_addr = 0;
                end
                else if ($signed(`MEM_ADDR_SIZE-send_progress*`BANDWIDTH_WRITE_ADDRESS) > 0) begin
                    addr_bus = 0;
                    send_addr = 1;
                    addr_bus[0 +: (`MEM_ADDR_SIZE  % `BANDWIDTH_WRITE_ADDRESS)] = address_in[send_progress*`BANDWIDTH_WRITE_ADDRESS +: (`MEM_ADDR_SIZE  % `BANDWIDTH_WRITE_ADDRESS)];
                    send_progress = send_progress + 1;
                    done_addr = 0;
                end
                else begin
                    done_addr = 1;
                    send_addr = 0;
                    send_progress = 0;
                end
            end
            else begin
                done_addr = 0;
                send_progress = 0;
            end
        end
    end
endmodule
