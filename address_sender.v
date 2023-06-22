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
    output reg done // to buffer or memory, 1 to indicate transmission finishs.
);
    reg [10:0] send_progress;
    reg [5:0] count;
    integer i,j;
    initial begin
        addr_bus = 0;
        send_addr = 0;
        done = 0;
        send_progress = 0;
        count = 0;
    end
    always@(posedge clk) begin
        if (reset) begin
            send_addr = 0;
            done = 0;
            send_progress = 0;
        end
        else begin
            if (send) begin
                if($signed(`MEM_ADDR_SIZE-(send_progress+1)*`BANDWIDTH_WRITE_ADDRESS) >= 0) begin
                    send_addr = 1;
                    addr_bus = addr_in[(send_progress*`BANDWIDTH_WRITE_ADDRESS) +: `BANDWIDTH_WRITE_ADDRESS];
                    send_progress = send_progress + 1;
                    done = 0;
                end
                else if ($signed(`MEM_ADDR_SIZE-send_progress*`BANDWIDTH_WRITE_ADDRESS) > 0) begin
                    addr_bus = 0;
                    send_addr = 1;
                    addr_bus[0 +: (`BANDWIDTH_WRITE_ADDRESS  % `BANDWIDTH_WRITE_ADDRESS)] = addr_in[send_progress*`BANDWIDTH_WRITE_ADDRESS +: (`BANDWIDTH_WRITE_ADDRESS  % `BANDWIDTH_WRITE_ADDRESS)];
                    send_progress = send_progress + 1;
                    done = 0;
                end
                else begin
                    done = 1;
                    send_addr = 0;
                    send_progress = 0;
                end
            end
            else begin
                done = 0;
                send_progress = 0;
            end
        end
    end
endmodule
