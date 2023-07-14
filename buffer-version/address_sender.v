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
    input [`WORD_SIZE_BIT-1:0] data_in,
    input [`MEM_ADDR_SIZE-1:0] addr_in,
    input write,
    output reg [`BANDWIDTH_WRITE_ADDRESS-1:0] bus,
    output reg send_bus, // to receiver module, 1 tells the receiver to start receiving
    output reg done // to buffer or memory, 1 to indicate transmission finishs.
);
    reg [10:0] send_progress;
    reg [`WORD_SIZE_BIT+`MEM_ADDR_SIZE-1:0] message_in;
    integer i,j;

    assign message_in = {addr_in,data_in};
    initial begin
        bus = 0;
        send_bus = 0;
        done = 0;
        send_progress = 0;
        message_in = 0;
    end
    always@(posedge clk) begin
        if (reset) begin
            bus = 0;
            send_bus = 0;
            done = 0;
            send_progress = 0;
            message_in = 0;
        end
        else begin
            if (send) begin
                if($signed(`WORD_SIZE_BIT+`MEM_ADDR_SIZE-(send_progress+1)*`BANDWIDTH_WRITE_ADDRESS) >= 0) begin
                    send_bus = 1;
                    bus = message_in[(send_progress*`BANDWIDTH_WRITE_ADDRESS) +: `BANDWIDTH_WRITE_ADDRESS];
                    send_progress = send_progress + 1;
                    done_addr = 0;
                end
                else if ($signed(`WORD_SIZE_BIT+`MEM_ADDR_SIZE-send_progress*`BANDWIDTH_WRITE_ADDRESS) > 0) begin
                    bus = 0;
                    send_bus = 1;
                    bus[0 +: ((`WORD_SIZE_BIT+`MEM_ADDR_SIZE)  % `BANDWIDTH_WRITE_ADDRESS)] = message_in[send_progress*`BANDWIDTH_WRITE_ADDRESS +: ((`WORD_SIZE_BIT+`MEM_ADDR_SIZE)  % `BANDWIDTH_WRITE_ADDRESS)];
                    send_progress = send_progress + 1;
                    done = 0;
                end
                else begin
                    done = 1;
                    send_bus = 0;
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
