`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.06.2023 17:38:50
// Design Name: 
// Module Name: testbench
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

module testbench(
    );
// wires to watch: write_out, data_out, addr_out
    reg clk,reset, write,byte_type;
    reg [`MEM_ADDR_SIZE-1 : 0] write_back_address;
    reg [`WORD_SIZE_BIT-1 : 0] write_back_data;
    wire [`WORD_SIZE_BIT-1:0] data_out,write_data;
    wire [`BANDWIDTH_WRITE_DATA-1:0] data_bus;
    wire [`BANDWIDTH_WRITE_ADDRESS-1:0] addr_bus;
    wire [`MEM_ADDR_SIZE-1:0] write_address,addr_out;
    wire send_data,done,full,send_wr_data,write_out,send_wr_addr,send_addr,addr_done;
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    
    buffer bbff(.clk(clk), .reset(reset), .write_back_address(write_back_address), .write_back_data(write_back_data), .write(write),
    .byte_type(byte_type), .done(done), .addr_done(addr_done), .full(full), .write_data(write_data), .write_address(write_address), .send_wr_data(send_wr_data), .send_wr_addr(send_wr_addr));
    
    sender sd(.clk(clk),.send(send_wr_data),.reset(reset),.data_in(write_data),.data_bus(data_bus),.send_data(send_data),.done_data(done));
    receiver rec(.clk(clk),.send_data(send_data),.reset(reset),.data_bus(data_bus),.data_out(data_out),.write(write_out));
    
    
    
    address_sender adsd(.clk(clk),.send(send_wr_addr),.reset(reset),.addr_in(write_address),.addr_bus(addr_bus),.send_addr(send_addr),.done_addr(addr_done));
    address_receiver adrec(.clk(clk),.send_addr(send_addr),.reset(reset),.addr_bus(addr_bus),.addr_out(addr_out));

    initial begin
       reset = 1;
       #20
       reset = 0;
       byte_type= 0;
       write_back_address = 1;
       write_back_data = 32'h1234abcd;
       write = 1;
       #20
       reset = 0;
       byte_type= 0;
       write_back_address = 64;
       write_back_data = 32'hf0ffff0f;
       write = 1;
       #20
       reset = 0;
       byte_type= 0;
       write_back_address = 16;
       write_back_data = 32'h12345678;
       write = 1;
       #20
       reset = 0;
       byte_type= 0;
       write_back_address = 128;
       write_back_data = 32'h078945ad;
       write = 1;
       #20
       reset = 0;
       byte_type= 0;
       write_back_address = 32;
       write_back_data = 32'habcd1897;
       write = 1;
       #20
       @(negedge full)
       reset = 0;
       byte_type= 0;
       write_back_address = 512;
       write_back_data = 32'hcccccccc;
       write = 1;
       #20
       @(negedge full)
       reset = 0;
       byte_type= 0;
       write_back_address = 107;
       write_back_data = 32'hbbbbbbbb;
       write = 1;
       #20
       @(negedge full)
       reset = 0;
       byte_type= 0;
       write_back_address = 819;
       write_back_data = 32'hcccccccc;
       write = 1;
    end
endmodule
