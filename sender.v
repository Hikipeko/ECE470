`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2023 16:43:30
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

module sender(
    input clk,
    input send,//tells sender to start sending
    input reset,
    input [`WORD_SIZE_BIT-1:0] data_in,
    output reg [`BANDWIDTH_WRITE_DATA-1:0] data_bus,
    output reg send_data, // to receiver module, 1 tells the receiver to start receiving
    output reg done // to buffer or memory, 1 to indicate transmission finishs.
);
    reg [10:0] send_progress;
    reg [5:0] count;
    integer i,j;
    initial begin
        data_bus = 0;
        send_data = 0;
        done = 0;
        send_progress = 0;
        count = 0;
    end
    always@(posedge clk) begin
        if (reset) begin
            send_data = 0;
            done = 0;
            send_progress = 0;
        end
        else begin
            if (send) begin
                if($signed(`WORD_SIZE_BIT-(send_progress+1)*`BANDWIDTH_WRITE_DATA) >= 0) begin
                    send_data = 1;
                    data_bus = data_in[(`WORD_SIZE_BIT-(send_progress+1)*`BANDWIDTH_WRITE_DATA) +: `BANDWIDTH_WRITE_DATA];
                    send_progress = send_progress + 1;
                    done = 0;
                end
                else begin
                    done = 1;
                    send_data = 0;
                    send_progress = 0;
                end
            end
            else begin
                send_data = 0;
                done = 0;
                send_progress = 0;
            end
        end
    end
endmodule
