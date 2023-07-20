`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2023 13:30:12
// Design Name: 
// Module Name: buffer
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

module buffer(
    input clk,
    input reset,
    input [`MEM_ADDR_SIZE-1 : 0] write_back_address,
    input [`WORD_SIZE_BIT-1 : 0] write_back_data,
    input write,//read and write can't be 1 at the same time.
    input done,//from sender
    input addr_done,//from sender
    input read,//read and write can't be 1 at the same time.
    output reg full,
    output write_out,
    output buffer_hit, //1 when read = 1 and the address of the desired read is in the buffer
    output reg [`WORD_SIZE_BIT-1:0] write_data,
    output reg [`MEM_ADDR_SIZE-1:0] write_address,
    output [`WORD_SIZE_BIT-1:0] data_read_to_cache, //data output corresponding to read input signal
    output reg send_wr_data,
    output reg send_wr_addr
);
    integer i;
    reg [`WORD_SIZE_BIT-1 : 0] buffer_line_data [3:0];
    reg [`MEM_ADDR_SIZE-1 : 0] buffer_line_address [3:0];
    reg [2:0] count,count_addr;
    reg addr_history_done;
    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            buffer_line_data[i] = 0;
            buffer_line_address[i] = 0;
        end
        full = 0;
        write_data = 0;
        write_address = 0;
        send_wr_data = 0;
        count = 0;
        count_addr = 0;
        send_wr_addr = 0;
        addr_history_done = 0;
    end
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 4; i = i + 1)begin
                buffer_line_data[i] = 0;
                buffer_line_address[i] = 0;
            end
            full = 0;
            write_data = 0;
            write_address = 0;
            send_wr_data = 0;
            send_wr_addr = 0;
            count = 0;
            count_addr = 0;
            addr_history_done = 0;
        end
        else begin
            if (count == 4) begin
                full = 1;
            end
            else begin
                full = 0;
            end
            if (write) begin
                if (count < 4) begin
                    buffer_line_data[count] = write_back_data;
                    count = count + 1;
                    buffer_line_address[count_addr] = write_back_address;
                    count_addr = count_addr + 1;
                end
            end
        end
    end
    always @(negedge clk) begin
        if (count == 0) begin
            write_data = 0;
            write_address = 0;
            send_wr_data = 0;
            send_wr_addr = 0;
            addr_history_done = 0;
        end
        else if (done | addr_done) begin
            if (done) begin
                send_wr_data = 0;
                write_data = 0;
                for (i = 0; i < 3; i = i + 1) begin
                    buffer_line_data[i] =  buffer_line_data[i+1];
                end
                buffer_line_data[3] = 0;
                count = count - 1;
                addr_history_done = 0;
                for (i = 0; i < 3; i = i + 1) begin
                    buffer_line_address[i] = buffer_line_address[i+1];
                end
                buffer_line_address[3] = 0;
                count_addr = count_addr - 1;
            end
            if (addr_done) begin
                send_wr_addr = 0;
                write_address = 0;
                addr_history_done = 1;
            end
        end
        else begin
            write_data = buffer_line_data[0];
            write_address = buffer_line_address[0];
            send_wr_data = 1;
            send_wr_addr = !addr_history_done;
        end
    end

    assign write_out = (count > 0);

    assign {buffer_hit,data_read_to_cache} = (read) ? 
                        ((write_back_address == buffer_line_address[0] && count > 0 ) ? {1'b1,buffer_line_data[0]} : 
                            (write_back_address == buffer_line_address[1] && count > 1) ? {1'b1,buffer_line_data[1]} : 
                                (write_back_address == buffer_line_address[2] && count > 2) ? {1'b1,buffer_line_data[2]} :
                                    (write_back_address == buffer_line_address[3] && count > 3) ? {1'b1,buffer_line_data[3]} : {1'b0,`WORD_SIZE_BIT'b0}):
                                        {1'b0,`WORD_SIZE_BIT'b0};

endmodule
